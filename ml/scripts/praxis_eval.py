"""§13 · Evalúa jueces en la tarea acción ↔ principio y de temática.

    .venv/Scripts/python scripts/praxis_eval.py [models/mdeberta_v4 ...]

- test: data/praxis/tus_praxis_test.tsv (nunca entrena; principios redactados distinto y escenarios nuevos).
- dev:  split dev de data/praxis/praxis_v1.jsonl (reacciones no vistas, principios del catálogo).
Postura: acierto de 3 clases, y "decidido" como lo usa la app (confianza ≥ 0.9 y no neutral).
Temática: acierto binario con P(confirma) ≥ 0.5, el corte de MindMap.minRelevance.
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np  # noqa: E402

from teleios_ml import DATA, OUT  # noqa: E402
from teleios_ml.models import HFNliJudge  # noqa: E402
from teleios_ml.system_one import NLI_LABELS  # noqa: E402

from praxis_build import LABELS, align, topic  # noqa: E402

PRAXIS = DATA / "praxis"


def test_rows() -> list[dict]:
    rows = []
    for line in (PRAXIS / "tus_praxis_test.tsv").read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        task, lab, reg, premise, target = line.split("\t")
        rows.append({"task": task, "label": LABELS[lab], "register": reg, "premise": premise,
                     "hypothesis": align(target) if task == "A" else topic(target)})
    return rows


def dev_rows() -> list[dict]:
    return [r for r in (json.loads(x) for x in (PRAXIS / "praxis_v1.jsonl").open(encoding="utf-8")) if r["split"] == "dev"]


def evaluate(judge, rows: list[dict]) -> dict:
    p = judge([r["premise"] for r in rows], [r["hypothesis"] for r in rows])
    out, cells = {}, defaultdict(list)
    for r, q in zip(rows, p):
        if r["task"] == "A":
            pred = NLI_LABELS[int(q.argmax())]
            cells["A"].append(pred == r["label"])
            cells[f"A|{r['label']}"].append(pred == r["label"])
            decided = q.max() >= 0.9 and pred != "neutral"
            if decided:
                cells["A_decided_precision"].append(pred == r["label"])
            if r["label"] != "neutral":
                cells["A_decided_recall"].append(decided and pred == r["label"])
            if r.get("register"):
                cells[f"A|reg|{r['register']}"].append(pred == r["label"])
        else:
            cells["T"].append((q[0] >= 0.5) == (r["label"] == "entailment"))
            cells[f"T|{r['label']}"].append((q[0] >= 0.5) == (r["label"] == "entailment"))
    for k, v in cells.items():
        out[k] = round(float(np.mean(v)), 3)
        out[f"n|{k}"] = len(v)
    return out


def main() -> None:
    names = sys.argv[1:] or ["models/mdeberta_v4"]
    test, dev = test_rows(), dev_rows()
    report = {}
    for name in names:
        j = HFNliJudge(name)
        report[name] = {"test": evaluate(j, test), "dev": evaluate(j, dev)}
    OUT.mkdir(exist_ok=True)
    (OUT / "praxis_eval.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    keys = ["A", "A|entailment", "A|contradiction", "A|neutral", "A_decided_precision", "A_decided_recall",
            "T", "T|entailment", "T|neutral"]
    print(f"{'':24s}" + "".join(f"{Path(n).name[:14]:>16s}{'':>8s}" for n in names))
    print(f"{'':24s}" + "".join(f"{'test':>12s}{'dev':>12s}" for _ in names))
    for k in keys:
        print(f"{k:24s}" + "".join(f"{report[n]['test'].get(k, float('nan')):>12.1%}{report[n]['dev'].get(k, float('nan')):>12.1%}"
                                   for n in names))


if __name__ == "__main__":
    main()
