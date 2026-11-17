"""S12 · Protocolo de etiquetado (§10) y datos sintéticos (§11.4).

    .venv/Scripts/python scripts/s12_labeling.py

1. Genera data/synth_v1/{thoughts,pairs,triplets}.jsonl (etiquetas por construcción).
2. Escribe app/assets/ml/shared_items_v1.json: ítems compartidos (proposición ↔ versículo y escenarios
   anónimos) con ítems de oro sintéticos intercalados. Ningún ítem viene de diarios.
3. Pre-etiqueta una muestra con el maestro si hay servidor local (teacher.py) y deja
   out/s12_validation_sample.csv para la validación humana.
4. Valida la agregación con etiquetadores simulados: Dawid-Skene vs voto mayoritario, α de Krippendorff.
"""

import csv
import json
import random
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from teleios_ml import APP, DATA, OUT  # noqa: E402
from teleios_ml import bible, teacher  # noqa: E402
from teleios_ml.agreement import dawid_skene, krippendorff_alpha_nominal, verdict  # noqa: E402
from teleios_ml.synth import BY_ID, NEUTRAS, generate, negate, thought  # noqa: E402

VERSION = "shared-v1"

# Interpretaciones frecuentes con su versículo ancla: lo que la comunidad etiqueta (P1).
PROPOSITIONS = [
    ("Dios provee lo necesario a quien confía en él.", "PHI", 4, 19),
    ("La salvación es por gracia, no por obras.", "EPH", 2, 8),
    ("Dios disciplina a los que ama.", "HEB", 12, 6),
    ("Debemos perdonar como Dios nos perdonó.", "COL", 3, 13),
    ("La ansiedad se combate presentando todo a Dios en oración.", "PHI", 4, 6),
    ("Dios obra todas las cosas para bien de los que le aman.", "ROM", 8, 28),
    ("El creyente fiel prosperará económicamente.", "3JO", 1, 2),
    ("Las pruebas producen paciencia y madurez.", "JAM", 1, 3),
    ("Dios no deja de amar a sus hijos cuando fallan.", "ROM", 8, 38),
    ("La fe sin obras está muerta.", "JAM", 2, 17),
    ("El enojo en sí mismo es pecado.", "EPH", 4, 26),
    ("Dios escucha la oración del justo.", "JAM", 5, 16),
    ("El descanso es un mandato de Dios.", "EXO", 20, 8),
    ("La enfermedad es consecuencia del pecado personal.", "JOH", 9, 2),
    ("Dar con generosidad trae bendición.", "2CO", 9, 6),
    ("Hay que someterse a las autoridades.", "ROM", 13, 1),
    ("El temor a Dios es el principio de la sabiduría.", "PRO", 9, 10),
    ("Ningún creyente debería sentir tristeza.", "JOH", 11, 35),
    ("Dios usa la debilidad para mostrar su poder.", "2CO", 12, 9),
    ("Debemos llevar las cargas unos de otros.", "GAL", 6, 2),
]

PROVEE = "Dios provee lo necesario a quien confía en él."
CONTROL = "Dios gobierna lo que no puedo controlar."
VALOR = "Mi valor está en ser hijo de Dios, no en mi desempeño."
AGRADAR = "No necesito agradar a todos; busco agradar a Dios."
RESP = "Soy responsable de cómo respondo."
RECHAZO = "Las dificultades no significan que Dios me rechace."
PERDON = "Debemos perdonar como Dios nos perdonó."
CARGAS = "Debemos llevar las cargas unos de otros."
DESCANSO = "El descanso es un mandato de Dios."

SCENARIOS = [
    ("Alguien deja de diezmar por miedo a que no le alcance el mes.", PROVEE),
    ("Alguien comparte su comida con un vecino aunque tiene poco.", PROVEE),
    ("Alguien revisa diez veces el trabajo de su equipo y no delega nada.", CONTROL),
    ("Alguien entrega a Dios en oración una decisión difícil y duerme tranquilo.", CONTROL),
    ("Alguien se insulta a sí mismo después de equivocarse en una presentación.", VALOR),
    ("Alguien acepta una corrección en el trabajo sin sentirse menos.", VALOR),
    ("Alguien dice que sí a todos los pedidos de la iglesia aunque está agotado.", AGRADAR),
    ("Alguien rechaza con amabilidad un compromiso extra para descansar.", AGRADAR),
    ("Alguien culpa a su esposa de su mal humor durante toda la semana.", RESP),
    ("Alguien pide perdón por haber gritado, sin excusarse.", RESP),
    ("Alguien cree que su enfermedad es castigo y deja de ir a la iglesia.", RECHAZO),
    ("Alguien ora agradeciendo a Dios en medio de un diagnóstico difícil.", RECHAZO),
    ("Alguien perdona a un amigo que le falló y lo invita a cenar.", PERDON),
    ("Alguien guarda rencor durante años por una ofensa pequeña.", PERDON),
    ("Alguien sale a caminar por el parque un sábado.", PERDON),
    ("Alguien organiza su escritorio antes de empezar el día.", PROVEE),
    ("Alguien ayuda a un compañero cargado de trabajo sin que se lo pidan.", CARGAS),
    ("Alguien ignora a un amigo que atraviesa un duelo para no complicarse.", CARGAS),
    ("Alguien se toma el domingo para descansar y estar con su familia.", DESCANSO),
    ("Alguien trabaja todos los días sin pausa porque siente que si para, todo fallará.", DESCANSO),
]

NLI_OPTIONS = {"entailment": "La confirma", "neutral": "No tiene que ver / neutral", "contradiction": "La contradice"}
SCENARIO_OPTIONS = {"desde": "Actúa desde esa creencia", "neutral": "No se relaciona", "contra": "Actúa contra ella"}


def write_jsonl(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


def shared_items(rng: random.Random) -> list[dict]:
    items = []
    for k, (prop, book, ch, vs) in enumerate(PROPOSITIONS):
        anchor = bible.verse_id(book, ch, vs)
        targets = [anchor] + [dst for dst, _ in bible.crossrefs(anchor, limit=6) if bible.text(dst).strip()][:2]
        for j, vid in enumerate(targets):
            items.append({
                "id": f"p{k:02d}v{j}",
                "type": "nli",
                "prompt": "¿Este versículo confirma, contradice o es neutral frente a la interpretación?",
                "a": prop,
                "b": f"{bible.text(vid)} ({bible.label(vid)})",
                "options": NLI_OPTIONS,
            })
    for k, (scene, belief) in enumerate(SCENARIOS):
        items.append({
            "id": f"s{k:02d}",
            "type": "escenario",
            "prompt": "¿Cómo actúa esta persona respecto de la creencia?",
            "a": scene,
            "b": belief,
            "options": SCENARIO_OPTIONS,
        })
    # Ítems de oro: respuesta conocida por construcción (paráfrasis, negación explícita, otra cadena).
    for k in range(15):
        c = BY_ID[rng.choice(list(BY_ID))]
        slot = rng.choice(["mi trabajo", "mi familia", "la iglesia", "mis estudios"]) if "{dom}" in c.templates[0][0] else "mi dinero"
        i, j = rng.sample(range(len(c.templates)), 2)
        a = thought(c, i, slot, rng, prefix=False)["text"]
        kind = ["entailment", "contradiction", "neutral"][k % 3]
        b = {
            "entailment": thought(c, j, slot, rng, prefix=False)["text"],
            "contradiction": negate(a),
            "neutral": rng.choice(NEUTRAS).replace("{dom}", slot),
        }[kind]
        items.append({
            "id": f"g{k:02d}",
            "type": "nli",
            "prompt": "¿El segundo pensamiento confirma, contradice o es neutral frente al primero?",
            "a": a,
            "b": b,
            "options": NLI_OPTIONS,
            "gold": kind,
        })
    return items


def simulate_aggregation(rng: random.Random) -> dict:
    """30 ítems, 12 etiquetadores (3 descuidados): Dawid-Skene debe recuperar mejor la verdad que el voto."""
    cats = ["entailment", "neutral", "contradiction"]
    truth = {f"i{k}": rng.choice(cats) for k in range(30)}
    acc = {f"a{k}": (0.9 if k < 9 else 0.4) for k in range(12)}
    labels = []
    for it, t in truth.items():
        for an, p in acc.items():
            if rng.random() < 0.7:
                labels.append((it, an, t if rng.random() < p else rng.choice([c for c in cats if c != t])))
    ds = dawid_skene(labels)
    ds_hits = sum(max(ds["posterior"][i], key=ds["posterior"][i].get) == t for i, t in truth.items())
    votes = {}
    for it, _, lab in labels:
        votes.setdefault(it, Counter())[lab] += 1
    mv_hits = sum(votes[i].most_common(1)[0][0] == t for i, t in truth.items())
    alpha = krippendorff_alpha_nominal(labels)
    return {"dawid_skene_accuracy": ds_hits / 30, "majority_accuracy": mv_hits / 30, "alpha": alpha,
            "alpha_verdict": verdict(alpha),
            "reliability_careful": sum(ds["reliability"][f"a{k}"] for k in range(9)) / 9,
            "reliability_careless": sum(ds["reliability"][f"a{k}"] for k in range(9, 12)) / 3}


def main() -> None:
    rng = random.Random(2026)
    data = generate()
    out_dir = DATA / "synth_v1"
    for name, rows in data.items():
        write_jsonl(out_dir / f"{name}.jsonl", rows)

    items = shared_items(rng)
    asset = APP / "assets" / "ml" / "shared_items_v1.json"
    asset.write_text(json.dumps({"version": VERSION, "items": items}, ensure_ascii=False, indent=1), encoding="utf-8")

    OUT.mkdir(exist_ok=True)
    sample = rng.sample(data["thoughts"], 60)
    has_teacher = teacher.available()
    with (OUT / "s12_validation_sample.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["texto", "cadena", "esquema", "agente", "polaridad", "modalidad", "distorsion", "maestro", "acuerdo_humano(s/n)"])
        agree = []
        for t in sample:
            pred = teacher.label_heads(t["text"]) if has_teacher else None
            if pred:
                agree.append(sum(pred.get(h) == t[h] for h in pred) / len(pred))
            w.writerow([t["text"], t["chain"], t["esquema"], t["agente"], t["polaridad"], t["modalidad"], t["distorsion"],
                        json.dumps(pred, ensure_ascii=False) if pred else "", ""])

    report = {
        "synth": {k: len(v) for k, v in data.items()},
        "pair_labels": dict(Counter(p["label"] for p in data["pairs"])),
        "shared_items": dict(Counter(i["type"] + ("-oro" if "gold" in i else "") for i in items)),
        "teacher": {"available": has_teacher, "agreement_with_construction": (sum(agree) / len(agree)) if agree else None},
        "aggregation_simulation": simulate_aggregation(rng),
    }
    (OUT / "s12_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
