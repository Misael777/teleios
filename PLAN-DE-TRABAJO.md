# 📋 PLAN DE TRABAJO — TELEIOS v1

Plan de entrega por **sprints de 2 semanas** para un desarrollador a tiempo parcial (~15-20 h/semana).
Fundamento técnico: [`docs/ANALISIS-TECNICO.md`](./docs/ANALISIS-TECNICO.md) · Visión: [`ARCHITECTURE.md`](./ARCHITECTURE.md).

**Duración estimada:** Sprint 0 (1 semana) + 13 sprints ≈ **27 semanas (~6,5 meses)**.
**Costo de infraestructura:** $0 (+ $25 Play Store; + $99/año si se publica en iOS).

---

## 🗺️ Roadmap por releases

Cada release es **usable por sí sola**. Si el proyecto se pausa en cualquier punto, lo construido sirve.

| Release | Sprints | Qué obtiene el usuario | Backend |
|---------|---------|------------------------|---------|
| **0.1 — Personal** | S0 – S8 | Estudio + Bitácora + Altar + Dashboards + Grafo, todo offline y cifrado | Ninguno |
| **0.2 — Respaldo** | S9 | Backup/restore cifrado en Google Drive o archivo | Google Drive |
| **0.3 — Comunidad** | S10 – S11 | Cuentas, comunidades, subgrupos, devocionales públicos con imágenes | Supabase |
| **0.4 — Líder (Beta)** | S12 – S13 | Métricas anónimas, dashboard de salud con drill-down, IA semántica, release en tiendas | Supabase |

```
Semana:  1  3  5  7  9  11 13 15 17 19 21 23 25 27
         S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13
         ├────────── 0.1 Personal ──────────┤
                                            ├0.2┤
                                                ├─0.3─┤
                                                      ├─0.4─┤
```

---

## ✅ Definition of Done (aplica a toda historia)

- [ ] `flutter analyze` sin warnings · `dart format` aplicado.
- [ ] Lógica de dominio con tests unitarios (cobertura de `domain/` ≥ 80%).
- [ ] Widgets de flujos críticos con al menos un widget test.
- [ ] ~~Textos de UI en `l10n/app_es.arb`~~ → pospuesto (ver nota l10n en S4).
- [ ] Ningún dato 🔴 sale del dispositivo (revisado en el PR).
- [ ] Funciona en Android y Windows/macOS (iOS desde S8).
- [ ] PR revisado (autorrevisión con checklist si se trabaja solo) y CI verde.

## 🔁 Ceremonias (versión solo-dev)

- **Planning** (lunes inicio de sprint, 45 min): mover historias de backlog a sprint en GitHub Projects.
- **Daily** (5 min escrito): una línea en el issue del sprint.
- **Review/Demo** (fin de sprint): grabar un video de 2 min del incremento → evidencia del entregable.
- **Retro** (15 min): qué ajustar; registrar cambios de alcance al final de este archivo.

---

## 🧱 SPRINT 0 — Decisiones y Andamiaje *(1 semana)* ✅ 2026-10-27

**Objetivo:** que cualquier línea de código futura tenga dónde vivir y cómo validarse.

- [x] ADRs en `docs/adr/` (001 Drift, 002 IA, 003 Privacidad/K-anonimato, 004 Backup).
- [x] Proyecto Flutter en `app/` (monorepo: `supabase/` vivirá al lado desde el S10). Plataformas: android, ios, windows, macos, linux, web.
- [x] Estructura feature-first + Clean Architecture (ver `ARCHITECTURE.md`).
- [x] Paquetes base: `flutter_riverpod`, `go_router`, `drift` + `sqlite3` (SQLite3MultipleCiphers), `flutter_secure_storage`, `intl`, `uuid`, `local_auth`, `share_plus`.
  - ⚖️ *Cambio:* sin `freezed` ni `riverpod_generator` (clases inmutables simples; menos codegen). Drift sí usa `build_runner`.
- [x] Lints: `flutter_lints` + reglas estrictas (`strict-casts`, `strict-raw-types`, `unawaited_futures`…). Formato a 120 columnas.
- [x] Entornos `dev` / `prod` con `--dart-define-from-file=config/<env>.json` (base de datos separada por entorno).
- [x] GitHub Actions: código generado de Drift al día + formato + analyze + test con cobertura de dominio + APK debug.
- [ ] GitHub Projects con columnas e issues → **requiere tu cuenta de GitHub** (pendiente).
- [x] Tema Material 3 claro/oscuro con tokens de las 4 dimensiones (`DimensionColors`).

**Entregable:** ✅ compila en Windows (verificado) y Android (APK verificado con `libsqlite3mc.so` para arm64/armv7/x86_64).

---

## 🗄️ SPRINT 1 — Dominio y Persistencia Cifrada ✅ 2026-10-27

- [x] Entidades de dominio en Dart puro: `Dimension`, `Topic` (con máquina de estados), `PassageRef`, `HistoricalContext`, `PraxisEntry`, `PrayerEntry`, `DevotionalEntry`.
  - ⚖️ *Cambio:* se agrega `TopicStatus.refutado` — una cosmovisión examinada y descartada se conserva como registro (no se borra).
- [x] Esquema Drift `schemaVersion = 1` con **todas** las tablas (incluye Bitácora y Altar, para no migrar en S5/S6).
- [ ] Test de migración con `drift_dev schema dump` → se agrega al crear `schemaVersion = 2`.
- [x] Cifrado SQLite3MultipleCiphers con llave de 256 bits en Keychain/Keystore/DPAPI. **Test:** el archivo no contiene texto plano, no abre con otra llave y sí con la correcta. Verificado también en la app real de Windows.
- [x] Seeds: 4 dimensiones, 25 emociones (primarias/secundarias), 9 detonantes, 10 épocas, 26 hitos bíblicos.
- [x] Índice bíblico **completo** (RV1909, 31.102 versículos) — adelantado del S3.
- [x] Repositorios con contratos en `domain` e implementación Drift en `data`.
- [x] Casos de uso: `CreateTopic` (sin duplicados por nombre normalizado), `CreateIncubationTopic`, `ValidateTopic`, `RefuteTopic`, `ReopenTopic`.
- [ ] `MarkAsShadow` → movido al **S7** (necesita datos de praxis para detectar fallas recurrentes).
- [x] Tests con Drift en memoria.

---

## 📱 SPRINT 2 — Shell de la App, Seguridad y Onboarding ✅ 2026-10-27

- [x] Navegación `go_router` + `StatefulShellRoute`: Estudio · Bitácora · Altar · Ejes. Barra inferior en móvil, riel lateral en pantallas ≥ 840 px.
- [x] Bloqueo biométrico/PIN (`local_auth`) al abrir y tras ≥ 1 min en segundo plano; el contenido no se pinta mientras está bloqueado.
- [x] Onboarding en 3 pasos con **dos consentimientos obligatorios** (datos sensibles · no es herramienta de salud mental).
- [x] Ajustes: tema, bloqueo (pide autenticación para cambiarlo), exportar JSON (con aviso de que no va cifrado), borrar todo (escribiendo BORRAR).
  - [ ] Selector de idioma → la app es solo en español por ahora (ver nota l10n abajo).
- [x] `Failure` sealed + `AppLogger` local + pantalla de error de arranque (llave perdida → opción de empezar de cero).
- [x] Componentes: `DimensionChip`, `ScoreSlider`, `EmptyState`, `SectionCard`, `ComingSoonScreen`.
- [x] Android: `FlutterFragmentActivity`, permiso `USE_BIOMETRIC`, **auto-backup del sistema desactivado** (restauraría la base sin su llave). iOS: `NSFaceIDUsageDescription`.

---

## 📖 SPRINT 3 — Estudio I: Devocional + Biblia ✅ 2026-10-27

- [x] RV1909 (dominio público, eBible.org) empaquetada como SQLite + FTS5 comprimido (3,8 MB). Script reproducible: `app/tool/build_bible_db.py`.
- [ ] Concordancia Strong → **la fuente RV1909 no trae números Strong**. Pendiente buscar una fuente de dominio público etiquetada (backlog).
- [x] Lector bíblico: libro/capítulo, anterior/siguiente, búsqueda por palabras (sin tildes, prefijos, resaltado) o por cita ("Ro 8:28"). Mantener pulsado un versículo inicia un devocional.
- [x] Selector de pasaje: cita escrita ("gá 5:22-23", "1co 13.4") o libro → capítulo → rango tocando versículos.
- [x] Editor del devocional (texto plano multilínea; ⚖️ *cambio:* sin `flutter_quill` hasta validar que hace falta formato enriquecido).
- [x] Tópicos manuales por dimensión: elegir existente (autocompletar) / crear / mover de dimensión / quitar.
- [x] Lista con filtros por dimensión y libro; detalle con texto bíblico, reflexión, tópicos y contexto. Aviso al salir con cambios sin guardar.
  - [ ] Filtro por rango de fechas → al S7 (junto al heatmap).
- [x] Widget tests: sección de tópicos + flujo completo de crear devocional.

**Entregable:** ✅ escribo un devocional sobre Gálatas 5 y lo etiqueto con "Paciencia" en Vida Práctica (cubierto por el test de flujo).

---

## 🧭 SPRINT 4 — Estudio II: Cronología + Sugeridor Nivel 0 + Incubación ✅ 2026-10-27

- [x] Formulario cronológico (época, imperio, región, autor, año a.C./d.C.) **pre-llenado** con el autor y la época tradicionales del libro.
- [x] Línea de tiempo: épocas, hitos arriba, devocionales abajo (color = dimensión dominante), zoom, toque para abrir. Dos escalas: **por épocas** (por defecto; el NT no queda aplastado) y **real**. Panel de densidad por época.
- [x] `AiClassificationService` (`choose / score / noul`) + `LexicalClassifier` (nivel 0).
- [x] `TopicSuggester`: léxico de 47 tópicos en español + tus tópicos mencionados + historial del mismo libro; cada sugerencia explica **por qué**.
- [x] UI del sugeridor: chips ✨ (aceptar), ✕ (descartar), recalcular; espera de 600 ms al escribir.
- [x] Pantalla "Incubación teológica": crear cosmovisión, validar con pasaje, refutar con motivo (y pasaje opcional), reabrir.
- [ ] 🎯 **Dogfooding diario** → acción tuya desde hoy.

**Entregable:** ✅ el sugeridor propone tópicos razonables sin conexión (test: Gálatas 5 → Paciencia, Dominio propio, Fruto del Espíritu, Cartas paulinas).

### 📊 Estado de calidad al cierre del S4

| Métrica | Valor |
|---------|-------|
| Tests | **81 en verde** (unitarios, datos, cifrado, Biblia real, widgets, flujo E2E) |
| `flutter analyze` | 0 issues |
| Builds verificados | Windows debug ✅ (ejecutada) · Android APK debug ✅ |
| No verificado | iOS/macOS (requiere Mac o Codemagic) · ejecución en un teléfono Android físico |

### ⚖️ Nota sobre l10n

La DoD pedía textos en `app_es.arb`. Se decidió **posponer l10n**: la app es solo en español y migrar después es mecánico. Se retoma si aparece demanda de otro idioma.

---

## 📝 SPRINT 5 — Bitácora de Praxis A-B-C ✅ 2026-10-27

- [x] Flujo guiado en 4 pasos (Stepper): **A** circunstancia + emociones + intensidad → **B** filtro + fundamento + tópicos → **C** acción, paz y coherencia → fotos.
- [x] Rama "falla" (impulso): detonantes del catálogo + "Otro" propio.
- [x] Rama "cosmovisión": la creencia se crea en Incubación y se vincula; o se elige una ya incubada.
- [x] Sugerencias de tópicos: primero los **estudiados en los últimos 14 días**, más el sugeridor léxico sobre el texto.
- [x] Fotos privadas: se reducen a 1600 px, **se borran sus metadatos EXIF (GPS, cámara)** y se guardan **cifradas** (AES-GCM).
- [x] **Registro rápido** (< 30 s): circunstancia, emoción, intensidad, filtro y paz. La coherencia queda vacía (no se inventa) y el detalle invita a completarla.
- [x] Emociones primarias → secundarias desplegables, con emociones propias.
- [x] **Migración de esquema v1 → v2** (coherencia opcional y tabla de adjuntos) con test que valida el esquema migrado contra una instalación nueva. Cierra la tarea pendiente del S1.
- [x] Reglas: un tópico nuevo creado en la bitácora nace **en incubación**, salvo que se cite un pasaje.
- [x] Tests: guardado, reglas de tópicos, rollback de archivos si falla la transacción, borrado en cascada y cifrado de adjuntos.

**Entregable:** ✅ registro una falla por impaciencia vinculada a "Paciencia" (test de flujo con registro rápido incluido).

---

## 🎙️ SPRINT 6 — Altar: Oración por Voz ✅ 2026-10-27

- [x] `SpeechService` (interfaz) + `DeviceSpeechService` con `speech_to_text` en modo **on-device** (`onDevice: true`, locale en español).
- [x] Si el dispositivo no ofrece dictado sin conexión → el micrófono se desactiva y se explica por qué (no se envía la voz a servidores).
- [x] Voz **deshabilitada en Web** por diseño.
- [x] Onda animada (`CustomPainter`) con niveles normalizados por plataforma.
- [x] Transcripción editable; **el audio nunca se guarda**.
- [x] Intención sugerida por un clasificador léxico (agradecimiento / petición / lamentación) con su explicación; el usuario confirma.
- [x] Tópicos de la oración (nacen en incubación) y **vínculo a registros de la bitácora de los últimos 7 días**.
- [x] Permisos: Android `RECORD_AUDIO` + consulta de `RecognitionService`; iOS micrófono y reconocimiento de voz.
- [x] Tests con un servicio de voz falso: dictado → intención sugerida → guardado; y el caso sin dictado sin conexión.

**Entregable:** ✅ dicto una oración y queda transcrita, clasificada y vinculada (probado con voz simulada).
- [ ] **Probar el dictado real en un teléfono Android**: no fue posible en este entorno.

---

## 📈 SPRINT 7 — Motor Analítico + Dashboards ✅ 2026-10-27

- [x] Servicios de dominio puros, todos con tests:
  - `Statistics`: media, mediana, rangos con empates, Pearson, **Spearman**, **IET** normalizado.
  - `topicStats`: estudios, praxis, fallas, coherencia media (solo registros evaluados), paz, IET y **desfase** (mediana de días entre estudiar y vivir).
  - `studyVsCoherence`: correlación con **n ≥ 8**; con menos muestra se rotula "datos insuficientes".
  - `blindSpots`: 3 o más fallas por un detonante en 7 días sin estudiar sus "remedios" en 20 días.
  - `shadowCandidates` + `MarkTopicAsShadow` (pendiente del S1): **la app propone y el usuario confirma**.
- [x] Dashboards (`fl_chart`): KPIs, radar de dimensiones, heatmap de 20 semanas, paz semanal, dispersión estudio ↔ coherencia con ρ y n, ranking por IET con desfase.
- [x] Selector de período (30 días / 90 días / 1 año / todo). Equivale al filtro por fechas que estaba pendiente.
- [x] El lenguaje siempre habla de **correlación**, con la aclaración "no es causa y efecto".

---

## 🕸️ SPRINT 8 — Grafo de Personalidad + Aluvión ✅ 2026-10-27 · Release 0.1 ⏳

- [x] Grafo **propio** de fuerza dirigida (Fruchterman-Reingold), **determinista** (semilla fija) y calculado en otro isolate.
  - ⚖️ *Cambio:* sin `graphview`. El layout propio es testeable, pinta las aristas por paz y fija las 4 dimensiones en los puntos cardinales para que el mapa sea estable entre visitas.
  - Nodos: dimensión → tópico (sólido, punteado si está en incubación, borde rojo si es sombra) → emoción (pulsa si la intensidad promedio es 8 o más).
  - Aristas tópico ↔ emoción coloreadas por la paz promedio (rojo → verde). Zoom, centrado, toque para ver el detalle y filtro por dimensión.
- [x] Aluvión **Emoción primaria → Filtro → Paz** (baja / media / alta) con conservación de flujo verificada por test.
- [x] Política de privacidad: [`docs/PRIVACIDAD.md`](./docs/PRIVACIDAD.md), lista para publicar con GitHub Pages.
- [x] Builds firmadas: `build-release.bat` (Windows portable + APK firmado).
- [ ] Prueba de rendimiento con 200 nodos en un teléfono de gama media.
- [ ] **Play Console** (internal testing) y formulario *Data Safety*: requieren tu cuenta (USD 25).

---

## 💾 SPRINT 9 — Backup Cifrado ✅ 2026-10-27 (Release 0.2)

- [x] Formato `.teleios`: cabecera autenticada + AES-256-GCM. La llave de datos va envuelta por la **contraseña (Argon2id, en otro isolate)** y por el **código de recuperación** (Base32, 256 bits). Ver ADR-004 revisado.
  - ⚖️ *Cambio:* exportación lógica (JSON + adjuntos) en vez de `VACUUM INTO`. El backup no depende de la llave del dispositivo y sobrevive a cambios de esquema.
- [x] Configurar, cambiar la contraseña y regenerar el código de recuperación (se muestra **una vez** y hay que confirmar que se guardó).
- [x] Destino **archivo**: compartir en móvil, "Guardar como" en escritorio.
- [x] Destino **Google Drive** `appDataFolder` (scope `drive.appdata`, conserva 5): conectar, respaldar, listar, restaurar y desconectar.
- [x] **Respaldo automático semanal** al abrir o volver a la app.
  - ⚖️ *Cambio:* sin `workmanager`, para no depender de tareas en segundo plano.
- [x] Restaurar: rechaza backups de versiones más nuevas y **no toca nada si la contraseña es incorrecta**. Conserva las llaves para los respaldos siguientes.
- [x] Test E2E: respaldo → borrar todo → restaurar deja los **datos idénticos** (todas las tablas y las fotos). Restaurar en "otro dispositivo" funciona solo con el código de recuperación.
- [ ] **Credenciales OAuth de Google**: requieren tu cuenta de Google Cloud. Guía en [`docs/GOOGLE-DRIVE-SETUP.md`](./docs/GOOGLE-DRIVE-SETUP.md). Mientras tanto, el respaldo a archivo funciona y se puede guardar en Drive desde la hoja de compartir.

### 📊 Estado de calidad al cierre del S9

| Métrica | Valor |
|---------|-------|
| Tests | **151 en verde** (dominio, datos, migración v1 → v2, cifrado, backup E2E, analítica, grafo, aluvión, widgets) |
| `flutter analyze` | 0 issues |
| Bugs encontrados por los tests y las capturas | 7 (Hero duplicado, isolate que capturaba el widget, controlador creado en `dispose`, etiquetas de gráficos encimadas, entre otros). Todos corregidos |
| Pendiente de probar en dispositivo | dictado real, Google Drive real (requiere OAuth), cámara |

---

## 👥 SPRINT 10 — Supabase: Cuentas, Comunidades y Subgrupos

**Objetivo:** la base multiusuario segura (sin tocar aún datos privados).

- [ ] Proyecto Supabase `prod` + `dev`; **migraciones SQL versionadas** en `supabase/migrations` (CLI) con `GRANT` explícitos y RLS en todas las tablas.
- [ ] Auth: Google (reutiliza la cuenta del backup) + email magic link.
- [ ] Esquema: `profiles`, `communities`, `groups` (`parent_id` + columna `ltree path`), `group_members(role: member|leader|admin)`, `invitations` (código/QR).
- [ ] Políticas RLS: miembro ve su grupo y ancestros; líder ve su subárbol; admin todo en su comunidad.
- [ ] Tests de RLS con `pgTAP` (`supabase test db`) en CI.
- [ ] Keep-alive: GitHub Action cada 3 días para evitar la pausa del free tier.
- [ ] UI: crear/unirse a comunidad, árbol de subgrupos, gestionar miembros.
- [ ] La app sigue funcionando 100% offline si el usuario nunca inicia sesión.

**Entregable:** creo una comunidad con 3 niveles de subgrupos e invito a testers.

---

## 📢 SPRINT 11 — Devocionales Comunitarios + Imágenes (Release 0.3)

**Objetivo:** hermenéutica colaborativa.

- [ ] "Publicar a la comunidad" desde un devocional (copia explícita del texto; nunca automático).
- [ ] Feed por comunidad/subgrupo, filtros por pasaje y dimensión.
- [ ] Interpretaciones: proponer tópico/dimensión sobre un pasaje; votos útil/no-útil; "adoptar en mi devocional".
- [ ] Imágenes públicas: compresión cliente (WebP, máx. 1280 px, ~150 KB) → **Supabase Storage** bucket `public-devotionals` con RLS por comunidad.
- [ ] Abstracción `ObjectStorage` con implementación R2 lista (Edge Function que firma URLs) para cuando Storage pase el 80%.
- [ ] Moderación mínima: reportar, ocultar por líder, borrar propio contenido.
- [ ] Borrado de cuenta in-app (requisito de tiendas).

**Entregable 🚀 Release 0.3:** testers publican y comentan interpretaciones con imágenes.

---

## 🩺 SPRINT 12 — Métricas Anónimas + Dashboard de Líder

**Objetivo:** "backpropagation pastoral" sin violar la privacidad.

- [ ] Opt-in explícito "compartir métricas anónimas con mi grupo".
- [ ] Cliente calcula **semanalmente** por tópico/dimensión: `avg_coherencia`, `avg_paz`, `iet`, `n_registros` — sin texto, sin fechas exactas.
- [ ] Envío vía RPC `submit_weekly_metrics(group_id, week, vector)`; la tabla cruda **no** tiene `SELECT` para nadie (solo `SECURITY DEFINER`).
- [ ] RPC `get_group_health(group_id, desde, hasta)`:
  - Agrega hojas → raíz por `ltree`.
  - Umbral **k = 5 reportantes distintos** en el período.
  - **Supresión complementaria** para evitar despeje por resta (ver ADR-003).
- [ ] Tests de propiedad: para cualquier árbol aleatorio, ningún grupo con < 5 reportantes es deducible.
- [ ] Dashboard de líder: treemap jerárquico (tamaño = reportantes, color = paz), drill-down, tendencia por subgrupo, tópicos con IET más alto/bajo.
- [ ] Vista Web habilitada para el líder (solo capa comunitaria).

**Entregable:** el líder navega comunidad → red → célula y ve "datos insuficientes" donde corresponde.

---

## 🤖 SPRINT 13 — IA Semántica + Endurecimiento + Release Beta (0.4)

**Objetivo:** mejor sugeridor y salida a beta pública.

- [ ] `EmbeddingClassifier` (nivel 1): modelo multilingüe cuantizado vía `onnxruntime`, **descarga opcional** (no infla la app). `choose` = similitud coseno texto ↔ tópicos/prototipos.
- [ ] `OllamaClassifier` (nivel 2, desktop): detección automática de `localhost:11434`, prompt con salida JSON tipada.
- [ ] Selector de proveedor en Ajustes; fallback automático al nivel 0.
- [ ] Evaluación: set de 100 ejemplos etiquetados a mano → precisión top-3 de cada nivel (dejar registrado).
- [ ] **Auditoría de privacidad**: revisar con proxy (mitmproxy) que ningún request contenga texto 🔴.
- [ ] Pruebas E2E (`integration_test`): devocional → praxis → oración → dashboard → backup.
- [ ] Crashlytics alternativo opt-in (Sentry free) o ninguno.
- [ ] Play Store **Open testing** (+ TestFlight si iOS). README final.

**Entregable 🚀 Release 0.4 Beta** pública.

---

## 📌 Backlog post-Beta

- Sync E2E en vivo entre dispositivos (p. ej. PowerSync/CRDT con cifrado cliente).
- STT 100% offline con `whisper.cpp`.
- Otras traducciones bíblicas vía API con licencia.
- Mapa geográfico interactivo de eventos bíblicos.
- Exportación de dashboards a PDF.
- Recordatorios inteligentes (notificaciones locales).
- Jev API opt-in para clasificar contenido comunitario público.
- Grupos de estudio colaborativo en tiempo real (Supabase Realtime).

---

## 🧪 Métricas del proyecto

| Métrica | Meta |
|---------|------|
| Cobertura `domain/` | ≥ 80% |
| Tiempo para registrar praxis express | < 30 s |
| Arranque en frío (gama media) | < 2 s |
| Tamaño APK base (sin modelo IA) | < 40 MB |
| Crash-free sessions en beta | ≥ 99% |
| Uso de Supabase Free | < 70% de cada límite |

---

## 📝 Registro de cambios de alcance

| Fecha | Cambio | Motivo |
|-------|--------|--------|
| 2026-10-27 | Plan reestructurado de 6 fases a 13 sprints con releases incrementales | Ver `docs/ANALISIS-TECNICO.md` §2 |
| 2026-10-27 | Isar → Drift; LocalJev → heurística + ONNX; RVR60 → RV1909 | Mantenimiento, existencia real de la tecnología, licencias |
| 2026-10-27 | Se agrega backup cifrado a Google Drive (Sprint 9) | Requisito: respaldo personal sin costo |
| 2026-10-27 | Sprints 0-4 completados | Ver estado de calidad en el S4 |
| 2026-10-27 | Sin `freezed`/`riverpod_generator`; sin `flutter_quill`; l10n pospuesto | Menos dependencias y codegen; agregar cuando haga falta |
| 2026-10-27 | Nuevo estado `refutado` para tópicos | Conservar el proceso de discernimiento («examinadlo todo») |
| 2026-10-27 | `MarkAsShadow` y filtro por fechas → S7 | Dependen de datos de praxis / heatmap |
| 2026-10-27 | Sprints 5-9 completados (Release 0.2) | Ver estado de calidad en el S9 |
| 2026-10-27 | Grafo propio en vez de `graphview` | Determinista, testeable, aristas por paz |
| 2026-10-27 | Backup lógico (JSON+ZIP) en vez de `VACUUM INTO`; automático al abrir en vez de `workmanager` | Independiente de la llave del dispositivo y del esquema; sin permisos de segundo plano |
| 2026-10-27 | Esquema v2: coherencia opcional + adjuntos cifrados | Registro rápido honesto; privacidad de fotos |
| 2026-10-29 | Reflexión guiada en 5 secciones (exégesis, hermenéutica, teología, homilética opcional, aplicación) con batería de preguntas; la pregunta clave de cada sección es obligatoria | Pedido del usuario: guiar y obligar a desarrollar la reflexión. Se guarda en `content` con un encabezado por pregunta; las reflexiones anteriores se reubican solas |
| 2026-10-29 | Versículos vinculados escribiendo `{` en la reflexión | Se guardan como texto legible `{Juan 3:16}`; en el detalle se tocan para leer el pasaje |
| 2026-10-29 | Esquema v3: portada del devocional (título y versículo lema) + portada de la app (logo, ΤΕΛΕΙΟΣ, Mateo 5:48) | Presentación profesional; la portada al abrir se puede desactivar en Ajustes |
| 2026-10-29 | Épocas anteriores a Abraham: Creación y antediluvianos, Diluvio y Babel | Faltaban Génesis 1-11; Génesis se ubica por capítulo |
| 2026-10-29 | Red de pasajes en la línea de tiempo: riel de versículos vinculados ubicados en su época, hilos de cada devocional a cada versículo con el color de la sección donde se citó, filtro por sección y selección con ficha | Pedido del usuario: ver la interconexión de pasajes y de qué sección (exégesis, homilética…) nace cada vínculo. Sin cambio de esquema: se deriva de las citas `{…}` |
| 2026-10-30 | Plan de coherencia medida (`docs/PLAN-COHERENCIA.md`): Sprints 11-17 en dos líneas paralelas, app (O4 → O2 → O1) y laboratorio `ml/` (System One local multi-cabeza + clusterizador de grafo con signo, destilación maestro → alumno en la GPU local) | La coherencia pasa de declararse a medirse con evidencia; la negación se trata como restricción, no como parecido; el diario nunca sale del teléfono |
| 2026-10-31 | Sprints 11-15 de coherencia medida (app 0.4.0+8, esquema v4): creencias, evidencia canónica con referencias cruzadas de OpenBible, vínculos desde/contra, gráficos 1-8, etiquetado compartido, juez local ONNX (System One) con tokenizador en Dart, prototipos de pensamiento | Resultados y límites en `docs/PLAN-COHERENCIA.md` §12. Ningún juez cumple aún el 90 % en pares mínimos (alumno int8: 72/84): el modelo solo sugiere |
| 2026-10-31 | Laboratorio `ml/`: línea base, generador sintético, grafo con signo (0 % de opuestos mezclados, 7/7 antagonistas), System One multi-cabeza calibrado y exportación del paquete | La GPU local alcanza; el diario nunca entra al laboratorio |
| 2026-10-31 | Corrección: los streams `customSelect('SELECT 1', readsFrom: …)` de devocionales, bitácora, altar y Ejes compartían un único stream | Drift reutiliza streams por SQL e ignora `readsFrom`: solo se vigilaban las tablas del primero que se registraba. Ahora cada repositorio usa un SQL propio |
