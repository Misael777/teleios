"""Envoltorios uniformes de modelos de Hugging Face para el laboratorio."""

from __future__ import annotations

from typing import Sequence

import numpy as np
import torch

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"


class HFNliJudge:
    """Juez NLI de Hugging Face. Reordena sus etiquetas a (entailment, neutral, contradiction)."""

    def __init__(self, name: str, batch_size: int = 32):
        from transformers import AutoModelForSequenceClassification, AutoTokenizer

        self.name = name
        self.tok = AutoTokenizer.from_pretrained(name)
        self.model = AutoModelForSequenceClassification.from_pretrained(name).to(DEVICE).eval()
        labels = {v.lower(): k for k, v in self.model.config.id2label.items()}
        self.order = [labels["entailment"], labels["neutral"], labels["contradiction"]]
        self.batch_size = batch_size

    @torch.no_grad()
    def __call__(self, premises: Sequence[str], hypotheses: Sequence[str]) -> np.ndarray:
        out = []
        for i in range(0, len(premises), self.batch_size):
            enc = self.tok(
                list(premises[i : i + self.batch_size]),
                list(hypotheses[i : i + self.batch_size]),
                truncation=True,
                padding=True,
                max_length=256,
                return_tensors="pt",
            ).to(DEVICE)
            out.append(self.model(**enc).logits.float().softmax(-1)[:, self.order].cpu().numpy())
        return np.concatenate(out)


class STEmbedder:
    """sentence-transformers con prefijo opcional (los modelos e5 esperan "query: ")."""

    def __init__(self, name: str, prefix: str = ""):
        from sentence_transformers import SentenceTransformer

        self.name = name
        self.prefix = prefix
        self.model = SentenceTransformer(name, device=DEVICE)

    def __call__(self, texts: Sequence[str]) -> np.ndarray:
        return self.model.encode([self.prefix + t for t in texts], normalize_embeddings=True, batch_size=64)
