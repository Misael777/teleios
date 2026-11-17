import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/domain/entities/prayer_entry.dart';
import '../../../shared/domain/entities/topic.dart';

class StudyEvent {
  const StudyEvent({required this.date, required this.bookCode, required this.topicIds});

  final DateTime date;
  final String bookCode;
  final List<String> topicIds;
}

class PraxisEvent {
  const PraxisEvent({
    required this.date,
    required this.topicIds,
    required this.emotionIds,
    required this.triggerIds,
    required this.filter,
    required this.intensity,
    required this.peace,
    this.coherence,
  });

  final DateTime date;
  final List<String> topicIds;
  final List<String> emotionIds;
  final List<String> triggerIds;
  final FilterType filter;
  final int intensity;
  final int peace;
  final int? coherence;

  bool get isFailure => filter == FilterType.impulso || (coherence != null && coherence! <= 3);
}

class PrayerEvent {
  const PrayerEvent({required this.date, required this.topicIds, required this.intent});

  final DateTime date;
  final List<String> topicIds;
  final PrayerIntent intent;
}

/// Todo lo necesario para la analítica personal, en memoria (un diario personal es pequeño).
class AnalyticsData {
  const AnalyticsData({
    required this.studies,
    required this.praxis,
    required this.prayers,
    required this.topics,
    required this.emotions,
    required this.triggers,
  });

  static const empty = AnalyticsData(studies: [], praxis: [], prayers: [], topics: {}, emotions: {}, triggers: {});

  final List<StudyEvent> studies;
  final List<PraxisEvent> praxis;
  final List<PrayerEvent> prayers;
  final Map<String, Topic> topics;
  final Map<String, CatalogEntry> emotions;
  final Map<String, CatalogEntry> triggers;

  bool get isEmpty => studies.isEmpty && praxis.isEmpty && prayers.isEmpty;

  /// Eventos desde [from] (inclusive). Los catálogos se conservan completos.
  AnalyticsData since(DateTime? from) => from == null
      ? this
      : AnalyticsData(
          studies: [
            for (final s in studies)
              if (!s.date.isBefore(from)) s,
          ],
          praxis: [
            for (final p in praxis)
              if (!p.date.isBefore(from)) p,
          ],
          prayers: [
            for (final p in prayers)
              if (!p.date.isBefore(from)) p,
          ],
          topics: topics,
          emotions: emotions,
          triggers: triggers,
        );
}

enum AnalyticsPeriod {
  days30('30 días', 30),
  days90('90 días', 90),
  year('1 año', 365),
  all('Todo', null);

  const AnalyticsPeriod(this.label, this.days);

  final String label;
  final int? days;

  DateTime? from(DateTime now) =>
      days == null ? null : DateTime(now.year, now.month, now.day).subtract(Duration(days: days! - 1));
}
