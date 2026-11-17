"""Métricas del test de pares mínimos (§11.3) para jueces NLI y para espacios de embeddings."""

from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path
from typing import Callable, Sequence

import numpy as np

from .minimal_pairs import pairs

LABELS = ("entailment", "neutral", "contradiction")
CRITERION = 0.90

# (premisas, hipótesis) → matriz n×3 de probabilidades en el orden de LABELS.
JudgeFn = Callable[[Sequence[str], Sequence[str]], np.ndarray]
# textos → matriz n×d de vectores normalizados.
EmbedFn = Callable[[Sequence[str]], np.ndarray]


def _rate(xs: list[bool]) -> float:
    return float(np.mean(xs)) if xs else float("nan")


AUDIT = Path(__file__).resolve().parents[1] / "data" / "minimal_pairs_audit.json"


def audited_out() -> set[str]:
    """Pares que la auditoría marcó como discutibles (data/minimal_pairs_audit.json)."""
    return set(json.loads(AUDIT.read_text(encoding="utf-8"))["excluir"]) if AUDIT.exists() else set()


def evaluate_judge(judge: JudgeFn, audited: bool = False) -> dict:
    rows = pairs()
    if audited:
        out = audited_out()
        rows = [r for r in rows if r["id"] not in out]
    probs = judge([r["a"] for r in rows], [r["b"] for r in rows])
    pred = [LABELS[i] for i in probs.argmax(1)]
    by_rel: dict[str, list[bool]] = defaultdict(list)
    by_cat: dict[str, list[bool]] = defaultdict(list)
    confusion = np.zeros((3, 3), dtype=int)
    for r, p in zip(rows, pred):
        ok = p == r["nli"]
        by_rel[r["relation"]].append(ok)
        by_cat[r["category"]].append(ok)
        confusion[LABELS.index(r["nli"]), LABELS.index(p)] += 1
    join, sep = _rate(by_rel["misma_cadena"]), _rate(by_rel["opuesto"])
    return {
        "paraphrase_join": join,
        "opposite_separation": sep,
        "other_neutral": _rate(by_rel["otra_cadena"]),
        "accuracy": _rate([p == r["nli"] for r, p in zip(rows, pred)]),
        "by_category": {k: _rate(v) for k, v in sorted(by_cat.items())},
        "confusion": confusion.tolist(),
        "passes": join >= CRITERION and sep >= CRITERION,
    }


def evaluate_embeddings(embed: EmbedFn) -> dict:
    rows = pairs()
    texts = sorted({t for r in rows for t in (r["a"], r["b"])})
    index = {t: i for i, t in enumerate(texts)}
    vecs = embed(texts)
    by_anchor: dict[int, dict[str, float]] = defaultdict(dict)
    cats = {}
    for r in rows:
        by_anchor[r["anchor"]][r["relation"]] = float(vecs[index[r["a"]]] @ vecs[index[r["b"]]])
        if r["relation"] == "opuesto":
            cats[r["anchor"]] = r["category"]
    triplet_by_cat: dict[str, list[bool]] = defaultdict(list)
    for a, v in by_anchor.items():
        triplet_by_cat[cats[a]].append(v["misma_cadena"] > v["opuesto"])
    para = np.array([v["misma_cadena"] for v in by_anchor.values()])
    opp = np.array([v["opuesto"] for v in by_anchor.values()])
    other = np.array([v["otra_cadena"] for v in by_anchor.values()])
    # Umbral único (oráculo, optimista): ¿existe un corte que junte paráfrasis y separe opuestos?
    best = max(
        ((float(t), float((para >= t).mean()), float((opp < t).mean())) for t in np.linspace(-1, 1, 401)),
        key=lambda x: min(x[1], x[2]),
    )
    return {
        "triplet_accuracy": float((para > opp).mean()),
        "triplet_by_category": {k: _rate(v) for k, v in sorted(triplet_by_cat.items())},
        "mean_cos": {"misma_cadena": float(para.mean()), "opuesto": float(opp.mean()), "otra_cadena": float(other.mean())},
        "oracle_threshold": {"tau": best[0], "paraphrase_join": best[1], "opposite_separation": best[2]},
        "passes": best[1] >= CRITERION and best[2] >= CRITERION,
    }
