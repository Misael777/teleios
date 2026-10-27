import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/domain/timeline_layout.dart';
import 'package:teleios/shared/domain/catalogs/historical_catalog.dart';
import 'package:teleios/shared/domain/entities/historical_context.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';

DevotionalEntry entry(String id, HistoricalContext context) => DevotionalEntry(
  id: id,
  date: DateTime(2026),
  passage: const PassageRef(bookCode: 'GEN', chapter: 1),
  content: '',
  context: context,
  topics: const [],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  test('las épocas del catálogo son contiguas y crecientes', () {
    final periods = HistoricalCatalog.periods;
    for (var i = 1; i < periods.length; i++) {
      expect(periods[i].startYear, periods[i - 1].endYear, reason: periods[i].name);
      expect(periods[i].endYear, greaterThan(periods[i].startYear));
    }
  });

  test('cada hito pertenece a una época existente', () {
    for (final m in HistoricalCatalog.milestones) {
      expect(HistoricalCatalog.period(m.periodId), isNotNull, reason: m.title);
    }
  });

  group('LinearTimelineScale', () {
    const scale = LinearTimelineScale(minYear: -1000, maxYear: 0, pxPerYear: 1, padding: 10);

    test('mapea años linealmente y recorta fuera de rango', () {
      expect(scale.x(-1000), 10);
      expect(scale.x(-500), 510);
      expect(scale.x(-5000), 10);
      expect(scale.width, 1020);
    });
  });

  group('PeriodTimelineScale', () {
    const scale = PeriodTimelineScale(periodWidth: 100, padding: 0);

    test('cada época mide lo mismo', () {
      for (final (i, p) in HistoricalCatalog.periods.indexed) {
        expect(scale.x(p.startYear), closeTo(i * 100, 0.001), reason: p.name);
      }
    });

    test('es monótona creciente', () {
      var last = -1.0;
      for (var y = -2100; y <= 100; y += 7) {
        final x = scale.x(y);
        expect(x, greaterThanOrEqualTo(last));
        last = x;
      }
    });

    test('la Iglesia primitiva no queda aplastada frente a los Patriarcas', () {
      final nt = scale.x(100) - scale.x(30);
      final patriarcas = scale.x(-1800) - scale.x(-2100);
      expect(nt, closeTo(patriarcas, 0.001));
    });
  });

  test('yearFor usa el año del usuario o la mitad de la época', () {
    expect(TimelineLayout.yearFor(const HistoricalContext(approxYear: 57, periodId: 'exilio')), 57);
    expect(TimelineLayout.yearFor(const HistoricalContext(periodId: 'exilio')), (-586 + -538) ~/ 2);
    expect(TimelineLayout.yearFor(const HistoricalContext()), isNull);
  });

  test('placeInLanes separa puntos cercanos en carriles', () {
    const scale = LinearTimelineScale(minYear: 0, maxYear: 100, pxPerYear: 1);
    final placed = TimelineLayout.placeInLanes([('a', 10), ('b', 12), ('c', 50), ('d', 13)], scale, minGapPx: 10);
    final lanes = {for (final p in placed) p.item: p.lane};
    expect(lanes['a'], 0);
    expect(lanes['b'], 1);
    expect(lanes['d'], 2);
    expect(lanes['c'], 0);
  });

  test('placeInLanes respeta el máximo de carriles', () {
    const scale = LinearTimelineScale(minYear: 0, maxYear: 100, pxPerYear: 1);
    final placed = TimelineLayout.placeInLanes([for (var i = 0; i < 10; i++) (i, 50)], scale, maxLanes: 3);
    expect(placed.map((p) => p.lane).toSet().length, lessThanOrEqualTo(3));
  });

  test('densityByPeriod cuenta devocionales por época e ignora los no fechables', () {
    final density = TimelineLayout.densityByPeriod([
      entry('1', const HistoricalContext(periodId: 'iglesia_primitiva')),
      entry('2', const HistoricalContext(approxYear: 57)),
      entry('3', const HistoricalContext(periodId: 'exilio')),
      entry('4', const HistoricalContext()),
    ]);
    expect(density['iglesia_primitiva'], 2);
    expect(density['exilio'], 1);
    expect(density.values.reduce((a, b) => a + b), 3);
  });
}
