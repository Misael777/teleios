"""System One multi-cabeza (§11.1): un codificador pequeño, embeddings + NLI + 5 cabezas tipadas en una
sola pasada, con temperatura de calibración por cabeza.

Codificador: multilingual-e5-small (118M, XLM-R): mismo tokenizador SentencePiece que el teléfono
implementa en Dart (lib/infrastructure/ml/unigram_tokenizer.dart). Se inicia desde el espacio
contrastivo de S13 para conservar la separación de opuestos.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Sequence

import numpy as np
import torch
import torch.nn.functional as F
from torch import nn

from .models import DEVICE
from .synth import HEADS

NLI_LABELS = ["entailment", "neutral", "contradiction"]


class SystemOne(nn.Module):
    """Si [encoder_path] ya es un clasificador NLI (p. ej. multilingual-MiniLMv2-L12-mnli-xnli), se
    reutiliza su cabeza sobre <s>, con las salidas reordenadas a NLI_LABELS: el alumno parte sabiendo NLI."""

    def __init__(self, encoder_path: str):
        super().__init__()
        from transformers import AutoConfig, AutoModel, AutoModelForSequenceClassification

        config = AutoConfig.from_pretrained(encoder_path)
        labels = {v.lower(): k for k, v in (config.id2label or {}).items()}
        if all(lab in labels for lab in NLI_LABELS):
            clf = AutoModelForSequenceClassification.from_pretrained(encoder_path)
            self.encoder = clf.base_model
            head = clf.classifier
            order = torch.tensor([labels[lab] for lab in NLI_LABELS])
            with torch.no_grad():
                head.out_proj.weight.copy_(head.out_proj.weight[order])
                head.out_proj.bias.copy_(head.out_proj.bias[order])
            self.nli_on_cls = head
            self.nli = None
        else:
            self.encoder = AutoModel.from_pretrained(encoder_path)
            self.nli_on_cls = None
        h = self.encoder.config.hidden_size
        if self.nli_on_cls is None:
            self.nli = nn.Sequential(nn.Dropout(0.1), nn.Linear(h, len(NLI_LABELS)))
        self.heads = nn.ModuleDict({k: nn.Sequential(nn.Dropout(0.1), nn.Linear(h, len(v))) for k, v in HEADS.items()})

    def forward(self, input_ids: torch.Tensor, attention_mask: torch.Tensor):
        hidden = self.encoder(input_ids=input_ids, attention_mask=attention_mask).last_hidden_state
        mask = attention_mask.unsqueeze(-1).to(hidden.dtype)
        pooled = (hidden * mask).sum(1) / mask.sum(1).clamp(min=1e-6)
        nli = self.nli_on_cls(hidden) if self.nli_on_cls is not None else self.nli(pooled)
        out = {"embedding": F.normalize(pooled, dim=-1), "nli_logits": nli}
        for k, head in self.heads.items():
            out[f"{k}_logits"] = head(pooled)
        return out


class OnnxWrapper(nn.Module):
    """Salidas en orden fijo para el teléfono."""

    OUTPUTS = ["embedding", "nli_logits"] + [f"{k}_logits" for k in HEADS]

    def __init__(self, model: SystemOne):
        super().__init__()
        self.model = model

    def forward(self, input_ids, attention_mask):
        out = self.model(input_ids, attention_mask)
        return tuple(out[k] for k in self.OUTPUTS)


def save(model: SystemOne, tok, path: Path, temperatures: dict[str, float], meta: dict) -> None:
    path.mkdir(parents=True, exist_ok=True)
    torch.save(model.state_dict(), path / "system_one.pt")
    tok.save_pretrained(path)
    (path / "system_one.json").write_text(json.dumps({"temperatures": temperatures, **meta}, indent=2), encoding="utf-8")


def load(path: Path, encoder_path: str | None = None) -> tuple[SystemOne, object, dict]:
    from transformers import AutoTokenizer

    meta = json.loads((path / "system_one.json").read_text(encoding="utf-8"))
    model = SystemOne(encoder_path or meta["encoder"])
    model.load_state_dict(torch.load(path / "system_one.pt", map_location="cpu"))
    return model.to(DEVICE).eval(), AutoTokenizer.from_pretrained(path), meta


class StudentJudge:
    """Interfaz de juez del laboratorio (evaluation.JudgeFn) sobre el System One calibrado."""

    def __init__(self, model: SystemOne, tok, temperature: float = 1.0, batch_size: int = 64):
        self.model, self.tok, self.t, self.bs = model, tok, temperature, batch_size

    @torch.no_grad()
    def __call__(self, premises: Sequence[str], hypotheses: Sequence[str]) -> np.ndarray:
        out = []
        for i in range(0, len(premises), self.bs):
            enc = self.tok(list(premises[i : i + self.bs]), list(hypotheses[i : i + self.bs]), truncation=True,
                           padding=True, max_length=128, return_tensors="pt").to(DEVICE)
            logits = self.model(enc["input_ids"], enc["attention_mask"])["nli_logits"].float()
            out.append((logits / self.t).softmax(-1).cpu().numpy())
        return np.concatenate(out)


class StudentEncoder:
    """Embeddings y cabezas para textos sueltos (prefijo "query: ", igual que en el teléfono)."""

    def __init__(self, model: SystemOne, tok, temperatures: dict[str, float] | None = None, prefix: str = "query: "):
        self.model, self.tok, self.prefix = model, tok, prefix
        self.t = temperatures or {}

    @torch.no_grad()
    def run(self, texts: Sequence[str], bs: int = 128) -> dict[str, np.ndarray]:
        acc: dict[str, list] = {}
        for i in range(0, len(texts), bs):
            enc = self.tok([self.prefix + t for t in texts[i : i + bs]], truncation=True, padding=True,
                           max_length=128, return_tensors="pt").to(DEVICE)
            out = self.model(enc["input_ids"], enc["attention_mask"])
            for k, v in out.items():
                v = v.float()
                if k.endswith("_logits"):
                    v = (v / self.t.get(k[:-7], 1.0)).softmax(-1)
                acc.setdefault(k, []).append(v.cpu().numpy())
        return {k: np.concatenate(v) for k, v in acc.items()}

    def __call__(self, texts: Sequence[str]) -> np.ndarray:
        return self.run(texts)["embedding"]


# ─── Calibración (§11.1): temperatura por cabeza, ECE y Brier ───────────────

def fit_temperature(logits: np.ndarray, labels: np.ndarray) -> float:
    lt = torch.tensor(logits, dtype=torch.float32)
    yt = torch.tensor(labels, dtype=torch.long)
    log_t = torch.zeros(1, requires_grad=True)
    opt = torch.optim.LBFGS([log_t], lr=0.1, max_iter=200)

    def closure():
        opt.zero_grad()
        loss = F.cross_entropy(lt / log_t.exp(), yt)
        loss.backward()
        return loss

    opt.step(closure)
    return float(log_t.exp())


def ece_brier(probs: np.ndarray, labels: np.ndarray, bins: int = 10) -> dict:
    conf = probs.max(1)
    pred = probs.argmax(1)
    correct = (pred == labels).astype(float)
    ece = 0.0
    curve = []
    for b in range(bins):
        m = (conf >= b / bins) & (conf < (b + 1) / bins if b < bins - 1 else conf <= 1)
        if m.any():
            ece += m.mean() * abs(conf[m].mean() - correct[m].mean())
            curve.append({"bin": b, "n": int(m.sum()), "conf": float(conf[m].mean()), "acc": float(correct[m].mean())})
    onehot = np.eye(probs.shape[1])[labels]
    return {"ece": float(ece), "brier": float(((probs - onehot) ** 2).sum(1).mean()), "accuracy": float(correct.mean()),
            "curve": curve}


def route_threshold(probs: np.ndarray, labels: np.ndarray, target: float = 0.9) -> tuple[float, float]:
    """Menor confianza t con acierto ≥ target entre las predicciones con confianza ≥ t → (t, cobertura)."""
    conf, correct = probs.max(1), probs.argmax(1) == labels
    for t in np.linspace(0.34, 0.99, 66):
        m = conf >= t
        if m.sum() >= 20 and correct[m].mean() >= target:
            return float(t), float(m.mean())
    return 0.99, float((conf >= 0.99).mean())
