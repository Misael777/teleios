// ignore_for_file: recursive_getters — patrón de Drift: check() se refiere a la propia columna.

import 'package:drift/drift.dart';

import '../../../features/coherencia/domain/belief.dart';
import '../../domain/entities/praxis_entry.dart';
import '../../domain/entities/prayer_entry.dart';
import '../../domain/entities/topic.dart';

// ─── Catálogos ──────────────────────────────────────────────────────────────

@DataClassName('DimensionRow')
class Dimensions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get colorHex => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('EmotionRow')
class Emotions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable().references(Emotions, #id)();
  BoolColumn get isSystem => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TriggerRow')
class Triggers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Tópicos ────────────────────────────────────────────────────────────────

@DataClassName('TopicRow')
class Topics extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Nombre normalizado (minúsculas, sin tildes) para unicidad por dimensión.
  TextColumn get nameKey => text()();
  TextColumn get dimensionId => text().references(Dimensions, #id)();
  TextColumn get status => textEnum<TopicStatus>()();
  TextColumn get origin => textEnum<TopicOrigin>()();
  RealColumn get confidence => real().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get validationPassage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {nameKey, dimensionId},
  ];
}

// ─── Estudio ────────────────────────────────────────────────────────────────

@TableIndex(name: 'devotionals_date', columns: {#date})
@TableIndex(name: 'devotionals_book', columns: {#bookCode})
@DataClassName('DevotionalRow')
class Devotionals extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get bookCode => text().withLength(min: 3, max: 3)();
  IntColumn get chapter => integer()();
  IntColumn get verseStart => integer().nullable()();
  IntColumn get verseEnd => integer().nullable()();
  TextColumn get content => text()();

  // Portada (v3)
  TextColumn get title => text().nullable()();

  /// Versículo lema (`PassageRef.encode`).
  TextColumn get keyVerse => text().nullable()();

  // Formulario cronológico
  TextColumn get periodId => text().nullable()();
  TextColumn get empireId => text().nullable()();
  TextColumn get regionId => text().nullable()();
  TextColumn get author => text().nullable()();
  IntColumn get approxYear => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DevotionalTopicRow')
class DevotionalTopics extends Table {
  TextColumn get devotionalId => text().references(Devotionals, #id, onDelete: KeyAction.cascade)();
  TextColumn get topicId => text().references(Topics, #id, onDelete: KeyAction.cascade)();
  TextColumn get origin => textEnum<TopicOrigin>()();

  @override
  Set<Column> get primaryKey => {devotionalId, topicId};
}

// ─── Bitácora de Praxis (UI en Sprint 5) ────────────────────────────────────

@TableIndex(name: 'praxis_date', columns: {#date})
@DataClassName('PraxisRow')
class PraxisEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get circumstance => text()();
  IntColumn get intensity => integer().check(intensity.isBetweenValues(1, 10))();
  TextColumn get filter => textEnum<FilterType>()();
  TextColumn get foundationDetail => text().nullable()();
  TextColumn get passage => text().nullable()();
  TextColumn get action => text()();
  IntColumn get peace => integer().check(peace.isBetweenValues(1, 10))();

  /// Opcional: el registro rápido no la pide (v2). Nunca se inventa un valor por defecto.
  IntColumn get coherence => integer().nullable().check(coherence.isBetweenValues(1, 10))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PraxisEmotions extends Table {
  TextColumn get praxisId => text().references(PraxisEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get emotionId => text().references(Emotions, #id)();

  @override
  Set<Column> get primaryKey => {praxisId, emotionId};
}

class PraxisTriggers extends Table {
  TextColumn get praxisId => text().references(PraxisEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get triggerId => text().references(Triggers, #id)();

  @override
  Set<Column> get primaryKey => {praxisId, triggerId};
}

class PraxisTopics extends Table {
  TextColumn get praxisId => text().references(PraxisEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get topicId => text().references(Topics, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {praxisId, topicId};
}

// ─── Adjuntos privados (v2) ─────────────────────────────────────────────────

/// Imágenes privadas guardadas en la carpeta de la app; viajan solo dentro del backup cifrado.
@TableIndex(name: 'attachments_owner', columns: {#ownerType, #ownerId})
@DataClassName('AttachmentRow')
class Attachments extends Table {
  TextColumn get id => text()();

  /// Tipo de registro dueño: 'praxis' por ahora.
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();

  /// Nombre del archivo dentro de la carpeta de adjuntos (no ruta absoluta: cambia entre dispositivos).
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Altar (UI en Sprint 6) ─────────────────────────────────────────────────

@DataClassName('PrayerRow')
class Prayers extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get transcript => text()();
  TextColumn get intent => textEnum<PrayerIntent>()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PrayerTopics extends Table {
  TextColumn get prayerId => text().references(Prayers, #id, onDelete: KeyAction.cascade)();
  TextColumn get topicId => text().references(Topics, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {prayerId, topicId};
}

class PrayerPraxisLinks extends Table {
  TextColumn get prayerId => text().references(Prayers, #id, onDelete: KeyAction.cascade)();
  TextColumn get praxisId => text().references(PraxisEntries, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {prayerId, praxisId};
}

// ─── Coherencia medida (v4, docs/PLAN-COHERENCIA.md) ────────────────────────

/// Creencia operativa: la interpretación que guía la conducta.
@DataClassName('BeliefRow')
class Beliefs extends Table {
  TextColumn get id => text()();
  TextColumn get proposition => text().withLength(min: 1, max: 280)();
  TextColumn get status => textEnum<BeliefStatus>()();
  TextColumn get origin => textEnum<BeliefOrigin>()();
  TextColumn get dimensionId => text().nullable().references(Dimensions, #id)();
  TextColumn get devotionalId => text().nullable().references(Devotionals, #id, onDelete: KeyAction.setNull)();

  /// Pasaje base (`PassageRef.encode`): ancla de la huella canónica.
  TextColumn get basePassage => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BeliefTopics extends Table {
  TextColumn get beliefId => text().references(Beliefs, #id, onDelete: KeyAction.cascade)();
  TextColumn get topicId => text().references(Topics, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {beliefId, topicId};
}

/// Pasaje que sostiene o tensiona una creencia. Guarda la versión del juez que lo produjo (§9).
@TableIndex(name: 'belief_evidence_belief', columns: {#beliefId})
@DataClassName('BeliefEvidenceRow')
class BeliefEvidenceTable extends Table {
  @override
  String get tableName => 'belief_evidence';

  TextColumn get id => text()();
  TextColumn get beliefId => text().references(Beliefs, #id, onDelete: KeyAction.cascade)();
  TextColumn get passage => text()();
  TextColumn get kind => textEnum<EvidenceKind>()();
  TextColumn get source => textEnum<EvidenceSource>()();
  IntColumn get votes => integer().nullable()();
  RealColumn get probEntail => real().nullable()();
  RealColumn get probContra => real().nullable()();
  TextColumn get modelVersion => text().nullable()();
  BoolColumn get resolved => boolean().withDefault(const Constant(false))();
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {beliefId, passage},
  ];
}

/// Acción (praxis u oración) → creencia, con dirección. Sin FK a la acción: es polimórfico; los
/// repositorios de bitácora y altar lo limpian al borrar.
@TableIndex(name: 'action_beliefs_belief', columns: {#beliefId})
@DataClassName('ActionBeliefRow')
class ActionBeliefs extends Table {
  TextColumn get actionKind => textEnum<ActionKind>()();
  TextColumn get actionId => text()();
  TextColumn get beliefId => text().references(Beliefs, #id, onDelete: KeyAction.cascade)();
  TextColumn get alignment => textEnum<ActionAlignment>()();
  TextColumn get origin => textEnum<LinkOrigin>()();
  RealColumn get confidence => real().nullable()();
  TextColumn get source => text().nullable()();
  BoolColumn get confirmed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {actionKind, actionId, beliefId};
}

/// Respuestas del usuario a ítems compartidos del protocolo de etiquetado (§10).
@DataClassName('SharedLabelRow')
class SharedLabels extends Table {
  TextColumn get itemId => text()();
  TextColumn get label => text()();
  BoolColumn get isGold => boolean()();

  /// Solo ítems de oro: si coincidió con la respuesta conocida.
  BoolColumn get correct => boolean().nullable()();
  IntColumn get durationMs => integer()();
  DateTimeColumn get answeredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {itemId};
}

/// Asignación de una acción a un prototipo de pensamiento (§11.2). Nunca se clusteriza en el teléfono.
@DataClassName('ThoughtPatternRow')
class ThoughtPatterns extends Table {
  TextColumn get actionKind => textEnum<ActionKind>()();
  TextColumn get actionId => text()();
  TextColumn get prototypeId => text()();
  RealColumn get similarity => real()();
  TextColumn get modelVersion => text()();

  /// null: pendiente; true/false: el usuario confirmó o rechazó.
  BoolColumn get confirmed => boolean().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {actionKind, actionId};
}

/// Predicción del juez + veredicto del usuario: alimenta el gráfico 8 (calibración y confusión).
@DataClassName('JudgeFeedbackRow')
class JudgeFeedback extends Table {
  TextColumn get id => text()();
  TextColumn get judgeVersion => text()();

  /// 'nli' | 'alineacion' | 'patron'.
  TextColumn get task => text()();
  TextColumn get predicted => text()();
  RealColumn get probability => real()();
  TextColumn get userLabel => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
