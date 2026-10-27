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

## 📝 SPRINT 5 — Bitácora de Praxis A-B-C

**Objetivo:** capturar la vida real con el modelo completo.

- [ ] Flujo guiado de 4 pasos (stepper): **A** circunstancia → emociones (chips multiselección) + intensidad → **B** filtro (Bíblico / Cosmovisión / Impulso) + fundamento → **C** acción + coherencia + paz.
- [ ] Rama "falla": detonantes (ira, orgullo, miedo, cansancio…).
- [ ] Rama "cosmovisión": crea/actualiza nodo en Incubación automáticamente.
- [ ] Vincular a tópicos: sugerir primero los **estudiados en los últimos 14 días**.
- [ ] Adjuntar foto privada opcional (compresión a WebP, guardada en directorio privado de la app).
- [ ] Captura rápida (< 30 s): modo "registro express" con solo circunstancia + emoción + paz.
- [ ] Tests del use case de correlación praxis ↔ tópico.

**Entregable:** registro una falla por impaciencia vinculada a "Paciencia" en menos de 1 minuto.

---

## 🎙️ SPRINT 6 — Altar: Oración por Voz

**Objetivo:** dictar oraciones sin que salgan del teléfono.

- [ ] `speech_to_text` forzando reconocimiento **on-device** (Android 13+ `onDevice`, iOS `requiresOnDeviceRecognition`); si no está disponible → aviso claro + modo escritura.
- [ ] Deshabilitar voz en Web (el navegador envía audio a la nube).
- [ ] UI de grabación con waveform animado (`CustomPainter` alimentado por nivel de sonido).
- [ ] Transcripción editable antes de guardar; **no se guarda el audio** por defecto.
- [ ] Intención (Agradecimiento / Petición / Lamentación) sugerida por `LexicalClassifier`, confirmada por el usuario.
- [ ] Tópicos de la oración → puentes a Bitácora (`TopicLink` origen = oración).

**Entregable:** dicto una oración en modo avión, se transcribe y queda vinculada a mis tópicos.

---

## 📈 SPRINT 7 — Motor Analítico + Dashboards I

**Objetivo:** convertir los registros en insight, con estadística honesta.

- [ ] Servicios de dominio puros (100% testeados):
  - `CoherenceCalculator` (promedios por tópico/dimensión/período).
  - `IetCalculator` — `IET = Σ(coh·paz) / (100·n)` ∈ [0,1].
  - `CorrelationService` — Spearman estudio ↔ coherencia, con n mínimo = 8 y etiqueta de confianza.
  - `LagTimeAnalyzer` — días entre estudiar un tópico y aplicarlo.
  - `BlindSpotDetector` — ≥ 3 fallas por un detonante sin estudio relacionado en 20 días.
- [ ] Dashboards con `fl_chart`: radar de dimensiones, dispersión estudio↔coherencia, heatmap tipo GitHub, tendencias de paz.
- [ ] Tarjeta de "Puntos ciegos" con sugerencia de estudio (lenguaje no condenatorio).
- [ ] Lenguaje de UI: "correlación", nunca "demuestra" o "causa".

**Entregable:** pantalla Ejes con 4 gráficos alimentados por mis datos reales de 3+ semanas.

---

## 🕸️ SPRINT 8 — Grafo de Personalidad + Release 0.1

**Objetivo:** la visualización insignia y la primera versión publicable.

- [ ] Grafo de fuerza dirigida (`graphview` Fruchterman-Reingold, o `CustomPainter` propio si el rendimiento no alcanza con > 150 nodos).
  - Nodos: dimensión → tópico → emoción. Estilos: validado (sólido), incubación (punteado), sombra (alerta).
  - Color de arista por paz promedio (rojo → verde); pulso para emociones de alta intensidad.
  - Filtros: encender/apagar dimensiones, rango de fechas.
- [ ] Diagrama de aluvión (Sankey) Circunstancia → Emoción → Filtro → Paz.
- [ ] Rendimiento: grafo a 60 fps con 200 nodos en gama media (profiling).
- [ ] Build firmado Android (AAB) + Desktop (MSIX/DMG). iOS vía Codemagic (si se publica).
- [ ] Google Play **Internal testing**; política de privacidad en GitHub Pages; formulario Data Safety.

**Entregable 🚀 Release 0.1 Personal** instalada por 3-5 testers de confianza.

---

## 💾 SPRINT 9 — Backup Cifrado (Release 0.2)

**Objetivo:** que nadie pierda años de diario por perder el teléfono.

- [ ] Servicio `BackupService` (ver ADR-004):
  1. `VACUUM INTO` → snapshot consistente.
  2. Zip con adjuntos privados + `manifest.json` (versión de esquema, fecha, hash).
  3. Cifrado AES-256-GCM, llave derivada con **Argon2id** de la *passphrase de backup* (paquete `cryptography`).
- [ ] Configuración: passphrase + **código de recuperación** de 24 palabras (mostrado una sola vez).
- [ ] Destino A — **Google Drive `appDataFolder`** (`google_sign_in` + `googleapis` drive v3, scope `drive.appdata`). Rotación: conservar 5.
- [ ] Destino B — **Archivo** vía hoja de compartir (iCloud Drive, Files, correo, USB).
- [ ] Backup automático semanal (`workmanager` en Android / `BGTaskScheduler` iOS) solo con Wi-Fi.
- [ ] Restore en dispositivo nuevo con migración de esquema si el backup es antiguo.
- [ ] Test E2E: backup → borrar app → reinstalar → restaurar → datos idénticos (hash).

**Entregable 🚀 Release 0.2:** restauro mi diario completo en otro teléfono.

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
