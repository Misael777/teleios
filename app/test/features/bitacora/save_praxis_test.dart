import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/errors/failure.dart';
import 'package:teleios/features/bitacora/data/drift_praxis_repository.dart';
import 'package:teleios/features/bitacora/domain/praxis.dart';
import 'package:teleios/features/bitacora/domain/save_praxis.dart';
import 'package:teleios/features/estudio/data/drift_devotional_repository.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/domain/save_devotional.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/repositories/drift_topic_repository.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';
import 'package:teleios/shared/domain/entities/topic.dart';
import 'package:teleios/shared/domain/repositories/attachment_store.dart';

import '../../helpers.dart';

/// Almacén que falla al escribir: para probar el rollback de archivos.
class _FailingDbAttachments extends DriftAttachmentRepository {
  _FailingDbAttachments(super.db);

  @override
  Future<void> add(Attachment attachment) => throw StateError('fallo simulado');
}

void main() {
  late AppDatabase db;
  late DriftPraxisRepository praxis;
  late DriftTopicRepository topics;
  late DriftAttachmentRepository attachments;
  late MemoryAttachmentStore store;
  late SavePraxis save;

  setUp(() {
    db = memoryDatabase();
    praxis = DriftPraxisRepository(db);
    topics = DriftTopicRepository(db);
    attachments = DriftAttachmentRepository(db);
    store = MemoryAttachmentStore();
    save = SavePraxis(praxis: praxis, topics: topics, attachments: attachments, store: store, transaction: db);
  });
  tearDown(() => db.close());

  PraxisDraft draft({
    String? id,
    FilterType filter = FilterType.impulso,
    List<TopicDraft> topicDrafts = const [],
    String? worldview,
    PassageRef? passage,
    int? coherence = 2,
    List<PendingImage> images = const [],
    List<String> removed = const [],
    List<String> emotions = const ['ira'],
  }) => PraxisDraft(
    id: id,
    date: DateTime(2026, 10, 27, 18),
    circumstance: 'Mi compañero entregó tarde el reporte',
    emotionIds: emotions,
    intensity: 8,
    filter: filter,
    action: 'Le grité',
    peace: 2,
    coherence: coherence,
    triggerIds: const ['t_ira'],
    topics: topicDrafts,
    worldview: worldview,
    passage: passage,
    newImages: images,
    removedAttachmentIds: removed,
  );

  PendingImage image() => PendingImage(bytes: Uint8List.fromList([1, 2, 3]), width: 10, height: 10);

  test('guarda el registro con emociones, detonantes y tópicos', () async {
    final id = await save(
      draft(
        topicDrafts: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    final r = (await praxis.getById(id))!;
    expect(r.entry.circumstance, 'Mi compañero entregó tarde el reporte');
    expect(r.emotions.single.name, 'Ira');
    expect(r.triggers.single.name, 'Ira');
    expect(r.topics.single.name, 'Paciencia');
    expect(r.entry.isFailure, isTrue);
  });

  test('un tópico nuevo creado desde la bitácora nace en incubación', () async {
    final id = await save(
      draft(
        topicDrafts: const [TopicDraft(name: 'Tolerancia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    expect((await praxis.getById(id))!.topics.single.status, TopicStatus.incubacion);
  });

  test('si el registro cita un pasaje, el tópico nuevo nace validado', () async {
    final id = await save(
      draft(
        filter: FilterType.biblico,
        passage: const PassageRef(bookCode: 'PRO', chapter: 15, verseStart: 1),
        topicDrafts: const [TopicDraft(name: 'Respuesta blanda', dimensionId: Dimension.vidaPractica)],
      ),
    );
    expect((await praxis.getById(id))!.topics.single.status, TopicStatus.validado);
  });

  test('reutiliza un tópico validado del estudio sin cambiar su estado', () async {
    await SaveDevotional(devotionals: DriftDevotionalRepository(db), topics: topics, transaction: db)(
      DevotionalDraft(
        date: DateTime(2026, 10, 20),
        passage: const PassageRef(bookCode: 'GAL', chapter: 5),
        content: 'x',
        topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    final id = await save(
      draft(
        topicDrafts: const [TopicDraft(name: 'paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    final t = (await praxis.getById(id))!.topics.single;
    expect(t.status, TopicStatus.validado);
    expect(await topics.getAll(), hasLength(1));
  });

  test('con filtro cosmovisión crea la creencia en Incubación y la vincula', () async {
    final id = await save(draft(filter: FilterType.cosmovision, worldview: 'No prestar a desordenados'));
    final r = (await praxis.getById(id))!;
    expect(r.topics.single.name, 'No prestar a desordenados');
    expect(r.topics.single.status, TopicStatus.incubacion);
  });

  test('el registro rápido guarda coherencia nula, no un valor inventado', () async {
    final id = await save(draft(coherence: null));
    expect((await praxis.getById(id))!.entry.coherence, isNull);
    expect((await praxis.getById(id))!.entry.isQuick, isTrue);
  });

  group('validación', () {
    test('circunstancia vacía', () {
      expect(
        save(
          PraxisDraft(
            date: DateTime(2026),
            circumstance: ' ',
            emotionIds: const ['ira'],
            intensity: 5,
            filter: FilterType.impulso,
            peace: 5,
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });
    test('sin emociones', () => expect(save(draft(emotions: const [])), throwsA(isA<ValidationFailure>())));
    test('coherencia fuera de rango', () => expect(save(draft(coherence: 11)), throwsA(isA<ValidationFailure>())));
  });

  group('imágenes', () {
    test('se guardan en el almacén y se registran', () async {
      final id = await save(draft(images: [image(), image()]));
      final r = (await praxis.getById(id))!;
      expect(r.attachments, hasLength(2));
      expect(store.files.keys, unorderedEquals(r.attachments.map((a) => a.fileName)));
    });

    test('quitar una imagen al editar borra la fila y el archivo', () async {
      final id = await save(draft(images: [image(), image()]));
      final first = (await praxis.getById(id))!.attachments.first;
      await save(draft(id: id, removed: [first.id]));
      final r = (await praxis.getById(id))!;
      expect(r.attachments, hasLength(1));
      expect(store.files.containsKey(first.fileName), isFalse);
    });

    test('si la transacción falla, no quedan archivos huérfanos', () async {
      final failing = SavePraxis(
        praxis: praxis,
        topics: topics,
        attachments: _FailingDbAttachments(db),
        store: store,
        transaction: db,
      );
      await expectLater(failing(draft(images: [image()])), throwsStateError);
      expect(store.files, isEmpty);
      expect(await db.select(db.praxisEntries).get(), isEmpty);
    });
  });

  test('DeletePraxis borra el registro, sus enlaces y sus imágenes', () async {
    final id = await save(draft(images: [image()]));
    await DeletePraxis(praxis: praxis, attachments: attachments, store: store, transaction: db)(id);
    expect(await praxis.getById(id), isNull);
    expect(await attachments.all(), isEmpty);
    expect(store.files, isEmpty);
    expect(await db.select(db.praxisEmotions).get(), isEmpty);
  });

  test('recentlyStudiedTopics devuelve solo lo estudiado en la ventana', () async {
    final saveDev = SaveDevotional(devotionals: DriftDevotionalRepository(db), topics: topics, transaction: db);
    await saveDev(
      DevotionalDraft(
        date: DateTime(2026, 10, 25),
        passage: const PassageRef(bookCode: 'GAL', chapter: 5),
        content: 'x',
        topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
      ),
    );
    await saveDev(
      DevotionalDraft(
        date: DateTime(2026, 8, 1),
        passage: const PassageRef(bookCode: 'ROM', chapter: 8),
        content: 'x',
        topics: const [TopicDraft(name: 'Soberanía', dimensionId: Dimension.caracterDios)],
      ),
    );
    final recent = await praxis.recentlyStudiedTopics(DateTime(2026, 10, 13));
    expect(recent.map((t) => t.name), ['Paciencia']);
  });

  test('catálogo: emociones propias sin duplicados', () async {
    final catalog = DriftPraxisCatalogRepository(db);
    final a = await catalog.addEmotion('Nostalgia', parentId: 'tristeza');
    final b = await catalog.addEmotion('nostalgia');
    expect(b.id, a.id);
    expect(a.isSystem, isFalse);
    expect((await catalog.watchEmotions().first).where((e) => e.name == 'Nostalgia'), hasLength(1));
  });

  group('EncryptedAttachmentStore', () {
    test('cifra en disco y descifra al leer', () async {
      final raw = MemoryAttachmentStore();
      final key = await EncryptedAttachmentStore.deriveKey(List.filled(32, 7));
      final enc = EncryptedAttachmentStore(raw, key);
      final data = Uint8List.fromList(List.generate(100, (i) => i));
      await enc.write('a.enc', data);
      expect(raw.files['a.enc'], isNot(equals(data)));
      expect(raw.files['a.enc']!.length, data.length + 28);
      expect(await enc.read('a.enc'), data);
    });

    test('no se puede leer con otra llave ni renombrado', () async {
      final raw = MemoryAttachmentStore();
      final enc = EncryptedAttachmentStore(raw, await EncryptedAttachmentStore.deriveKey(List.filled(32, 7)));
      await enc.write('a.enc', Uint8List.fromList([1, 2, 3]));
      final other = EncryptedAttachmentStore(raw, await EncryptedAttachmentStore.deriveKey(List.filled(32, 8)));
      await expectLater(other.read('a.enc'), throwsA(anything));
      raw.files['b.enc'] = raw.files['a.enc']!;
      await expectLater(enc.read('b.enc'), throwsA(anything));
    });
  });
}
