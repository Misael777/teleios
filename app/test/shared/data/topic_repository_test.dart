import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/errors/failure.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/repositories/drift_topic_repository.dart';
import 'package:teleios/shared/domain/catalogs/emotion_catalog.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/topic.dart';
import 'package:teleios/shared/domain/usecases/topic_usecases.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftTopicRepository repo;
  late FakeClock clock;
  late CreateTopic create;

  setUp(() {
    db = memoryDatabase();
    repo = DriftTopicRepository(db);
    clock = FakeClock();
    create = CreateTopic(repo, clock: clock.call);
  });
  tearDown(() => db.close());

  test('siembra las 4 dimensiones fijas y los catálogos', () async {
    final dims = await db.select(db.dimensions).get();
    expect(dims.map((d) => d.id), unorderedEquals(Dimension.all.map((d) => d.id)));
    expect(await db.select(db.emotions).get(), hasLength(EmotionCatalog.emotions.length));
    expect(await db.select(db.triggers).get(), hasLength(EmotionCatalog.triggers.length));
  });

  test('la siembra es idempotente', () async {
    await db.seedCatalogs();
    expect(await db.select(db.dimensions).get(), hasLength(4));
  });

  group('CreateTopic', () {
    test('crea un tópico validado por defecto', () async {
      final t = await create(name: 'paciencia', dimensionId: Dimension.vidaPractica);
      expect(t.name, 'Paciencia');
      expect(t.status, TopicStatus.validado);
      expect((await repo.findById(t.id))!.name, 'Paciencia');
    });

    test('no duplica: mismo nombre (sin importar tildes/mayúsculas) en la misma dimensión', () async {
      final a = await create(name: 'Soberanía', dimensionId: Dimension.caracterDios);
      final b = await create(name: 'soberania', dimensionId: Dimension.caracterDios);
      expect(b.id, a.id);
      expect(await repo.getAll(), hasLength(1));
    });

    test('el mismo nombre puede existir en otra dimensión', () async {
      await create(name: 'Ley', dimensionId: Dimension.contextoHistorico);
      await create(name: 'Ley', dimensionId: Dimension.estructuraPensamiento);
      expect(await repo.getAll(), hasLength(2));
    });

    test('rechaza dimensiones inexistentes', () {
      expect(create(name: 'X', dimensionId: 'inventada'), throwsA(isA<ValidationFailure>()));
    });

    test('la confianza solo se guarda para tópicos sugeridos', () async {
      final user = await create(name: 'A', dimensionId: Dimension.vidaPractica, confidence: 0.9);
      final ai = await create(
        name: 'B',
        dimensionId: Dimension.vidaPractica,
        origin: TopicOrigin.sugerido,
        confidence: 0.9,
      );
      expect(user.confidence, isNull);
      expect(ai.confidence, 0.9);
    });
  });

  group('ciclo de incubación', () {
    test('crear → validar con pasaje', () async {
      final t = await CreateIncubationTopic(create)(
        name: 'No prestar a desordenados',
        dimensionId: Dimension.vidaPractica,
        note: 'Lo aprendí de mi padre',
      );
      expect(t.status, TopicStatus.incubacion);

      clock.advance(const Duration(days: 3));
      const passage = PassageRef(bookCode: 'PRO', chapter: 22, verseStart: 26, verseEnd: 27);
      await ValidateTopic(repo, clock: clock.call)(t.id, passage);

      final saved = (await repo.findById(t.id))!;
      expect(saved.status, TopicStatus.validado);
      expect(saved.validationPassage, passage);
      expect(saved.updatedAt, clock.now);
      expect(saved.note, 'Lo aprendí de mi padre');
    });

    test('crear → refutar → reabrir', () async {
      final t = await CreateIncubationTopic(create)(name: 'Ojo por ojo', dimensionId: Dimension.vidaPractica);
      await RefuteTopic(repo)(t.id, reason: 'Mt 5:38-39');
      expect((await repo.findById(t.id))!.status, TopicStatus.refutado);
      await ReopenTopic(repo)(t.id);
      expect((await repo.findById(t.id))!.status, TopicStatus.incubacion);
    });

    test('validar un tópico inexistente falla con NotFound', () {
      expect(
        ValidateTopic(repo)('nope', const PassageRef(bookCode: 'GEN', chapter: 1)),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  test('watchAll filtra por estado y re-emite al cambiar', () async {
    final stream = repo.watchAll(statuses: {TopicStatus.incubacion});
    final t = await CreateIncubationTopic(create)(name: 'X', dimensionId: Dimension.vidaPractica);
    await expectLater(stream, emits(predicate<List<Topic>>((l) => l.length == 1)));
    await ValidateTopic(repo)(t.id, const PassageRef(bookCode: 'GEN', chapter: 1));
    await expectLater(stream, emits(isEmpty));
  });
}
