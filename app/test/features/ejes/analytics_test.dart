import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/ejes/domain/analytics_data.dart';
import 'package:teleios/features/ejes/domain/analytics_service.dart';
import 'package:teleios/features/ejes/domain/statistics.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';
import 'package:teleios/shared/domain/entities/topic.dart';

Topic t(String id, String name, String dim, {TopicStatus status = TopicStatus.validado}) => Topic(
  id: id,
  name: name,
  dimensionId: dim,
  status: status,
  origin: TopicOrigin.usuario,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

PraxisEvent px(
  DateTime date, {
  List<String> topics = const [],
  List<String> triggers = const [],
  FilterType filter = FilterType.biblico,
  int peace = 7,
  int? coherence = 7,
}) => PraxisEvent(
  date: date,
  topicIds: topics,
  emotionIds: const ['ira'],
  triggerIds: triggers,
  filter: filter,
  intensity: 5,
  peace: peace,
  coherence: coherence,
);

void main() {
  group('Statistics', () {
    test('media y mediana', () {
      expect(Statistics.mean([1, 2, 3, 4]), 2.5);
      expect(Statistics.median([5, 1, 3]), 3);
      expect(Statistics.median([4, 1, 3, 2]), 2.5);
      expect(Statistics.mean(<int>[]), isNull);
    });

    test('rangos con empates promediados', () {
      expect(Statistics.ranks([10, 20, 20, 30]), [1, 2.5, 2.5, 4]);
    });

    test('Spearman: relación monótona perfecta = 1 aunque no sea lineal', () {
      expect(Statistics.spearman([1, 2, 3, 4, 5], [1, 4, 9, 16, 25]), closeTo(1, 1e-9));
      expect(Statistics.spearman([1, 2, 3, 4, 5], [5, 4, 3, 2, 1]), closeTo(-1, 1e-9));
    });

    test('Spearman: valor conocido con empates', () {
      // A mano: rangos y = [2, 1, 4, 4, 4]; Σdx·dy = 7, Σdx² = 10, Σdy² = 8 → ρ = 7/√80.
      expect(Statistics.spearman([1, 2, 3, 4, 5], [2, 1, 3, 3, 3]), closeTo(0.7826, 1e-3));
    });

    test('varianza cero → null (no se inventa una correlación)', () {
      expect(Statistics.spearman([1, 2, 3], [5, 5, 5]), isNull);
    });

    test('IET normalizado en [0, 1]', () {
      expect(Statistics.iet([(10, 10)]), 1.0);
      expect(Statistics.iet([(1, 2), (5, 4)]), closeTo((2 + 20) / 200, 1e-9));
      expect(Statistics.iet(const []), isNull);
    });

    test('CorrelationResult exige n ≥ 8', () {
      expect(const CorrelationResult(rho: 0.9, n: 7).sufficient, isFalse);
      expect(const CorrelationResult(rho: 0.9, n: 8).strength, 'Correlación positiva fuerte');
      expect(const CorrelationResult(rho: -0.3, n: 10).strength, 'Correlación negativa débil');
    });
  });

  final topics = {
    'pac': t('pac', 'Paciencia', Dimension.vidaPractica),
    'sob': t('sob', 'Soberanía', Dimension.caracterDios),
    'man': t('man', 'Mansedumbre', Dimension.vidaPractica),
    'inc': t('inc', 'Cuidar lo mío', Dimension.vidaPractica, status: TopicStatus.incubacion),
  };

  AnalyticsData data({List<StudyEvent> studies = const [], List<PraxisEvent> praxis = const []}) => AnalyticsData(
    studies: studies,
    praxis: praxis,
    prayers: const [],
    topics: topics,
    emotions: const {},
    triggers: const {'t_ira': CatalogEntry(id: 't_ira', name: 'Ira')},
  );

  test('balance de dimensiones cuenta enlaces de estudio', () {
    final b = AnalyticsService.dimensionBalance(
      data(
        studies: [
          StudyEvent(date: DateTime(2026, 10, 1), bookCode: 'GAL', topicIds: const ['pac', 'sob']),
          StudyEvent(date: DateTime(2026, 10, 2), bookCode: 'ROM', topicIds: const ['sob']),
        ],
      ),
    );
    expect(b[Dimension.caracterDios], 2);
    expect(b[Dimension.vidaPractica], 1);
    expect(b[Dimension.contextoHistorico], 0);
  });

  test('topicStats: conteos, promedios solo con coherencia, IET y desfase', () {
    final stats = AnalyticsService.topicStats(
      data(
        studies: [
          StudyEvent(date: DateTime(2026, 10, 1), bookCode: 'GAL', topicIds: const ['pac']),
        ],
        praxis: [
          px(DateTime(2026, 10, 3), topics: ['pac'], peace: 8, coherence: 8),
          px(DateTime(2026, 10, 6), topics: ['pac'], peace: 2, coherence: null, filter: FilterType.impulso),
        ],
      ),
    );
    final pac = stats.firstWhere((s) => s.topic.id == 'pac');
    expect(pac.studyCount, 1);
    expect(pac.praxisCount, 2);
    expect(pac.failureCount, 1);
    expect(pac.avgCoherence, 8, reason: 'el registro rápido (sin coherencia) no cuenta');
    expect(pac.avgPeace, 5);
    expect(pac.iet, 0.64);
    expect(pac.lagDaysMedian, 3.5, reason: 'días 2 y 5 tras el estudio');
  });

  test('estudio ↔ coherencia: correlación con n explícito', () {
    final studies = <StudyEvent>[];
    final praxis = <PraxisEvent>[];
    final many = {for (var i = 0; i < 9; i++) 'x$i': t('x$i', 'Tópico $i', Dimension.vidaPractica)};
    for (var i = 0; i < 9; i++) {
      for (var k = 0; k <= i; k++) {
        studies.add(StudyEvent(date: DateTime(2026, 1, 1 + k), bookCode: 'GEN', topicIds: ['x$i']));
      }
      praxis.add(px(DateTime(2026, 3, 1), topics: ['x$i'], coherence: 1 + i));
    }
    final stats = AnalyticsService.topicStats(
      AnalyticsData(
        studies: studies,
        praxis: praxis,
        prayers: const [],
        topics: many,
        emotions: const {},
        triggers: const {},
      ),
    );
    final c = AnalyticsService.studyVsCoherence(stats);
    expect(c.n, 9);
    expect(c.rho, closeTo(1, 1e-9));
    expect(c.sufficient, isTrue);
  });

  test('paz semanal agrupa por semana ISO (lunes)', () {
    final weeks = AnalyticsService.weeklyPeace(
      data(
        praxis: [
          px(DateTime(2026, 10, 26), peace: 4), // lunes
          px(DateTime(2026, 11, 1), peace: 8), // domingo, misma semana
          px(DateTime(2026, 11, 2), peace: 6), // lunes siguiente
        ],
      ),
    );
    expect(weeks, hasLength(2));
    expect(weeks.first.weekStart, DateTime(2026, 10, 26));
    expect(weeks.first.avgPeace, 6);
    expect(weeks.first.n, 2);
  });

  group('puntos ciegos', () {
    final now = DateTime(2026, 10, 27, 20);
    final fails = [
      for (var i = 0; i < 3; i++)
        px(
          now.subtract(Duration(days: i)),
          triggers: ['t_ira'],
          filter: FilterType.impulso,
        ),
    ];

    test('3 fallas por ira sin estudiar mansedumbre → alerta', () {
      final spots = AnalyticsService.blindSpots(data(praxis: fails), now: now);
      expect(spots.single.trigger, 'Ira');
      expect(spots.single.failures, 3);
      expect(spots.single.suggestedTopics, contains('Mansedumbre'));
      expect(spots.single.daysSinceStudy, isNull);
    });

    test('si estudió el remedio hace poco, no alerta', () {
      final spots = AnalyticsService.blindSpots(
        data(
          praxis: fails,
          studies: [
            StudyEvent(date: now.subtract(const Duration(days: 5)), bookCode: 'MAT', topicIds: const ['man']),
          ],
        ),
        now: now,
      );
      expect(spots, isEmpty);
    });

    test('si el estudio fue hace más de 20 días, alerta con los días transcurridos', () {
      final spots = AnalyticsService.blindSpots(
        data(
          praxis: fails,
          studies: [
            StudyEvent(date: now.subtract(const Duration(days: 40)), bookCode: 'MAT', topicIds: const ['man']),
          ],
        ),
        now: now,
      );
      expect(spots.single.daysSinceStudy, 40);
    });

    test('2 fallas no bastan', () {
      expect(AnalyticsService.blindSpots(data(praxis: fails.take(2).toList()), now: now), isEmpty);
    });
  });

  test('candidatos a sombra: incubación + fallas recurrentes + nunca estudiado', () {
    final now = DateTime(2026, 10, 27);
    final praxis = [
      for (var i = 0; i < 3; i++)
        px(
          now.subtract(Duration(days: i)),
          topics: ['inc', 'pac'],
          filter: FilterType.impulso,
        ),
    ];
    final candidates = AnalyticsService.shadowCandidates(data(praxis: praxis), now: now);
    expect(candidates.map((t) => t.id), ['inc'], reason: 'Paciencia está validado: no puede ser sombra');
  });

  test('período: since filtra eventos y conserva catálogos', () {
    final d = data(praxis: [px(DateTime(2026, 1, 1)), px(DateTime(2026, 10, 1))]).since(DateTime(2026, 9, 1));
    expect(d.praxis, hasLength(1));
    expect(d.topics, isNotEmpty);
    expect(AnalyticsPeriod.days30.from(DateTime(2026, 10, 30, 15)), DateTime(2026, 10, 1));
  });
}
