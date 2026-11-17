# Plan: coherencia medida

> Estado: S11–S15 implementados (31-10-2026, app 0.4.0); resultados en §12. Propuesta original del 30-10-2026. Extiende el mapa de Ejes: la coherencia deja de ser solo
> un número que el usuario declara y pasa a medirse, con evidencia y con su margen de error.

## 1. Objetivo y preguntas de investigación

La Biblia es veraz, pero se ha interpretado de muchas maneras. TELEIOS no decide qué interpretación es
"la correcta": **mide** dos cosas que sí se pueden observar y deja la evidencia a la vista.

| # | Pregunta | Nivel |
|---|---|---|
| **P1** | ¿Qué tan sostenida está una interpretación por el conjunto de la Escritura, y no por un solo versículo aislado? | Interpretación |
| **P2** | ¿Cuánto vive una persona lo que ella misma interpretó? | Persona y acción |
| **P3** | ¿Qué relación hay entre vivir una interpretación y la paz, y cambia según la coherencia canónica de esa interpretación? | Persona, y después población |

**Hipótesis central (H3).** Actuar en línea con interpretaciones de **mayor coherencia canónica** se asocia a
más paz que actuar en línea con interpretaciones de baja coherencia. Es falsable: si el efecto de la
interacción es nulo o negativo, la hipótesis se rechaza y la app lo muestra igual.

**Qué NO mide.** No mide la verdad teológica ni la espiritualidad de una persona. La coherencia canónica es
*sostén intertextual*: cuántos pasajes independientes respaldan la idea y cuántos la tensionan.

## 2. Modelo conceptual

```
                    Canon (RV1909, ~31 000 versículos)
                               │ soporte / tensión
                               ▼
Pasaje ──► Interpretación ──► Creencia operativa ──► Acción (bitácora, oración) ──► Paz
          (principio del         ("Dios provee →           alineada / neutral /         (1-10 y
           devocional)            dar aunque falte")       contraria                     escala semanal)
```

- **Interpretación**: proposición explícita que sale de un devocional. Las fuentes son las respuestas de
  *Hermenéutica · principio atemporal*, *Teología* y *Aplicación*, junto con sus citas `{…}`.
- **Creencia operativa**: lo que guía la conducta. Puede nacer de una interpretación o de la vida
  ("si no controlo todo, sale mal"). Sigue el ciclo que ya existe: incubación → validada o refutada.
- **Acción**: un registro de la bitácora o una oración, vinculado a una creencia, con una dirección
  (actué *desde* esa creencia o *contra* ella).

## 3. Variables

| Nivel | Variable | Símbolo | Escala | Fuente |
|---|---|---|---|---|
| Interpretación | Texto del principio | I | texto | Devocional |
| | Pasaje base y citas vinculadas | — | refs | Devocional (`{…}`) |
| | Soporte canónico | S | ≥ 0 | §4.1 (referencias cruzadas; luego NLI) |
| | Diversidad del soporte (número efectivo de libros) | D | ≥ 1 | §4.1 |
| | Tensión sin resolver | T | ≥ 0 | §4.1, revisada por el usuario |
| | Fidelidad al contexto inmediato | F | [−1, 1] | NLI entre el principio y la perícopa |
| Creencia | Proposición, dominio y estado | B | texto, catálogo | Usuario (lo propone el modelo y el usuario confirma) |
| | Interpretaciones que la sustentan | — | relación | Usuario |
| Acción | Alineación con la creencia | a | {−1, 0, 1} → luego [−1, 1] | Etiqueta del usuario; luego modelo |
| | Coherencia autodeclarada (ya existe) | c | 1-10 | Bitácora |
| | Emoción, intensidad, detonante (ya existen) | — | catálogo, 1-10 | Bitácora |
| Resultado | Paz momentánea (ya existe) | p | 1-10 | Bitácora |
| | Bienestar semanal (opcional, escala validada, p. ej. WHO-5*) | W | 0-100 | Cuestionario semanal |
| Exposición | Frecuencia de estudio y de oración | — | conteo por semana | Derivado |
| Covariables | Día, hora, evento de vida relevante (marcador opcional) | — | — | Derivado / usuario |
| Validez | Acuerdo humano-humano y modelo-humano | κ | [−1, 1] | Conjunto de validación |
| | Calibración del modelo | ECE | [0, 1] | Confirmaciones del usuario |

\* Verificar la licencia de cada escala antes de incluirla en la app.

## 4. Métricas

### 4.1 Coherencia canónica de una interpretación (P1)

1. **Recuperar** los pasajes candidatos R(I):
   - las referencias cruzadas del pasaje base (Treasury of Scripture Knowledge, dominio público, u OpenBible.info, CC-BY);
   - los pasajes citados con `{…}`;
   - y, desde la fase de embeddings, los k versículos más cercanos al principio.
2. **Juzgar** cada candidato r con NLI (premisa = r, hipótesis = I) → `p_e(r)` (confirma) y `p_c(r)` (contradice).
3. **Agregar**:
   - **S** = Σ p_e(r)
   - **D** = exp(−Σ_b q_b · ln q_b), donde q_b es la fracción del soporte que viene del libro b.
     Es el *número efectivo de libros*: 10 versículos de un mismo capítulo dan D ≈ 1, y 5 libros distintos dan D ≈ 5.
   - **T** = Σ p_c(r) de las tensiones que el usuario no marcó como "resuelta por el contexto".
4. **Reportar** el vector (S, D, T, F) con intervalos bootstrap sobre R(I), **no un solo número**.
   Toda cifra se acompaña de los versículos que la producen.

En la fase sin ML, `p_e` = 1 para las referencias cruzadas y las citas confirmadas por el usuario, y
`T` sale solo de las tensiones que el usuario registre a mano.

### 4.2 Alineación (P2)

- Por acción: `a` = etiqueta del usuario, o `P(confirma) − P(contradice)` entre la descripción de la acción
  y la creencia, cuando el modelo esté validado (§7).
- Semanal: **A_w** = promedio de `a` en la semana, con su n.

### 4.3 Efecto sobre la paz (P3)

- **Dentro de una persona (N-of-1)**:
  - Spearman entre A_w y la paz media, y correlación cruzada con rezagos de −2 a +2 semanas;
  - n mínimo explícito (ya existe en `Statistics.minPairs`);
  - Benjamini-Hochberg cuando se exploran muchas creencias a la vez.
- **Entre personas (fase de investigación)**: modelo multinivel
  `p_it = β0 + β1·a_it + β2·CC_i + β3·a_it×CC_i + covariables + u_i + ε_it`.
  **H3 ⇔ β3 > 0.** Las hipótesis se pre-registran antes de mirar los datos.
- El lenguaje siempre es de asociación: "cuando actuaste desde X, tu paz media fue Y (n, IC 95 %)".

## 5. Gráficos de salida

| # | Gráfico | Pregunta que responde | Codificación | Datos mínimos |
|---|---|---|---|---|
| 1 | **Huella canónica** | ¿La interpretación se sostiene en toda la Escritura o en un versículo? | Eje horizontal con los 66 libros (Gn → Ap); arcos desde el pasaje base a cada soporte (sólido) y a cada tensión (punteado); franja inferior con el soporte por libro | 1 interpretación |
| 2 | **Fichas de tensión** | ¿Dónde choca mi interpretación con otro texto? | Lista: tu principio ↔ el versículo, la probabilidad y "resuelta / pendiente" | 1 tensión |
| 3 | **Mapa de creencias** | ¿Qué interpretaciones gobiernan realmente mis acciones? | Grafo por capas: Interpretación → Creencia → Acciones → Paz; grosor = frecuencia, color = alineación | ~5 creencias |
| 4 | **Alineación vs paz** | ¿Vivir lo que entiendo se asocia a más paz? | Dispersión por acción con tendencia, ρ, n e IC; selector por tercil de coherencia canónica (muestra H3) | ≥ 10 pares |
| 5 | **Serie semanal** | ¿Cómo evolucionan juntas? | Dos paneles alineados (alineación arriba, paz abajo) con bandas de IC; no doble eje | ≥ 6 semanas |
| 6 | **Correlación con rezago** | ¿La alineación precede a la paz o al revés? | Barras por rezago −2…+2 con IC | ≥ 12 semanas |
| 7 | **Aluvión extendido** | ¿Qué pasa cuando actúo contra una creencia? | Creencia → acción (alineada / neutral / contraria) → banda de paz | ≥ 20 acciones |
| 8 | **Transparencia del modelo** | ¿Cuánto puedo confiar en las sugerencias automáticas? | Diagrama de calibración y matriz de confusión contra tus confirmaciones | ≥ 50 confirmaciones |
| 9 | **Bosque de efectos** (multiusuario) | ¿Qué interpretaciones se asocian a más paz entre personas? | Forest plot: efecto por interpretación con IC, ordenado por coherencia canónica | Fase de investigación |

Debajo del mínimo de datos, cada gráfico muestra "aún no hay suficientes datos (n = x de y)" en vez de una
tendencia engañosa.

## 6. Dependencias tecnológicas

| Pieza | Opción | Notas |
|---|---|---|
| Texto bíblico | RV1909 (ya en la app) | Español arcaico: afecta a los modelos, hay que calibrar |
| Referencias cruzadas | TSK (dominio público) / OpenBible.info (CC-BY, ~340 000) | Llevan el sesgo de su tradición: se declara |
| Inferencia local | ONNX Runtime (plugin de Flutter) + tokenizador SentencePiece | Descarga bajo demanda para no inflar el APK |
| Embeddings | `multilingual-e5-small` o `paraphrase-multilingual-MiniLM-L12-v2` (384 dim) | Los versículos se pre-calculan una vez (~24 MB en fp16); búsqueda por fuerza bruta en un isolate |
| NLI | `mDeBERTa-v3-base-xnli` multilingüe (cuantizado int8) | El más pesado (~300 MB); hay alternativas destiladas |
| LLM (opcional) | En el dispositivo (Gemma / Qwen 1-2B vía llama.cpp o MediaPipe) o API (Claude Haiku 5.5 / Sonnet 5.5) con salida estructurada | Solo para proponer creencias y explicar tensiones; nunca puntúa solo |
| Estadística | Dart puro: Spearman (ya existe), bootstrap, correlación cruzada, BH | Sin dependencias |
| Multinivel | Servidor: R (`lme4`) o Python (`statsmodels`, PyMC) | Solo en la fase multiusuario |
| Backend | Supabase (Sprint 10) + consentimiento + agregados | Ver §7 |
| Evaluación | Notebooks offline (Python): κ / α de Krippendorff, matriz de confusión, ECE | Fuera de la app |
| Laboratorio de entrenamiento | `ml/` en el repo (Python): PyTorch + CUDA, `transformers`, `sentence-transformers`, `optimum` (exportación ONNX), `llama.cpp` para el maestro local | GPU disponible: RTX 3050 Ti Laptop, 4 GB (bf16). Ver §11.4 |
| Clusterización | `igraph` / `leidenalg` (grafo con signo), `hdbscan` | Offline; en el teléfono solo se asigna a grupos existentes |
| Agregación de etiquetas | Dawid-Skene (implementación propia o `crowd-kit`) | Servidor, fase multiusuario |

## 7. Opciones de arquitectura (de la más compleja y segura a la más económica)

| | O1 · Local total + analítica federada | O2 · Local + LLM en la nube opcional | O3 · Servidor | O4 · Sin ML |
|---|---|---|---|---|
| **Qué corre dónde** | Embeddings, NLI y LLM pequeño en el teléfono; solo números anónimos (a, p, CC) salen, con ruido de privacidad diferencial | Embeddings y NLI en el teléfono; un LLM en la nube solo si el usuario lo activa | Texto a Supabase + pgvector + API de LLM | Etiquetas del usuario + referencias cruzadas + estadística |
| **Privacidad** | Máxima: el texto nunca sale | Alta (opt-in explícito) | Baja: el servidor ve diarios espirituales | Máxima |
| **Complejidad** | Muy alta | Alta | Media | Baja |
| **Costo operativo** | ~0 (servidor mínimo para agregados) | Por uso, solo de quienes lo activen | Recurrente por usuario | 0 |
| **Tamaño de la app** | +300-500 MB descargables | +150-350 MB descargables | Sin cambio | Sin cambio |
| **Calidad automática** | Media (modelos chicos, español arcaico) | Media-alta | Alta | Ninguna: todo manual |
| **Responde P1 / P2 / P3** | Sí / Sí / Sí, entre personas | Sí / Sí / Sí, por persona | Sí / Sí / Sí | Parcial / Sí / Sí, por persona |

**Recomendación**: construir en el orden **O4 → O2 → O1**. O4 genera los datos etiquetados sin los que
nada se puede validar. O2 agrega automatización medible. O1 es la base ética para investigar entre
personas. O3 se descarta como arquitectura principal: los datos religiosos son *datos sensibles* en la
mayoría de las legislaciones.

**Juez en cascada (O2 y O1).** Es el patrón "System One": decidir rápido lo fácil y escalar lo incierto.

```
Recuperar (embeddings con negativos duros)  →  System One local multi-cabeza (§11.1)
        │ confianza ≥ umbral calibrado → sugerencia que el usuario confirma
        │ confianza < umbral
        ▼
LLM pequeño local leído por logits (ocasional)
        │ sigue dudoso
        ▼
El usuario decide  —o—  nube opcional (Jev / LLM grande), solo si la activó
```

El diseño es **agnóstico al juez**: una interfaz `CoherenceJudge` con varias implementaciones, y cada
juicio guarda el modelo y la versión que lo produjo. Los candidatos se comparan en S14 sobre el mismo
conjunto de validación:
- mDeBERTa NLI;
- mmBERT ajustado;
- LLM pequeño por logits;
- Jev, fijado a una versión exacta.

## 8. Fases

Hay dos líneas en paralelo:
- **App** (Flutter): produce etiquetas y muestra resultados.
- **Laboratorio** (`ml/`, Python, en la GPU local): entrena y valida modelos.

El laboratorio nunca toca diarios reales. Trabaja con datos sintéticos, ítems compartidos y etiquetas
que el usuario confirmó.

| Sprint | App | Laboratorio | Arquitectura |
|---|---|---|---|
| **S11** | Entidad *Creencia* (esquema v4), vínculo de acciones (desde / contra), referencias cruzadas con sus votos, huella canónica v0, gráficos 3, 4, 5 y 7, reglas de supervisión débil sobre los datos existentes | Entorno CUDA, **test de pares mínimos** (§11.3) y línea base: cuánto fallan hoy mDeBERTa y e5 con la negación | O4 |
| **S12** | Protocolo de etiquetado (§10): ítems compartidos, ítems de oro y exportación de etiquetas confirmadas | Generador de negaciones y variantes en español, pre-etiquetado por el maestro y validación de una muestra | O4 |
| **S13** | Sugerencias de vínculos con embeddings locales y recuperación canónica | Embeddings contrastivos con negativos duros y **catálogo de prototipos** por grafo con signo (§11.2) | O2 |
| **S14** | Juez local en el teléfono: soporte y tensión con evidencia; gráficos 1, 2 y 8 completos | **System One multi-cabeza** (§11.1): entrenamiento, calibración, exportación a ONNX int8 y comparación de jueces candidatos | O2 |
| **S15** | Estadística temporal: rezagos, BH y gráfico 6; asignación de pensamientos a patrones en el dispositivo | Mapa de **patrones antagónicos** y nombres de patrones propuestos por el LLM y confirmados por una persona | O2 |
| **S16** | (Opcional) LLM en la nube opt-in para proponer creencias desde la bitácora | Reentrenamiento periódico con las nuevas etiquetas confirmadas | O2 |
| **S17+** | Investigación multiusuario (requiere el Sprint 10): consentimiento, pre-registro, agregados federados, gráfico 9 | Dawid-Skene, **perfiles de interpretación** (clases latentes), análisis factorial y prueba de las 4 dimensiones, modelo multinivel | O1 |

## 9. Validez y ética

- **Criterio para confiar en el modelo**: κ humano-humano ≥ 0.6 antes de comparar al modelo, y el κ del
  modelo frente a humanos se publica en el gráfico 8. Si el modelo no alcanza el acuerdo humano, queda solo
  como sugerencia.
- **Sin puntaje global**: se muestran tensiones con su evidencia, no una nota de "qué tan bíblico eres"
  (ley de Goodhart y riesgo de escrupulosidad).
- **Toda inferencia automática se confirma** antes de contar en una estadística.
- **Versionado**: cada vector y cada juicio guardan la versión del modelo que los produjo.
- **Multiusuario**: consentimiento informado, revisión ética si se publica, pre-registro (p. ej. OSF) y
  agregados con privacidad diferencial. Los datos de creencias religiosas son de categoría especial.
- **Limitación declarada**: las referencias cruzadas y los modelos llevan los sesgos de su tradición y de su
  entrenamiento. La coherencia canónica es una medida de sostén intertextual, no de verdad.

## 10. Protocolo de etiquetado y fiabilidad

Los resultados son tan fiables como las etiquetas. Con muchas personas etiquetando, los desacuerdos no son
solo ruido: contienen los patrones de pensamiento que se buscan.

### 10.1 Qué se etiqueta entre todos y qué queda privado

| Tipo de ítem | Ejemplo | Quién etiqueta | Dónde vive |
|---|---|---|---|
| Compartido | "Dios provee" ↔ Fil 4:19: ¿confirma, contradice o es neutral? | Todos | Servidor |
| Escenario anónimo | "Alguien deja de diezmar por miedo al mes": ¿actúa desde o contra "Dios provee"? | Todos | Servidor |
| Privado | Un registro de la bitácora ↔ una creencia propia | Solo el usuario | Teléfono |

De lo privado solo se comparten números asociados a **prototipos** (§11.2), nunca texto.

### 10.2 Reutilizar etiquetas existentes

- **Supervisión débil sobre los datos de la app.** Se escriben reglas sobre lo que ya existe (tópicos
  validados o refutados, vínculos de praxis con tópicos, coherencia autodeclarada, paz, emoción,
  detonante). Por ejemplo: "praxis vinculada a X con coherencia ≥ 8 → probablemente alineada". Producen
  etiquetas ruidosas a gran escala; de cada regla se mide la precisión sobre una muestra confirmada.
- **Votos de OpenBible.info**: cada referencia cruzada trae votos, que ponderan el soporte en P1.
- **Corpus de NLI multilingüe** (XNLI y similares): entrenamiento previo del juez.
- **Taxonomía de distorsiones cognitivas de la terapia cognitivo-conductual** y los **esquemas
  argumentativos de Walton**: catálogos ya validados de patrones de razonamiento, que sirven de eje de
  comparación para los patrones que emerjan. Verificar las licencias de los conjuntos de datos.

### 10.3 Agregación con muchas personas

- **Ítems de oro** intercalados, con respuesta conocida: miden la fiabilidad de cada persona.
- **α de Krippendorff** (muchos etiquetadores, datos faltantes): ≥ 0.8 es fiable; entre 0.667 y 0.8 solo
  admite conclusiones tentativas.
- **Dawid-Skene**: estima a la vez la etiqueta más probable de cada ítem y la confiabilidad de cada
  persona. No es voto mayoritario.
- **Etiquetas suaves**: un ítem 60/40 se guarda como distribución, y los modelos se entrenan sobre ella.
- **Aprendizaje activo**: se pide etiquetar primero lo que el modelo tiene más incierto.

### 10.4 Garantías por gráfico

| Gráfico | Garantía |
|---|---|
| 1-2 | Juez calibrado y validado contra etiquetas agregadas (α ≥ 0.8); soporte ponderado por votos; intervalos bootstrap |
| 3, 7 | Solo creencias confirmadas o prototipos estables |
| 4-6 | Se calculan con probabilidades (no etiquetas duras) y la incertidumbre se propaga a los intervalos; n mínimo y BH |
| 8 | Prueba separada **por persona**: el modelo se evalúa con personas que nunca vio; incluye el test de pares mínimos |
| 9 | Modelo multinivel con el perfil de interpretación como moderador, pre-registrado; se reportan efectos con intervalo, no solo p |

## 11. Modelos: System One local y clusterizador por estructura de razonamiento

### 11.0 El problema que resuelven

| # | Pensamiento | Embeddings normales | Lo correcto |
|---|---|---|---|
| A | "Si no controlo todo, todo sale mal" | — | — |
| B | "Debo controlarlo todo o fracasaré" | parecido a A | **misma cadena** que A |
| C | "Aunque no controle todo, Dios obra para bien" | muy parecido a A | **opuesto** a A |
| D | "Controlar mis finanzas es buena mayordomía" | parecido a A | **otra cadena** |

Agrupar por parecido junta A, C y D. Agrupar por estructura de razonamiento junta A con B, pone C enfrente
como su opuesto y deja D aparte.

### 11.1 System One multi-cabeza (clasificador y ruteador)

Un codificador pequeño (mmBERT-small, 140M, o mDeBERTa-base) con varias cabezas que responden en una
sola pasada, con probabilidades calibradas:

| Cabeza | Respuesta tipada |
|---|---|
| Relación entre dos textos (NLI) | vincula / contradice / neutral |
| Esquema de razonamiento (Toulmin / Walton) | condicional causal / deber / generalización / promesa / concesivo / identidad… |
| Agente de control | yo / Dios / otros / circunstancias |
| Polaridad de la conclusión | positiva / negativa |
| Modalidad | necesidad / posibilidad / hecho |
| Distorsión cognitivo-conductual | catastrofización / todo o nada / "debería" / ninguna… |

- Cada pensamiento se convierte en una **estructura**, no solo en un vector.
- El mismo modelo hace de **ruteador** (§7): con confianza alta, sugiere; con confianza baja, escala.
- **Calibración**: temperatura por cabeza, ajustada sobre un conjunto de validación separado.
  Se reportan ECE y Brier.
- **Exportación**: ONNX int8, unos 150-300 MB, descargable bajo demanda.

### 11.2 Clusterizador de grafo con signo

1. **Candidatos**: los ~20 vecinos más cercanos por embeddings (solo filtra por tema). Los embeddings se
   reentrenan con **negativos duros**: tripletas (ancla, paráfrasis, negación), para que los opuestos
   queden lejos.
2. **Aristas**: el juez NLI evalúa cada par en ambos sentidos. Si se implican mutuamente → arista
   **positiva**. Si se contradicen → arista **negativa**.
3. **Peso estructural**: el mismo esquema y el mismo agente refuerzan la arista positiva; una polaridad
   distinta la anula.
4. **Agrupación**: *correlation clustering* o Leiden adaptado a signos. Los opuestos **no pueden** caer
   en el mismo grupo: la negación pasa a ser una restricción.
5. **Salidas**:
   - grupos de "misma cadena": el **catálogo de prototipos**;
   - pares de **patrones antagónicos** (p. ej. "control propio → catástrofe" frente a "Dios gobierna → descanso").
6. **Nombres**: un LLM lee los ejemplos más representativos y propone un nombre y una definición; una
   persona los confirma.
7. **Validez**: los grupos deben ser estables al remuestrear (bootstrap, ARI) y, además, interpretables.
   La silueta sola no basta.

En el teléfono no se clusteriza: solo se **asigna** cada pensamiento nuevo al prototipo más cercano, si
la confianza lo permite.

### 11.3 Test de pares mínimos (criterio de aceptación)

- Unos 300 pares en español del tipo A/B/C/D, **fijos y nunca usados para entrenar**.
- Categorías: negación, cuantificadores (siempre / nunca, todo / nada), cambio de agente, antónimos,
  paráfrasis y "mismas palabras, otra cadena".
- **Criterio**: separar ≥ 90 % de los opuestos y juntar ≥ 90 % de las paráfrasis.
- Se mide primero la línea base (modelos sin ajustar), para cuantificar la mejora. El resultado se
  publica en el gráfico 8.

### 11.4 Entrenamiento: destilación maestro → alumno

1. **Datos sintéticos.** Un generador en español produce variantes con su etiqueta correcta: insertar o
   quitar negación, invertir cuantificadores, cambiar el agente, antónimos, paráfrasis.
2. **Maestro.** Un LLM grande pre-etiqueta esquema, agente, modalidad y distorsión. Opciones: un modelo
   de 3-4B en Q4, local, o una API usada una sola vez, offline. Solo ve datos sintéticos e ítems
   compartidos, nunca diarios.
3. **Validación humana** de una muestra; se descartan las reglas o categorías con baja precisión.
4. **Alumno.** Se entrena en la GPU local; se calibra y se exporta.
5. **Reentrenamiento** periódico con nuevas etiquetas confirmadas, versionado.

Capacidad de la GPU local (RTX 3050 Ti, 4 GB):

| Tarea | Viable |
|---|---|
| Ajustar mmBERT-small y e5-small | ✅ cómodo (bf16) |
| Ajustar mDeBERTa-base | ✅ justo (bf16 + gradient checkpointing) |
| Calibración y exportación ONNX | ✅ |
| Maestro local de 3-4B (inferencia Q4) | ⚠️ sí; 7B+ no cabe |
| LoRA de un LLM de 1.5-3B | ⚠️ posible pero lento; no prioritario |
| Maestro de alta calidad | ❌ local → API puntual o GPU alquilada por horas |

## 12. Implementación y resultados (S11–S15, 31-10-2026)

### 12.1 App (0.4.0+8, esquema v4)

| Sprint | Entregado |
|---|---|
| S11 | Tablas `beliefs`, `belief_topics`, `belief_evidence` y `action_beliefs` (migración v1/v2/v3 → v4 verificada). Creencia desde un devocional ("Convertir en creencia", propone el principio atemporal). 117 466 referencias cruzadas de OpenBible (≥ 5 votos) dentro del asset de la Biblia. Huella canónica (gráfico 1) con el vector S, D, T, F e IC bootstrap. Fichas de tensión (gráfico 2). Gráficos 3, 4 (con selector de tercil H3), 5 y 7. Vínculo desde/neutral/contra en registros y oraciones. Cuatro reglas de supervisión débil con su precisión medida. Las tablas nuevas entran en el respaldo cifrado |
| S12 | Pestaña **Etiquetar**: 95 ítems compartidos (60 proposición ↔ versículo, 20 escenarios, 15 de oro intercalados), fiabilidad propia y exportación sin texto privado con id anónimo |
| S13 | Recuperación canónica con embeddings ("Buscar en toda la Escritura"): índice int8 de 31 102 versículos, búsqueda por fuerza bruta en un isolate |
| S14 | Juez local ONNX (ORT 1.15, int8) con tokenizador SentencePiece en Dart. Paridad con Python verificada. Cascada con umbral calibrado. Interfaz agnóstica `CoherenceJudge`. Instalación por zip o URL (`MODEL_BUNDLE_URL`). Gráfico 8 completo: tarjeta del laboratorio, diagrama de calibración y matriz de confusión contra las confirmaciones del usuario |
| S15 | Gráfico 6 (rezagos −2…+2 con IC). N-of-1 por creencia con Benjamini-Hochberg. Asignación de un registro a un prototipo de pensamiento en el teléfono, con el patrón opuesto y confirmación del usuario |

### 12.2 Laboratorio (`ml/`, RTX 3050 Ti)

**Test de pares mínimos** (300 pares fijos, criterio ≥ 90 % / ≥ 90 %):

| Modelo | Junta paráfrasis | Separa opuestos | Nota |
|---|---|---|---|
| mDeBERTa-v3-base XNLI (sin ajustar) | 87 % | 86 % | El más fuerte, pero pesa ~300 MB y no cumple |
| MiniLMv2-L12 XNLI (sin ajustar) | 81 % | 73 % | Base del alumno |
| e5-small como espacio de embeddings (umbral óptimo) | 42 % | 35 % | **Pone la negación más cerca que la paráfrasis** (coseno 0.94 frente a 0.92) |
| e5-small contrastivo (S13) | 60 % | 60 % | Acierto en la tripleta: de 0.34 a 0.69; con negación, de 11 % a 50 % |
| **System One fp32 (S14)** | 73 % | 83 % | Negación 87 %, antónimos 92 %, cuantificadores 62 % |
| **System One int8 (en el teléfono)** | 72 % | 84 % | Coseno 0.97 frente a fp32; paquete de 93 MB |

**Conclusión honesta:** ningún juez cumple todavía el criterio del 90 %. Por §9, el modelo **solo sugiere** y
nada cuenta sin confirmación. El umbral del ruteador se fijó en un mínimo conservador de 0.9, porque la
validación (sintético + XNLI, ECE 0.004) es más fácil que el uso real. El 94 % del alumno en XNLI
validation probablemente está inflado: la base se entrenó con XNLI.

**Clusterizador de grafo con signo** (corpus sintético de 14 cadenas en 7 pares antagónicos):

| | Por parecido (e5) | Grafo con signo |
|---|---|---|
| Grupos | 1 | 19 (tras unir subgrupos de la misma cadena) |
| Opuestos en el mismo grupo | 100 % | **0 %** |
| ARI frente a la cadena real | 0.00 | 0.79 |
| Estabilidad bootstrap (ARI) | — | 0.91 ± 0.02 |
| Pares antagónicos recuperados | — | **7 de 7** |

Hallazgo de método: en un espacio contrastivo los opuestos casi nunca son vecinos, así que el antagonismo se
mide entre prototipos (ejemplos representativos juzgados en ambos sentidos) y no con las aristas de los vecinos.
Las cabezas predichas aciertan agente, polaridad y distorsión al 100 %, modalidad al 90 % y esquema al 67 %,
siempre sobre datos sintéticos.

**Agregación** (simulación con 12 etiquetadores, 3 descuidados): Dawid-Skene estima una fiabilidad de 0.90
para los cuidadosos y de 0.28 para los descuidados. El α resulta 0.39 ("no fiable"), que es justo la señal que
debe disparar una revisión.

### 12.3 Pendientes y límites

- **Cuantificadores** (62 %) y **paráfrasis lejanas**: hace falta más variedad en el generador o un maestro
  (LLM local de 3-4B, `teacher.py`) para pre-etiquetar los ítems compartidos.
- Los nombres de los 19 patrones están **propuestos, sin confirmar** (`ml/out/s15_names_review.csv` →
  `ml/data/prototype_names.json`).
- Los embeddings del alumno están comprimidos (cosenos de 0.97–0.99): sirven para proponer candidatos; el
  juez es quien decide.
- Licencias: XNLI es CC BY-NC 4.0, así que antes de un uso comercial hay que reentrenar sin XNLI o con datos
  propios. OpenBible es CC-BY (atribución visible en la app).
- Jev y el LLM por logits no se evaluaron (requieren API o un servidor local).
- Probar en un teléfono real el rendimiento del juez (ORT en ARM, 118 MB en memoria).

### 12.4 Semillas del maestro (03-11-2026)

844 pares NLI escritos a mano por Claude (`ml/data/seeds/`, 67 % difíciles, 10 categorías). El filtro descartó 28
que se parecían al test de pares mínimos. División fija: 675 para entrenar y 169 en seed-dev.

| Modelo | Registros (42 pares, 7 registros) | Seed-dev (169) | Pares mínimos (paráfrasis / opuestos) |
|---|---|---|---|
| v1 (S14) | 67 % | 62.7 % | 73 / 83 |
| v2 (+559 semillas) | 76 % | 78.1 % | 80 / 83 |
| **v3a (+844 semillas) → exportado** | **83 %** | **79.3 %** | 74 / 85 (int8: 73 / 84) |
| v3 / v3b (+ destilación de mDeBERTa) | 83 % | 79.3 / 78.7 % | 72 / 85 · 72 / 83 |
| mDeBERTa (300 MB) | 86 % | — | 87 / 86 |

Hallazgos:
- La **destilación de mDeBERTa no aporta**. Coincide solo en el 59 % con las etiquetas sintéticas y se
  equivoca con total seguridad en "X" frente a "No es cierto que X".
- La mejora vino de las semillas de **alto solapamiento**, que vuelven al juez más estricto: suben las
  contradicciones y baja la paráfrasis flexible.
- En texto **dictado por voz** el alumno supera a mDeBERTa (83 % frente a 50 %, n = 6).
- Sigue fallando cuando la contradicción depende de un caso particular, como "nunca falto" frente a "el
  domingo pasado no fui".
- Cada modelo se entrenó una sola vez: las diferencias de 1–2 puntos son ruido.

Paquete: `teleios-system-one-s1-2026.11.03-v3a.zip` (93 MB). Patrones con v3a: 16 grupos, ARI 0.83, 0 %
opuestos mezclados, 7/7 antagonistas.

### 12.5 Experimento v4: ¿datos o tamaño? (03-11-2026)

Se auditó el test: 11 de 300 pares son discutibles (`ml/data/minimal_pairs_audit.json`). Se añadieron 999
semillas dirigidas en `ml/data/seeds/v4/`, con circunstancias variadas, registros sociales y versículos.
Seed-dev quedó en 364 pares.

| Modelo | % v4 | Seed-dev (364) | Pares mínimos crudos | Auditados | Registros (42) |
|---|---|---|---|---|---|
| v3a · semilla 13 / 29 | 0 | 71.7 / 69.2 % | 74 / 85 · 79 / 84 | 78 / 89 · 82 / 86 | 83 / 74 % |
| v4_25 | 25 | 74.5 % | 78 / 83 | 82 / 87 | — |
| v4_50 | 50 | 78.6 % | 87 / 86 | 91 / 90 | — |
| v4_100 · semilla 13 / 29 | 100 | 79.7 / 79.1 % | 85 / 84 · 90 / 81 | 89 / 88 · 91 / 84 | 86 / 86 % |
| **mDeBERTa + semillas** | 100 | **91.2 %** | **98 / 96** | **98 / 98** | **98 %** |

Hallazgos:
- **Curva de aprendizaje:** el seed-dev del alumno sube +4, +4 y +1 puntos y se aplana cerca del 80 %.
  Más semillas ya no lo llevan al 90 %.
- **Ruido entre repeticiones:** ±1 punto en seed-dev, pero **±3–5 puntos** en los pares mínimos y hasta 9
  en registros (n = 42). Que v4_50 "pase" es suerte de la repetición.
- **El límite es el tamaño del modelo.** Con las mismas semillas, mDeBERTa supera el criterio holgadamente
  incluso sin auditar.
- Siguiente paso: (a) usar mDeBERTa ajustado como maestro para destilar al alumno, ahora que el maestro sí
  acierta; o (b) llevar mDeBERTa al teléfono recortando el vocabulario a español, de unos 280 MB a unos
  110–140 MB en int8.

**v5 · destilación con mDeBERTa ajustado (03-11-2026).** Esta vez el maestro coincide en el 98.7 % con las
etiquetas sintéticas, frente al 59 % de antes. Se destilaron 26 218 pares, entre sintéticos y semillas.

| Modelo | Seed-dev | Pares mínimos crudos | Auditados | Registros |
|---|---|---|---|---|
| v4_100 (sin destilar) | 79.7 % | 85 / 84 | 89 / 88 | 86 % |
| v5a (α 0.5) | 81.6 % | 87 / 83 | 89 / 87 | 95 % |
| v5b (α 0.8) | 80.8 % | 91 / 86 | 93 / 88 | 90 % |

La destilación aporta +1–2 puntos en seed-dev, en el borde del ruido, y mejora en registros, sobre todo en
dictado y formal. Aun así los opuestos siguen bajo el 90 %: el alumno de 118 MB no alcanza el criterio. Se pasa
al camino (b), llevar mDeBERTa al teléfono.

**Camino (b) · mDeBERTa en el teléfono (`ml/scripts/mdeberta_trim.py`).**
- **Vocabulario recortado a español:** se conservan las piezas presentes en 1 M de textos (XNLI-es, sintéticos,
  semillas, pares, RV1909). Pasa de 250 101 a 59 850 piezas y de 278 M a 132 M parámetros, con paridad de
  tokenizador del 100 % y predicciones idénticas.
- **La cuantización dinámica int8 lo destruye:** el acuerdo con fp32 cae al 12–30 %. La causa son las
  activaciones atípicas en las FFN de 8 de las 12 capas. Se usa en cambio **int8 solo de pesos**:
  DequantizeLinear por columna y MatMul en fp32, con las embeddings en Gather int8.
- **Resultado int8 (`models/mdeberta_v4_es/nli.int8.onnx`, 137 MB):** pares mínimos 99 / 96 (auditados
  98.9 / 97.9), seed-dev 90.4 %, registros 97.6 %. **Cumple el criterio.**
- **Costo en PC (4 hilos):** 171 ms por par y +260 MB de RAM. Con `session.disable_quant_qdq=1` los pesos se
  descuantizan una vez al cargar: 30 ms por par y +466 MB. En un teléfono de gama media se espera de 2 a 4 veces
  más tiempo.
- **Para la app falta:**
  - tokenizador Dart con el formato DeBERTa: `[CLS] A [SEP] B [SEP]`, ids PAD 0 / CLS 1 / SEP 2 / UNK 3,
    normalización NFC, sin bytes de respaldo;
  - un segundo modelo en el paquete;
  - CascadeJudge en dos niveles: el alumno resuelve lo seguro y mDeBERTa los pares dudosos.

**Integración en la app (07-11-2026).**
- **Paquete:** `ml/scripts/nli_export.py` genera `teleios-juez-nli-2026.11.07-mdeberta_v4.zip` (113 MB, kind
  `nli-judge`).
- **Calibración:** la temperatura (2.77) se ajusta sobre XNLI-es *test*, porque la validación de XNLI está
  contaminada: el modelo base de MoritzLaurer se entrenó con ella y acierta el 99.9 %. En test acierta el
  81.9 %, con ECE 0.044.
- **Umbral 0.90 sobre seed-dev:** decide solo el 67 % de los pares, con un 97.1 % de acierto.
- **Tarjeta del int8:** pares mínimos 99 / 96, seed-dev 90.1 %, registros 97.6 %.
- **App:**
  - `TokenizerFormat.deberta` en el tokenizador Dart (paridad 67/67);
  - `OnnxNliJudge` (`lib/infrastructure/ml/nli_judge_bundle.dart`);
  - `ModelStore` con dos carpetas: «Importar paquete» detecta el tipo por el manifest;
  - `CascadeJudge` en dos niveles: System One → juez grande (solo lo incierto) → usuario. Cada juicio guarda la
    versión del juez que lo dio;
  - lo usan la evaluación de pasajes y las sugerencias de acciones;
  - tarjeta «Juez grande (opcional)» en la pestaña Modelo.
- **Pruebas:** 197 pasan. Las de paridad y humo corren con `TELEIOS_NLI_DIR=ml/out/nli_bundle`: unos 145 ms
  por par en PC desde Dart.
- **Pendiente:**
  - medir en un teléfono real;
  - el modo rápido (+466 MB, 30 ms) requiere `AddSessionConfigEntry`, que el plugin de Flutter no expone.

## 13. Mente de Cristo frente a mi mente, por temática (Ejes, 17-11-2026)

**Objetivo.** Cuantificar Mt 16:23 ("no ves las cosas como las ve Dios, sino como los hombres") y Ro 12:2
(renovación de la mente) en cada área de la vida.

- **Mente de Cristo:** por ahora, las creencias no refutadas y las frases de los devocionales de este teléfono.
  Después se sumarán las creencias compartidas de todos, solo extraídas y confirmadas, anónimas y ponderadas por
  coherencia canónica S/D/T, cuando exista un servidor. También se sumarán las proposiciones del laboratorio.
- **Mi mente:** la bitácora, es decir, circunstancia y acción, con el filtro y la paz posterior.
- **Temática:** la escribe el usuario. Es una búsqueda, no una etiqueta fija.

**Flujo (`app/lib/features/ejes/domain/mind_map.dart`, pantalla `/ejes/mente`).**
1. **Preselección:** el embedding del System One trae 30 candidatos por mente.
2. **Temática:** el juez grande confirma de qué trata cada candidato con "Este texto trata sobre {tema}."
   (P ≥ 0.5) y quedan hasta 20.
3. **Postura:** cada reacción mía se juzga contra sus 3 afirmaciones de Cristo más cercanas, con premisa = mi
   reacción e hipótesis = "Esta persona actuó conforme a esto: {afirmación}". Solo cuenta lo decidido con
   confianza ≥ umbral y no neutral.
4. **Resumen por componente:**
   - postura (−1 a +1, con IC 95 %);
   - contradicciones;
   - puntos ciegos (afirmaciones que ninguna reacción toca);
   - mezcla de filtros (bíblico, cosmovisión, impulso);
   - paz media.
5. **Mapa 2D:** PCA de los embeddings encontrados, solo para el ojo. Nodos dorados para Cristo y azules para mí;
   aristas verdes si confirmo y rojas si contradigo.

**Hallazgos al probarlo con los modelos reales.**
- **El embedding del System One no sirve para buscar por temática.** Para "amor", la factura de la luz quedó en
  0.65 y "le grité a mi esposa" en 0.33: se entrenó para la estructura del razonamiento, no para el tema. Por
  eso solo preselecciona.
- **El System One no sirve para estas dos preguntas.** En la temática responde siempre neutral. En la postura
  comete errores con confianza alta, por ejemplo "le dije que no podía mentir" contradice la honestidad con
  C 1.00. Solo responde el juez grande.
- **El juez grande, sin entrenar para esto, acierta lo claro:** "le grité" contradice el amor (−0.88) y la
  factura trata del dinero.
- **Falla casos importantes:**
  - "la perdoné" contradice el amor;
  - negarse a mentir contradice la honestidad;
  - "El amor es sufrido…" no trata del amor, con P < 0.5.
- **Causa:** se entrenó para comparar creencias entre sí, y esta es otra tarea, acción ↔ principio.

**Siguiente paso: semillas de la tarea acción ↔ principio.**
- **Datos:** pares con las etiquetas encarna (E), viola (C) y no aplica (N), en los 7 registros.
- **Temática:** pares "trata sobre {tema}".
- **Entrenamiento:** ajustar `mdeberta_v4` como multitarea, vigilando que los pares mínimos NLI no bajen.
- **Sin cambios en la app:** las mismas preguntas y el mismo formato de paquete.
