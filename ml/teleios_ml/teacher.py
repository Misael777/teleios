"""Maestro (§11.4 paso 2): un LLM pre-etiqueta esquema, agente, polaridad, modalidad y distorsión.

Por defecto apunta a un servidor local compatible con OpenAI (p. ej. `llama-server` de llama.cpp con un
modelo de 3-4B en Q4, que cabe en la RTX 3050 Ti de 4 GB). Solo ve datos sintéticos e ítems
compartidos: nunca diarios. Si no hay servidor, `available()` es False y los scripts lo omiten.

    llama-server -m qwen2.5-3b-instruct-q4_k_m.gguf -ngl 99 --port 8080
    set TELEIOS_TEACHER_URL=http://127.0.0.1:8080/v1
"""

from __future__ import annotations

import json
import os
import urllib.request

from .synth import HEADS

URL = os.environ.get("TELEIOS_TEACHER_URL", "http://127.0.0.1:8080/v1")
MODEL = os.environ.get("TELEIOS_TEACHER_MODEL", "local")

SYSTEM = (
    "Eres un anotador de estructuras de razonamiento en español. Para cada pensamiento devuelves JSON "
    "con las claves exactas y solo los valores permitidos. Sin explicaciones."
)


def available(timeout: float = 2.0) -> bool:
    try:
        with urllib.request.urlopen(f"{URL}/models", timeout=timeout) as r:
            return r.status == 200
    except Exception:
        return False


def _ask(prompt: str, timeout: float = 120) -> str:
    body = json.dumps({
        "model": MODEL,
        "temperature": 0,
        "response_format": {"type": "json_object"},
        "messages": [{"role": "system", "content": SYSTEM}, {"role": "user", "content": prompt}],
    }).encode()
    req = urllib.request.Request(f"{URL}/chat/completions", body, {"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.loads(r.read())["choices"][0]["message"]["content"]


def label_heads(text: str) -> dict | None:
    allowed = "\n".join(f"- {h}: {', '.join(v)}" for h, v in HEADS.items())
    prompt = f"Pensamiento: «{text}»\nValores permitidos:\n{allowed}\nResponde con un objeto JSON con esas 5 claves."
    try:
        out = json.loads(_ask(prompt))
    except Exception:
        return None
    return {h: out.get(h) for h in HEADS if out.get(h) in HEADS[h]} or None


def name_prototype(examples: list[str], structure: dict[str, str]) -> dict | None:
    """Propone nombre y definición de un patrón (§11.2 paso 6). Una persona lo confirma después."""
    prompt = (
        "Estos pensamientos siguen la misma cadena de razonamiento:\n"
        + "\n".join(f"- {e}" for e in examples[:8])
        + f"\nEstructura dominante: {json.dumps(structure, ensure_ascii=False)}\n"
        'Devuelve JSON {"name": "<máx. 5 palabras, con flecha causa → efecto si aplica>", '
        '"definition": "<una frase neutral, sin juicio moral>"}.'
    )
    try:
        out = json.loads(_ask(prompt))
        return {"name": str(out["name"])[:60], "definition": str(out["definition"])[:200]}
    except Exception:
        return None
