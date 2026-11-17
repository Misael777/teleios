"""S14 · Exporta el System One para el teléfono (corre después de s15_antagonism.py).

    .venv/Scripts/python scripts/s14_export.py

Genera out/bundle/ y out/teleios-system-one-<versión>.zip con:
  manifest.json          versión, cabezas + temperaturas, umbrales, tarjeta del gráfico 8
  system_one.int8.onnx   opset 17, IR 8 (ONNX Runtime 1.15 del plugin de Flutter), pesos int8
  sentencepiece.tsv      vocabulario Unigram para el tokenizador en Dart
  tokenizer_cases.tsv    casos de paridad (test/infrastructure/unigram_tokenizer_test.dart)
  verses.i8 / verse_ids.u32   embeddings de los 31 102 versículos (int8) para la recuperación canónica
  prototypes.json        catálogo de patrones con antagonistas (S15)
"""

import json
import sys
import zipfile
from datetime import date
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import numpy as np  # noqa: E402
import torch  # noqa: E402

from teleios_ml import MODELS, OUT, bible  # noqa: E402
from teleios_ml.evaluation import evaluate_judge  # noqa: E402
from teleios_ml.synth import HEADS  # noqa: E402
from teleios_ml.system_one import NLI_LABELS, OnnxWrapper, StudentEncoder, load  # noqa: E402

VERSION = f"s1-{date.today():%Y.%m.%d}" + ("" if "--model" not in sys.argv else "-" + sys.argv[sys.argv.index("--model") + 1].replace("system_one_", ""))
BUNDLE = OUT / "bundle"

CASES = [
    "Dios provee lo necesario a quien confía en él.",
    "Si no controlo todo, todo sale mal.",
    "No es cierto que siempre arruino mi matrimonio.",
    "¿Qué vas a hacer distinto mañana?",
    "Mansedumbre, templanza: contra tales cosas no hay ley.",
    "Aunque ande en valle de sombra de muerte, no temeré mal alguno.",
    "Él es el Alfa y la Omega: 1 Juan 4:8, Romanos 8:28 — ¡ánimo!",
    "Ñandú, pingüino, acción, corazón, Jehová, Señor.",
]


def export_onnx(model, tok, path: Path) -> None:
    import onnx
    from onnxruntime.quantization import QuantType, quantize_dynamic

    wrapper = OnnxWrapper(model.float().cpu().eval())
    sample = tok(["query: hola mundo"], return_tensors="pt")
    fp32 = path.with_name("system_one.fp32.onnx")
    torch.onnx.export(
        wrapper,
        (sample["input_ids"], sample["attention_mask"]),
        str(fp32),
        input_names=["input_ids", "attention_mask"],
        output_names=OnnxWrapper.OUTPUTS,
        dynamic_axes={"input_ids": {0: "batch", 1: "seq"}, "attention_mask": {0: "batch", 1: "seq"},
                      **{o: {0: "batch"} for o in OnnxWrapper.OUTPUTS}},
        opset_version=17,
        dynamo=False,
    )
    m = onnx.load(str(fp32))
    m.ir_version = 8  # ONNX Runtime 1.15 acepta hasta IR 9
    onnx.save(m, str(fp32))
    # Por canal y solo MatMul/Gather del codificador: las cabezas (pocos parámetros) quedan en fp32.
    graph = onnx.load(str(fp32)).graph
    heads = [n.name for n in graph.node if n.op_type in ("MatMul", "Gemm")
             and any(k in n.name for k in ("classifier", "heads", "nli_on_cls", "out_proj"))]
    quantize_dynamic(str(fp32), str(path), weight_type=QuantType.QInt8, per_channel=True,
                     op_types_to_quantize=["MatMul", "Gather"], nodes_to_exclude=heads)
    q = onnx.load(str(path))
    q.ir_version = 8
    onnx.save(q, str(path))
    fp32.unlink()


def check_onnx(path: Path, model, tok) -> float:
    import onnxruntime as ort

    sess = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
    texts = ["query: " + t for t in CASES]
    enc = tok(texts, padding=True, return_tensors="np")
    onnx_out = sess.run(None, {"input_ids": enc["input_ids"].astype(np.int64), "attention_mask": enc["attention_mask"].astype(np.int64)})
    with torch.no_grad():
        ref = model.float().cpu()(torch.tensor(enc["input_ids"]), torch.tensor(enc["attention_mask"]))["embedding"].numpy()
    return float(np.mean(np.sum(onnx_out[0] * ref, 1)))  # coseno medio int8 vs fp32


class OnnxJudge:
    """El modelo int8 exportado como juez: lo que realmente correrá en el teléfono."""

    def __init__(self, path: Path, tok, temperature: float):
        import onnxruntime as ort

        self.sess = ort.InferenceSession(str(path), providers=["CPUExecutionProvider"])
        self.tok, self.t = tok, temperature

    def __call__(self, premises, hypotheses):
        out = []
        for i in range(0, len(premises), 32):
            e = self.tok(list(premises[i : i + 32]), list(hypotheses[i : i + 32]), truncation=True, padding=True,
                         max_length=128, return_tensors="np")
            logits = self.sess.run(["nli_logits"], {"input_ids": e["input_ids"].astype(np.int64),
                                                    "attention_mask": e["attention_mask"].astype(np.int64)})[0]
            z = logits / self.t
            z = np.exp(z - z.max(1, keepdims=True))
            out.append(z / z.sum(1, keepdims=True))
        return np.concatenate(out)


# --model nombre: carpeta en models/ (por defecto system_one).
MODEL_NAME = sys.argv[sys.argv.index("--model") + 1] if "--model" in sys.argv else "system_one"


def main() -> None:
    BUNDLE.mkdir(parents=True, exist_ok=True)
    model, tok, meta = load(MODELS / MODEL_NAME)
    temps = meta["temperatures"]
    report = OUT / ("s14_report.json" if MODEL_NAME == "system_one" else f"s14_report_{MODEL_NAME}.json")
    s14 = json.loads(report.read_text(encoding="utf-8"))
    s15_path = OUT / "s15_prototypes.json"
    s15 = json.loads(s15_path.read_text(encoding="utf-8")) if s15_path.exists() else None
    s11 = json.loads((OUT / "s11_baseline.json").read_text(encoding="utf-8"))

    # 1. Embeddings de versículos (antes de pasar el modelo a CPU para ONNX).
    verses = [(vid, t) for vid, t in bible.all_verses() if t.strip()]
    # El alumno se entrenó solo con el prefijo "query: ": se usa también para los versículos.
    enc = StudentEncoder(model, tok, temps, prefix="query: ")
    vecs = enc([t for _, t in verses])
    (BUNDLE / "verses.i8").write_bytes(np.clip(np.round(vecs * 127), -127, 127).astype(np.int8).tobytes())
    (BUNDLE / "verse_ids.u32").write_bytes(np.array([v for v, _ in verses], dtype="<u4").tobytes())

    # 2. Vocabulario y casos de paridad del tokenizador.
    vocab = json.loads(tok.backend_tokenizer.to_str())["model"]["vocab"]
    with (BUNDLE / "sentencepiece.tsv").open("w", encoding="utf-8", newline="\n") as f:
        for piece, score in vocab:
            f.write("#\n" if ("\n" in piece or "\r" in piece) else f"{piece}\t{score}\n")
    with (BUNDLE / "tokenizer_cases.tsv").open("w", encoding="utf-8", newline="\n") as f:
        for t in CASES:
            f.write(f"{t}\t{' '.join(map(str, tok(t, truncation=True, max_length=512)['input_ids']))}\n")

    # 3. Prototipos (centroides en el espacio final).
    files = {"model": "system_one.int8.onnx", "vocab": "sentencepiece.tsv", "verse_vectors": "verses.i8",
             "verse_ids": "verse_ids.u32"}
    if s15:
        (BUNDLE / "prototypes.json").write_text(json.dumps({"version": s15["version"], "prototypes": [
            {k: p[k] for k in ("id", "name", "definition", "centroid", "examples", "stability", "structure", "confirmed")}
            | {"antagonist": p.get("antagonist")} for p in s15["prototypes"]]}, ensure_ascii=False), encoding="utf-8")
        files["prototypes"] = "prototypes.json"

    # 4. ONNX int8 y verificación contra PyTorch.
    onnx_path = BUNDLE / files["model"]
    export_onnx(model, tok, onnx_path)
    fidelity = check_onnx(onnx_path, model, tok)
    int8 = evaluate_judge(OnnxJudge(onnx_path, tok, temps["nli"]))

    base = s11["judges"]["MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7"]
    student = s14["judges"]["system_one"]
    manifest = {
        "id": "system-one",
        "version": VERSION,
        "encoder": f"{meta['encoder']} (ajustado: NLI + cabezas + contrastivo)",
        "max_length": 128,
        "embedding_dim": int(vecs.shape[1]),
        "query_prefix": "query: ",
        "passage_prefix": "query: ",
        # La validación (sintético + XNLI) es más fácil que el uso real: piso conservador de 0.9.
        "route_threshold": max(0.9, s14["route_threshold"]),
        "prototype_threshold": s15["threshold"] if s15 else 0.6,
        "heads": {"nli": {"labels": NLI_LABELS, "temperature": temps["nli"]},
                  **{k: {"labels": v, "temperature": temps[k]} for k, v in HEADS.items()}},
        "files": files,
        "card": {
            # Medido sobre el ONNX int8 exportado (lo que corre en el teléfono), no sobre PyTorch.
            "minimal_pairs": {k: int8[k] for k in ("paraphrase_join", "opposite_separation", "other_neutral", "passes", "by_category")},
            "minimal_pairs_fp32": {k: student[k] for k in ("paraphrase_join", "opposite_separation", "passes")},
            "baseline": {k: base[k] for k in ("paraphrase_join", "opposite_separation")},
            "calibration": {k: s14["calibration"]["nli"][k] for k in ("ece", "brier", "accuracy")},
            "xnli_val_accuracy": student.get("xnli_val_accuracy"),
            "route_coverage": s14["route_coverage"],
            "onnx_int8_cosine_vs_fp32": fidelity,
            "license_note": "Base: multilingual-e5-small (MIT). Datos: XNLI (CC BY-NC 4.0) — revisar para uso comercial.",
        },
    }
    (BUNDLE / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    zpath = OUT / f"teleios-system-one-{VERSION}.zip"
    with zipfile.ZipFile(zpath, "w", zipfile.ZIP_DEFLATED) as z:
        for f in sorted(BUNDLE.iterdir()):
            z.write(f, f.name)
    print(json.dumps({"zip": str(zpath), "mb": round(zpath.stat().st_size / 1e6, 1), "onnx_cosine": fidelity,
                      "minimal_pairs_int8": {k: int8[k] for k in ("paraphrase_join", "opposite_separation", "passes")},
                      "files": {f.name: round(f.stat().st_size / 1e6, 2) for f in BUNDLE.iterdir()}}, indent=2))


if __name__ == "__main__":
    main()
