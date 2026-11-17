"""Camino (b) · ¿Cabe mDeBERTa en el teléfono? Recorta el vocabulario a español, exporta a ONNX int8 y mide.

    .venv/Scripts/python scripts/mdeberta_trim.py [--model mdeberta_v4]

1. Cuenta qué piezas del vocabulario (251 000, 192 M de parámetros en embeddings) aparecen en un corpus en
   español: XNLI-es completo, sintéticos, semillas, tus pares, pares mínimos y la RV1909. Conserva esas, los
   especiales, los bytes de respaldo y todas las piezas de un carácter.
2. Guarda models/<model>_es (HF) y comprueba que el recorte no cambia las predicciones.
3. Exporta a ONNX (opset 17, IR 8) y cuantiza solo los pesos a int8 por canal (DequantizeLinear → MatMul en
   fp32). La cuantización dinámica (activaciones int8) destruye a DeBERTa: sus FFN tienen activaciones atípicas
   enormes y con int8 por tensor el acuerdo con fp32 cae al 15–30 %.
4. Evalúa el int8 (lo que correría en el teléfono): pares mínimos crudos y auditados, seed-dev, registros, y
   mide tamaño y latencia en CPU.
"""

import json
import sys
import time
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parent))

import numpy as np  # noqa: E402
import torch  # noqa: E402

from teleios_ml import DATA, MODELS, OUT, bible, minimal_pairs  # noqa: E402
from teleios_ml.evaluation import evaluate_judge  # noqa: E402
from teleios_ml.models import HFNliJudge  # noqa: E402
from teleios_ml.system_one import NLI_LABELS  # noqa: E402

from user_pairs_eval import parse  # noqa: E402

NAME = sys.argv[sys.argv.index("--model") + 1] if "--model" in sys.argv else "mdeberta_v4"
SRC, DST = MODELS / NAME, MODELS / f"{NAME}_es"


def corpus() -> list[str]:
    from datasets import load_dataset

    texts = []
    for split in load_dataset("facebook/xnli", "es").values():
        texts += list(split["premise"]) + list(split["hypothesis"])
    for name in ("pairs.jsonl", "triplets.jsonl", "thoughts.jsonl"):
        for line in (DATA / "synth_v1" / name).open(encoding="utf-8"):
            texts += [v for v in json.loads(line).values() if isinstance(v, str)]
    for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8"):
        r = json.loads(line)
        texts += [r["premise"], r["hypothesis"]]
    texts += [t for r in parse(DATA / "seeds" / "tus_pares.tsv") for t in (r["premise"], r["hypothesis"])]
    praxis = DATA / "praxis" / "praxis_v1.jsonl"
    if praxis.exists():
        texts += [t for line in praxis.open(encoding="utf-8") for t in json.loads(line).values() if isinstance(t, str)]
    texts += sorted(minimal_pairs.sentences())
    texts += [t for _, t in bible.all_verses()]
    return texts


def trim():
    from transformers import AutoModelForSequenceClassification, AutoTokenizer

    tok = AutoTokenizer.from_pretrained(SRC)
    spec = json.loads(tok.backend_tokenizer.to_str())
    vocab = spec["model"]["vocab"]
    counts = Counter()
    texts = corpus()
    for i in range(0, len(texts), 4096):
        for ids in tok(texts[i : i + 4096], add_special_tokens=False)["input_ids"]:
            counts.update(ids)
    keep = [i for i, (piece, _) in enumerate(vocab)
            if i < 4 or piece.startswith("<0x") or piece.startswith("[") or len(piece) == 1 or counts[i] > 0]
    old2new = {o: n for n, o in enumerate(keep)}
    assert all(old2new[i] == i for i in range(4)), "los especiales deben conservar su id"

    spec["model"]["vocab"] = [vocab[i] for i in keep]
    # [MASK] (250101) vive fuera del vocabulario Unigram y no hace falta para clasificar: se descarta.
    spec["added_tokens"] = [{**t, "id": old2new[t["id"]]} for t in spec.get("added_tokens", []) if t["id"] in old2new]
    for v in spec["post_processor"].get("special_tokens", {}).values():
        v["ids"] = [old2new[i] for i in v["ids"]]
    DST.mkdir(parents=True, exist_ok=True)
    tok.save_pretrained(DST)
    (DST / "tokenizer.json").write_text(json.dumps(spec, ensure_ascii=False), encoding="utf-8")
    cfg = json.loads((DST / "tokenizer_config.json").read_text(encoding="utf-8"))
    cfg.pop("mask_token", None)
    for k, v in cfg.get("added_tokens_decoder", {}).copy().items():
        cfg["added_tokens_decoder"].pop(k)
        if int(k) in old2new:
            cfg["added_tokens_decoder"][str(old2new[int(k)])] = v
    (DST / "tokenizer_config.json").write_text(json.dumps(cfg, indent=2, ensure_ascii=False), encoding="utf-8")

    model = AutoModelForSequenceClassification.from_pretrained(SRC, dtype=torch.float32)
    emb = model.get_input_embeddings()
    new = torch.nn.Embedding(len(keep), emb.weight.shape[1], padding_idx=0)
    new.weight.data = emb.weight.data[torch.tensor(keep)].clone()
    model.set_input_embeddings(new)
    model.config.vocab_size = len(keep)
    model.save_pretrained(DST)

    # Paridad del tokenizador recortado: misma segmentación (ids remapeados) en todo el corpus de evaluación.
    tok2 = AutoTokenizer.from_pretrained(DST)
    sample = texts[-40000:]
    a = tok(sample, add_special_tokens=False)["input_ids"]
    b = tok2(sample, add_special_tokens=False)["input_ids"]
    same = sum([old2new.get(x, -1) for x in u] == v for u, v in zip(a, b)) / len(sample)
    params = sum(p.numel() for p in model.parameters())
    return {"vocab_before": len(vocab), "vocab_after": len(keep), "params_after_M": round(params / 1e6, 1),
            "tokenizer_parity": same, "corpus_texts": len(texts)}


class OnnxNli:
    def __init__(self, path: Path, tok, threads: int = 0):
        import onnxruntime as ort

        opts = ort.SessionOptions()
        if threads:
            opts.intra_op_num_threads = threads
        self.sess = ort.InferenceSession(str(path), opts, providers=["CPUExecutionProvider"])
        self.tok = tok
        labels = {v.lower(): int(k) for k, v in json.loads((DST / "config.json").read_text())["id2label"].items()}
        self.order = [labels[x] for x in NLI_LABELS]

    def __call__(self, premises, hypotheses, batch=32):
        out = []
        for i in range(0, len(premises), batch):
            e = self.tok(list(premises[i : i + batch]), list(hypotheses[i : i + batch]), truncation=True,
                         padding=True, max_length=128, return_tensors="np")
            z = self.sess.run(None, {"input_ids": e["input_ids"].astype(np.int64),
                                     "attention_mask": e["attention_mask"].astype(np.int64)})[0][:, self.order]
            z = np.exp(z - z.max(1, keepdims=True))
            out.append(z / z.sum(1, keepdims=True))
        return np.concatenate(out)


def export():
    import onnx
    from onnxruntime.quantization import QuantType, quantize_dynamic
    from transformers import AutoModelForSequenceClassification, AutoTokenizer

    tok = AutoTokenizer.from_pretrained(DST)
    model = AutoModelForSequenceClassification.from_pretrained(DST, dtype=torch.float32).eval()

    class Wrapper(torch.nn.Module):
        def __init__(self, m):
            super().__init__()
            self.m = m

        def forward(self, input_ids, attention_mask):
            return self.m(input_ids=input_ids, attention_mask=attention_mask).logits

    s = tok(["Dios provee."], ["El Señor da lo necesario."], return_tensors="pt")
    fp32, int8 = DST / "model.fp32.onnx", DST / "nli.int8.onnx"
    torch.onnx.export(Wrapper(model), (s["input_ids"], s["attention_mask"]), str(fp32),
                      input_names=["input_ids", "attention_mask"], output_names=["logits"],
                      dynamic_axes={"input_ids": {0: "batch", 1: "seq"}, "attention_mask": {0: "batch", 1: "seq"},
                                    "logits": {0: "batch"}},
                      opset_version=17, dynamo=False)
    m = onnx.load(str(fp32))
    m.ir_version = 8
    onnx.save(m, str(fp32))
    # Embeddings: Gather int8 (sin pérdida medible). MatMul: pesos int8 por columna + DequantizeLinear.
    quantize_dynamic(str(fp32), str(int8), weight_type=QuantType.QInt8, per_channel=True, op_types_to_quantize=["Gather"])
    q = onnx.load(str(int8))
    weight_only(q)
    q.ir_version = 8
    onnx.save(q, str(int8))
    return tok, fp32, int8


def weight_only(m) -> None:
    from onnx import helper, numpy_helper

    inits = {i.name: i for i in m.graph.initializer}
    nodes = []
    for n in m.graph.node:
        w = next((x for x in n.input if x in inits), None) if n.op_type == "MatMul" else None
        arr = numpy_helper.to_array(inits[w]) if w else None
        if arr is None or arr.ndim != 2 or "classifier" in n.name or "pooler" in n.name:
            nodes.append(n)
            continue
        scale = (np.abs(arr).max(0) / 127).clip(1e-12).astype(np.float32)
        qw = np.clip(np.round(arr / scale), -127, 127).astype(np.int8)
        m.graph.initializer.remove(inits[w])
        m.graph.initializer.extend([numpy_helper.from_array(qw, w + "_q"), numpy_helper.from_array(scale, w + "_s"),
                                    numpy_helper.from_array(np.zeros_like(scale, dtype=np.int8), w + "_z")])
        nodes.append(helper.make_node("DequantizeLinear", [w + "_q", w + "_s", w + "_z"], [w], axis=1, name=w + "_dq"))
        nodes.append(n)
    del m.graph.node[:]
    m.graph.node.extend(nodes)


def score(judge, seed_dev, regs) -> dict:
    raw, aud = evaluate_judge(judge), evaluate_judge(judge, audited=True)
    p = judge([r["premise"] for r in seed_dev], [r["hypothesis"] for r in seed_dev]).argmax(1)
    q = judge([r["premise"] for r in regs], [r["hypothesis"] for r in regs]).argmax(1)
    return {"mp_raw": [raw["paraphrase_join"], raw["opposite_separation"]],
            "mp_audited": [round(aud["paraphrase_join"], 3), round(aud["opposite_separation"], 3)],
            "passes_raw": raw["passes"],
            "seed_dev": round(float(np.mean([NLI_LABELS[i] == r["label"] for i, r in zip(p, seed_dev)])), 3),
            "registers": round(float(np.mean([NLI_LABELS[i] == r["label"] for i, r in zip(q, regs)])), 3)}


def main() -> None:
    # --skip-trim: reutiliza models/<model>_es (el recorte es determinista y ya se verificó).
    report = {"model": NAME, "trim": trim() if "--skip-trim" not in sys.argv else "reutilizado"}
    print(json.dumps(report, indent=2), flush=True)
    seeds = [json.loads(line) for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8")]
    seed_dev = [r for r in seeds if r["split"] == "dev"]
    regs = parse(DATA / "seeds" / "tus_pares.tsv")
    if "--skip-trim" not in sys.argv:
        report["hf_full"] = score(HFNliJudge(str(SRC)), seed_dev, regs)
        report["hf_trimmed"] = score(HFNliJudge(str(DST)), seed_dev, regs)
    print(json.dumps(report, indent=2), flush=True)
    torch.cuda.empty_cache()

    tok, fp32, int8 = export()
    report["size_MB"] = {"fp32_onnx": round(fp32.stat().st_size / 1e6), "int8_onnx": round(int8.stat().st_size / 1e6)}
    fp32.unlink()
    judge = OnnxNli(int8, tok)
    report["onnx_int8"] = score(judge, seed_dev, regs)

    # Latencia de un par (lo que hace la app al juzgar una creencia frente a otra), 4 hilos como un teléfono.
    lat = OnnxNli(int8, tok, threads=4)
    p, h = "Si no controlo todo, todo sale mal en mi casa.", "Puedo soltar el control y confiar en Dios."
    for _ in range(3):
        lat([p], [h])
    t = time.perf_counter()
    for _ in range(20):
        lat([p], [h])
    report["latency_ms_pair_4threads_pc"] = round((time.perf_counter() - t) / 20 * 1000, 1)
    import psutil

    report["process_rss_MB"] = round(psutil.Process().memory_info().rss / 1e6)
    if "--skip-trim" in sys.argv:
        prev = OUT / f"report_{NAME}_es.json"
        old = json.loads(prev.read_text(encoding="utf-8")) if prev.exists() else {}
        report = {**{k: old[k] for k in ("trim", "hf_full", "hf_trimmed") if k in old}, **{k: v for k, v in report.items() if k != "trim"}}
    (OUT / f"report_{NAME}_es.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
