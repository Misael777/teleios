# 📋 PLAN DE TRABAJO — MVP 1

Plan del MVP 1 de **TELEIOS** dividido en **6 fases** secuenciales. Cada fase produce entregables verificables antes de avanzar a la siguiente.

**Duración estimada total:** ~14-16 semanas (trabajo individual a tiempo parcial).

---

## 🎯 Criterios de Éxito del MVP 1

Al cierre del MVP 1, la aplicación debe permitir a un usuario:

- [ ] Registrar devocionales con tópicos validados manualmente.
- [ ] Registrar praxis diaria con el modelo A-B-C (circunstancia, emoción, filtro, acción).
- [ ] Grabar y transcribir oraciones por voz.
- [ ] Visualizar su grafo de personalidad con nodos validados e incubados.
- [ ] Consultar un dashboard clínico personal con correlaciones.
- [ ] (Beta) Un líder puede observar métricas comunitarias anonimizadas por subgrupo anidado.

---

## 🏗️ FASE 1 — Fundación del Proyecto

**Objetivo:** base técnica lista para construir el modelo de dominio.

- [ ] Crear repositorio `teleios-system-one` en GitHub.
- [ ] Subir `README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, `PLAN-DE-TRABAJO.md`, `LICENSE`.
- [ ] Inicializar proyecto Flutter multiplataforma (`flutter create` con iOS, Android, macOS, Windows, Web).
- [ ] Configurar estructura de carpetas según Clean Architecture (ver `ARCHITECTURE.md`).
- [ ] Configurar `analysis_options.yaml` con `flutter_lints` estrictos.
- [ ] Configurar `riverpod` como gestor de estado principal.
- [ ] Configurar tema base (Material 3) con tokens de color para las 4 dimensiones teológicas.
- [ ] Configurar CI básico en GitHub Actions (analyze + test).

**Entregable:** Proyecto que compila en las 5 plataformas sin errores de lint.

---

## 🗄️ FASE 2 — Modelo de Dominio y Persistencia Local

**Objetivo:** capa de datos completa y testeada antes de construir UI.

- [ ] Definir entidades de dominio en Dart puro (`Dimension`, `Topic`, `DevotionalEntry`, `PraxisEntry`, `PrayerEntry`, `Emotion`, `Subgroup`).
- [ ] Implementar colecciones Isar con `@collection` y relaciones `IsarLink` / `IsarLinks`.
- [ ] Sembrar las **4 dimensiones fijas** en el primer arranque (migración seed).
- [ ] Implementar repositorios (`TopicRepository`, `PraxisRepository`, `PrayerRepository`).
- [ ] Escribir tests unitarios de repositorios (cobertura > 70%).
- [ ] Implementar cálculo del **Índice de Coherencia** y **Nivel de Paz** agregados.
- [ ] Implementar lógica de **validación de nodo**: pasar de *Cosmovisión (por validar)* a *Bíblico (validado)*.

**Entregable:** base de datos funcional con tests verdes.

---

## 📖 FASE 3 — Módulo de Estudio (Devocionales)

**Objetivo:** captura de devocionales con sugeridor híbrido de tópicos.

- [ ] Pantalla de creación de devocional con editor de texto enriquecido.
- [ ] Selector de versículo con búsqueda local (índice bíblico mínimo precargado).
- [ ] Formulario cronológico estructurado (época, imperio, región, autor).
- [ ] UI del sugeridor híbrido: chips agrupados por las 4 dimensiones.
- [ ] Implementar flujo **aceptar / mover / crear tópico propio**.
- [ ] Pantalla de "Lista de Incubación Teológica" para conductas por validar.
- [ ] Vista de línea de tiempo histórica con hitos bíblicos precargados.
- [ ] Tests de widget para el sugeridor híbrido.

**Entregable:** un usuario puede registrar y estructurar un devocional completo.

---

## 📝 FASE 4 — Bitácora de Praxis y Emociones

**Objetivo:** captura del modelo A-B-C con todas las variantes.

- [ ] Pantalla de nueva entrada de praxis con flujo A-B-C guiado.
- [ ] Chips de emociones primarias y secundarias (catálogo precargado editable).
- [ ] Sliders de Intensidad Emocional, Coherencia y Paz (1-10).
- [ ] Selector de filtro: **Bíblico / Cosmovisión / Impulso**.
- [ ] Formulario de "detonante" en caso de falla (ira, orgullo, miedo, cansancio).
- [ ] Vinculación de entrada de praxis a tópicos existentes.
- [ ] Integración con "Lista de Incubación" (crear nodo punteado si aplica).
- [ ] Tests de lógica de correlación praxis ↔ tópico.

**Entregable:** bitácora completa con fallas, cosmovisiones e impulsos registrados.

---

## 🎙️ FASE 5 — Módulo de Oración por Voz

**Objetivo:** captura, transcripción y clasificación de oraciones.

- [ ] Integrar `speech_to_text` (o STT nativo vía MethodChannel) para transcripción local.
- [ ] UI de grabación con waveform animado (`AnimationController` + `CustomPainter`).
- [ ] Guardar transcripción asociada a la entrada de oración.
- [ ] Implementar `AiClassificationService` con la interfaz de clasificación.
- [ ] Implementar el cliente de **Ollama** para Desktop (HTTP local).
- [ ] Implementar prompt de clasificación con formato Jev: `Choice` (tópicos), `Score` (intensidad), `Noul` (intención).
- [ ] Vincular tópicos de la oración a la Bitácora y al grafo.
- [ ] Tests de integración con Ollama usando un modelo mockeado.

**Entregable:** usuario dicta una oración, obtiene transcripción y tópicos vinculados.

---

## 📊 FASE 6 — Dashboards y Cierre de MVP 1

**Objetivo:** visualización completa personal + vista comunitaria.

### 6A — Dashboard Personal
- [ ] Grafo de fuerza dirigida con `graphview` (nodos dimensión, tópico, emoción).
- [ ] Lógica de color de enlaces por tensión (rojo → verde según nivel de paz).
- [ ] Animación de "pulso" para emociones de alta intensidad.
- [ ] Gráfico de radar de balance de dimensiones.
- [ ] Gráfico de dispersión: estudio ↔ coherencia.
- [ ] Heatmap temporal (estilo GitHub commits).
- [ ] Diagrama de aluvión: Circunstancia → Emoción → Filtro → Paz.

### 6B — Capa Comunitaria (Beta)
- [ ] Configurar proyecto en Supabase (tablas multiusuario + Edge Functions).
- [ ] Implementar sincronización de **solo vectores numéricos anonimizados**.
- [ ] Implementar estructura de subgrupos anidados (adjacency list).
- [ ] Implementar regla de **K-Anonimato (N ≥ 5)** en queries de agregación.
- [ ] Dashboard de líder con **Treemap jerárquico** y navegación por niveles.
- [ ] Algoritmo de propagación de métricas de subgrupo hoja → nodo raíz.

### 6C — Cierre
- [ ] Auditoría de privacidad: verificar que datos cualitativos nunca salen del dispositivo.
- [ ] Suite de tests end-to-end del flujo completo (devocional → praxis → oración → dashboard).
- [ ] Documentar en `README.md` el estado final del MVP 1.
- [ ] Preparar builds de release para Android y Desktop.

**Entregable:** MVP 1 funcional, testeado y listo para usuarios beta.

---

## 🧪 Fase Continua — Calidad

Actividades permanentes durante todas las fases:

- [ ] Mantener cobertura de tests > 70% en la capa de dominio.
- [ ] Ejecutar `flutter analyze` sin warnings antes de cada merge.
- [ ] Documentar decisiones arquitectónicas en `/docs/adr/`.
- [ ] Revisión bíblica de la terminología usada en la UI (precisión teológica).

---

## 📌 Priorización Post-MVP 1 (Backlog)

Ideas fuera del alcance del MVP 1:

- Comparación de traducciones bíblicas (RVR60, LBLA, NVI).
- Mapa geográfico interactivo de eventos bíblicos.
- Exportación de dashboards en PDF.
- Integración con calendario para recordatorios de praxis.
- Modo multijugador (grupo de estudio colaborativo en tiempo real).
- Análisis de sentimiento longitudinal por libro bíblico.

---

## ✅ Cómo Usar Este Plan

1. Cada vez que completes una tarea, marca `[x]`.
2. No avances de fase sin cerrar los entregables.
3. Si una fase requiere ajustar alcance, documenta el cambio en este mismo archivo con fecha.