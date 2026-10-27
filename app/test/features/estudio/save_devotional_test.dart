import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/errors/failure.dart';
import 'package:teleios/features/estudio/data/drift_devotional_repository.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/domain/save_devotional.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/repositories/drift_topic_repository.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/historical_context.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/topic.dart';
import 'package:teleios/shared/domain/usecases/topic_usecases.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftTopicRepository topics;
  late DriftDevotionalRepository devotionals;
  late SaveDevotional save;

  const gal = PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22, verseEnd: 23);
  const rom = PassageRef(bookCode: 'ROM', chapter: 5, verseStart: 3, verseEnd: 4);

  setUp(() {
    db = memoryDatabase();
    topics = DriftTopicRepository(db);
    devotionals = DriftDevotionalRepository(db);
    save = SaveDevotional(devotionals: devotionals, topics: topics, transaction: db);
  });
  tearDown(() => db.close());

  DevotionalDraft draft({
    String? id,
    PassageRef passage = gal,
    String content = 'El fruto del Espíritu es paciencia.',
    List<TopicDraft> topics = const [],
    HistoricalContext context = const HistoricalContext(),
  }) => DevotionalDraft(
    id: id,
    date: DateTime(2026, 10, 27),
    passage: passage,
    content: content,
    topics: topics,
    context: context,
  );

  test('guarda el devocional, crea tópicos nuevos validados y los enlaza', () async {
    final id = await save(
      draft(
        topics: const [
          TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica),
          TopicDraft(
            name: 'Fruto del Espíritu',
            dimensionId: Dimension.estructuraPensamiento,
            origin: TopicOrigin.sugerido,
            confidence: 0.8,
          ),
        ],
        context: const HistoricalContext(periodId: 'iglesia_primitiva', author: 'Pablo', approxYear: 49),
      ),
    );

    final entry = (await devotionals.getById(id))!;
    expect(entry.passage, gal);
    expect(entry.context.author, 'Pablo');
    expect(entry.context.approxYear, 49);
    expect(entry.topics.map((t) => t.name), unorderedEquals(['Paciencia', 'Fruto del Espíritu']));
    expect(entry.topics.every((t) => t.status == TopicStatus.validado), isTrue);
    expect(entry.topics.firstWhere((t) => t.origin == TopicOrigin.sugerido).confidence, 0.8);
  });

  test('reutiliza tópicos existentes en lugar de duplicarlos', () async {
    await save(
      draft(
        topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    await save(
      draft(
        passage: rom,
        topics: const [TopicDraft(name: 'paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    expect(await topics.getAll(), hasLength(1));
    expect((await topics.usageCounts()).values.single, 2);
  });

  test('no valida automáticamente una cosmovisión en incubación vinculada', () async {
    final incub = await CreateIncubationTopic(CreateTopic(topics))(
      name: 'Cuidar lo mío',
      dimensionId: Dimension.vidaPractica,
    );
    await save(
      draft(
        topics: [TopicDraft(name: incub.name, dimensionId: incub.dimensionId, existingId: incub.id)],
      ),
    );
    expect((await topics.findById(incub.id))!.status, TopicStatus.incubacion);
  });

  test('al editar reemplaza los enlaces y conserva createdAt', () async {
    final id = await save(
      draft(
        topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    final before = (await devotionals.getById(id))!;
    await save(
      draft(
        id: id,
        content: 'Editado',
        topics: const [TopicDraft(name: 'Gozo', dimensionId: Dimension.vidaPractica)],
      ),
    );
    final after = (await devotionals.getById(id))!;
    expect(after.content, 'Editado');
    expect(after.topics.map((t) => t.name), ['Gozo']);
    expect(after.createdAt, before.createdAt);
  });

  test('rechaza reflexión vacía', () {
    expect(save(draft(content: '   ')), throwsA(isA<ValidationFailure>()));
  });

  test('la transacción es atómica: si falla un tópico no queda nada guardado', () async {
    await expectLater(
      save(
        draft(
          topics: const [
            TopicDraft(name: 'Válido', dimensionId: Dimension.vidaPractica),
            TopicDraft(name: '   ', dimensionId: Dimension.vidaPractica),
          ],
        ),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    expect(await topics.getAll(), isEmpty);
    expect(await db.select(db.devotionals).get(), isEmpty);
  });

  group('consultas', () {
    setUp(() async {
      await save(
        draft(
          topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
        ),
      );
      await save(
        draft(
          passage: rom,
          topics: const [TopicDraft(name: 'Soberanía', dimensionId: Dimension.caracterDios)],
        ),
      );
    });

    test('filtra por dimensión', () async {
      final list = await devotionals.watch(const DevotionalFilter(dimensionId: Dimension.caracterDios)).first;
      expect(list.single.passage, rom);
    });

    test('filtra por libro', () async {
      final list = await devotionals.watch(const DevotionalFilter(bookCode: 'GAL')).first;
      expect(list.single.passage, gal);
    });

    test('topicsUsedWithBook alimenta el sugeridor', () async {
      expect((await topics.topicsUsedWithBook('ROM')).map((t) => t.name), ['Soberanía']);
    });

    test('watch re-emite cuando cambia un tópico enlazado', () async {
      final queue = StreamQueue(devotionals.watch());
      expect(await queue.next, hasLength(2));
      final t = (await topics.findByName('Paciencia', Dimension.vidaPractica))!;
      await topics.update(t.moveTo(Dimension.estructuraPensamiento, at: DateTime(2027)));
      final updated = await queue.next;
      expect(updated.any((e) => e.topics.any((t) => t.dimensionId == Dimension.estructuraPensamiento)), isTrue);
      await queue.cancel();
    });

    test('eliminar un devocional no borra sus tópicos', () async {
      final all = await devotionals.watch().first;
      await devotionals.delete(all.first.id);
      expect(await devotionals.watch().first, hasLength(1));
      expect(await topics.getAll(), hasLength(2));
    });
  });
}
