import '../../../core/utils/text_normalizer.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/domain/entities/topic.dart';
import 'analytics_data.dart';
import 'statistics.dart';

class TopicStat {
  const TopicStat({
    required this.topic,
    required this.studyCount,
    required this.praxisCount,
    required this.failureCount,
    this.avgCoherence,
    this.avgPeace,
    this.iet,
    this.lagDaysMedian,
  });

  final Topic topic;
  final int studyCount;
  final int praxisCount;
  final int failureCount;
  final double? avgCoherence;
  final double? avgPeace;
  final double? iet;

  /// Mediana de días entre el último estudio del tópico y una praxis vinculada.
  final double? lagDaysMedian;
}

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.studies,
    required this.praxis,
    required this.prayers,
    required this.failures,
    this.avgPeace,
    this.avgCoherence,
  });

  final int studies;
  final int praxis;
  final int prayers;
  final int failures;
  final double? avgPeace;
  final double? avgCoherence;
}

class WeeklyPoint {
  const WeeklyPoint(this.weekStart, this.avgPeace, this.n);

  final DateTime weekStart;
  final double avgPeace;
  final int n;
}

class BlindSpot {
  const BlindSpot({required this.trigger, required this.failures, required this.suggestedTopics, this.daysSinceStudy});

  final String trigger;
  final int failures;
  final List<String> suggestedTopics;

  /// null = nunca estudiado.
  final int? daysSinceStudy;
}

/// Servicios analíticos puros (sin base de datos ni UI): testeables y deterministas.
abstract final class AnalyticsService {
  static DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime weekStart(DateTime d) => day(d).subtract(Duration(days: d.weekday - 1));

  static AnalyticsSummary summary(AnalyticsData data) => AnalyticsSummary(
    studies: data.studies.length,
    praxis: data.praxis.length,
    prayers: data.prayers.length,
    failures: data.praxis.where((p) => p.isFailure).length,
    avgPeace: Statistics.mean(data.praxis.map((p) => p.peace)),
    avgCoherence: Statistics.mean([
      for (final p in data.praxis)
        if (p.coherence != null) p.coherence!,
    ]),
  );

  /// Cuántas veces se estudió cada dimensión (enlaces devocional → tópico).
  static Map<String, int> dimensionBalance(AnalyticsData data) {
    final counts = {for (final d in Dimension.all) d.id: 0};
    for (final s in data.studies) {
      for (final id in s.topicIds) {
        final dim = data.topics[id]?.dimensionId;
        if (dim != null) counts[dim] = counts[dim]! + 1;
      }
    }
    return counts;
  }

  static List<TopicStat> topicStats(AnalyticsData data) {
    final studiesByTopic = <String, List<DateTime>>{};
    for (final s in data.studies) {
      for (final id in s.topicIds) {
        studiesByTopic.putIfAbsent(id, () => []).add(s.date);
      }
    }
    final praxisByTopic = <String, List<PraxisEvent>>{};
    for (final p in data.praxis) {
      for (final id in p.topicIds) {
        praxisByTopic.putIfAbsent(id, () => []).add(p);
      }
    }
    final ids = {...studiesByTopic.keys, ...praxisByTopic.keys};
    return [
      for (final id in ids)
        if (data.topics[id] case final topic?)
          () {
            final studies = (studiesByTopic[id] ?? [])..sort();
            final praxis = praxisByTopic[id] ?? const <PraxisEvent>[];
            final evaluated = [
              for (final p in praxis)
                if (p.coherence != null) (p.coherence!, p.peace),
            ];
            final lags = <int>[
              for (final p in praxis)
                if (studies.lastWhere((s) => !s.isAfter(p.date), orElse: () => DateTime(0)) case final last
                    when last.year > 0)
                  day(p.date).difference(day(last)).inDays,
            ];
            return TopicStat(
              topic: topic,
              studyCount: studies.length,
              praxisCount: praxis.length,
              failureCount: praxis.where((p) => p.isFailure).length,
              avgCoherence: Statistics.mean(evaluated.map((e) => e.$1)),
              avgPeace: Statistics.mean(praxis.map((p) => p.peace)),
              iet: Statistics.iet(evaluated),
              lagDaysMedian: Statistics.median(lags),
            );
          }(),
    ]..sort((a, b) => (b.studyCount + b.praxisCount).compareTo(a.studyCount + a.praxisCount));
  }

  /// ¿Los tópicos más estudiados muestran más coherencia al vivirse? (correlación, no causa)
  static CorrelationResult studyVsCoherence(List<TopicStat> stats) {
    final pairs = [
      for (final s in stats)
        if (s.avgCoherence != null) (s.studyCount.toDouble(), s.avgCoherence!),
    ];
    return CorrelationResult(
      rho: Statistics.spearman([for (final p in pairs) p.$1], [for (final p in pairs) p.$2]),
      n: pairs.length,
    );
  }

  /// Actividad por día (estudios + registros + oraciones) para el heatmap.
  static Map<DateTime, int> activityByDay(AnalyticsData data) {
    final map = <DateTime, int>{};
    for (final d in [
      ...data.studies.map((s) => s.date),
      ...data.praxis.map((p) => p.date),
      ...data.prayers.map((p) => p.date),
    ]) {
      map.update(day(d), (v) => v + 1, ifAbsent: () => 1);
    }
    return map;
  }

  static List<WeeklyPoint> weeklyPeace(AnalyticsData data) {
    final byWeek = <DateTime, List<int>>{};
    for (final p in data.praxis) {
      byWeek.putIfAbsent(weekStart(p.date), () => []).add(p.peace);
    }
    final weeks = byWeek.keys.toList()..sort();
    return [for (final w in weeks) WeeklyPoint(w, Statistics.mean(byWeek[w]!)!, byWeek[w]!.length)];
  }

  /// Detonante → tópicos del léxico que lo trabajan.
  static const triggerRemedies = <String, List<String>>{
    't_ira': ['Mansedumbre', 'Dominio propio'],
    't_impaciencia': ['Paciencia'],
    't_orgullo': ['Humildad'],
    't_miedo': ['Confianza en Dios', 'Soberanía'],
    't_cansancio': ['Paz interior', 'Providencia'],
    't_envidia': ['Gratitud', 'Generosidad'],
    't_rechazo': ['Identidad en Cristo', 'Paternidad de Dios'],
    't_deseo': ['Dominio propio', 'Carne y Espíritu'],
    't_estres': ['Paz interior', 'Confianza en Dios'],
  };

  /// ≥ [minFailures] fallas por un detonante en [window] sin estudiar sus "remedios" en [studyWindow].
  static List<BlindSpot> blindSpots(
    AnalyticsData data, {
    required DateTime now,
    int minFailures = 3,
    Duration window = const Duration(days: 7),
    Duration studyWindow = const Duration(days: 20),
  }) {
    final counts = <String, int>{};
    for (final p in data.praxis) {
      if (!p.isFailure || now.difference(p.date) > window || p.date.isAfter(now)) continue;
      for (final t in p.triggerIds) {
        counts.update(t, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final result = <BlindSpot>[];
    for (final MapEntry(key: triggerId, value: n) in counts.entries) {
      if (n < minFailures) continue;
      final remedies = triggerRemedies[triggerId] ?? const <String>[];
      final keys = remedies.map(TextNormalizer.key).toSet();
      DateTime? lastStudy;
      for (final s in data.studies) {
        final studied = s.topicIds.any((id) => keys.contains(TextNormalizer.key(data.topics[id]?.name ?? '')));
        if (studied && (lastStudy == null || s.date.isAfter(lastStudy))) lastStudy = s.date;
      }
      if (lastStudy != null && now.difference(lastStudy) <= studyWindow) continue;
      result.add(
        BlindSpot(
          trigger: data.triggers[triggerId]?.name ?? triggerId,
          failures: n,
          suggestedTopics: remedies,
          daysSinceStudy: lastStudy == null ? null : now.difference(lastStudy).inDays,
        ),
      );
    }
    return result..sort((a, b) => b.failures.compareTo(a.failures));
  }

  /// Tópicos en incubación con fallas recurrentes y ningún estudio: candidatos a "sombra".
  static List<Topic> shadowCandidates(
    AnalyticsData data, {
    required DateTime now,
    int minFailures = 3,
    Duration window = const Duration(days: 30),
  }) {
    final studied = {for (final s in data.studies) ...s.topicIds};
    final failures = <String, int>{};
    for (final p in data.praxis) {
      if (!p.isFailure || now.difference(p.date) > window) continue;
      for (final id in p.topicIds) {
        failures.update(id, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    return [
      for (final MapEntry(key: id, value: n) in failures.entries)
        if (n >= minFailures && !studied.contains(id) && data.topics[id]?.status == TopicStatus.incubacion)
          data.topics[id]!,
    ];
  }
}
