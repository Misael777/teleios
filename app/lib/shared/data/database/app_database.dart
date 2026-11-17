import 'package:drift/drift.dart';

import '../../../features/coherencia/domain/belief.dart';
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
    Attachments,
    Beliefs,
    BeliefTopics,
    BeliefEvidenceTable,
    ActionBeliefs,
    SharedLabels,
    ThoughtPatterns,
    JudgeFeedback,
  ],
)
class AppDatabase extends _$AppDatabase implements TransactionRunner {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedCatalogs();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v2: coherencia opcional (registro rápido) + adjuntos privados.
        await m.alterTable(TableMigration(praxisEntries));
        await m.createTable(attachments);
        await m.createIndex(attachmentsOwner);
        // En v1 los índices se creaban a mano (fuera del esquema): se aseguran aquí.
        await customStatement('CREATE INDEX IF NOT EXISTS devotionals_date ON devotionals (date)');
        await customStatement('CREATE INDEX IF NOT EXISTS devotionals_book ON devotionals (book_code)');
        await customStatement('CREATE INDEX IF NOT EXISTS praxis_date ON praxis_entries (date)');
      }
      if (from < 3) {
        // v3: portada del devocional (título y versículo lema).
        await m.addColumn(devotionals, devotionals.title);
        await m.addColumn(devotionals, devotionals.keyVerse);
      }
      if (from < 4) {
        // v4: coherencia medida (creencias, evidencia, vínculos, etiquetado, patrones, juez).
        for (final TableInfo<Table, Object?> table in [
          beliefs,
          beliefTopics,
          beliefEvidenceTable,
          actionBeliefs,
          sharedLabels,
          thoughtPatterns,
          judgeFeedback,
        ]) {
          await m.createTable(table);
        }
        await m.createIndex(beliefEvidenceBelief);
        await m.createIndex(actionBeliefsBelief);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Mantiene los catálogos del sistema al día tras actualizar la app (idempotente).
      if (!details.wasCreated) await seedCatalogs();
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
