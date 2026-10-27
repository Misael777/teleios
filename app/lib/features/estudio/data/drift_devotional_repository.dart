import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/database/app_database.dart';
import '../../../shared/data/repositories/drift_topic_repository.dart';
import '../../../shared/domain/entities/historical_context.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../domain/devotional.dart';
import '../domain/repositories.dart';

class DriftDevotionalRepository implements DevotionalRepository {
  DriftDevotionalRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<DevotionalEntry>> watch([DevotionalFilter filter = const DevotionalFilter()]) {
    final query = _db.select(_db.devotionals)
      ..orderBy([(d) => OrderingTerm.desc(d.date), (d) => OrderingTerm.desc(d.createdAt)]);
    if (filter.bookCode != null) query.where((d) => d.bookCode.equals(filter.bookCode!));
    if (filter.dimensionId != null) {
      query.where(
        (d) => existsQuery(
          _db.select(_db.devotionalTopics).join([
            innerJoin(_db.topics, _db.topics.id.equalsExp(_db.devotionalTopics.topicId)),
          ])..where(
            _db.devotionalTopics.devotionalId.equalsExp(d.id) & _db.topics.dimensionId.equals(filter.dimensionId!),
          ),
        ),
      );
    }
    return _watchTables(() async => _withTopics(await query.get()));
  }

  @override
  Stream<DevotionalEntry?> watchById(String id) => _watchTables(() => getById(id));

  /// Re-emite cuando cambian devocionales, enlaces o tópicos (p. ej. al validar uno).
  ///
  /// Un "query centinela" de Drift observa las tres tablas desde la suscripción,
  /// así no se pierden cambios; `asyncMap` serializa las recargas en orden.
  Stream<T> _watchTables<T>(Future<T> Function() load) => _db
      .customSelect('SELECT 1', readsFrom: {_db.devotionals, _db.devotionalTopics, _db.topics})
      .watch()
      .asyncMap((_) => load());

  @override
  Future<DevotionalEntry?> getById(String id) async {
    final rows = await (_db.select(_db.devotionals)..where((d) => d.id.equals(id))).get();
    return (await _withTopics(rows)).firstOrNull;
  }

  @override
  Future<void> upsert({
    required String id,
    required DateTime date,
    required PassageRef passage,
    required String content,
    required HistoricalContext context,
    required List<TopicLink> topics,
  }) => _db.transaction(() async {
    final now = DateTime.now();
    final existing = await (_db.select(_db.devotionals)..where((d) => d.id.equals(id))).getSingleOrNull();
    await _db
        .into(_db.devotionals)
        .insertOnConflictUpdate(
          DevotionalsCompanion.insert(
            id: id,
            date: date,
            bookCode: passage.bookCode,
            chapter: passage.chapter,
            verseStart: Value(passage.verseStart),
            verseEnd: Value(passage.verseEnd),
            content: content,
            periodId: Value(context.periodId),
            empireId: Value(context.empireId),
            regionId: Value(context.regionId),
            author: Value(context.author?.trim().isEmpty ?? true ? null : context.author!.trim()),
            approxYear: Value(context.approxYear),
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
          ),
        );
    await (_db.delete(_db.devotionalTopics)..where((l) => l.devotionalId.equals(id))).go();
    await _db.batch(
      (b) => b.insertAll(_db.devotionalTopics, [
        for (final link in topics)
          DevotionalTopicsCompanion.insert(devotionalId: id, topicId: link.topicId, origin: link.origin),
      ]),
    );
  });

  @override
  Future<void> delete(String id) => (_db.delete(_db.devotionals)..where((d) => d.id.equals(id))).go();

  Future<List<DevotionalEntry>> _withTopics(List<DevotionalRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final links =
        await (_db.select(_db.devotionalTopics).join([
                innerJoin(_db.topics, _db.topics.id.equalsExp(_db.devotionalTopics.topicId)),
              ])
              ..where(_db.devotionalTopics.devotionalId.isIn(ids))
              ..orderBy([OrderingTerm.asc(_db.topics.nameKey)]))
            .get();
    final topicsByDevotional = groupBy(links, (TypedResult r) => r.readTable(_db.devotionalTopics).devotionalId);
    return [
      for (final row in rows)
        DevotionalEntry(
          id: row.id,
          date: row.date,
          passage: PassageRef(
            bookCode: row.bookCode,
            chapter: row.chapter,
            verseStart: row.verseStart,
            verseEnd: row.verseEnd,
          ),
          content: row.content,
          context: HistoricalContext(
            periodId: row.periodId,
            empireId: row.empireId,
            regionId: row.regionId,
            author: row.author,
            approxYear: row.approxYear,
          ),
          topics: [
            for (final r in topicsByDevotional[row.id] ?? const <TypedResult>[])
              DriftTopicRepository.toTopic(r.readTable(_db.topics)),
          ],
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
    ];
  }
}
