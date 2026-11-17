"""§13 · Semillas de la tarea acción ↔ principio y de temática para el juez grande.

    .venv/Scripts/python scripts/praxis_build.py

Lee data/praxis/principios.tsv y las reacciones (data/praxis/*.tsv, salvo tus_*) y escribe
data/praxis/praxis_v1.jsonl con pares NLI en el mismo formato que pregunta la app (lib/features/ejes/domain/mind_map.dart):

  A (postura):  premisa = reacción · hipótesis = "Esta persona actuó conforme a esto: {principio}"
                E encarna · C viola · N no aplica
  T (temática): premisa = reacción o principio · hipótesis = "Este texto trata sobre {tema}." · E sí · N no

Además de lo escrito a mano genera:
  - N cruzados: cada reacción frente a principios de familias lejanas (no aplica), para que "gasté en una tele"
    no salga como contradicción de "amad a vuestros enemigos";
  - temática positiva desde los temas del principio y los contextos de la reacción, y negativa desde temas de
    familias lejanas.
División fija por reacción (md5 % 5 == 0 → dev). Nada que se parezca a tus_praxis_test.tsv entra.
"""

import hashlib
import json
import random
import sys
from collections import Counter, defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from teleios_ml import DATA  # noqa: E402
from teleios_ml.synth import _ngrams  # noqa: E402

PRAXIS = DATA / "praxis"
LABELS = {"E": "entailment", "N": "neutral", "C": "contradiction"}
# Familias que se tocan: entre ellas no se generan N cruzados ni temas negativos.
ADJ = {
    "REL": {"PAL", "FAM", "HUM", "PRO"}, "PAL": {"REL", "FAM", "VER"}, "VER": {"PAL", "TRA"},
    "DIN": {"PRO", "FAM"}, "PRO": {"REL", "DIN", "HUM"}, "CON": set(), "HUM": {"REL", "PRO", "TRA"},
    "PUR": {"FAM"}, "FAM": {"REL", "PAL", "PUR", "DIN"}, "TRA": {"VER", "HUM"},
}
CONTEXT_THEMES = {
    "familia": ["la familia"], "pareja": ["el matrimonio", "la pareja"], "hijos": ["los hijos", "la familia"],
    "trabajo": ["el trabajo"], "dinero": ["el dinero"], "iglesia": ["la iglesia"], "amigos": ["la amistad"],
    "salud": ["la salud"], "estudio": ["los estudios"], "vecinos": ["los vecinos"], "redes": ["las redes sociales"],
    "calle": [],
}


def topic(theme: str) -> str:
    return f"Este texto trata sobre {theme}."  # = MindMap.topicTemplate


def align(principle: str) -> str:
    return f"Esta persona actuó conforme a esto: {principle}"  # = MindMap.alignTemplate


def bare(theme: str, rng: random.Random) -> str:
    """Los usuarios escriben "amor" tanto como "el amor"."""
    head, _, rest = theme.partition(" ")
    return rest if head in ("el", "la", "los", "las") and rest and rng.random() < 0.4 else theme


def digest(text: str) -> int:
    return int(hashlib.md5(text.encode("utf-8")).hexdigest(), 16)


def main() -> None:
    principles: dict[str, dict] = {}
    for line in (PRAXIS / "principios.tsv").read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        pid, fam, themes, text = line.split("\t")
        p = principles.setdefault(pid, {"family": fam, "themes": themes.split(";"), "texts": []})
        p["texts"].append(text)
    all_themes = {(t, p["family"]) for p in principles.values() for t in p["themes"]}

    test_premises = []
    for line in (PRAXIS / "tus_praxis_test.tsv").read_text(encoding="utf-8").splitlines():
        if line.strip() and not line.startswith("#"):
            test_premises.append(_ngrams(line.split("\t")[3]))

    def leaks(text: str) -> bool:
        g = _ngrams(text)
        return any(len(g & t) / max(1, len(g | t)) > 0.5 for t in test_premises)

    rows, problems, seen = [], [], set()

    def add(task, premise, hypothesis, lab, split, **meta):
        key = (premise, hypothesis)
        if key in seen:
            return
        seen.add(key)
        rows.append({"task": task, "premise": premise, "hypothesis": hypothesis, "label": LABELS[lab],
                     "split": split, **meta})

    reactions = 0
    for path in sorted(PRAXIS.glob("*.tsv")):
        if path.name.startswith("tus_") or path.name == "principios.tsv":
            continue
        for n, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if not line.strip() or line.startswith("#"):
                continue
            parts = line.split("\t")
            if len(parts) != 5 or parts[0] not in principles or parts[1] not in LABELS or parts[2] not in "FMD":
                problems.append(f"{path.name}:{n} formato: {line[:70]}")
                continue
            pid, lab, diff, contexts, text = parts
            if leaks(text):
                problems.append(f"{path.name}:{n} se parece al test: {text[:60]}")
                continue
            reactions += 1
            d = digest(text)
            rng = random.Random(d)
            split = "dev" if d % 5 == 0 else "train"
            p = principles[pid]
            meta = {"principle": pid, "family": p["family"], "difficulty": diff, "source": path.stem}
            # Postura: el principio con cada una de sus formulaciones.
            for t in p["texts"]:
                add("A", text, align(t), lab, split, **meta)
            # N cruzados: dos principios de familias lejanas.
            far = [q for q, v in principles.items() if v["family"] != p["family"] and v["family"] not in ADJ[p["family"]]
                   and p["family"] not in ADJ[v["family"]]]
            for q in rng.sample(far, 2):
                add("A", text, align(rng.choice(principles[q]["texts"])), "N", split, **{**meta, "principle": q, "cross": True})
            # Temática: positivos (temas del principio si la reacción lo toca, y contextos); negativos lejanos.
            ctx = [t for c in contexts.split(";") if c for t in CONTEXT_THEMES.get(c, [])]
            positive = (p["themes"][:2] if lab != "N" else []) + ctx
            for t in positive:
                add("T", text, topic(bare(t, rng)), "E", split, **meta)
            blocked = set(positive) | (set(p["themes"]) if lab != "N" else set()) | set(ctx)
            negatives = [t for t, f in all_themes if t not in blocked and f != p["family"] and f not in ADJ[p["family"]]
                         and t not in {x for c in CONTEXT_THEMES.values() for x in c}]
            for t in rng.sample(sorted(negatives), 2):
                add("T", text, topic(bare(t, rng)), "N", split, **meta)

    # Lado de Cristo: cada formulación de un principio trata de sus temas y no de temas lejanos.
    for pid, p in principles.items():
        for t in p["texts"]:
            rng = random.Random(digest(t))
            if leaks(t):
                problems.append(f"principio {pid} se parece al test: {t[:60]}")
                continue
            for th in p["themes"]:
                add("T", t, topic(bare(th, rng)), "E", "train", principle=pid, family=p["family"], difficulty="M",
                    source="principios")
            far = sorted(th for th, f in all_themes if f != p["family"] and f not in ADJ[p["family"]])
            for th in rng.sample(far, 2):
                add("T", t, topic(bare(th, rng)), "N", "train", principle=pid, family=p["family"], difficulty="M",
                    source="principios")

    out = PRAXIS / "praxis_v1.jsonl"
    with out.open("w", encoding="utf-8", newline="\n") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    count = Counter((r["task"], r["split"], r["label"]) for r in rows)
    print(f"reacciones: {reactions} · pares: {len(rows)} → {out.name}")
    for k in sorted(count):
        print(f"  {k}: {count[k]}")
    per = defaultdict(Counter)
    for r in rows:
        if r["task"] == "A" and not r.get("cross"):
            per[r["principle"]][r["label"][0].upper()] += 1
    thin = [p for p, c in per.items() if c["E"] < 6 or c["C"] < 6]
    if thin:
        print("principios con pocas reacciones E/C:", thin)
    for p in problems:
        print("  !", p)


if __name__ == "__main__":
    main()
