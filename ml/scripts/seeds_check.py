"""Valida las semillas del maestro y genera la división fija entrenamiento / seed-dev.

    .venv/Scripts/python scripts/seeds_check.py [--show-verses]

- Formato: dificultad (F/M/D), etiqueta (E/N/C), premisa, hipótesis; la categoría es el nombre del archivo.
- `@LIBRO.CAP.VERS` en la premisa se reemplaza por el texto exacto de la RV1909 de la app.
- Descarta duplicados y todo lo que se parezca al test de pares mínimos (nunca se entrena con él).
- División 80/20 estratificada por categoría × dificultad, con semilla fija → data/seeds/seeds_v1.jsonl.
"""

import hashlib
import json
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from teleios_ml import DATA, bible  # noqa: E402
from teleios_ml.synth import leaks  # noqa: E402

SEEDS = DATA / "seeds"
LABELS = {"E": "entailment", "N": "neutral", "C": "contradiction"}


def resolve(text: str) -> str:
    if not text.startswith("@"):
        return text
    book, ch, vs = text[1:].split(".")
    verse = bible.text(bible.verse_id(book, int(ch), int(vs))).strip()
    if not verse:
        raise ValueError(f"Versículo vacío o inexistente: {text}")
    return verse


def main() -> None:
    rows, problems, seen = [], [], set()
    # tus_pares.tsv es el test independiente del usuario: nunca entra al entrenamiento.
    # Lote v1 en data/seeds/*.tsv; lote v4 en data/seeds/v4/*.tsv (curva de aprendizaje por cubetas).
    files = [(p, "v1") for p in sorted(SEEDS.glob("*.tsv")) if not p.name.startswith("tus_")]
    files += [(p, "v4") for p in sorted((SEEDS / "v4").glob("*.tsv"))]
    for path, batch in files:
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if not line.strip() or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) != 4 or parts[0] not in "FMD" or parts[1] not in LABELS:
                problems.append(f"{path.name}:{n} formato: {line[:60]}")
                continue
            diff, lab, premise, hypothesis = parts
            ref = premise if premise.startswith("@") else None
            premise = resolve(premise)
            key = (premise, hypothesis)
            if key in seen:
                problems.append(f"{path.name}:{n} duplicado")
                continue
            seen.add(key)
            if leaks(premise) or leaks(hypothesis):
                side = premise if leaks(premise) else hypothesis
                problems.append(f"{path.name}:{n} se parece al test de pares mínimos: {side[:60]}")
                continue
            rows.append({"batch": batch, "category": path.stem, "difficulty": diff, "label": LABELS[lab], "premise": premise,
                         "hypothesis": hypothesis, "ref": ref})

    # División fija estratificada. Las semillas ya divididas conservan su lado (comparabilidad entre versiones);
    # las nuevas van a dev de forma estable según el hash del par (~20 %).
    out_path = SEEDS / "seeds_v1.jsonl"
    frozen = {}
    if out_path.exists():
        for line in out_path.open(encoding="utf-8"):
            r = json.loads(line)
            frozen[(r["premise"], r["hypothesis"])] = r["split"]
    rng = random.Random(2026)
    strata = defaultdict(list)
    for r in rows:
        strata[(r["category"], r["difficulty"])].append(r)
    if frozen:
        for r in rows:
            key = (r["premise"], r["hypothesis"])
            digest = int(hashlib.md5("	".join(key).encode("utf-8")).hexdigest(), 16)
            r["split"] = frozen.get(key) or ("dev" if digest % 5 == 0 else "train")
            # Cubeta 0-99 independiente del split: 25 % = cubetas < 25, anidadas.
            r["bucket"] = (digest // 5) % 100
    else:
        for group in strata.values():
            rng.shuffle(group)
            k = max(1, round(len(group) * 0.2)) if len(group) >= 3 else 0
            for i, r in enumerate(group):
                r["split"] = "dev" if i < k else "train"
    for i, r in enumerate(rows):
        r["id"] = f"s{i:04d}"
    with out_path.open("w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")

    print(f"Semillas válidas: {len(rows)}  (descartadas: {len(problems)})")
    for p in problems:
        print("  -", p)
    for b in ("v1", "v4"):
        sub = [r for r in rows if r["batch"] == b]
        print(f"Lote {b}: {len(sub)} (train {sum(r['split'] == 'train' for r in sub)}, dev {sum(r['split'] == 'dev' for r in sub)})")
    cats = Counter(r["category"] for r in rows)
    print("\nCategoría        F   M   D  total | E   N   C")
    for c in sorted(cats):
        d = Counter(r["difficulty"] for r in rows if r["category"] == c)
        lab = Counter(r["label"][0].upper() for r in rows if r["category"] == c)
        print(f"{c:15s} {d['F']:3d} {d['M']:3d} {d['D']:3d} {cats[c]:5d} | {lab['E']:3d} {lab['N']:3d} {lab['C']:3d}")
    d = Counter(r["difficulty"] for r in rows)
    lab = Counter(r["label"] for r in rows)
    print(f"{'TOTAL':15s} {d['F']:3d} {d['M']:3d} {d['D']:3d} {len(rows):5d} | "
          f"{lab['entailment']:3d} {lab['neutral']:3d} {lab['contradiction']:3d}")
    print(f"Entrenamiento: {sum(r['split'] == 'train' for r in rows)} · seed-dev: {sum(r['split'] == 'dev' for r in rows)}")
    if "--show-verses" in sys.argv:
        for r in rows:
            if r["ref"]:
                print(f"\n[{r['label'][0].upper()}] {r['ref']}: {r['premise']}\n    → {r['hypothesis']}")


if __name__ == "__main__":
    main()
