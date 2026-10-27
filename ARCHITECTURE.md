# 🏗️ ARCHITECTURE — TELEIOS

Documento de visión técnica de **TELEIOS**. Define las decisiones arquitectónicas clave, la estructura del modelo de dominio, la estrategia de IA **System One** y el modelo de privacidad.

---

## 🎯 Principios Rectores

1. **Local-First:** toda la información sensible vive en el dispositivo. La nube es opcional, agregada y anonimizada.
2. **Clean Architecture:** separación estricta de capas (`presentation`, `domain`, `data`, `core`).
3. **Hibridez cognitiva:** la IA **asiste** pero el usuario **decide** (aprobación explícita de tópicos).
4. **Costo cero de IA:** el procesamiento delegado al hardware del usuario.
5. **Precisión teológica:** el vocabulario y las categorías respetan la ortodoxia cristiana histórica.
6. **Testabilidad:** el dominio debe ser testeable sin base de datos, sin UI, sin red.

---

## 🧱 Clean Architecture — Estructura de Capas
lib/
├── core/ # Utilidades transversales
│ ├── constants/
│ ├── errors/ # Failure, Exception
│ ├── theme/ # Material 3 + tokens de las 4 dimensiones
│ └── utils/
│
├── domain/ # ← Reglas de negocio puras (Dart, sin Flutter)
│ ├── entities/ # Dimension, Topic, DevotionalEntry, PraxisEntry...
│ ├── repositories/ # Contratos abstractos
│ ├── usecases/ # ValidateTopic, ComputeCoherenceIndex, ...
│ └── services/ # CoherenceCalculator, LagTimeAnalyzer
│
├── data/ # ← Implementaciones concretas
│ ├── datasources/ # IsarDataSource, SupabaseDataSource, OllamaDataSource
│ ├── models/ # DTOs + mappers
│ └── repositories/ # Implementación de los contratos
│
├── infrastructure/ # ← Integración con el mundo exterior
│ ├── ai/ # AiClassificationService (Jev / Ollama / LocalJev)
│ ├── stt/ # Speech-to-Text
│ └── db/ # Inicialización Isar + migraciones seed
│
└── presentation/ # ← UI Flutter
├── bloc/ # BLoC / Riverpod notifiers
├── screens/
│ ├── estudio/
│ ├── bitacora/
│ ├── altar/
│ └── ejes/
└── widgets/



**Regla de dependencia:** `presentation → domain ← data ← infrastructure`. El dominio no depende de nada.

---

## 🧬 Modelo de Dominio (Entidades Clave)

### `Dimension` — inmutable
Entidad sembrada en el primer arranque. **Nunca editable por el usuario.**

```dart
class Dimension {
  final String id;
  final String nombre;       // "Carácter de Dios", "Contexto Histórico", ...
  final String colorHex;     // Token visual
  final bool isSystem;       // true = fija
}
Las 4 dimensiones fijas:

caracter_dios

contexto_historico

vida_practica

estructura_pensamiento

Topic — orgánico
Creado por el usuario o sugerido por IA (con aprobación).

dart
class Topic {
  final String id;
  final String nombre;
  final String dimensionId;
  final TopicStatus status;   // validado | incubacion | sombra
  final double? confidence;   // si vino de IA
  final DateTime createdAt;
}

enum TopicStatus { validado, incubacion, sombra }
validado → nodo sólido, conectado a un versículo.

incubacion → cosmovisión aprendida pendiente de validar (línea punteada).

sombra → tópico recurrente de falla sin estudio asociado (color alerta).

DevotionalEntry
dart
class DevotionalEntry {
  final String id;
  final DateTime fecha;
  final String versiculo;           // "Romanos 5:3-4"
  final String contenido;
  final List<TopicRef> topicos;      // con dimensión explícita
  final HistoricalContext? contexto; // formulario cronológico
}
PraxisEntry — modelo A-B-C
dart
class PraxisEntry {
  final String id;
  final DateTime fecha;

  // A — Acontecimiento
  final String circunstancia;
  final List<String> emociones;      // ["Ansiedad", "Frustración"]
  final int intensidadEmocional;      // 1-10

  // B — Filtro cognitivo
  final FilterType filtro;            // biblico | cosmovision | impulso
  final String? detalleFundamento;
  final String? topicoId;

  // C — Consecuencia
  final String accionTomada;
  final int nivelPaz;                 // 1-10
  final int coherencia;               // 1-10
}

enum FilterType { biblico, cosmovision, impulso }
PrayerEntry
dart
class PrayerEntry {
  final String id;
  final DateTime fecha;
  final String transcripcion;
  final List<String> topicosDetectados;
  final PrayerIntent intencion;       // agradecimiento | peticion | lamentacion
  final List<String> praxisLinkedIds; // vínculos con bitácoras
}

enum PrayerIntent { agradecimiento, peticion, lamentacion }
Subgroup — estructura anidada (comunidad)
dart
class Subgroup {
  final String id;
  final String nombre;
  final String? parentId;             // null = nodo raíz (comunidad)
  final int memberCount;
  final AggregatedHealth? health;     // solo si memberCount >= 5
}
🤖 System One — Motor de IA
¿Por qué System One?
Los LLMs generativos tradicionales son sobre-ingeniería para TELEIOS:

No necesitamos que la IA redacte; necesitamos que clasifique.

Los LLMs pesan > 2 GB y consumen batería en móvil.

Los modelos de System One devuelven decisiones tipadas en 70-300 ms.

Interfaz de Clasificación
Toda inferencia pasa por un contrato único:

dart
abstract class AiClassificationService {
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
Primitivas
Primitiva	Tipo de salida	Uso en TELEIOS
Choice	{ option: String, confidence: double }	Clasificar tópicos en las 4 dimensiones
Score	{ scores: Map<String, double> }	Intensidad emocional, coherencia, paz
Noul	{ yes: bool, confidence: double }	¿Esta acción se alineó con el fundamento?
Estrategia Multiplataforma
text
┌─────────────────────────────┐
│  AiClassificationService    │
└──────────────┬──────────────┘
               │
      ┌────────┴────────┐
      ▼                 ▼
┌──────────┐      ┌──────────────┐
│ Desktop  │      │   Mobile     │
└────┬─────┘      └──────┬───────┘
     │                   │
     ▼                   ▼
┌──────────┐      ┌──────────────────┐
│  Ollama  │      │ 1. LocalJev      │
│  local   │      │ 2. Ollama Bridge │
│ :11434   │      │ 3. Jev API (opt) │
└──────────┘      └──────────────────┘
Orden de preferencia en móvil:

LocalJev on-device (llama.cpp + dart:ffi, GGUF Q4, < 1.5 GB RAM).

Ollama Bridge por Wi-Fi LAN si el usuario tiene Ollama en su PC.

Jev API (opt-in explícito del usuario) como fallback online.

🔐 Modelo de Privacidad
Zonas de Datos
Zona	Datos	Persistencia	Sale del dispositivo
🔴 Privado Crudo	Contenido de bitácoras, emociones, transcripciones de oración	Isar local, cifrado	Nunca
🟡 Privado Derivado	Índices de coherencia, paz, vectores numéricos	Isar local	Solo como agregado anónimo
🟢 Comunitario	Tópicos globales, textos de devocionales públicos, scores anonimizados	Supabase	Sí (con K-Anonimato)
Regla de K-Anonimato
Ningún subgrupo con N < 5 miembros activos expone métricas propias.

Sus datos se promedian al nodo padre en la jerarquía.

La agregación se ejecuta en Edge Functions de Supabase, no en el cliente.

Fórmula del IET (Índice de Efectividad Teológica)
text
IET(tópico) = Σ (coherencia_i × paz_i) / frecuencia_uso
Calculado localmente por usuario, subido como valor anonimizado y promediado por subgrupo respetando K-Anonimato.

🔄 Flujo de Datos — Ejemplo Completo
Escenario: el usuario estudia Gálatas 5 (fruto del Espíritu) y horas más tarde registra una praxis de impaciencia.

text
1. Devocional: usuario escribe sobre Gálatas 5:22-23.
2. IA sugiere tópicos: [Paciencia, Dominio Propio, Amor] → usuario valida.
3. Topic "Paciencia" (validado) se crea bajo dimensión Vida Práctica.
4. Praxis: "Le grité a mi compañero" → Filtro = Impulso (no bíblico).
5. Usuario marca tópico "Paciencia" en praxis (filtro impulso).
6. Sistema calcula IET local del tópico "Paciencia" (baja esta semana).
7. Grafo: nodo "Paciencia" late con tensión roja (línea hacia emoción "Ira").
8. Dashboard: heatmap muestra gap entre estudio (alto) y praxis (bajo).
9. Recomendación: sugerir estudio del tópico "Paciencia" en próxima sesión.
📊 Diseño de Dashboards
Gráfico	Paquete	Datos que consume	Insight
Grafo de fuerza dirigida	graphview	Topic, Emotion, Prayer	Mapa mental dinámico
Radar de dimensiones	fl_chart	DevotionalEntry.topicos	Balance de estudio
Dispersión estudio ↔ coherencia	fl_chart	Agregado por tópico	Correlación positiva/negativa
Heatmap temporal	CustomPainter	Fechas de entrada	Densidad de estudio
Aluvión (Sankey)	CustomPainter	PraxisEntry	Ruta Circunstancia → Paz
Treemap jerárquico (líder)	syncfusion_flutter_treemap	Subgroup.health	Debugging comunitario
🧪 Estrategia de Testing
Dominio: tests unitarios puros. Cobertura objetivo > 70%.

Data: tests con Isar in-memory.

IA: mocks del AiClassificationService con respuestas deterministas.

UI: tests de widget para flujos críticos (creación de devocional, praxis A-B-C, sugeridor).

E2E: flujo completo devocional → praxis → oración → dashboard.

🚫 Decisiones Explícitas (No-Goals)
No sincronizar texto crudo de bitácoras a Supabase.

No depender obligatoriamente de APIs LLM de pago.

No permitir edición de las 4 dimensiones fijas.

No implementar chat conversacional con IA (fuera de alcance del MVP 1).

📚 Referencias Técnicas
Isar: https://isar.dev

graphview: https://pub.dev/packages/graphview

fl_chart: https://pub.dev/packages/fl_chart

Ollama: https://ollama.com

llama.cpp: https://github.com/ggerganov/llama.cpp

Jev / TypeSafe AI: modelo System One con decisiones tipadas.

