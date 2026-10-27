# ADR-003 — Métricas comunitarias: k-anonimato con supresión complementaria

- **Estado:** Aceptado · 2026-10-27

## Contexto
El líder navega una jerarquía de subgrupos. La regla original "si N < 5, promediar al padre" permite despejar un grupo pequeño restando a sus hermanos visibles del padre.

## Decisión
1. Umbral sobre **reportantes distintos en el período** (k = 5), no sobre miembros inscritos.
2. **Supresión complementaria:** si un hijo se suprime, se suprime el hermano más pequeño adicional; si el residuo del padre < k, el padre también.
3. La tabla `weekly_metrics` no guarda `user_id` ni texto, y no tiene `SELECT` para roles de cliente; solo RPC `SECURITY DEFINER`.
4. Subida solo con opt-in, granularidad semanal.

## Consecuencias
- ✅ Ningún grupo con < 5 reportantes es deducible (verificado con tests de propiedad en pgTAP).
- ⚠️ Es **pseudonimización**, no anonimato perfecto: el operador del servidor ve qué sesión autenticada envía cada vector. Se documenta en la política de privacidad.
- ⚠️ Grupos pequeños verán "datos insuficientes" con frecuencia; es intencional.
