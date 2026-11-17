# 🏗️ ARCHITECTURE — TELEIOS

Documento de visión técnica de **TELEIOS**. Define las decisiones arquitectónicas clave, el modelo de dominio, la estrategia de IA y el modelo de privacidad.

Decisiones formales: [`docs/adr/`](./docs/adr/) · Análisis de origen: [`docs/ANALISIS-TECNICO.md`](./docs/ANALISIS-TECNICO.md).

---

## 🎯 Principios Rectores

1. **Local-First:** toda la información sensible vive en el dispositivo, cifrada. La nube es opcional, agregada y anonimizada.
2. **Clean Architecture:** separación estricta de capas (`presentation`, `domain`, `data`, `infrastructure`).
3. **Hibridez cognitiva:** la IA **sugiere**, el usuario **decide** (aprobación explícita de tópicos).
4. **Costo cero:** procesamiento en el hardware del usuario; servicios en capa gratuita.
5. **Precisión teológica:** vocabulario y categorías respetan la ortodoxia cristiana histórica.
6. **Honestidad estadística:** se muestran correlaciones con su tamaño de muestra, nunca "causas".
7. **Testabilidad:** el dominio se testea sin base de datos, sin UI, sin red.

---

## 🧱 Estructura de Capas

Organización **feature-first**, con Clean Architecture dentro de cada feature:

El código vive en `app/` (monorepo; `supabase/` se agregará al lado en el Sprint 10).

```
app/
├── assets/bible/            # rv1909.sqlite.gz (generado por tool/build_bible_db.py)
├── config/                  # dev.json / prod.json (--dart-define-from-file)
├── tool/                    # Scripts de build de datos
├── test/                    # Espejo de lib/ + widget/ (fakes y flujo E2E)
└── lib/
    ├── main.dart            # Arranque: llave → base cifrada → Biblia → ProviderScope
    ├── app.dart             # MaterialApp.router + tema + AppLockGate
    ├── core/                # Transversal
    │   ├── config/          # Env (dev/prod)
    │   ├── errors/          # Failure (sealed)
    │   ├── preferences/     # AppSettings (no sensibles: onboarding, tema, bloqueo)
    │   ├── router/          # go_router + HomeShell responsive
    │   ├── security/        # DatabaseKeyStore, AppLock (local_auth)
    │   ├── theme/           # Material 3 + DimensionColors
    │   └── utils/           # TextNormalizer, ids (UUID v7), formatters, logger
    │
    ├── shared/
    │   ├── domain/          # entities · catalogs · repositories (contratos) · usecases
    │   ├── data/            # AppDatabase (Drift) · tablas · platform_storage · repos
    │   ├── widgets/         # DimensionChip, ScoreSlider, EmptyState, SectionCard…
    │   └── providers.dart   # Composición de dependencias (Riverpod)
    │
    ├── features/
    │   ├── estudio/         # ✅ Devocionales, Biblia, línea de tiempo, incubación
    │   │   ├── domain/      #   DevotionalEntry, contratos, SaveDevotional, TimelineLayout
    │   │   ├── data/        #   DriftDevotionalRepository, SqliteBibleRepository
    │   │   └── presentation/#   pantallas + widgets + providers
    │   ├── onboarding/      # ✅ Consentimiento
    │   ├── settings/        # ✅ Ajustes + exportación JSON
    │   ├── bitacora/        # Praxis A-B-C (S5)
    │   ├── altar/           # Oración por voz (S6)
    │   ├── ejes/            # Analítica, dashboards, grafo (S7-S8)
    │   ├── backup/          # Backup cifrado (S9)
    │   └── comunidad/       # Supabase (S10+)
    │
    └── infrastructure/
        └── ai/              # ✅ AiClassificationService, LexicalClassifier, TopicSuggester, léxico
```

**Regla de dependencia:** `presentation → domain ← data ← infrastructure`. El dominio no importa Flutter, Drift ni Supabase.

---

## 💻 Tech Stack

| Capa | Tecnología | Nota |
|------|------------|------|
| Framework | Flutter (Android, iOS, Windows, macOS, Linux, Web) | Web solo para capa comunitaria |
| Estado | `flutter_riverpod` (sin generador) | Providers explícitos en `shared/providers.dart` |
| Navegación | `go_router` | |
| Modelos | Clases inmutables de Dart puro | Sin `freezed`: menos codegen; se reevalúa si crece el boilerplate |
| DB local | **Drift 2.34** + `sqlite3` 3.x con `source: sqlite3mc` | Reemplaza a Isar (ADR-001). Cifrado verificado por test |
| Llaves | `flutter_secure_storage` (Keychain / Keystore) | |
| Biblia | Reina-Valera 1909 (dominio público) en SQLite + FTS5 | |
| Gráficos | `fl_chart` 1.3 + `CustomPainter` (heatmap, aluvión, línea de tiempo) | |
| Grafo | Fruchterman-Reingold propio, determinista, en otro isolate | Reemplaza a `graphview` |
| Voz | `speech_to_text` en modo on-device | |
| IA | Léxico local → ONNX embeddings → Ollama (desktop) | ADR-002 |
| Backup | `cryptography` (AES-GCM, Argon2id, HKDF) + `archive` + `google_sign_in` 7 + `googleapis` | ADR-004 (revisado) |
| Backend comunitario | Supabase (Auth, Postgres + RLS + `ltree`, Storage, Edge Functions) | |
| Imágenes overflow | Cloudflare R2 | |
| CI/CD | GitHub Actions + Codemagic (iOS) | |

---

## 🧬 Modelo de Dominio

### `Dimension` — inmutable

Sembrada en el primer arranque. **Nunca editable por el usuario.**

```dart
@freezed
class Dimension with _$Dimension {
  const factory Dimension({
    required String id,        // caracter_dios | contexto_historico | vida_practica | estructura_pensamiento
    required String nombre,
    required String colorHex,
  }) = _Dimension;
}
```

### `Topic` — orgánico

```dart
enum TopicStatus { validado, incubacion, sombra, refutado }
enum TopicOrigin { usuario, sugerido }

@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,          // UUID v7 (ordenable, sin colisiones entre dispositivos)
    required String nombre,
    required String dimensionId,
    required TopicStatus status,
    required TopicOrigin origin,
    double? confidence,          // solo si fue sugerido
    String? globalTopicId,       // enlace opcional al tópico comunitario
    required DateTime createdAt,
  }) = _Topic;
}
```

- `validado` → nodo sólido, conectado al menos a un versículo.
- `incubacion` → cosmovisión aprendida pendiente de validar (línea punteada).
- `sombra` → tópico recurrente de falla sin estudio asociado (color alerta).
- `refutado` → cosmovisión examinada y descartada; se conserva como registro del discernimiento.

Transiciones (en `Topic`, testeadas): `incubacion → validado | refutado`, `sombra → validado`, `refutado → incubacion` (reabrir). Un tópico creado dentro de un devocional nace `validado` (está anclado a un pasaje); vincular una cosmovisión en incubación a un devocional **no** la valida.

### `DevotionalEntry`

```dart
@freezed
class DevotionalEntry with _$DevotionalEntry {
  const factory DevotionalEntry({
    required String id,
    required DateTime fecha,
    required PassageRef pasaje,          // libro, capítulo, versículo inicio/fin
    required String contenido,
    required List<String> topicIds,
    HistoricalContext? contexto,         // época, imperio, región, autor, año aprox.
    String? publicPostId,                // si se publicó a la comunidad
  }) = _DevotionalEntry;
}
```

### `PraxisEntry` — modelo A-B-C

```dart
enum FilterType { biblico, cosmovision, impulso }

@freezed
class PraxisEntry with _$PraxisEntry {
  const factory PraxisEntry({
    required String id,
    required DateTime fecha,
    // A — Acontecimiento
    required String circunstancia,
    required List<String> emocionIds,
    required int intensidadEmocional,    // 1-10
    // B — Filtro cognitivo
    required FilterType filtro,
    String? detalleFundamento,
    PassageRef? versiculoUsado,
    @Default([]) List<String> detonanteIds,
    @Default([]) List<String> topicIds,
    // C — Consecuencia
    required String accionTomada,
    required int nivelPaz,               // 1-10
    required int coherencia,             // 1-10
    @Default([]) List<String> adjuntosPrivados,  // rutas locales
  }) = _PraxisEntry;
}
```

### `PrayerEntry`

```dart
enum PrayerIntent { agradecimiento, peticion, lamentacion }

@freezed
class PrayerEntry with _$PrayerEntry {
  const factory PrayerEntry({
    required String id,
    required DateTime fecha,
    required String transcripcion,       // el audio NO se guarda por defecto
    required PrayerIntent intencion,
    @Default([]) List<String> topicIds,
    @Default([]) List<String> praxisLinkedIds,
  }) = _PrayerEntry;
}
```

### Comunidad (Supabase, Postgres)

```sql
create extension if not exists ltree;

create table groups (
  id           uuid primary key default gen_random_uuid(),
  community_id uuid not null references communities(id) on delete cascade,
  parent_id    uuid references groups(id) on delete cascade,  -- null = raíz
  path         ltree not null,                                -- raiz.red_norte.celula_3
  name         text not null
);
create index on groups using gist (path);

create table group_members (
  group_id uuid references groups(id) on delete cascade,
  user_id  uuid references auth.users(id) on delete cascade,
  role     text not null check (role in ('member','leader','admin')),
  primary key (group_id, user_id)
);

-- Métricas: sin texto, sin user_id; solo accesible vía RPC SECURITY DEFINER
create table weekly_metrics (
  group_id   uuid not null references groups(id) on delete cascade,
  week       date not null,
  topic_key  text not null,        -- tópico global o dimensión
  avg_coh    numeric(4,2),
  avg_paz    numeric(4,2),
  iet        numeric(4,3),
  n_entries  int
);
revoke all on weekly_metrics from anon, authenticated;
```

---

## 🤖 Motor de Clasificación

TELEIOS **no genera texto**; **clasifica** con primitivas tipadas inspiradas en los modelos *System One* (Jev). El contrato es independiente del proveedor:

```dart
abstract interface class AiClassificationService {
  Future<ChoiceResult> choose({
    required String context,
    required List<String> options,
    String? instruction,
  });

  Future<ScoreResult> score({
    required String context,
    required List<ScoreQuestion> questions,
  });

  Future<NoulResult> noul({
    required String context,
    required String yesNoQuestion,
  });
}
```

| Primitiva | Salida | Uso |
|-----------|--------|-----|
| `choose` | `{ option, confidence, reasons }` | Sugerir tópicos por dimensión, intención de oración |
| `score` | `{ scores: Map<String,double> }` | Solo como *pre-llenado opcional*; el usuario siempre ajusta los sliders |
| `noul` | `{ yes, confidence }` | ¿La acción se alineó con el fundamento declarado? (sugerencia) |

### Proveedores (en orden de preferencia)

```
            AiClassificationService
                     │
   ┌────────────┬────┴────────┬─────────────────┐
   ▼            ▼             ▼                 ▼
Nivel 0      Nivel 1       Nivel 2           Nivel 3
Léxico +     Embeddings    Ollama local      Jev API
historial    ONNX on-device (desktop)        (opt-in, SOLO
(todas)      (móvil/desktop)                  contenido público)
```

> ⚠️ Jev es una API en la nube de pago. No existe versión on-device verificable ("LocalJev"). Por eso **nunca** recibe datos de la zona 🔴. Ver ADR-002.

---

## 🔐 Modelo de Privacidad

### Zonas de datos

| Zona | Datos | Persistencia | Sale del dispositivo |
|------|-------|--------------|----------------------|
| 🔴 Privado crudo | Bitácoras, emociones, oraciones, adjuntos privados | Drift cifrado | Solo dentro del backup cifrado con passphrase del usuario |
| 🟡 Privado derivado | Promedios semanales por tópico | Drift cifrado | Solo con opt-in, sin texto, agregado por grupo |
| 🟢 Comunitario | Devocionales publicados, tópicos globales, votos, imágenes públicas | Supabase | Sí |

### K-anonimato con supresión complementaria

1. Un grupo expone métricas solo si tiene **≥ 5 reportantes distintos** en el período.
2. Si un hijo se suprime, se suprime también el **hermano más pequeño** que permita despejarlo por resta (`padre − Σ hermanos visibles`).
3. Si tras suprimir el residuo del padre sigue < 5, el padre también se suprime para ese período.
4. La agregación se hace en Postgres (`get_group_health`, `SECURITY DEFINER`), nunca en el cliente.

Detalle en ADR-003.

### Backup

Snapshot `VACUUM INTO` → zip con adjuntos → AES-256-GCM con llave derivada (Argon2id) de la passphrase del usuario → Google Drive `appDataFolder` o archivo local. Google almacena un blob que no puede leer. Detalle en ADR-004.

### Fórmulas

```
IET(tópico) = Σ (coherencia_i × paz_i) / (100 × n)          ∈ [0, 1]
Correlación estudio↔coherencia = Spearman ρ   (solo si n ≥ 8)
Lag-time(tópico) = mediana(días entre estudio y primera praxis vinculada)
```

---

## 🔄 Flujo de Datos — Ejemplo

```
1. Devocional sobre Gálatas 5:22-23.
2. Sugeridor (nivel 0/1) propone [Paciencia, Dominio Propio, Amor] → usuario valida.
3. "Paciencia" (validado) queda en Vida Práctica.
4. Praxis: "Le grité a mi compañero" → Filtro = Impulso, detonante = Ira, paz 2, coherencia 1.
5. Se sugiere "Paciencia" (estudiado hace < 14 días) → usuario lo vincula.
6. IET local de "Paciencia" baja esta semana.
7. Grafo: arista Paciencia → Ira en rojo, pulso por intensidad alta.
8. Dashboard: brecha entre estudio (alto) y praxis (baja) en el heatmap.
9. Si el usuario compartió métricas: su grupo recibe solo {Paciencia, coh 1, paz 2, n 1} agregado semanal.
```

---

## 📊 Dashboards

| Gráfico | Implementación | Datos | Insight |
|---------|----------------|-------|---------|
| Grafo de fuerza dirigida | `graphview` / `CustomPainter` | Topic, Emotion, Prayer | Mapa mental dinámico |
| Radar de dimensiones | `fl_chart` | Devocionales por dimensión | Balance de estudio |
| Dispersión estudio ↔ coherencia | `fl_chart` | Agregado por tópico | Correlación (con n) |
| Heatmap temporal | `CustomPainter` | Fechas de entrada | Constancia |
| Aluvión (Sankey) | `CustomPainter` | PraxisEntry | Circunstancia → Paz |
| Línea de tiempo | `CustomPainter` | HistoricalContext + hitos | Cobertura histórica |
| Treemap de líder | `CustomPainter` (squarified) o Syncfusion Community | `get_group_health` | Salud comunitaria |

---

## 🧪 Estrategia de Testing

| Nivel | Herramienta | Alcance |
|-------|-------------|---------|
| Dominio | `test` | Calculadoras, use cases. Cobertura ≥ 80% |
| Datos | Drift in-memory | Repositorios, migraciones de esquema |
| Backend | `pgTAP` (`supabase test db`) | RLS, RPC k-anónimas, tests de propiedad |
| IA | Mocks deterministas + set etiquetado de 100 ejemplos | Precisión top-3 por proveedor |
| UI | widget tests | Sugeridor, flujo A-B-C, grabación |
| E2E | `integration_test` | Devocional → praxis → oración → dashboard → backup/restore |

---

## 🚫 Decisiones Explícitas (No-Goals)

- No subir texto crudo de bitácoras ni oraciones a ningún servidor.
- No depender de APIs de IA de pago para funcionar.
- No permitir edición de las 4 dimensiones fijas.
- No implementar chat conversacional con IA.
- No empaquetar traducciones bíblicas con copyright.
- No presentar correlaciones como causalidad ni la app como herramienta de salud mental.

---

## 📚 Referencias

- Drift: https://drift.simonbinder.eu
- Supabase: https://supabase.com/docs
- graphview: https://pub.dev/packages/graphview
- fl_chart: https://pub.dev/packages/fl_chart
- Ollama: https://ollama.com
- ONNX Runtime: https://onnxruntime.ai
- Google Drive appDataFolder: https://developers.google.com/drive/api/guides/appdata
