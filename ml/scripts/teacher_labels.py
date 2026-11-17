"""Maestro de probabilidades: mDeBERTa etiqueta los pares sintéticos con distribuciones suaves (destilación).

    .venv/Scripts/python scripts/teacher_labels.py [--teacher models/mdeberta_v4 --tag mdeberta_v4]

Escribe data/synth_v1/teacher_<tag>.npy (n×3, orden NLI_LABELS, alineado con pairs.jsonl) y un resumen
de acuerdo maestro ↔ etiqueta por construcción. Con --tag también etiqueta las semillas
(data/seeds/teacher_<tag>.npy, alineado con seeds_v1.jsonl). Solo ve datos sintéticos y semillas: nunca diarios.
"""

import json
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np  # noqa: E402

from teleios_ml import DATA, OUT  # noqa: E402
from teleios_ml.models import HFNliJudge  # noqa: E402
from teleios_ml.system_one import NLI_LABELS  # noqa: E402

TEACHER = sys.argv[sys.argv.index("--teacher") + 1] if "--teacher" in sys.argv else     "MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"
TAG = sys.argv[sys.argv.index("--tag") + 1] if "--tag" in sys.argv else "mdeberta"


def main() -> None:
    pairs = [json.loads(line) for line in (DATA / "synth_v1" / "pairs.jsonl").open(encoding="utf-8")]
    judge = HFNliJudge(TEACHER, batch_size=64)
    probs = judge([p["premise"] for p in pairs], [p["hypothesis"] for p in pairs]).astype(np.float32)
    np.save(DATA / "synth_v1" / f"teacher_{TAG}.npy", probs)
    if "--tag" in sys.argv:
        seeds = [json.loads(line) for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8")]
        seed_probs = judge([r["premise"] for r in seeds], [r["hypothesis"] for r in seeds]).astype(np.float32)
        np.save(DATA / "seeds" / f"teacher_{TAG}.npy", seed_probs)
    gold = np.array([NLI_LABELS.index(p["label"]) for p in pairs])
    pred = probs.argmax(1)
    report = {
        "teacher": TEACHER,
        "n": len(pairs),
        "agreement_with_construction": float((pred == gold).mean()),
        "agreement_by_label": {lab: float((pred[gold == i] == i).mean()) for i, lab in enumerate(NLI_LABELS)},
        "confusion_gold_x_teacher": [[int(((gold == i) & (pred == j)).sum()) for j in range(3)] for i in range(3)],
        "mean_confidence": float(probs.max(1).mean()),
        "disagreement_examples": [
            {"gold": pairs[i]["label"], "teacher": NLI_LABELS[pred[i]], "p": round(float(probs[i].max()), 2),
             "premise": pairs[i]["premise"], "hypothesis": pairs[i]["hypothesis"]}
            for i in np.where(pred != gold)[0][:15]
        ],
    }
    OUT.mkdir(exist_ok=True)
    (OUT / f"teacher_labels_report_{TAG}.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps({k: v for k, v in report.items() if k != "disagreement_examples"}, indent=2))
    print(Counter(NLI_LABELS[i] for i in pred))


if __name__ == "__main__":
    main()
