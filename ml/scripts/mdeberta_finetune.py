"""v4 · Brazo grande: ajusta mDeBERTa-v3-base (XNLI) con las semillas, para saber si el límite del juez
pequeño es el tamaño del modelo o los datos.

    .venv/Scripts/python scripts/mdeberta_finetune.py [--steps 2500] [--target mdeberta_v4]
        [--base models/mdeberta_v4 --praxis 4 --lr 1e-5 --seed-repeat 10 --synth 10000 --xnli 15000]

Cabe en 4 GB congelando las embeddings de vocabulario (190 M de los 278 M parámetros): se entrenan las capas
de atención y el clasificador, en fp32 con gradient checkpointing. Mezcla: semillas (v1 + v4, split train),
pares sintéticos y XNLI-es para no olvidar.

§13 · --praxis R suma la tarea acción ↔ principio y de temática (data/praxis/praxis_v1.jsonl, split train,
repetida R veces), en el mismo formato NLI que pregunta la app. --base continúa desde un modelo ya ajustado.
"""

import json
import random
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import torch  # noqa: E402
import torch.nn.functional as F  # noqa: E402

from teleios_ml import DATA, MODELS, OUT  # noqa: E402
from teleios_ml.evaluation import evaluate_judge  # noqa: E402
from teleios_ml.models import DEVICE, HFNliJudge  # noqa: E402

def arg(name: str, default):
    return type(default)(sys.argv[sys.argv.index(name) + 1]) if name in sys.argv else default


BASE = arg("--base", "MoritzLaurer/mDeBERTa-v3-base-xnli-multilingual-nli-2mil7")
STEPS = arg("--steps", 2500)
TARGET = MODELS / arg("--target", "mdeberta_v4")
BATCH, ACCUM, SEED = 8, 2, 13
LR = arg("--lr", 1.5e-5)
SEED_REPEAT = arg("--seed-repeat", 20)
PRAXIS_REPEAT = arg("--praxis", 0)
N_SYNTH, N_XNLI = arg("--synth", 15000), arg("--xnli", 20000)


def main() -> None:
    from datasets import load_dataset
    from transformers import AutoModelForSequenceClassification, AutoTokenizer, get_linear_schedule_with_warmup

    random.seed(SEED)
    torch.manual_seed(SEED)
    tok = AutoTokenizer.from_pretrained(BASE)
    # Transformers 5 respeta el dtype guardado: este checkpoint viene en fp16, y AdamW sobre fp16 da NaN.
    model = AutoModelForSequenceClassification.from_pretrained(BASE, dtype=torch.float32)
    lid = {k.lower(): v for k, v in model.config.label2id.items()}
    for p in model.base_model.embeddings.parameters():
        p.requires_grad = False
    model.gradient_checkpointing_enable()
    model.to(DEVICE)

    seeds = [json.loads(line) for line in (DATA / "seeds" / "seeds_v1.jsonl").open(encoding="utf-8")]
    seed_train = [(r["premise"], r["hypothesis"], lid[r["label"]]) for r in seeds if r["split"] == "train"]
    pairs = [json.loads(line) for line in (DATA / "synth_v1" / "pairs.jsonl").open(encoding="utf-8")]
    synth = [(p["premise"], p["hypothesis"], lid[p["label"]]) for p in random.sample(pairs, N_SYNTH)]
    xnli = load_dataset("facebook/xnli", "es")["train"].shuffle(seed=SEED).select(range(N_XNLI))
    names = ["entailment", "neutral", "contradiction"]  # orden de etiquetas de XNLI
    x_train = [(r["premise"], r["hypothesis"], lid[names[r["label"]]]) for r in xnli]
    data = seed_train * SEED_REPEAT + synth + x_train
    if PRAXIS_REPEAT:
        praxis = [json.loads(line) for line in (DATA / "praxis" / "praxis_v1.jsonl").open(encoding="utf-8")]
        data += [(r["premise"], r["hypothesis"], lid[r["label"]]) for r in praxis if r["split"] == "train"] * PRAXIS_REPEAT

    params = [p for p in model.parameters() if p.requires_grad]
    opt = torch.optim.AdamW(params, lr=LR, weight_decay=0.01)
    sched = get_linear_schedule_with_warmup(opt, 150, STEPS)
    print(f"entrenables: {sum(p.numel() for p in params) / 1e6:.0f} M · datos: {len(data)}", flush=True)
    model.train()
    for step in range(1, STEPS + 1):
        for _ in range(ACCUM):
            b = random.sample(data, BATCH)
            enc = tok([x[0] for x in b], [x[1] for x in b], truncation=True, padding=True, max_length=128,
                      return_tensors="pt").to(DEVICE)
            # fp32: DeBERTa-v3 se desestabiliza en bf16/fp16 (pérdida NaN que corrompe los pesos).
            logits = model(**enc).logits.float()
            loss = F.cross_entropy(logits, torch.tensor([x[2] for x in b], device=DEVICE)) / ACCUM
            loss.backward()
        norm = torch.nn.utils.clip_grad_norm_(params, 1.0)
        if not torch.isfinite(norm):
            opt.zero_grad()
            continue
        opt.step()
        sched.step()
        opt.zero_grad()
        if step % 250 == 0:
            print(f"paso {step}: loss {loss.item() * ACCUM:.3f}", flush=True)
    model.eval()
    TARGET.mkdir(parents=True, exist_ok=True)
    model.save_pretrained(TARGET)
    tok.save_pretrained(TARGET)

    judge = HFNliJudge(str(TARGET))
    raw, aud = evaluate_judge(judge), evaluate_judge(judge, audited=True)
    seed_dev = [r for r in seeds if r["split"] == "dev"]
    probs = judge([r["premise"] for r in seed_dev], [r["hypothesis"] for r in seed_dev])
    hits = [names[i] == r["label"] for i, r in zip(probs.argmax(1), seed_dev)]
    report = {
        "base": BASE, "steps": STEPS, "seed_repeat": SEED_REPEAT,
        "minimal_pairs": {k: raw[k] for k in ("paraphrase_join", "opposite_separation", "passes", "by_category")},
        "minimal_pairs_audited": {k: aud[k] for k in ("paraphrase_join", "opposite_separation", "passes")},
        "seed_dev": sum(hits) / len(hits),
    }
    if PRAXIS_REPEAT:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        from praxis_eval import dev_rows, evaluate, test_rows

        report |= {"praxis_repeat": PRAXIS_REPEAT, "lr": LR, "init": BASE,
                   "praxis_test": evaluate(judge, test_rows()), "praxis_dev": evaluate(judge, dev_rows())}
    (OUT / f"report_{TARGET.name}.json").write_text(json.dumps(report, indent=2, ensure_ascii=False), encoding="utf-8")
    print(json.dumps(report, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
