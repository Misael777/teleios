"""S15 · Mapa de patrones antagónicos y nombres propuestos (§11.2 pasos 5-7).

    .venv/Scripts/python scripts/s15_antagonism.py

Repite el grafo con signo con el System One de S14 (embeddings + juez + cabezas PREDICHAS, ya no la
estructura por construcción), mide estabilidad y antagonismo, y propone nombres:
  - con un LLM local si hay servidor (teacher.py);
  - si no, con los nombres que el laboratorio propuso para cada cadena (también de un LLM, offline).
Los nombres quedan "sin confirmar" hasta que una persona revise out/s15_names_review.csv y guarde
data/prototype_names.json ({"<cadena>": {"name": ..., "definition": ...}}).
Escribe out/s15_prototypes.json (lo empaqueta s14_export.py), out/s15_report.json y out/s15_map.png.
"""

import csv
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import matplotlib  # noqa: E402

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
from sklearn.metrics import adjusted_rand_score  # noqa: E402

from teleios_ml import DATA, MODELS, OUT, teacher  # noqa: E402
from teleios_ml.signed_graph import (  # noqa: E402
    correlation_clustering,
    knn_pairs,
    opposite_violations,
    group_relations,
    merge_groups,
    signed_edges,
    stability,
)
from teleios_ml.synth import BY_ID, HEADS, corpus_for_clustering  # noqa: E402
from teleios_ml.system_one import StudentEncoder, StudentJudge, load  # noqa: E402

DEFINITIONS = {
    "control_catastrofe": "Si no controlo cada detalle, todo terminará mal.",
    "confianza_descanso": "Lo que no controlo está en manos de Dios; puedo soltarlo y descansar.",
    "valor_desempeno": "Mi valor como persona sube o baja con mis resultados.",
    "identidad_gracia": "Mi valor viene de ser amado por Dios, no de mi desempeño.",
    "generalizacion_fracaso": "Un fallo se vuelve regla: todo, siempre o nunca sale mal.",
    "realismo_esperanza": "Tengo aciertos y errores, y puedo mejorar.",
    "deber_complacer": "Debo tener contentos a todos o me rechazarán.",
    "libertad_servicio": "Puedo servir sin depender de la aprobación ajena.",
    "castigo_divino": "Toda dificultad es un castigo de Dios por algo que hice.",
    "providencia_bondad": "Dios es bueno conmigo y usa aun lo difícil para bien.",
    "escasez": "Si comparto, me faltará: hay que guardar.",
    "provision_generosidad": "Dios provee; por eso puedo compartir.",
    "culpar_otros": "Cómo me siento y reacciono es culpa de los demás.",
    "responsabilidad_propia": "Soy responsable de cómo respondo, aunque otros fallen.",
}


# --model nombre: carpeta en models/ (por defecto system_one).
MODEL_NAME = sys.argv[sys.argv.index("--model") + 1] if "--model" in sys.argv else "system_one"


def main() -> None:
    model, tok, meta = load(MODELS / MODEL_NAME)
    temps = meta["temperatures"]
    enc = StudentEncoder(model, tok, temps)
    judge = StudentJudge(model, tok, temps["nli"])

    corpus = corpus_for_clustering(per_chain=45, seed=29)
    texts = [c["text"] for c in corpus]
    chains = [c["chain"] for c in corpus]
    out = enc.run(texts)
    emb = out["embedding"]
    predicted = [{k: HEADS[k][int(out[f"{k}_logits"][i].argmax())] for k in HEADS} for i in range(len(texts))]
    head_acc = {k: float(np.mean([p[k] == c[k] for p, c in zip(predicted, corpus)])) for k in HEADS}

    edges = signed_edges(texts, knn_pairs(emb, k=20), judge, structure=predicted)
    labels = correlation_clustering(len(texts), edges)
    stab = stability(len(texts), edges, labels)

    def representatives(lab_list):
        groups = [c for c in sorted(set(lab_list)) if lab_list.count(c) >= 5]
        reps = []
        for c in groups:
            idx = [i for i, lab in enumerate(lab_list) if lab == c]
            cen = emb[idx].mean(0)
            reps.append([texts[i] for i in sorted(idx, key=lambda i: -float(emb[i] @ cen))])
        return groups, reps

    # Relaciones entre prototipos con el juez: unir subgrupos de una misma cadena y medir antagonismo.
    groups, reps = representatives(labels)
    entail, contra = group_relations(reps, judge)
    clusters_before_merge = len(groups)
    labels = merge_groups(labels, groups, entail, contra)
    groups, reps = representatives(labels)
    entail, contra = group_relations(reps, judge)
    anti, used = [], set()
    for i, j in sorted(((i, j) for i in range(len(groups)) for j in range(i + 1, len(groups))), key=lambda p: -contra[p]):
        if contra[i, j] < 0.5 or i in used or j in used:
            continue
        used |= {i, j}
        anti.append((groups[i], groups[j], float(contra[i, j])))
    antagonist_of = {c.id: c.antagonist for c in BY_ID.values()}

    confirmed = {}
    names_file = DATA / "prototype_names.json"
    if names_file.exists():
        confirmed = json.loads(names_file.read_text(encoding="utf-8"))
    use_llm = teacher.available()

    protos, by_cluster = [], {}
    for c in sorted(set(labels)):
        idx = [i for i, lab in enumerate(labels) if lab == c]
        if len(idx) < 5:
            continue
        member_chains = [chains[i] for i in idx]
        majority = max(set(member_chains), key=member_chains.count)
        centroid = emb[idx].mean(0)
        centroid /= np.linalg.norm(centroid)
        structure = {k: max(set(predicted[i][k] for i in idx), key=[predicted[i][k] for i in idx].count)
                     for k in ("agente", "polaridad", "distorsion", "esquema")}
        examples = [texts[i] for i in sorted(idx, key=lambda i: -float(emb[i] @ centroid))[:6]]
        if majority in confirmed:
            name, definition, is_confirmed = confirmed[majority]["name"], confirmed[majority]["definition"], True
        else:
            proposal = teacher.name_prototype(examples, structure) if use_llm else None
            name = proposal["name"] if proposal else BY_ID[majority].name
            definition = proposal["definition"] if proposal else DEFINITIONS[majority]
            is_confirmed = False
        pid = f"p{len(protos):02d}-{majority}"
        by_cluster[c] = pid
        protos.append({"id": pid, "cluster": int(c), "name": name, "definition": definition, "confirmed": is_confirmed,
                       "size": len(idx), "purity": member_chains.count(majority) / len(idx),
                       "stability": round(stab["per_cluster"].get(c, 0.0), 3), "structure": structure,
                       "examples": examples[:3], "centroid": [round(float(x), 5) for x in centroid],
                       "majority_chain": majority})
    for a, b, s in anti:
        pa, pb = by_cluster.get(a), by_cluster.get(b)
        for p in protos:
            if p["id"] == pa:
                p["antagonist"], p["antagonism"] = pb, round(s, 3)
            elif p["id"] == pb:
                p["antagonist"], p["antagonism"] = pa, round(s, 3)

    # Umbral de asignación en el teléfono: el menor coseno con ≥ 90 % de asignaciones a la cadena correcta.
    cents = np.array([p["centroid"] for p in protos])
    sims = emb @ cents.T
    best = sims.argmax(1)
    correct = np.array([protos[b]["majority_chain"] == ch for b, ch in zip(best, chains)])
    top = sims.max(1)
    threshold = 0.95
    for t in np.linspace(0.5, 0.95, 46):
        m = top >= t
        if m.sum() >= 30 and correct[m].mean() >= 0.9:
            threshold = float(t)
            break

    expected = {(min(a, b), max(a, b)) for a, b in antagonist_of.items()}
    found = {tuple(sorted((p["majority_chain"], next(q["majority_chain"] for q in protos if q["id"] == p["antagonist"]))))
             for p in protos if p.get("antagonist")}
    report = {
        "n": len(texts),
        "heads_accuracy_on_corpus": head_acc,
        "clusters_before_merge": clusters_before_merge,
        "clusters": len(protos),
        "ari_vs_chain": adjusted_rand_score(chains, labels),
        "opposite_violations": opposite_violations(labels, chains, antagonist_of),
        "stability": {"ari_mean": stab["ari_mean"], "ari_sd": stab["ari_sd"]},
        "antagonist_pairs_found": len(found),
        "antagonist_pairs_correct": len(found & expected),
        "antagonist_pairs_expected": len(expected),
        "prototype_threshold": threshold,
        "assignment_accuracy_at_threshold": float(correct[top >= threshold].mean()) if (top >= threshold).any() else None,
        "assignment_coverage_at_threshold": float((top >= threshold).mean()),
        "naming": "llm_local" if use_llm else ("confirmado" if confirmed else "propuesto_por_laboratorio"),
    }
    OUT.mkdir(exist_ok=True)
    (OUT / "s15_prototypes.json").write_text(json.dumps({"version": "proto-v1", "threshold": threshold, "prototypes": protos},
                                                        ensure_ascii=False), encoding="utf-8")
    (OUT / "s15_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    with (OUT / "s15_names_review.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["cadena", "nombre_propuesto", "definicion_propuesta", "ejemplos", "estabilidad", "nombre_confirmado", "definicion_confirmada"])
        for p in protos:
            w.writerow([p["majority_chain"], p["name"], p["definition"], " | ".join(p["examples"]), p["stability"], "", ""])

    # Mapa: PCA de los centroides, tamaño = miembros, líneas rojas = antagonismo.
    from sklearn.decomposition import PCA

    xy = PCA(2, random_state=0).fit_transform(cents)
    fig, ax = plt.subplots(figsize=(10, 7))
    pos = {p["id"]: xy[i] for i, p in enumerate(protos)}
    for p in protos:
        if p.get("antagonist") and p["id"] < p["antagonist"]:
            a, b = pos[p["id"]], pos[p["antagonist"]]
            ax.plot([a[0], b[0]], [a[1], b[1]], color="#c0504d", lw=1 + 3 * p["antagonism"], alpha=0.7, zorder=1)
    for i, p in enumerate(protos):
        positive = p["structure"]["polaridad"] == "positiva"
        ax.scatter(*xy[i], s=40 + 8 * p["size"], color="#3c8d4f" if positive else "#7b4fb0", alpha=0.8, zorder=2)
        ax.annotate(p["name"], xy[i], fontsize=8, ha="center", va="bottom", xytext=(0, 8), textcoords="offset points")
    ax.set_title("S15 · Patrones de pensamiento y sus antagonistas (rojo = contradicción)")
    ax.set_xticks([])
    ax.set_yticks([])
    fig.tight_layout()
    fig.savefig(OUT / "s15_map.png", dpi=150)
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
