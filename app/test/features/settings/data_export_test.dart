import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/estudio/data/drift_devotional_repository.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/domain/save_devotional.dart';
import 'package:teleios/features/settings/data_export_service.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/repositories/drift_topic_repository.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await SaveDevotional(devotionals: DriftDevotionalRepository(db), topics: DriftTopicRepository(db), transaction: db)(
      DevotionalDraft(
        date: DateTime(2026, 10, 27),
        passage: const PassageRef(bookCode: 'GAL', chapter: 5),
        content: 'Reflexión de prueba',
        topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
  });
  tearDown(() => db.close());

  test('exporta todas las tablas en JSON válido', () async {
    final map = await DataExportService(db).exportMap(now: DateTime(2026, 10, 27));
    final tables = map['tables']! as Map<String, Object?>;
    expect(tables.keys, containsAll(['devotionals', 'topics', 'devotional_topics', 'dimensions']));
    expect((tables['devotionals']! as List).single, containsPair('content', 'Reflexión de prueba'));
    expect(map['schema_version'], db.schemaVersion);

    final bytes = await DataExportService(db).exportBytes();
    expect(() => jsonDecode(utf8.decode(bytes)), returnsNormally);
  });

  test('wipeUserData borra lo del usuario y conserva catálogos', () async {
    await db.wipeUserData();
    expect(await db.select(db.devotionals).get(), isEmpty);
    expect(await db.select(db.topics).get(), isEmpty);
    expect(await db.select(db.dimensions).get(), hasLength(4));
  });
}
