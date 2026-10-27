import 'package:drift/drift.dart';

import '../../domain/catalogs/emotion_catalog.dart';
import '../../domain/entities/dimension.dart';
import '../../domain/entities/praxis_entry.dart';
import '../../domain/entities/prayer_entry.dart';
import '../../domain/entities/topic.dart';
import '../../domain/repositories/topic_repository.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Base privada (zona 🔴). Cifrada en disco con SQLite3MultipleCiphers (ADR-001).
@DriftDatabase(
  tables: [
    Dimensions,
    Emotions,
    Triggers,
    Topics,
    Devotionals,
    DevotionalTopics,
    PraxisEntries,
    PraxisEmotions,
    PraxisTriggers,
    PraxisTopics,
    Prayers,
    PrayerTopics,
    PrayerPraxisLinks,
  ],
)
class AppDatabase extends _$AppDatabase implements TransactionRunner {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await m.createIndex(Index('devotionals_date', 'CREATE INDEX devotionals_date ON devotionals (date)'));
      await m.createIndex(Index('devotionals_book', 'CREATE INDEX devotionals_book ON devotionals (book_code)'));
      await m.createIndex(Index('praxis_date', 'CREATE INDEX praxis_date ON praxis_entries (date)'));
      await seedCatalogs();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Siembra idempotente de catálogos del sistema.
  Future<void> seedCatalogs() => batch((b) {
    b.insertAllOnConflictUpdate(dimensions, [
      for (final d in Dimension.all)
        DimensionsCompanion.insert(
          id: d.id,
          name: d.name,
          description: d.description,
          colorHex: d.colorHex,
          sortOrder: d.sortOrder,
        ),
    ]);
    // Primero las primarias para respetar la FK parentId.
    final ordered = [
      ...EmotionCatalog.emotions.where((e) => e.parentId == null),
      ...EmotionCatalog.emotions.where((e) => e.parentId != null),
    ];
    b.insertAllOnConflictUpdate(emotions, [
      for (final e in ordered) EmotionsCompanion.insert(id: e.id, name: e.name, parentId: Value(e.parentId)),
    ]);
    b.insertAllOnConflictUpdate(triggers, [
      for (final t in EmotionCatalog.triggers) TriggersCompanion.insert(id: t.id, name: t.name),
    ]);
  });

  @override
  Future<T> run<T>(Future<T> Function() action) => transaction(action);

  /// Borra todos los datos del usuario y vuelve a sembrar los catálogos.
  Future<void> wipeUserData() => transaction(() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    for (final table in allTables.toList().reversed) {
      await delete(table).go();
    }
    await customStatement('PRAGMA foreign_keys = ON');
    await seedCatalogs();
  });
}
