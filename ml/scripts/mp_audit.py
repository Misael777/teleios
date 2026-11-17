"""Auditoría del test de pares mínimos: errores de v3a y de mDeBERTa, lado a lado.

    .venv/Scripts/python scripts/mp_audit.py [models/system_one_v3a]

Escribe out/mp_audit.tsv (una fila por par fallado por alguno de los dos) para revisión humana.
El test NO se edita aquí: las decisiones se registran en data/minimal_pairs_audit.json.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from teleios_ml import MODELS, OUT  # noqa: E402
from teleios_ml.minimal_pairs import pairs  # noqa: E402
from teleios_ml.models import HFNliJudge  # noqa: E402
from teleios_ml.system_one import NLI_LABELS, StudentJudge, load  # noqa: E402

MDEBERTA = "MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"


def main() -> None:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else MODELS / "system_one_v3a"
    model, tok, meta = load(path)
    student = StudentJudge(model, tok, meta["temperatures"]["nli"])
    teacher = HFNliJudge(MDEBERTA)
    rows = pairs()
    ps = student([r["a"] for r in rows], [r["b"] for r in rows])
    pt = teacher([r["a"] for r in rows], [r["b"] for r in rows])
    short = {"entailment": "E", "neutral": "N", "contradiction": "C"}
    lines, both = [], 0
    for r, s, t in zip(rows, ps, pt):
        gs, gt = NLI_LABELS[s.argmax()], NLI_LABELS[t.argmax()]
        if gs == r["nli"] and gt == r["nli"]:
            continue
        both += gs != r["nli"] and gt != r["nli"]
        lines.append("\t".join([r["id"], r["category"], short[r["nli"]], short[gs], f"{s.max():.2f}", short[gt], f"{t.max():.2f}",
                                r["a"], r["b"]]))
    OUT.mkdir(exist_ok=True)
    (OUT / "mp_audit.tsv").write_text("id\tcategoria\tetiqueta\talumno\tp_al\tmdeberta\tp_md\tA\tB\n" + "\n".join(lines) + "\n",
                                      encoding="utf-8")
    wrong_s = sum(NLI_LABELS[s.argmax()] != r["nli"] for r, s in zip(rows, ps))
    wrong_t = sum(NLI_LABELS[t.argmax()] != r["nli"] for r, t in zip(rows, pt))
    print(f"errores alumno: {wrong_s} · errores mDeBERTa: {wrong_t} · ambos: {both} · filas: {len(lines)}")


if __name__ == "__main__":
    main()
