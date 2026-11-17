"""Fiabilidad de etiquetas con muchas personas (§10.3): α de Krippendorff y Dawid-Skene.

Entrada común: lista de (ítem, etiquetador, etiqueta). "no_se" se trata como dato faltante.
"""

from __future__ import annotations

from collections import Counter, defaultdict

import numpy as np

Label = tuple[str, str, str]  # (item, annotator, label)


def _clean(labels: list[Label]) -> list[Label]:
    return [x for x in labels if x[2] != "no_se"]


def krippendorff_alpha_nominal(labels: list[Label]) -> float:
    """α nominal con datos faltantes: 1 − D_o / D_e, contando solo ítems con ≥ 2 respuestas."""
    by_item: dict[str, list[str]] = defaultdict(list)
    for item, _, lab in _clean(labels):
        by_item[item].append(lab)
    units = [v for v in by_item.values() if len(v) >= 2]
    if not units:
        return float("nan")
    cats = sorted({lab for v in units for lab in v})
    idx = {c: i for i, c in enumerate(cats)}
    o = np.zeros((len(cats), len(cats)))
    for v in units:
        m = len(v)
        counts = Counter(v)
        for a, na in counts.items():
            for b, nb in counts.items():
                o[idx[a], idx[b]] += na * (nb - (a == b)) / (m - 1)
    n_c = o.sum(1)
    n = n_c.sum()
    d_o = (n - np.trace(o)) / n
    d_e = (n * n - (n_c**2).sum()) / (n * (n - 1))
    return float(1 - d_o / d_e) if d_e > 0 else 1.0


def dawid_skene(labels: list[Label], iters: int = 50, tol: float = 1e-6) -> dict:
    """EM de Dawid-Skene: etiqueta posterior de cada ítem y matriz de confusión de cada persona.

    Devuelve {'posterior': {item: {label: p}}, 'reliability': {annotator: acierto esperado}, 'labels': [...]}.
    """
    data = _clean(labels)
    items = sorted({x[0] for x in data})
    people = sorted({x[1] for x in data})
    cats = sorted({x[2] for x in data})
    ii = {v: k for k, v in enumerate(items)}
    pi = {v: k for k, v in enumerate(people)}
    ci = {v: k for k, v in enumerate(cats)}
    K = len(cats)
    # Inicio por voto mayoritario suave.
    T = np.full((len(items), K), 1e-6)
    for it, an, lab in data:
        T[ii[it], ci[lab]] += 1
    T /= T.sum(1, keepdims=True)
    prev = None
    for _ in range(iters):
        prior = T.mean(0)
        conf = np.full((len(people), K, K), 0.01)
        for it, an, lab in data:
            conf[pi[an], :, ci[lab]] += T[ii[it]]
        conf /= conf.sum(2, keepdims=True)
        logT = np.tile(np.log(prior), (len(items), 1))
        for it, an, lab in data:
            logT[ii[it]] += np.log(conf[pi[an], :, ci[lab]])
        logT -= logT.max(1, keepdims=True)
        T = np.exp(logT)
        T /= T.sum(1, keepdims=True)
        if prev is not None and np.abs(T - prev).max() < tol:
            break
        prev = T.copy()
    prior = T.mean(0)
    return {
        "labels": cats,
        "posterior": {it: {c: float(T[ii[it], ci[c]]) for c in cats} for it in items},
        "reliability": {p: float((prior * np.diag(conf[pi[p]])).sum() / prior.sum()) for p in people},
    }


def gold_accuracy(labels: list[Label], gold: dict[str, str]) -> dict[str, float]:
    hits: dict[str, list[bool]] = defaultdict(list)
    for it, an, lab in _clean(labels):
        if it in gold:
            hits[an].append(lab == gold[it])
    return {a: float(np.mean(v)) for a, v in hits.items()}


def verdict(alpha: float) -> str:
    if alpha != alpha:  # nan
        return "sin datos suficientes"
    if alpha >= 0.8:
        return "fiable"
    if alpha >= 0.667:
        return "solo conclusiones tentativas"
    return "no fiable: revisar la guía de etiquetado"
