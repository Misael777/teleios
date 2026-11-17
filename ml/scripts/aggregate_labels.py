"""Agrega exportaciones de etiquetas de varias personas (§10.3).

    .venv/Scripts/python scripts/aggregate_labels.py exportes/*.json

Cada archivo es el JSON de "Etiquetar → Exportar" de la app (id anónimo, sin texto privado).
Escribe out/labels_aggregated.json:
  - α de Krippendorff por tipo de ítem y su veredicto (≥ 0.8 fiable; 0.667-0.8 tentativo);
  - Dawid-Skene: etiqueta posterior (suave) por ítem y fiabilidad estimada de cada persona;
  - acierto en ítems de oro por persona (las de baja fiabilidad se pueden excluir);
  - acuerdo agregado con cada versión del juez (veredictos sobre sus sugerencias).
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from teleios_ml import APP, OUT  # noqa: E402
from teleios_ml.agreement import dawid_skene, gold_accuracy, krippendorff_alpha_nominal, verdict  # noqa: E402


def main(paths: list[str]) -> None:
    items = json.loads((APP / "assets" / "ml" / "shared_items_v1.json").read_text(encoding="utf-8"))["items"]
    kind = {i["id"]: i["type"] for i in items}
    gold = {i["id"]: i["gold"] for i in items if "gold" in i}
    labels, judge = [], defaultdict(lambda: [0, 0])
    for p in paths:
        data = json.loads(Path(p).read_text(encoding="utf-8"))
        for row in data["shared_labels"]:
            labels.append((row["item"], data["annotator"], row["label"]))
        for f in data.get("judge_feedback", []):
            judge[f["judge"]][0] += f["predicted"] == f["user"]
            judge[f["judge"]][1] += 1
    regular = [x for x in labels if x[0] not in gold]
    report = {
        "annotators": len({a for _, a, _ in labels}),
        "labels": len(labels),
        "alpha": {},
        "gold_accuracy": gold_accuracy(labels, gold),
        "judge_agreement": {k: {"agree": a, "n": n, "rate": a / n} for k, (a, n) in judge.items()},
    }
    for t in sorted(set(kind.values())):
        subset = [x for x in regular if kind.get(x[0]) == t]
        a = krippendorff_alpha_nominal(subset)
        report["alpha"][t] = {"alpha": a, "verdict": verdict(a), "n": len(subset)}
    if regular:
        ds = dawid_skene(regular)
        report["dawid_skene"] = {"reliability": ds["reliability"], "posterior": ds["posterior"]}
    OUT.mkdir(exist_ok=True)
    (OUT / "labels_aggregated.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps({k: v for k, v in report.items() if k != "dawid_skene"}, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main(sys.argv[1:])
