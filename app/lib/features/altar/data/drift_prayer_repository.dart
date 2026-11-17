import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/database/app_database.dart';
import '../../../shared/data/repositories/drift_topic_repository.dart';
import '../../../shared/domain/entities/prayer_entry.dart';
import '../../coherencia/domain/belief.dart';
import '../domain/prayer.dart';

class DriftPrayerRepository implements PrayerRepository {
  DriftPrayerRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<PrayerRecord>> watch() => _watchTables(_load);

  @override
  Stream<PrayerRecord?> watchById(String id) => _watchTables(() => getById(id));

  @override
  Future<PrayerRecord?> getById(String id) async => (await _load(id: id)).firstOrNull;

  Stream<T> _watchTables<T>(Future<T> Function() load) => _db
      .customSelect(
        // SQL único por repositorio: Drift comparte streams con el mismo SQL e ignora readsFrom.
        'SELECT 1 AS prayer_watch',
        readsFrom: {_db.prayers, _db.prayerTopics, _db.prayerPraxisLinks, _db.topics, _db.praxisEntries},
      )
      .watch()
      .asyncMap((_) => load());

  Future<List<PrayerRecord>> _load({String? id}) async {
    final query = _db.select(_db.prayers)..orderBy([(p) => OrderingTerm.desc(p.date)]);
    if (id != null) query.where((p) => p.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();

    final topics = await (_db.select(_db.prayerTopics).join([
      innerJoin(_db.topics, _db.topics.id.equalsExp(_db.prayerTopics.topicId)),
    ])..where(_db.prayerTopics.prayerId.isIn(ids))).get();
    final praxis = await (_db.select(_db.prayerPraxisLinks).join([
      innerJoin(_db.praxisEntries, _db.praxisEntries.id.equalsExp(_db.prayerPraxisLinks.praxisId)),
    ])..where(_db.prayerPraxisLinks.prayerId.isIn(ids))).get();
    final topicsBy = groupBy(topics, (TypedResult r) => r.readTable(_db.prayerTopics).prayerId);
    final praxisBy = groupBy(praxis, (TypedResult r) => r.readTable(_db.prayerPraxisLinks).prayerId);

    return [
      for (final row in rows)
        () {
          final tp = [
            for (final r in topicsBy[row.id] ?? const <TypedResult>[])
              DriftTopicRepository.toTopic(r.readTable(_db.topics)),
          ];
          final px = [
            for (final r in praxisBy[row.id] ?? const <TypedResult>[])
              LinkedPraxis(
                id: r.readTable(_db.praxisEntries).id,
                date: r.readTable(_db.praxisEntries).date,
                circumstance: r.readTable(_db.praxisEntries).circumstance,
              ),
          ];
          return PrayerRecord(
            entry: PrayerEntry(
              id: row.id,
              date: row.date,
              transcript: row.transcript,
              intent: row.intent,
              topicIds: tp.map((t) => t.id).toList(),
              praxisLinkedIds: px.map((p) => p.id).toList(),
            ),
            topics: tp,
            linkedPraxis: px,
            createdAt: row.createdAt,
          );
        }(),
    ];
  }

  @override
  Future<void> upsert(PrayerEntry entry) => _db.transaction(() async {
    final existing = await (_db.select(_db.prayers)..where((p) => p.id.equals(entry.id))).getSingleOrNull();
    await _db
        .into(_db.prayers)
        .insertOnConflictUpdate(
          PrayersCompanion.insert(
            id: entry.id,
            date: entry.date,
            transcript: entry.transcript,
            intent: entry.intent,
            createdAt: existing?.createdAt ?? DateTime.now(),
          ),
        );
    await (_db.delete(_db.prayerTopics)..where((l) => l.prayerId.equals(entry.id))).go();
    await (_db.delete(_db.prayerPraxisLinks)..where((l) => l.prayerId.equals(entry.id))).go();
    await _db.batch((b) {
      b.insertAll(_db.prayerTopics, [
        for (final t in entry.topicIds) PrayerTopicsCompanion.insert(prayerId: entry.id, topicId: t),
      ]);
      b.insertAll(_db.prayerPraxisLinks, [
        for (final p in entry.praxisLinkedIds) PrayerPraxisLinksCompanion.insert(prayerId: entry.id, praxisId: p),
      ]);
    });
  });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
    // Los vínculos con creencias son polimórficos (sin FK): se limpian a mano.
    await (_db.delete(_db.actionBeliefs)
          ..where((l) => l.actionKind.equalsValue(ActionKind.oracion) & l.actionId.equals(id)))
        .go();
    await (_db.delete(_db.thoughtPatterns)
          ..where((l) => l.actionKind.equalsValue(ActionKind.oracion) & l.actionId.equals(id)))
        .go();
    await (_db.delete(_db.prayers)..where((p) => p.id.equals(id))).go();
  });
}
