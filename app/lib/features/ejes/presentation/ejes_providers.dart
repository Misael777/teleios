import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/usecases/topic_usecases.dart';
import '../../../shared/providers.dart';
import '../data/drift_analytics_repository.dart';
import '../domain/analytics_data.dart';

final analyticsRepositoryProvider = Provider((ref) => DriftAnalyticsRepository(ref.watch(appDatabaseProvider)));

final allAnalyticsProvider = StreamProvider<AnalyticsData>((ref) => ref.watch(analyticsRepositoryProvider).watch());

final analyticsPeriodProvider = NotifierProvider<AnalyticsPeriodNotifier, AnalyticsPeriod>(AnalyticsPeriodNotifier.new);

class AnalyticsPeriodNotifier extends Notifier<AnalyticsPeriod> {
  @override
  AnalyticsPeriod build() => AnalyticsPeriod.days90;

  void set(AnalyticsPeriod p) => state = p;
}

/// Datos del período elegido.
final periodAnalyticsProvider = Provider<AsyncValue<AnalyticsData>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  return ref.watch(allAnalyticsProvider).whenData((d) => d.since(period.from(DateTime.now())));
});

final markShadowProvider = Provider((ref) => MarkTopicAsShadow(ref.watch(topicRepositoryProvider)));
