# Laboratorio de coherencia medida

Línea de laboratorio de [docs/PLAN-COHERENCIA.md](../docs/PLAN-COHERENCIA.md) (§8, §10, §11). Entrena y valida
los modelos que la app usa en el teléfono.

**Regla de privacidad:** el laboratorio nunca toca diarios reales. Trabaja solo con datos sintéticos,
ítems compartidos y etiquetas que alguien confirmó y exportó a propósito (sin texto privado).

## Entorno

```bash
py -3.12 -m venv .venv
.venv/Scripts/python -m pip install torch==2.6.0 --index-url https://download.pytorch.org/whl/cu124
.venv/Scripts/python -m pip install -r requirements.txt
```

GPU usada: RTX 3050 Ti Laptop (4 GB, bf16). Los scripts caben en esa memoria.

## Orden de ejecución

| Paso | Script | Sprint | Qué produce |
|---|---|---|---|
| 1 | `scripts/s11_baseline.py` | S11 | Línea base del test de pares mínimos: cuánto fallan hoy mDeBERTa, e5 y MiniLM con la negación |
| 2 | `scripts/s12_labeling.py` | S12 | Datos sintéticos (`data/synth_v1/`), ítems compartidos para la app (`app/assets/ml/shared_items_v1.json`), muestra para validación humana, simulación de agregación |
| 3 | `scripts/s13_prototypes.py` | S13 | Embeddings contrastivos con negativos duros (`models/s13_e5_contrastive`) y grafo con signo frente a agrupar por parecido |
| 4 | `scripts/s14_train.py` | S14 | System One multi-cabeza calibrado (`models/system_one`) y comparación de jueces |
| 5 | `scripts/s15_antagonism.py` | S15 | Prototipos con cabezas predichas, pares antagónicos, mapa y nombres para revisar |
| 6 | `scripts/s14_export.py` | S14 | Paquete del teléfono: `out/teleios-system-one-<versión>.zip` (ONNX int8, vocabulario, versículos y prototipos) |

Todos los scripts escriben un `out/sNN_report.json`, y la mayoría también un `.png`.

## Piezas

- `teleios_ml/minimal_pairs.py`: los **300 pares fijos** (100 anclas × misma cadena / opuesto / otra cadena).
  Nunca se entrena con ellos; el generador sintético descarta todo lo que se les parezca.
- `teleios_ml/synth.py`: 14 cadenas de razonamiento en 7 pares antagónicos. Cada cadena trae sus etiquetas
  por construcción: esquema, agente, polaridad, modalidad y distorsión.
- `teleios_ml/agreement.py`: α de Krippendorff, Dawid-Skene y acierto en ítems de oro (§10.3).
- `teleios_ml/signed_graph.py`: candidatos por kNN, aristas NLI con signo, correlation clustering con la regla
  de que los opuestos nunca van al mismo grupo, antagonistas y estabilidad bootstrap.
- `teleios_ml/system_one.py`: codificador e5-small con salida de embedding, NLI y 5 cabezas, calibración por
  temperatura, ECE/Brier y umbral del ruteador.
- `teleios_ml/teacher.py`: maestro opcional, un LLM local con API compatible con OpenAI (p. ej. `llama-server` con un
  modelo de 3-4B en Q4). Si no está disponible, los scripts lo omiten.

## Cómo llega el modelo al teléfono

1. Copia `out/teleios-system-one-<versión>.zip` al teléfono e impórtalo en **Ejes → Coherencia → Modelo →
   Importar paquete**. También puedes publicarlo y poner su URL en `MODEL_BUNDLE_URL` (`app/config/*.json`).
2. Para verificar que el tokenizador en Dart da los mismos tokens que el de Python:
   `TELEIOS_MODEL_DIR=ml/out/bundle flutter test test/infrastructure/unigram_tokenizer_test.dart`.

## Etiquetas de muchas personas

En la app, **Etiquetar → Exportar** genera un JSON con un id anónimo, las respuestas a los ítems compartidos y
los veredictos sobre el juez (sin texto). Para agregar varios archivos se usa `agreement.dawid_skene` y
`krippendorff_alpha_nominal`. Un gráfico solo se considera fiable con α ≥ 0.8 (§10.4).
