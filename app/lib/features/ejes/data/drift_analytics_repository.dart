import 'package:collection/collection.dart';

import '../../../shared/data/database/app_database.dart';
import '../../../shared/data/repositories/drift_topic_repository.dart';
import '../../bitacora/data/drift_praxis_repository.dart';
import '../domain/analytics_data.dart';

/// Carga los datos de la analítica en una sola pasada y se refresca ante cualquier cambio.
class DriftAnalyticsRepository {
  DriftAnalyticsRepository(this._db);

  final AppDatabase _db;

  Stream<AnalyticsData> watch() => _db
      .customSelect(
        // SQL único por repositorio: Drift comparte streams con el mismo SQL e ignora readsFrom.
        'SELECT 1 AS analytics_watch',
        readsFrom: {
          _db.devotionals,
          _db.devotionalTopics,
          _db.praxisEntries,
          _db.praxisTopics,
          _db.praxisEmotions,
          _db.praxisTriggers,
          _db.prayers,
          _db.prayerTopics,
          _db.topics,
        },
      )
      .watch()
      .asyncMap((_) => load());

  Future<AnalyticsData> load() async {
    final devotionals = await _db.select(_db.devotionals).get();
    final devTopics = groupBy(await _db.select(_db.devotionalTopics).get(), (r) => r.devotionalId);
    final praxis = await _db.select(_db.praxisEntries).get();
    final pxTopics = groupBy(await _db.select(_db.praxisTopics).get(), (r) => r.praxisId);
    final pxEmotions = groupBy(await _db.select(_db.praxisEmotions).get(), (r) => r.praxisId);
    final pxTriggers = groupBy(await _db.select(_db.praxisTriggers).get(), (r) => r.praxisId);
    final prayers = await _db.select(_db.prayers).get();
    final prTopics = groupBy(await _db.select(_db.prayerTopics).get(), (r) => r.prayerId);

    return AnalyticsData(
      studies: [
        for (final d in devotionals)
          StudyEvent(date: d.date, bookCode: d.bookCode, topicIds: [...?devTopics[d.id]?.map((l) => l.topicId)]),
      ],
      praxis: [
        for (final p in praxis)
          PraxisEvent(
            date: p.date,
            topicIds: [...?pxTopics[p.id]?.map((l) => l.topicId)],
            emotionIds: [...?pxEmotions[p.id]?.map((l) => l.emotionId)],
            triggerIds: [...?pxTriggers[p.id]?.map((l) => l.triggerId)],
            filter: p.filter,
            intensity: p.intensity,
            peace: p.peace,
            coherence: p.coherence,
          ),
      ],
      prayers: [
        for (final p in prayers)
          PrayerEvent(date: p.date, intent: p.intent, topicIds: [...?prTopics[p.id]?.map((l) => l.topicId)]),
      ],
      topics: {for (final t in await _db.select(_db.topics).get()) t.id: DriftTopicRepository.toTopic(t)},
      emotions: {for (final e in await _db.select(_db.emotions).get()) e.id: DriftPraxisRepository.toEmotion(e)},
      triggers: {for (final t in await _db.select(_db.triggers).get()) t.id: DriftPraxisRepository.toTrigger(t)},
    );
  }
}
