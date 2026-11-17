"""S11 · Línea base: cuánto fallan hoy los modelos sin ajustar con la negación (§11.3).

    .venv/Scripts/python scripts/s11_baseline.py

Escribe out/s11_baseline.json y out/s11_baseline.png.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import matplotlib  # noqa: E402

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from teleios_ml import DATA, OUT  # noqa: E402
from teleios_ml.evaluation import CRITERION, evaluate_embeddings, evaluate_judge  # noqa: E402
from teleios_ml.minimal_pairs import write  # noqa: E402
from teleios_ml.models import HFNliJudge, STEmbedder  # noqa: E402

JUDGES = ["MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"]
EMBEDDERS = [
    ("intfloat/multilingual-e5-small", "query: "),
    ("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", ""),
]


def plot(report: dict, path: Path, title: str) -> None:
    fig, ax = plt.subplots(figsize=(8, 4))
    labels, join, sep = [], [], []
    for name, r in report.get("judges", {}).items():
        labels.append("NLI\n" + name.split("/")[-1][:24])
        join.append(r["paraphrase_join"])
        sep.append(r["opposite_separation"])
    for name, r in report.get("embedders", {}).items():
        labels.append("Emb\n" + name.split("/")[-1][:24])
        join.append(r["oracle_threshold"]["paraphrase_join"])
        sep.append(r["oracle_threshold"]["opposite_separation"])
    x = list(range(len(labels)))
    ax.bar([i - 0.2 for i in x], join, 0.4, label="Junta paráfrasis")
    ax.bar([i + 0.2 for i in x], sep, 0.4, label="Separa opuestos")
    ax.axhline(CRITERION, color="k", ls="--", lw=1, label="Criterio 90 %")
    ax.set_xticks(x, labels, fontsize=7)
    ax.set_ylim(0, 1)
    ax.set_title(title)
    ax.legend(fontsize=8, loc="lower right")
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    plt.close(fig)


def main() -> None:
    write(DATA / "minimal_pairs_v1.jsonl")
    OUT.mkdir(exist_ok=True)
    report = {"criterion": CRITERION, "judges": {}, "embedders": {}}
    for name in JUDGES:
        print("Juez", name, flush=True)
        report["judges"][name] = evaluate_judge(HFNliJudge(name))
    for name, prefix in EMBEDDERS:
        print("Embeddings", name, flush=True)
        report["embedders"][name] = evaluate_embeddings(STEmbedder(name, prefix))
    (OUT / "s11_baseline.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    plot(report, OUT / "s11_baseline.png", "S11 · Línea base en el test de pares mínimos")
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
