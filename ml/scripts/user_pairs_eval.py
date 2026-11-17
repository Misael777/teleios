"""Evalúa jueces sobre data/seeds/tus_pares.tsv (test que nunca entrena), por registro y por etiqueta.

    .venv/Scripts/python scripts/user_pairs_eval.py [models/system_one models/system_one_v2 ...]

Acepta TAB o " | " como separador; "# registro: X" agrupa los pares siguientes. Antes de evaluar avisa si
algún par se parece al test de pares mínimos o a una semilla de entrenamiento (inflaría el resultado).
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np  # noqa: E402

from teleios_ml import DATA, MODELS, OUT  # noqa: E402
from teleios_ml.models import HFNliJudge  # noqa: E402
from teleios_ml.synth import _ngrams, leaks  # noqa: E402
from teleios_ml.system_one import NLI_LABELS, StudentJudge, load  # noqa: E402

from seeds_check import LABELS, resolve  # noqa: E402

MDEBERTA = "MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"


def parse(path: Path) -> list[dict]:
    rows, register = [], "sin_registro"
    for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        s = line.strip()
        if s.lower().startswith("# registro:"):
            register = s.split(":", 1)[1].strip()
            continue
        if not s or s.startswith("#"):
            continue
        parts = [p.strip() for p in (s.split("\t") if "\t" in s else s.split(" | "))]
        if len(parts) != 4 or parts[0] not in ("F", "M", "D") or parts[1] not in LABELS:
            print(f"  ! línea {n} con formato inválido: {s[:70]}")
            continue
        rows.append({"register": register, "difficulty": parts[0], "label": LABELS[parts[1]],
                     "premise": resolve(parts[2]), "hypothesis": parts[3]})
    return rows


def main() -> None:
    rows = parse(DATA / "seeds" / "tus_pares.tsv")
    seeds = [json.loads(line) for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8")]
    seed_grams = [_ngrams(t) for r in seeds if r["split"] == "train" for t in (r["premise"], r["hypothesis"])]
    for r in rows:
        for t in (r["premise"], r["hypothesis"]):
            g = _ngrams(t)
            if leaks(t):
                print(f"  ! se parece al test de pares mínimos: {t[:70]}")
            elif not t.startswith(("@",)) and any(len(g & s) / len(g | s) > 0.6 for s in seed_grams) and len(t) > 25:
                print(f"  ! se parece a una semilla de entrenamiento: {t[:70]}")

    judges = {}
    for path in [a for a in sys.argv[1:]] or [str(MODELS / "system_one"), str(MODELS / "system_one_v2")]:
        if path.startswith("hf:"):
            judges[Path(path[3:]).name] = HFNliJudge(path[3:])
            continue
        model, tok, meta = load(Path(path))
        judges[Path(path).name] = StudentJudge(model, tok, meta["temperatures"]["nli"])
    judges["mdeberta_xnli"] = HFNliJudge(MDEBERTA)

    report, table = {}, defaultdict(dict)
    for name, j in judges.items():
        pred = [NLI_LABELS[i] for i in j([r["premise"] for r in rows], [r["hypothesis"] for r in rows]).argmax(1)]
        cells = defaultdict(list)
        for r, p in zip(rows, pred):
            ok = p == r["label"]
            for key in ("total", f"reg|{r['register']}", f"lab|{r['label']}", f"dif|{r['difficulty']}"):
                cells[key].append(ok)
        for k, v in cells.items():
            table[k][name] = (float(np.mean(v)), len(v))
        report[name] = {"errors": [{**r, "pred": p} for r, p in zip(rows, pred) if p != r["label"]]}
    OUT.mkdir(exist_ok=True)
    (OUT / "user_pairs_eval.json").write_text(json.dumps({"table": table, **report}, indent=2, ensure_ascii=False),
                                              encoding="utf-8")
    names = list(judges)
    print(f"\nPares: {len(rows)}\n{'':22s}" + "".join(f"{n[:15]:>16s}" for n in names) + "     n")
    order = ["total"] + sorted(k for k in table if k.startswith("reg|")) + [f"lab|{l}" for l in NLI_LABELS] + \
            [f"dif|{d}" for d in "FMD" if f"dif|{d}" in table]
    for k in order:
        print(f"{k.split('|')[-1]:22s}" + "".join(f"{table[k][n][0]:>16.0%}" for n in names) + f"{table[k][names[0]][1]:6d}")


if __name__ == "__main__":
    main()
