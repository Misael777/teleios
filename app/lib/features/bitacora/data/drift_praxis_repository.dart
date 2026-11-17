import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../../core/utils/ids.dart';
import '../../../core/utils/text_normalizer.dart';
import '../../../shared/data/database/app_database.dart';
import '../../../shared/data/repositories/drift_topic_repository.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../coherencia/domain/belief.dart';
import '../domain/praxis.dart';
import '../domain/repositories.dart';

class DriftPraxisRepository implements PraxisRepository {
  DriftPraxisRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<PraxisRecord>> watch([PraxisFilter filter = const PraxisFilter()]) =>
      _watchTables(() => _load(filter: filter));

  @override
  Stream<PraxisRecord?> watchById(String id) => _watchTables(() => getById(id));

  @override
  Future<PraxisRecord?> getById(String id) async => (await _load(id: id)).firstOrNull;

  @override
  Future<List<PraxisRecord>> since(DateTime since) => _load(filter: PraxisFilter(since: since));

  /// Re-emite cuando cambian el registro o cualquiera de sus enlaces.
  Stream<T> _watchTables<T>(Future<T> Function() load) => _db
      .customSelect(
        // SQL único por repositorio: Drift comparte streams con el mismo SQL e ignora readsFrom.
        'SELECT 1 AS praxis_watch',
        readsFrom: {
          _db.praxisEntries,
          _db.praxisEmotions,
          _db.praxisTriggers,
          _db.praxisTopics,
          _db.topics,
          _db.emotions,
          _db.attachments,
        },
      )
      .watch()
      .asyncMap((_) => load());

  Future<List<PraxisRecord>> _load({PraxisFilter filter = const PraxisFilter(), String? id}) async {
    final query = _db.select(_db.praxisEntries)
      ..orderBy([(p) => OrderingTerm.desc(p.date), (p) => OrderingTerm.desc(p.createdAt)]);
    if (id != null) query.where((p) => p.id.equals(id));
    if (filter.filter != null) query.where((p) => p.filter.equalsValue(filter.filter));
    if (filter.since != null) query.where((p) => p.date.isBiggerOrEqualValue(filter.since!));
    final rows = await query.get();
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();

    final emotions = await (_db.select(_db.praxisEmotions).join([
      innerJoin(_db.emotions, _db.emotions.id.equalsExp(_db.praxisEmotions.emotionId)),
    ])..where(_db.praxisEmotions.praxisId.isIn(ids))).get();
    final triggers = await (_db.select(_db.praxisTriggers).join([
      innerJoin(_db.triggers, _db.triggers.id.equalsExp(_db.praxisTriggers.triggerId)),
    ])..where(_db.praxisTriggers.praxisId.isIn(ids))).get();
    final topics = await (_db.select(_db.praxisTopics).join([
      innerJoin(_db.topics, _db.topics.id.equalsExp(_db.praxisTopics.topicId)),
    ])..where(_db.praxisTopics.praxisId.isIn(ids))).get();
    final attachments = await (_db.select(
      _db.attachments,
    )..where((a) => a.ownerType.equals(Attachment.ownerPraxis) & a.ownerId.isIn(ids))).get();

    final emotionsBy = groupBy(emotions, (TypedResult r) => r.readTable(_db.praxisEmotions).praxisId);
    final triggersBy = groupBy(triggers, (TypedResult r) => r.readTable(_db.praxisTriggers).praxisId);
    final topicsBy = groupBy(topics, (TypedResult r) => r.readTable(_db.praxisTopics).praxisId);
    final attachmentsBy = groupBy(attachments, (AttachmentRow a) => a.ownerId);

    return [
      for (final row in rows)
        () {
          final e = [for (final r in emotionsBy[row.id] ?? const <TypedResult>[]) toEmotion(r.readTable(_db.emotions))];
          final t = [for (final r in triggersBy[row.id] ?? const <TypedResult>[]) toTrigger(r.readTable(_db.triggers))];
          final tp = [
            for (final r in topicsBy[row.id] ?? const <TypedResult>[])
              DriftTopicRepository.toTopic(r.readTable(_db.topics)),
          ];
          return PraxisRecord(
            entry: PraxisEntry(
              id: row.id,
              date: row.date,
              circumstance: row.circumstance,
              emotionIds: e.map((x) => x.id).toList(),
              intensity: row.intensity,
              filter: row.filter,
              foundationDetail: row.foundationDetail,
              passage: row.passage == null ? null : PassageRef.decode(row.passage!),
              triggerIds: t.map((x) => x.id).toList(),
              topicIds: tp.map((x) => x.id).toList(),
              action: row.action,
              peace: row.peace,
              coherence: row.coherence,
            ),
            emotions: e,
            triggers: t,
            topics: tp,
            attachments: [for (final a in attachmentsBy[row.id] ?? const <AttachmentRow>[]) toAttachment(a)],
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          );
        }(),
    ];
  }

  @override
  Future<void> upsert(PraxisEntry entry) => _db.transaction(() async {
    final now = DateTime.now();
    final existing = await (_db.select(_db.praxisEntries)..where((p) => p.id.equals(entry.id))).getSingleOrNull();
    await _db
        .into(_db.praxisEntries)
        .insertOnConflictUpdate(
          PraxisEntriesCompanion.insert(
            id: entry.id,
            date: entry.date,
            circumstance: entry.circumstance,
            intensity: entry.intensity,
            filter: entry.filter,
            foundationDetail: Value(entry.foundationDetail),
            passage: Value(entry.passage?.encode()),
            action: entry.action,
            peace: entry.peace,
            coherence: Value(entry.coherence),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
    await (_db.delete(_db.praxisEmotions)..where((l) => l.praxisId.equals(entry.id))).go();
    await (_db.delete(_db.praxisTriggers)..where((l) => l.praxisId.equals(entry.id))).go();
    await (_db.delete(_db.praxisTopics)..where((l) => l.praxisId.equals(entry.id))).go();
    await _db.batch((b) {
      b.insertAll(_db.praxisEmotions, [
        for (final e in entry.emotionIds) PraxisEmotionsCompanion.insert(praxisId: entry.id, emotionId: e),
      ]);
      b.insertAll(_db.praxisTriggers, [
        for (final t in entry.triggerIds) PraxisTriggersCompanion.insert(praxisId: entry.id, triggerId: t),
      ]);
      b.insertAll(_db.praxisTopics, [
        for (final t in entry.topicIds) PraxisTopicsCompanion.insert(praxisId: entry.id, topicId: t),
      ]);
    });
  });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    // Los vínculos con creencias son polimórficos (sin FK): se limpian a mano.
    await (_db.delete(_db.actionBeliefs)
          ..where((l) => l.actionKind.equalsValue(ActionKind.praxis) & l.actionId.equals(id)))
        .go();
    await (_db.delete(_db.thoughtPatterns)
          ..where((l) => l.actionKind.equalsValue(ActionKind.praxis) & l.actionId.equals(id)))
        .go();
    await (_db.delete(_db.praxisEntries)..where((p) => p.id.equals(id))).go();
  });

  @override
  Future<List<Topic>> recentlyStudiedTopics(DateTime since) async {
    final rows =
        await (_db.select(_db.topics).join([
                innerJoin(_db.devotionalTopics, _db.devotionalTopics.topicId.equalsExp(_db.topics.id)),
                innerJoin(_db.devotionals, _db.devotionals.id.equalsExp(_db.devotionalTopics.devotionalId)),
              ])
              ..where(_db.devotionals.date.isBiggerOrEqualValue(since))
              ..orderBy([OrderingTerm.desc(_db.devotionals.date)]))
            .get();
    final byId = <String, TopicRow>{};
    for (final r in rows) {
      final t = r.readTable(_db.topics);
      byId.putIfAbsent(t.id, () => t);
    }
    return byId.values.map(DriftTopicRepository.toTopic).toList();
  }

  static CatalogEntry toEmotion(EmotionRow r) =>
      CatalogEntry(id: r.id, name: r.name, parentId: r.parentId, isSystem: r.isSystem);

  static CatalogEntry toTrigger(TriggerRow r) => CatalogEntry(id: r.id, name: r.name, isSystem: r.isSystem);

  static Attachment toAttachment(AttachmentRow a) => Attachment(
    id: a.id,
    ownerType: a.ownerType,
    ownerId: a.ownerId,
    fileName: a.fileName,
    mimeType: a.mimeType,
    sizeBytes: a.sizeBytes,
    width: a.width,
    height: a.height,
    createdAt: a.createdAt,
  );
}

class DriftPraxisCatalogRepository implements PraxisCatalogRepository {
  DriftPraxisCatalogRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<CatalogEntry>> watchEmotions() =>
      _db.select(_db.emotions).watch().map((rows) => rows.map(DriftPraxisRepository.toEmotion).toList());

  @override
  Stream<List<CatalogEntry>> watchTriggers() =>
      _db.select(_db.triggers).watch().map((rows) => rows.map(DriftPraxisRepository.toTrigger).toList());

  @override
  Future<CatalogEntry> addEmotion(String name, {String? parentId}) async {
    final clean = name.trim();
    final existing = (await _db.select(_db.emotions).get()).where(
      (e) => TextNormalizer.key(e.name) == TextNormalizer.key(clean),
    );
    if (existing.isNotEmpty) return DriftPraxisRepository.toEmotion(existing.first);
    final row = EmotionRow(id: 'u_${newId()}', name: clean, parentId: parentId, isSystem: false);
    await _db.into(_db.emotions).insert(row);
    return DriftPraxisRepository.toEmotion(row);
  }

  @override
  Future<CatalogEntry> addTrigger(String name) async {
    final clean = name.trim();
    final existing = (await _db.select(_db.triggers).get()).where(
      (e) => TextNormalizer.key(e.name) == TextNormalizer.key(clean),
    );
    if (existing.isNotEmpty) return DriftPraxisRepository.toTrigger(existing.first);
    final row = TriggerRow(id: 'u_${newId()}', name: clean, isSystem: false);
    await _db.into(_db.triggers).insert(row);
    return DriftPraxisRepository.toTrigger(row);
  }
}

class DriftAttachmentRepository implements AttachmentRepository {
  DriftAttachmentRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Attachment>> listFor(String ownerType, String ownerId) async =>
      (await (_db.select(_db.attachments)
                ..where((a) => a.ownerType.equals(ownerType) & a.ownerId.equals(ownerId))
                ..orderBy([(a) => OrderingTerm.asc(a.createdAt)]))
              .get())
          .map(DriftPraxisRepository.toAttachment)
          .toList();

  @override
  Future<List<Attachment>> all() async =>
      (await _db.select(_db.attachments).get()).map(DriftPraxisRepository.toAttachment).toList();

  @override
  Future<void> add(Attachment a) => _db
      .into(_db.attachments)
      .insert(
        AttachmentsCompanion.insert(
          id: a.id,
          ownerType: a.ownerType,
          ownerId: a.ownerId,
          fileName: a.fileName,
          mimeType: a.mimeType,
          width: Value(a.width),
          height: Value(a.height),
          sizeBytes: a.sizeBytes,
          createdAt: a.createdAt,
        ),
      );

  @override
  Future<void> remove(String id) => (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();
}
