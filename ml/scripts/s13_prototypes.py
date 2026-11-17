"""S13 · Embeddings con negativos duros y catálogo de prototipos por grafo con signo (§11.2).

    .venv/Scripts/python scripts/s13_prototypes.py

1. Ajusta multilingual-e5-small con tripletas (ancla, paráfrasis, negación) → models/s13_e5_contrastive.
2. Mide el test de pares mínimos antes y después (los 300 pares nunca se usan para entrenar).
3. Clusteriza el corpus sintético por estructura de razonamiento y lo compara con agrupar por parecido.
   En S13 el peso estructural usa la estructura por construcción (sustituto de las cabezas, que llegan
   en S14); s15_antagonism.py repite todo con las cabezas predichas por el System One.
4. Escribe out/s13_report.json, out/s13_prototypes.json y out/s13_clusters.png.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import matplotlib  # noqa: E402

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from sklearn.metrics import adjusted_rand_score  # noqa: E402

from teleios_ml import DATA, MODELS, OUT  # noqa: E402
from teleios_ml.evaluation import evaluate_embeddings  # noqa: E402
from teleios_ml.models import DEVICE, HFNliJudge, STEmbedder  # noqa: E402
from teleios_ml.signed_graph import (  # noqa: E402
    antagonists,
    correlation_clustering,
    knn_pairs,
    opposite_violations,
    signed_edges,
    similarity_clustering,
    stability,
)
from teleios_ml.synth import BY_ID, corpus_for_clustering  # noqa: E402

BASE = "intfloat/multilingual-e5-small"
JUDGE = "MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"
TARGET = MODELS / "s13_e5_contrastive"


def train_contrastive() -> None:
    from sentence_transformers import InputExample, SentenceTransformer, losses
    from torch.utils.data import DataLoader

    rows = [json.loads(line) for line in (DATA / "synth_v1" / "triplets.jsonl").open(encoding="utf-8")]
    model = SentenceTransformer(BASE, device=DEVICE)
    q = "query: "
    examples = [InputExample(texts=[q + r["anchor"], q + r["positive"], q + r["negative"]]) for r in rows]
    loader = DataLoader(examples, shuffle=True, batch_size=32)
    # Ranking con negativos del lote + negativo duro explícito (la negación del ancla).
    loss = losses.MultipleNegativesRankingLoss(model, scale=30)
    model.fit(train_objectives=[(loader, loss)], epochs=2, warmup_steps=60, show_progress_bar=True,
              optimizer_params={"lr": 3e-5}, use_amp=True)
    TARGET.mkdir(parents=True, exist_ok=True)
    model.save(str(TARGET))


def plot(emb: np.ndarray, labels: list[int], chains: list[str], path: Path) -> None:
    from sklearn.decomposition import PCA

    xy = PCA(2, random_state=0).fit_transform(emb)
    fig, axes = plt.subplots(1, 2, figsize=(11, 5))
    cmap = plt.get_cmap("tab20")
    chain_ids = sorted(set(chains))
    axes[0].scatter(xy[:, 0], xy[:, 1], c=[cmap(chain_ids.index(c) % 20) for c in chains], s=10)
    axes[0].set_title("Cadena verdadera (sintética)")
    axes[1].scatter(xy[:, 0], xy[:, 1], c=[cmap(lab % 20) for lab in labels], s=10)
    axes[1].set_title("Grafo con signo (agrupamiento)")
    for ax in axes:
        ax.set_xticks([])
        ax.set_yticks([])
    fig.suptitle("S13 · Espacio contrastivo (PCA) y grupos por estructura de razonamiento")
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


def main() -> None:
    OUT.mkdir(exist_ok=True)
    before = evaluate_embeddings(STEmbedder(BASE, "query: "))
    if not (TARGET / "config.json").exists():
        train_contrastive()
    model = STEmbedder(str(TARGET), "query: ")
    after = evaluate_embeddings(model)

    corpus = corpus_for_clustering()
    texts = [c["text"] for c in corpus]
    chains = [c["chain"] for c in corpus]
    emb = model(texts)
    judge = HFNliJudge(JUDGE)
    pairs = knn_pairs(emb, k=20)
    edges = signed_edges(texts, pairs, judge, structure=corpus)
    labels = correlation_clustering(len(texts), edges)
    antagonist_of = {c.id: c.antagonist for c in BY_ID.values()}
    base_labels = similarity_clustering(STEmbedder(BASE, "query: ")(texts))
    stab = stability(len(texts), edges, labels)

    # Prototipos: grupos de ≥ 5 miembros, con su cadena mayoritaria (para nombrarlos en S15).
    prototypes = []
    for c in sorted(set(labels)):
        idx = [i for i, lab in enumerate(labels) if lab == c]
        if len(idx) < 5:
            continue
        centroid = emb[idx].mean(0)
        centroid /= np.linalg.norm(centroid)
        majority = max(set(chains[i] for i in idx), key=[chains[i] for i in idx].count)
        prototypes.append({"cluster": int(c), "size": len(idx), "majority_chain": majority,
                           "purity": [chains[i] for i in idx].count(majority) / len(idx),
                           "stability": stab["per_cluster"].get(c),
                           "examples": [texts[i] for i in idx[:6]], "centroid": centroid.round(5).tolist()})
    anti = antagonists(labels, edges)
    report = {
        "minimal_pairs_embeddings": {"before": before, "after": after},
        "clustering": {
            "n": len(texts),
            "edges": {"positive": sum(w > 0 for w in edges.values()), "negative": sum(w < 0 for w in edges.values())},
            "signed_graph": {"clusters": len(set(labels)), "ari_vs_chain": adjusted_rand_score(chains, labels),
                             "opposite_violations": opposite_violations(labels, chains, antagonist_of)},
            "similarity_baseline": {"clusters": len(set(base_labels)),
                                    "ari_vs_chain": adjusted_rand_score(chains, base_labels),
                                    "opposite_violations": opposite_violations(base_labels, chains, antagonist_of)},
            "stability": {"ari_mean": stab["ari_mean"], "ari_sd": stab["ari_sd"]},
        },
        "antagonist_pairs": [
            {"a": next((p["majority_chain"] for p in prototypes if p["cluster"] == a), str(a)),
             "b": next((p["majority_chain"] for p in prototypes if p["cluster"] == b), str(b)), "strength": s}
            for a, b, s in anti
        ],
    }
    (OUT / "s13_prototypes.json").write_text(json.dumps(prototypes, ensure_ascii=False), encoding="utf-8")
    (OUT / "s13_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    plot(emb, labels, chains, OUT / "s13_clusters.png")
    print(json.dumps({k: v for k, v in report.items() if k != "minimal_pairs_embeddings"}, indent=2, ensure_ascii=False))
    for k in ("before", "after"):
        r = report["minimal_pairs_embeddings"][k]
        print(k, r["triplet_accuracy"], r["triplet_by_category"], r["oracle_threshold"])


if __name__ == "__main__":
    main()
