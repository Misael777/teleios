# ADR-002 — Estrategia de IA: clasificación local por niveles

- **Estado:** Aceptado · 2026-10-27
- **Reemplaza:** "LocalJev / Open-Jev on-device"

## Contexto
La propuesta original asumía una versión on-device de Jev (TypeSafe AI). Jev existe (lanzado 15-sep-2026), pero es una **API en la nube de pago**; no hay versión local verificable. Enviar bitácoras u oraciones a una API externa contradice la zona de privacidad 🔴 y el objetivo de costo $0.

## Decisión
Mantener el contrato tipado `choose / score / noul` (diseño estilo System One) con proveedores intercambiables:
0. **Léxico + historial** (todas las plataformas, MVP).
1. **Embeddings multilingües ONNX** cuantizados, descarga opcional (móvil/desktop).
2. **Ollama** local (desktop).
3. **Jev API**: opt-in, solo para contenido comunitario público.

Los puntajes (intensidad, coherencia, paz) los ingresa el usuario; la IA solo sugiere.

## Consecuencias
- ✅ Funciona offline, $0, privado, explicable.
- ⚠️ Precisión del nivel 0 menor; se mide con un set etiquetado de 100 ejemplos (Sprint 13).
