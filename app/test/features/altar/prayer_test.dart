import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/errors/failure.dart';
import 'package:teleios/features/altar/data/drift_prayer_repository.dart';
import 'package:teleios/features/altar/domain/prayer.dart';
import 'package:teleios/features/bitacora/data/drift_praxis_repository.dart';
import 'package:teleios/features/bitacora/domain/praxis.dart';
import 'package:teleios/features/bitacora/domain/save_praxis.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/repositories/drift_topic_repository.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';
import 'package:teleios/shared/domain/entities/prayer_entry.dart';
import 'package:teleios/shared/domain/entities/topic.dart';
import 'package:teleios/shared/domain/entities/topic_draft.dart';
import 'package:teleios/shared/domain/repositories/attachment_store.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftPrayerRepository prayers;
  late SavePrayer save;

  setUp(() {
    db = memoryDatabase();
    prayers = DriftPrayerRepository(db);
    save = SavePrayer(prayers: prayers, topics: DriftTopicRepository(db), transaction: db);
  });
  tearDown(() => db.close());

  Future<String> praxis() =>
      SavePraxis(
        praxis: DriftPraxisRepository(db),
        topics: DriftTopicRepository(db),
        attachments: DriftAttachmentRepository(db),
        store: MemoryAttachmentStore(),
        transaction: db,
      )(
        PraxisDraft(
          date: DateTime(2026, 10, 26),
          circumstance: 'Discusión en casa',
          emotionIds: const ['ira'],
          intensity: 7,
          filter: FilterType.impulso,
          peace: 3,
        ),
      );

  test('guarda la transcripción, la intención, tópicos y praxis vinculada', () async {
    final praxisId = await praxis();
    final id = await save(
      PrayerDraft(
        date: DateTime(2026, 10, 27),
        transcript: '  Señor, te pido paciencia con mi familia  ',
        intent: PrayerIntent.peticion,
        topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
        praxisIds: [praxisId],
      ),
    );
    final r = (await prayers.getById(id))!;
    expect(r.entry.transcript, 'Señor, te pido paciencia con mi familia');
    expect(r.entry.intent, PrayerIntent.peticion);
    expect(r.topics.single.status, TopicStatus.incubacion, reason: 'sin pasaje, nace en incubación');
    expect(r.linkedPraxis.single.circumstance, 'Discusión en casa');
  });

  test('editar reemplaza vínculos; borrar la praxis quita el vínculo', () async {
    final praxisId = await praxis();
    final id = await save(
      PrayerDraft(date: DateTime(2026), transcript: 'x', intent: PrayerIntent.lamentacion, praxisIds: [praxisId]),
    );
    await save(PrayerDraft(id: id, date: DateTime(2026), transcript: 'y', intent: PrayerIntent.lamentacion));
    expect((await prayers.getById(id))!.linkedPraxis, isEmpty);

    await save(
      PrayerDraft(
        id: id,
        date: DateTime(2026),
        transcript: 'y',
        intent: PrayerIntent.lamentacion,
        praxisIds: [praxisId],
      ),
    );
    await DriftPraxisRepository(db).delete(praxisId);
    expect((await prayers.getById(id))!.linkedPraxis, isEmpty);
  });

  test('rechaza oraciones vacías', () {
    expect(
      save(PrayerDraft(date: DateTime(2026), transcript: '   ', intent: PrayerIntent.agradecimiento)),
      throwsA(isA<ValidationFailure>()),
    );
  });

  group('PrayerIntentClassifier', () {
    const c = PrayerIntentClassifier();

    test('agradecimiento', () {
      expect(c.classify('Padre, gracias por este día, te alabo por tu fidelidad')!.intent, PrayerIntent.agradecimiento);
    });
    test('petición', () {
      expect(c.classify('Te pido que sanes a mi madre y me ayudes en el trabajo')!.intent, PrayerIntent.peticion);
    });
    test('lamentación', () {
      expect(c.classify('¿Por qué, Señor? ¿Hasta cuándo? Me duele y no entiendo')!.intent, PrayerIntent.lamentacion);
    });
    test('sin evidencia no adivina', () => expect(c.classify('hoy es martes'), isNull));
  });
}
