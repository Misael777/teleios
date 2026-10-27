import '../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../shared/domain/entities/historical_context.dart';
import 'devotional.dart';

/// Convierte años en coordenadas horizontales.
abstract interface class TimelineScale {
  double x(int year);

  double get width;
}

/// Escala real: cada año ocupa lo mismo. Fiel a la duración, pero el NT queda comprimido.
class LinearTimelineScale implements TimelineScale {
  const LinearTimelineScale({required this.minYear, required this.maxYear, required this.pxPerYear, this.padding = 32})
    : assert(maxYear > minYear);

  final int minYear;
  final int maxYear;
  final double pxPerYear;
  final double padding;

  @override
  double x(int year) => padding + (year.clamp(minYear, maxYear) - minYear) * pxPerYear;

  @override
  double get width => padding * 2 + (maxYear - minYear) * pxPerYear;
}

/// Escala por épocas: cada período tiene el mismo ancho, sin importar cuántos años dure.
class PeriodTimelineScale implements TimelineScale {
  const PeriodTimelineScale({this.periods = HistoricalCatalog.periods, required this.periodWidth, this.padding = 32});

  final List<HistoricalPeriod> periods;
  final double periodWidth;
  final double padding;

  @override
  double x(int year) {
    final clamped = year.clamp(periods.first.startYear, periods.last.endYear);
    var index = periods.indexWhere((p) => clamped >= p.startYear && clamped < p.endYear);
    if (index == -1) index = periods.length - 1;
    final p = periods[index];
    final fraction = (clamped - p.startYear) / (p.endYear - p.startYear);
    return padding + (index + fraction) * periodWidth;
  }

  @override
  double get width => padding * 2 + periods.length * periodWidth;
}

class PlacedItem<T> {
  const PlacedItem(this.item, this.year, this.x, this.lane);

  final T item;
  final int year;
  final double x;
  final int lane;
}

abstract final class TimelineLayout {
  static const defaultMinYear = -2200;
  static const defaultMaxYear = 110;

  /// Año a ubicar: el año aproximado del usuario o, si no hay, la mitad del período.
  static int? yearFor(HistoricalContext context) =>
      context.approxYear ?? HistoricalCatalog.period(context.periodId)?.midYear;

  /// Asigna carriles para que los puntos cercanos no se encimen.
  static List<PlacedItem<T>> placeInLanes<T>(
    Iterable<(T, int)> items,
    TimelineScale scale, {
    double minGapPx = 20,
    int maxLanes = 6,
  }) {
    final sorted = items.toList()..sort((a, b) => a.$2.compareTo(b.$2));
    final laneEnds = <double>[];
    final placed = <PlacedItem<T>>[];
    for (final (item, year) in sorted) {
      final x = scale.x(year);
      var lane = laneEnds.indexWhere((end) => x - end >= minGapPx);
      if (lane == -1) {
        if (laneEnds.length < maxLanes) {
          laneEnds.add(x);
          lane = laneEnds.length - 1;
        } else {
          // Sin espacio: se apila en el carril que terminó antes.
          lane = laneEnds.indexOf(laneEnds.reduce((a, b) => a < b ? a : b));
        }
      }
      laneEnds[lane] = x;
      placed.add(PlacedItem(item, year, x, lane));
    }
    return placed;
  }

  /// Devocionales con contexto ubicable, listos para la línea de tiempo.
  static List<(DevotionalEntry, int)> datable(List<DevotionalEntry> entries) => [
    for (final e in entries)
      if (yearFor(e.context) case final year?) (e, year),
  ];

  /// periodId → cuántos devocionales caen en ese período.
  static Map<String, int> densityByPeriod(List<DevotionalEntry> entries) {
    final density = {for (final p in HistoricalCatalog.periods) p.id: 0};
    for (final (_, year) in datable(entries)) {
      final period = HistoricalCatalog.periods.where((p) => year >= p.startYear && year < p.endYear).firstOrNull;
      if (period != null) density[period.id] = density[period.id]! + 1;
    }
    return density;
  }
}
