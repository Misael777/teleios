// ignore_for_file: recursive_getters — patrón de Drift: check() se refiere a la propia columna.

import 'package:drift/drift.dart';

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

@DataClassName('DevotionalRow')
class Devotionals extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get bookCode => text().withLength(min: 3, max: 3)();
  IntColumn get chapter => integer()();
  IntColumn get verseStart => integer().nullable()();
  IntColumn get verseEnd => integer().nullable()();
  TextColumn get content => text()();

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
  IntColumn get coherence => integer().check(coherence.isBetweenValues(1, 10))();
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
