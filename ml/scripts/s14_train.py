"""S14 · System One multi-cabeza: entrenamiento, calibración y comparación de jueces (§11.1, §7).

    .venv/Scripts/python scripts/s14_train.py

Multitarea en la GPU local (bf16):
  - NLI: XNLI en español (entrenamiento previo, §10.2) + pares sintéticos con negación y antagonismo.
  - Cabezas tipadas: pensamientos sintéticos con etiquetas por construcción.
  - Contrastiva: tripletas con negativo duro (mantiene el espacio de S13).
Validación separada: temas retenidos (no vistos al entrenar) + XNLI validation. Ahí se ajustan las
temperaturas y el umbral del ruteador. El test de pares mínimos queda aparte y nunca entrena.
Escribe models/system_one/ y out/s14_report.json.
"""

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np  # noqa: E402
import torch  # noqa: E402
import torch.nn.functional as F  # noqa: E402

from teleios_ml import DATA, MODELS, OUT  # noqa: E402
from teleios_ml.evaluation import evaluate_embeddings, evaluate_judge  # noqa: E402
from teleios_ml.models import DEVICE, HFNliJudge  # noqa: E402
from teleios_ml.synth import HEADS  # noqa: E402
from teleios_ml.system_one import (  # noqa: E402
    NLI_LABELS,
    StudentEncoder,
    StudentJudge,
    SystemOne,
    ece_brier,
    fit_temperature,
    route_threshold,
    save,
)

# Base con NLI multilingüe y tokenizador XLM-R (el mismo que implementa el teléfono). Línea base sin
# ajustar: 81 % / 73 % en pares mínimos, frente a e5-small (sin NLI), que no pasó del 48 % al ajustarlo.
ENCODER = "MoritzLaurer/multilingual-MiniLMv2-L12-mnli-xnli"
# --seeds N: agrega las semillas del maestro (data/seeds, split train) repetidas N veces.
# --target nombre: carpeta de salida en models/ (por defecto system_one).
# --distill [tag]: destilación selectiva del maestro (teacher_labels.py) en los pares sintéticos donde el maestro
# coincide con la etiqueta por construcción; donde discrepa, manda la etiqueta. Con tag (p. ej. mdeberta_v4)
# usa teacher_<tag>.npy y destila también las semillas.
DISTILL = "--distill" in sys.argv
_tag = sys.argv[sys.argv.index("--distill") + 1] if DISTILL and sys.argv.index("--distill") + 1 < len(sys.argv) else ""
DISTILL_TAG = "" if _tag.startswith("--") else _tag
KD_T = 2.0
KD_ALPHA = float(sys.argv[sys.argv.index("--kd-alpha") + 1]) if "--kd-alpha" in sys.argv else 0.5
SEED_REPEAT = int(sys.argv[sys.argv.index("--seeds") + 1]) if "--seeds" in sys.argv else 0
TARGET = MODELS / (sys.argv[sys.argv.index("--target") + 1] if "--target" in sys.argv else "system_one")
HOLDOUT = {"mis proyectos", "mis amistades", "mis bienes"}  # temas que nunca se ven al entrenar
STEPS, LR = 3000, 3e-5
SEED = int(sys.argv[sys.argv.index("--seed") + 1]) if "--seed" in sys.argv else 13
# --v4-frac f: fracción del lote v4 de semillas (cubetas anidadas 0-99) que entra al entrenamiento.
V4_FRAC = float(sys.argv[sys.argv.index("--v4-frac") + 1]) if "--v4-frac" in sys.argv else 0.0
XNLI_TRAIN = 60000


def load_jsonl(name: str) -> list[dict]:
    return [json.loads(line) for line in (DATA / "synth_v1" / name).open(encoding="utf-8")]


def held(text: str) -> bool:
    return any(h in text for h in HOLDOUT)


def main() -> None:
    from datasets import load_dataset
    from transformers import AutoTokenizer, get_linear_schedule_with_warmup

    random.seed(SEED)
    torch.manual_seed(SEED)
    tok = AutoTokenizer.from_pretrained(ENCODER)
    xnli = load_dataset("facebook/xnli", "es")
    # XNLI: 0 entailment, 1 neutral, 2 contradiction (mismo orden que NLI_LABELS).
    x_train = [(r["premise"], r["hypothesis"], r["label"]) for r in xnli["train"].shuffle(seed=SEED).select(range(XNLI_TRAIN))]
    x_val = [(r["premise"], r["hypothesis"], r["label"]) for r in xnli["validation"]]
    pairs = load_jsonl("pairs.jsonl")
    teacher = np.load(DATA / "synth_v1" / f"teacher_{DISTILL_TAG or 'mdeberta'}.npy") if DISTILL else None
    s_train = []
    distilled = 0
    for i, p in enumerate(pairs):
        if held(p["premise"]):
            continue
        y = NLI_LABELS.index(p["label"])
        soft = teacher[i] if teacher is not None and int(teacher[i].argmax()) == y else None
        distilled += soft is not None
        s_train.append((p["premise"], p["hypothesis"], y, soft))
    x_train = [(a, b, y, None) for a, b, y in x_train]
    s_val = [(p["premise"], p["hypothesis"], NLI_LABELS.index(p["label"])) for p in pairs if held(p["premise"])][:3000]
    thoughts = load_jsonl("thoughts.jsonl")
    h_train = [t for t in thoughts if not held(t["text"])]
    h_val = [t for t in thoughts if held(t["text"])]
    triplets = [t for t in load_jsonl("triplets.jsonl") if not held(t["anchor"])]
    nli_train = x_train + s_train * 2  # el sintético pesa más: es lo que XNLI no enseña (negación, cadenas)
    seeds = [json.loads(line) for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8")]
    seed_soft = np.load(DATA / "seeds" / f"teacher_{DISTILL_TAG}.npy") if DISTILL_TAG else None
    seed_train = []
    for i, r in enumerate(seeds):
        if r["split"] != "train" or not (r.get("batch", "v1") == "v1" or r["bucket"] < V4_FRAC * 100):
            continue
        y = NLI_LABELS.index(r["label"])
        soft = seed_soft[i] if seed_soft is not None and int(seed_soft[i].argmax()) == y else None
        distilled += soft is not None
        seed_train.append((r["premise"], r["hypothesis"], y, soft))
    seed_dev = [r for r in seeds if r["split"] == "dev"]
    if SEED_REPEAT:
        nli_train += seed_train * SEED_REPEAT

    model = SystemOne(str(ENCODER)).to(DEVICE)
    opt = torch.optim.AdamW(model.parameters(), lr=LR, weight_decay=0.01)
    sched = get_linear_schedule_with_warmup(opt, 200, STEPS)

    def enc(a, b=None, prefix=""):
        return tok([prefix + x for x in a], b, truncation=True, padding=True, max_length=128, return_tensors="pt").to(DEVICE)

    model.train()
    for step in range(1, STEPS + 1):
        with torch.autocast("cuda", dtype=torch.bfloat16, enabled=DEVICE == "cuda"):
            nb = random.sample(nli_train, 32)
            e = enc([x[0] for x in nb], [x[1] for x in nb])
            logits = model(e["input_ids"], e["attention_mask"])["nli_logits"].float()
            ce = F.cross_entropy(logits, torch.tensor([x[2] for x in nb], device=DEVICE), reduction="none")
            soft_idx = [k for k, x in enumerate(nb) if x[3] is not None]
            if soft_idx:
                # KD de Hinton: KL(maestro‖alumno) con temperatura, escalado por T².
                t = torch.tensor(np.stack([nb[k][3] for k in soft_idx]), device=DEVICE).clamp_min(1e-6)
                t = (t.log() / KD_T).softmax(-1)
                kl = F.kl_div((logits[soft_idx] / KD_T).log_softmax(-1), t, reduction="none").sum(-1) * KD_T**2
                ce[soft_idx] = (1 - KD_ALPHA) * ce[soft_idx] + KD_ALPHA * kl
            loss_nli = ce.mean()
            hb = random.sample(h_train, 32)
            out = model(**{k: v for k, v in enc([t["text"] for t in hb], prefix="query: ").items() if k != "token_type_ids"})
            loss_heads = sum(F.cross_entropy(out[f"{k}_logits"].float(),
                                             torch.tensor([v.index(t[k]) for t in hb], device=DEVICE)) for k, v in HEADS.items())
            tb = random.sample(triplets, 16)
            ea = model(**{k: v for k, v in enc([t["anchor"] for t in tb], prefix="query: ").items() if k != "token_type_ids"})["embedding"]
            ep = model(**{k: v for k, v in enc([t["positive"] for t in tb] + [t["negative"] for t in tb], prefix="query: ").items()
                          if k != "token_type_ids"})["embedding"]
            sims = (ea.float() @ ep.float().T) * 30  # positivos en la diagonal; negativos duros + del lote
            loss_con = F.cross_entropy(sims, torch.arange(len(tb), device=DEVICE))
            loss = loss_nli + 0.5 * loss_heads + 0.3 * loss_con
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        opt.step()
        sched.step()
        opt.zero_grad()
        if step % 250 == 0:
            print(f"paso {step}: nli {loss_nli.item():.3f} cabezas {loss_heads.item():.3f} contrastiva {loss_con.item():.3f}", flush=True)
    model.eval()

    # ── Calibración sobre validación separada ──
    raw = StudentJudge(model, tok, 1.0)
    val_nli = x_val + s_val
    logits = np.log(np.clip(raw([p for p, _, _ in val_nli], [h for _, h, _ in val_nli]), 1e-9, 1))
    y = np.array([l for _, _, l in val_nli])
    temps = {"nli": fit_temperature(logits, y)}
    encoder = StudentEncoder(model, tok)
    heads_out = encoder.run([t["text"] for t in h_val])
    calib = {}
    for k, labels in HEADS.items():
        yk = np.array([labels.index(t[k]) for t in h_val])
        lk = np.log(np.clip(heads_out[f"{k}_logits"], 1e-9, 1))
        temps[k] = fit_temperature(lk, yk)
        probs = torch.tensor(lk / temps[k]).softmax(-1).numpy()
        calib[k] = {kk: v for kk, v in ece_brier(probs, yk).items() if kk != "curve"}
    p_nli = torch.tensor(logits / temps["nli"]).softmax(-1).numpy()
    calib["nli"] = ece_brier(p_nli, y)
    calib["nli_xnli_only"] = {k: v for k, v in ece_brier(p_nli[: len(x_val)], y[: len(x_val)]).items() if k != "curve"}
    threshold, coverage = route_threshold(p_nli, y)

    # ── Comparación de jueces sobre el mismo test (§7) ──
    student = StudentJudge(model, tok, temps["nli"])
    judges = {"system_one": evaluate_judge(student)}
    judges["system_one"]["audited"] = {k: v for k, v in evaluate_judge(student, audited=True).items()
                                       if k in ("paraphrase_join", "opposite_separation", "passes")}
    teacher = HFNliJudge("MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7")
    judges["mdeberta_xnli"] = evaluate_judge(teacher)
    xs = random.Random(1).sample(x_val, 1000)
    for name, j in (("system_one", student), ("mdeberta_xnli", teacher)):
        p = j([a for a, _, _ in xs], [b for _, b, _ in xs])
        judges[name]["xnli_val_accuracy"] = float((p.argmax(1) == np.array([l for _, _, l in xs])).mean())
    judges["llm_logits"] = {"status": "no evaluado: requiere servidor local (teacher.py)"}
    judges["jev"] = {"status": "no evaluado: API cerrada en acceso anticipado; fijar versión exacta al evaluarlo"}

    sp = student([r["premise"] for r in seed_dev], [r["hypothesis"] for r in seed_dev]).argmax(1)
    seed_dev_acc = {"total": float(np.mean([NLI_LABELS[i] == r["label"] for i, r in zip(sp, seed_dev)]))}
    for b in ("v1", "v4"):
        hits = [NLI_LABELS[i] == r["label"] for i, r in zip(sp, seed_dev) if r.get("batch", "v1") == b]
        if hits:
            seed_dev_acc[f"batch_{b}"] = float(np.mean(hits))
    for cat in sorted({r["category"] for r in seed_dev}):
        hits = [NLI_LABELS[i] == r["label"] for i, r in zip(sp, seed_dev) if r["category"] == cat]
        seed_dev_acc[cat] = float(np.mean(hits))
    report = {
        "seeds": {"seed": SEED, "v4_frac": V4_FRAC, "repeat": SEED_REPEAT, "train": len(seed_train), "dev": len(seed_dev), "dev_accuracy": seed_dev_acc},
        "steps": STEPS,
        "distill": {"enabled": DISTILL, "teacher": DISTILL_TAG or "mdeberta", "pairs_with_teacher": distilled, "T": KD_T, "alpha": KD_ALPHA},
        "data": {"xnli_train": len(x_train), "synth_nli_train": len(s_train), "heads_train": len(h_train),
                 "triplets": len(triplets), "holdout_topics": sorted(HOLDOUT)},
        "temperatures": temps,
        "calibration": calib,
        "route_threshold": threshold,
        "route_coverage": coverage,
        "judges": judges,
        "embeddings_minimal_pairs": evaluate_embeddings(encoder),
    }
    save(model, tok, TARGET, temps, {"encoder": str(ENCODER), "route_threshold": threshold})
    report["encoder"] = str(ENCODER)
    OUT.mkdir(exist_ok=True)
    (OUT / f"s14_report_{TARGET.name}.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    if TARGET.name == "system_one":
        (OUT / "s14_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    s = judges["system_one"]
    print(json.dumps({"system_one": {k: s[k] for k in ("paraphrase_join", "opposite_separation", "passes", "by_category", "xnli_val_accuracy")},
                      "mdeberta": {k: judges["mdeberta_xnli"][k] for k in ("paraphrase_join", "opposite_separation", "xnli_val_accuracy")},
                      "calibration_nli": {k: calib["nli"][k] for k in ("ece", "brier", "accuracy")},
                      "temperatures": temps, "route": (threshold, coverage),
                      "embeddings": report["embeddings_minimal_pairs"]["oracle_threshold"],
                      "seed_dev": seed_dev_acc}, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
