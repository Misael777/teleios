"""Clusterizador por estructura de razonamiento sobre un grafo con signo (§11.2).

1. Candidatos: k vecinos por embeddings (solo filtra por tema).
2. Aristas: NLI en ambos sentidos. Implicación mutua → positiva; contradicción → negativa.
3. Peso estructural: mismo esquema y agente refuerzan; polaridad distinta anula la positiva.
4. Agrupación: correlation clustering aglomerativo con restricción "no unir" sobre aristas negativas:
   los opuestos NO pueden caer en el mismo grupo.
5. Salidas: grupos (prototipos) y pares antagónicos (grupos unidos por aristas negativas).
6. Validez: estabilidad bootstrap (ARI) además de interpretabilidad.
"""

from __future__ import annotations

from collections import defaultdict
from typing import Callable, Sequence

import numpy as np
from sklearn.metrics import adjusted_rand_score

JudgeFn = Callable[[Sequence[str], Sequence[str]], np.ndarray]  # → n×3 (entail, neutral, contra)


def knn_pairs(emb: np.ndarray, k: int = 20) -> list[tuple[int, int]]:
    sims = emb @ emb.T
    np.fill_diagonal(sims, -np.inf)
    idx = np.argsort(-sims, axis=1)[:, :k]
    return sorted({(min(i, j), max(i, j)) for i in range(len(emb)) for j in idx[i]})


def signed_edges(
    texts: Sequence[str],
    pairs: list[tuple[int, int]],
    judge: JudgeFn,
    structure: list[dict] | None = None,
    pos_min: float = 0.5,
    neg_min: float = 0.5,
) -> dict[tuple[int, int], float]:
    fwd = judge([texts[i] for i, _ in pairs], [texts[j] for _, j in pairs])
    bwd = judge([texts[j] for _, j in pairs], [texts[i] for i, _ in pairs])
    edges = {}
    for (i, j), f, b in zip(pairs, fwd, bwd):
        entail = min(f[0], b[0])
        contra = max(f[2], b[2])
        w = 0.0
        if contra >= neg_min and contra > entail:
            w = -contra
        elif entail >= pos_min:
            w = entail
            if structure:
                si, sj = structure[i], structure[j]
                if si.get("polaridad") != sj.get("polaridad"):
                    w = 0.0
                elif si.get("esquema") == sj.get("esquema") and si.get("agente") == sj.get("agente"):
                    w = min(1.0, w + 0.1)
        elif structure and contra < 0.3:
            # NLI neutral entre temas distintos: misma estructura completa = misma cadena (arista débil).
            si, sj = structure[i], structure[j]
            if all(si.get(h) == sj.get(h) for h in ("esquema", "agente", "polaridad", "distorsion")):
                w = 0.3
        if w:
            edges[(i, j)] = float(w)
    return edges


def correlation_clustering(n: int, edges: dict[tuple[int, int], float], min_gain: float = 0.0) -> list[int]:
    """Aglomerativo: une los dos grupos con mayor peso positivo neto entre sí, nunca si los separa una
    arista negativa. Termina cuando ninguna unión mejora el objetivo de correlation clustering."""
    cluster = list(range(n))
    members = {i: {i} for i in range(n)}
    between: dict[tuple[int, int], float] = defaultdict(float)
    forbidden: set[tuple[int, int]] = set()
    for (i, j), w in edges.items():
        key = (min(i, j), max(i, j))
        if w < 0:
            forbidden.add(key)
        else:
            between[key] += w
    while True:
        best, gain = None, min_gain
        for key, w in between.items():
            if key not in forbidden and w > gain:
                best, gain = key, w
        if best is None:
            break
        a, b = best
        members[a] |= members.pop(b)
        for m in members[a]:
            cluster[m] = a
        new_between: dict[tuple[int, int], float] = defaultdict(float)
        for (x, y), w in between.items():
            x, y = (a if x == b else x), (a if y == b else y)
            if x != y:
                new_between[(min(x, y), max(x, y))] += w
        between = new_between
        forbidden = {(min(a if x == b else x, a if y == b else y), max(a if x == b else x, a if y == b else y))
                     for x, y in forbidden}
    remap = {c: k for k, c in enumerate(sorted(set(cluster)))}
    return [remap[c] for c in cluster]


def antagonists(labels: list[int], edges: dict[tuple[int, int], float], min_edges: int = 3) -> list[tuple[int, int, float]]:
    """Pares de grupos unidos por contradicciones: (grupo A, grupo B, fuerza media). Cada grupo se queda
    con su antagonista más fuerte."""
    neg: dict[tuple[int, int], list[float]] = defaultdict(list)
    for (i, j), w in edges.items():
        a, b = labels[i], labels[j]
        if w < 0 and a != b:
            neg[(min(a, b), max(a, b))].append(-w)
    scored = sorted(((a, b, float(np.mean(v)) * min(1.0, len(v) / 10)) for (a, b), v in neg.items() if len(v) >= min_edges),
                    key=lambda x: -x[2])
    used, out = set(), []
    for a, b, s in scored:
        if a in used or b in used:
            continue
        used |= {a, b}
        out.append((a, b, s))
    return out


def stability(n: int, edges: dict[tuple[int, int], float], labels: list[int], rounds: int = 20,
              frac: float = 0.8, seed: int = 0) -> dict:
    """ARI entre el agrupamiento completo y el de submuestras (solo nodos compartidos) y estabilidad por
    grupo (Jaccard del mejor emparejamiento)."""
    rng = np.random.default_rng(seed)
    aris, per_cluster = [], defaultdict(list)
    full = np.array(labels)
    for _ in range(rounds):
        keep = np.sort(rng.choice(n, int(n * frac), replace=False))
        pos = {int(v): k for k, v in enumerate(keep)}
        sub = {(pos[i], pos[j]): w for (i, j), w in edges.items() if i in pos and j in pos}
        lab = np.array(correlation_clustering(len(keep), sub))
        aris.append(adjusted_rand_score(full[keep], lab))
        for c in set(full[keep]):
            A = set(np.where(full[keep] == c)[0])
            best = max(len(A & set(np.where(lab == d)[0])) / len(A | set(np.where(lab == d)[0])) for d in set(lab))
            per_cluster[int(c)].append(best)
    return {"ari_mean": float(np.mean(aris)), "ari_sd": float(np.std(aris)),
            "per_cluster": {c: float(np.mean(v)) for c, v in per_cluster.items()}}


def similarity_clustering(emb: np.ndarray, k: int = 20, threshold: float = 0.85) -> list[int]:
    """Línea base "por parecido": componentes del grafo kNN con coseno ≥ umbral (sin signo, sin NLI)."""
    import igraph as ig

    pairs = [(i, j) for i, j in knn_pairs(emb, k) if emb[i] @ emb[j] >= threshold]
    g = ig.Graph(n=len(emb), edges=pairs)
    return list(g.connected_components().membership)


def opposite_violations(labels: list[int], chains: list[str], antagonist_of: dict[str, str]) -> float:
    """Fracción de pares (cadena, antagonista) que terminaron en el mismo grupo. Debe ser 0."""
    by_cluster: dict[int, set[str]] = defaultdict(set)
    for lab, ch in zip(labels, chains):
        by_cluster[lab].add(ch)
    pairs = {(min(a, b), max(a, b)) for a, b in antagonist_of.items()}
    bad = sum(any(a in s and b in s for s in by_cluster.values()) for a, b in pairs)
    return bad / len(pairs)


def group_relations(groups: list[list[str]], judge: JudgeFn, per_group: int = 4) -> tuple[np.ndarray, np.ndarray]:
    """Entailment y contradicción medias entre grupos (ejemplos representativos, ambos sentidos).

    Los opuestos casi nunca son vecinos en un espacio contrastivo, así que el antagonismo se mide aquí,
    entre prototipos, y no con las aristas de los vecinos."""
    reps = [g[:per_group] for g in groups]
    n = len(reps)
    pairs, owners = [], []
    for a in range(n):
        for b in range(a + 1, n):
            for x in reps[a]:
                for y in reps[b]:
                    pairs.append((x, y))
                    owners.append((a, b))
    entail, contra = np.zeros((n, n)), np.zeros((n, n))
    if not pairs:
        return entail, contra
    f = judge([x for x, _ in pairs], [y for _, y in pairs])
    r = judge([y for _, y in pairs], [x for x, _ in pairs])
    count = np.zeros((n, n))
    for (a, b), pf, pr in zip(owners, f, r):
        entail[a, b] += min(pf[0], pr[0])
        contra[a, b] += max(pf[2], pr[2])
        count[a, b] += 1
    count[count == 0] = 1
    entail, contra = entail / count, contra / count
    return entail + entail.T, contra + contra.T


def merge_groups(labels: list[int], groups: list[int], entail: np.ndarray, contra: np.ndarray,
                 min_entail: float = 0.5, max_contra: float = 0.2) -> list[int]:
    """Une subgrupos de la misma cadena: implicación mutua alta y ninguna contradicción entre ellos."""
    parent = {g: g for g in groups}

    def find(g):
        while parent[g] != g:
            g = parent[g]
        return g

    for i, a in enumerate(groups):
        for j, b in enumerate(groups):
            if i < j and entail[i, j] >= min_entail and contra[i, j] <= max_contra:
                parent[find(b)] = find(a)
    return [find(lab) if lab in parent else lab for lab in labels]
