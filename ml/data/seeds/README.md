# Semillas del maestro (v1)

700 pares NLI escritos a mano por Claude (Opus 5.5) para enseñarle al juez del teléfono los casos donde
falla (docs/PLAN-COHERENCIA.md §12.3). Formato TSV, una línea por par:

```
categoria <TAB> dificultad <TAB> etiqueta <TAB> premisa <TAB> hipotesis
```

- **dificultad**: `F` fácil · `M` media · `D` difícil.
- **etiqueta**: `E` vincula (la hipótesis se sigue de la premisa) · `C` contradice (no pueden ser verdad a la
  vez) · `N` neutral (ninguna de las dos).

## Mapa

| Categoría | Qué enseña | Ítems | F / M / D |
|---|---|---|---|
| `cuantificador` | todo / algunos / nada, siempre / a veces / nunca, "no siempre" = "a veces no", implicación hacia abajo ("todo" → "algo") | 120 | 15 / 25 / 80 |
| `negacion` | negación implícita (jamás, ni, sin, tampoco, dejar de), doble negación, alcance ("no es que no…") | 110 | 15 / 25 / 70 |
| `parafrasis` | misma cadena con otras palabras, otro orden, otra estructura (condicional ↔ causal ↔ deber) | 110 | 15 / 30 / 65 |
| `agente` | quién controla o causa: yo / Dios / otros / circunstancias | 70 | 10 / 20 / 40 |
| `antonimo` | polaridad por antónimos y verbos opuestos (acercar/alejar, ganar/perder) | 60 | 10 / 15 / 35 |
| `modalidad` | debo / puedo / es así; "no tengo que" ≠ "tengo que no" | 50 | 5 / 15 / 30 |
| `otra_cadena` | mismas palabras, otra afirmación → neutral | 60 | 10 / 15 / 35 |
| `versiculo` | versículo RV1909 (premisa) ↔ interpretación (hipótesis) | 80 | 15 / 20 / 45 |
| `escenario` | acción descrita ↔ creencia: actúa desde (E), contra (C) o sin relación (N) | 40 | 5 / 10 / 25 |
| **Total** | | **700** | **100 / 175 / 425** |

Reparto aproximado de etiquetas: E 35 % · C 35 % · N 30 %.

## Reglas

1. **Nunca** se copia ni parafrasea una frase del test de pares mínimos (`teleios_ml/minimal_pairs.py`):
   `scripts/seeds_check.py` descarta todo lo que se le parezca.
2. División fija: 80 % para entrenar y 20 % **seed-dev**, estratificado por categoría y dificultad. Seed-dev
   mide la mejora en el estilo de las semillas; el test de pares mínimos y los pares que escribas tú miden si la
   mejora se generaliza (antídoto contra el sesgo de autor).
3. Si un par es discutible, se deja fuera. Una semilla mala enseña el error con más fuerza que mil sintéticas.
