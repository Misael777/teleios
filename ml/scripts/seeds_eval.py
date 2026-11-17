"""Mapa de aciertos de un juez sobre las semillas, por categoría y dificultad.

    .venv/Scripts/python scripts/seeds_eval.py [models/system_one ...] [--split dev|all] [--out nombre]

Sin argumentos evalúa el System One actual y mDeBERTa sobre las 700 semillas.
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np  # noqa: E402

from teleios_ml import DATA, MODELS, OUT  # noqa: E402
from teleios_ml.models import HFNliJudge  # noqa: E402
from teleios_ml.system_one import NLI_LABELS, StudentJudge, load  # noqa: E402

MDEBERTA = "MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"


def evaluate(judge, rows: list[dict]) -> dict:
    probs = judge([r["premise"] for r in rows], [r["hypothesis"] for r in rows])
    pred = [NLI_LABELS[i] for i in probs.argmax(1)]
    cells: dict[tuple, list[bool]] = defaultdict(list)
    for r, p in zip(rows, pred):
        ok = p == r["label"]
        for key in (("total",), ("cat", r["category"]), ("dif", r["difficulty"]), ("lab", r["label"]),
                    ("cat_dif", r["category"], r["difficulty"])):
            cells[key].append(ok)
    acc = {"|".join(k): round(float(np.mean(v)), 3) for k, v in cells.items()}
    acc["n"] = len(rows)
    errors = [{"cat": r["category"], "dif": r["difficulty"], "gold": r["label"], "pred": p,
               "premise": r["premise"], "hypothesis": r["hypothesis"]}
              for r, p in zip(rows, pred) if p != r["label"]]
    return {"accuracy": acc, "errors": errors}


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    split = sys.argv[sys.argv.index("--split") + 1] if "--split" in sys.argv else "all"
    out_name = sys.argv[sys.argv.index("--out") + 1] if "--out" in sys.argv else f"seeds_eval_{split}"
    args = [a for a in args if a not in (split, out_name)]
    rows = [json.loads(line) for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8")]
    if split != "all":
        rows = [r for r in rows if r["split"] == split]
    judges = {}
    for path in args or [str(MODELS / "system_one")]:
        if path.startswith("hf:"):
            judges[Path(path[3:]).name] = HFNliJudge(path[3:])
            continue
        model, tok, meta = load(Path(path))
        judges[Path(path).name] = StudentJudge(model, tok, meta["temperatures"]["nli"])
    if not args:
        judges["mdeberta_xnli"] = HFNliJudge(MDEBERTA)
    report = {name: evaluate(j, rows) for name, j in judges.items()}
    OUT.mkdir(exist_ok=True)
    (OUT / f"{out_name}.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")

    cats = sorted({r["category"] for r in rows})
    names = list(report)
    print(f"Semillas: {len(rows)} ({split})\n")
    print(f"{'':16s}" + "".join(f"{n[:16]:>18s}" for n in names))
    for key in ["total"] + [f"cat|{c}" for c in cats] + [f"dif|{d}" for d in "FMD"] + [f"lab|{l}" for l in NLI_LABELS]:
        print(f"{key.split('|')[-1]:16s}" + "".join(f"{report[n]['accuracy'].get(key, float('nan')):>18.1%}" for n in names))


if __name__ == "__main__":
    main()
