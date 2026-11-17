import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/shared/data/database/app_database.dart';

import '../../generated_migrations/schema.dart';
import '../../generated_migrations/schema_v1.dart' as v1;
import '../../generated_migrations/schema_v2.dart' as v2;
import '../../generated_migrations/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2, 3]) {
    test('v$from → v4 produce exactamente el esquema de una instalación nueva', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      await verifier.migrateAndValidate(db, 4);
      await db.close();
    });
  }

  test('v3 → v4 conserva los devocionales y deja vacías las tablas de coherencia', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    await old.customStatement(
      'INSERT INTO devotionals (id, date, book_code, chapter, content, created_at, updated_at) '
      "VALUES ('d1', 1759276800, 'GEN', 1, 'En el principio', 1759276800, 1759276800)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    expect((await db.select(db.devotionals).get()).single.id, 'd1');
    expect(await db.select(db.beliefs).get(), isEmpty);
    expect(await db.select(db.actionBeliefs).get(), isEmpty);
    await db.close();
  });

  test('v2 → v3 conserva los devocionales y deja la portada vacía', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    await old.customStatement(
      'INSERT INTO devotionals (id, date, book_code, chapter, content, created_at, updated_at) '
      "VALUES ('d1', 1759276800, 'GEN', 1, 'En el principio', 1759276800, 1759276800)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final row = (await db.select(db.devotionals).get()).single;
    expect(row.content, 'En el principio');
    expect(row.title, isNull);
    expect(row.keyVerse, isNull);
    await db.close();
  });

  test('v1 → v2 conserva los datos de praxis y permite coherencia nula', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old.customStatement(
      'INSERT INTO praxis_entries (id, date, circumstance, intensity, filter, action, peace, coherence, created_at, updated_at) '
      "VALUES ('p1', 1759276800, 'Tráfico', 7, 'impulso', 'Grité', 2, 1, 1759276800, 1759276800)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    final rows = await db.select(db.praxisEntries).get();
    expect(rows.single.circumstance, 'Tráfico');
    expect(rows.single.coherence, 1);

    await db
        .into(db.praxisEntries)
        .insert(
          PraxisEntriesCompanion.insert(
            id: 'p2',
            date: DateTime(2026, 10, 2),
            circumstance: 'Rápido',
            intensity: 5,
            filter: rows.single.filter,
            action: '',
            peace: 6,
            createdAt: DateTime(2026, 10, 2),
            updatedAt: DateTime(2026, 10, 2),
          ),
        );
    expect((await db.select(db.praxisEntries).get()).last.coherence, isNull);
    await db.close();
  });
}
