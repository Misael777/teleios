import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../domain/analytics_service.dart';
import '../domain/statistics.dart';

/// Radar: ¿qué tan balanceado es el estudio entre las 4 dimensiones?
class DimensionRadar extends StatelessWidget {
  const DimensionRadar({super.key, required this.balance});

  final Map<String, int> balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final values = [for (final d in Dimension.all) (balance[d.id] ?? 0).toDouble()];
    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 3,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          gridBorderData: BorderSide(color: scheme.outlineVariant),
          tickBorderData: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
          radarBorderData: BorderSide(color: scheme.outlineVariant),
          titlePositionPercentageOffset: 0.12,
          titleTextStyle: Theme.of(context).textTheme.labelSmall,
          getTitle: (i, _) => RadarChartTitle(text: '${Dimension.all[i].shortName}\n${values[i].toInt()}'),
          dataSets: [
            RadarDataSet(
              dataEntries: [for (final v in values) RadarEntry(value: v)],
              fillColor: scheme.primary.withValues(alpha: 0.22),
              borderColor: scheme.primary,
              borderWidth: 2,
              entryRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tendencia semanal de la paz.
class PeaceTrend extends StatelessWidget {
  const PeaceTrend({super.key, required this.points});

  final List<WeeklyPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          minY: 1,
          maxY: 10,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 3,
            getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 0.6),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 3,
                minIncluded: false,
                maxIncluded: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                minIncluded: false,
                maxIncluded: false,
                interval: max(1, (points.length / 4).ceilToDouble()),
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox.shrink();
                  final d = points[i].weekStart;
                  return Text('${d.day}/${d.month}', style: Theme.of(context).textTheme.labelSmall);
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [for (final (i, p) in points.indexed) FlSpot(i.toDouble(), p.avgPeace)],
              isCurved: true,
              preventCurveOverShooting: true,
              color: scheme.primary,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: scheme.primary.withValues(alpha: 0.12)),
              dotData: FlDotData(show: points.length < 20),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dispersión estudio ↔ coherencia por tópico, con el resultado de Spearman.
class StudyCoherenceScatter extends StatelessWidget {
  const StudyCoherenceScatter({super.key, required this.stats, required this.correlation});

  final List<TopicStat> stats;
  final CorrelationResult correlation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final points = [
      for (final s in stats)
        if (s.avgCoherence != null) s,
    ];
    final maxX = points.isEmpty ? 5.0 : points.map((s) => s.studyCount).reduce(max).toDouble() + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.6,
          child: ScatterChart(
            ScatterChartData(
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: 10.5,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                getDrawingHorizontalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 0.6),
                getDrawingVerticalLine: (_) => FlLine(color: scheme.outlineVariant, strokeWidth: 0.6),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  axisNameWidget: Text('Coherencia', style: theme.textTheme.labelSmall),
                  sideTitles: const SideTitles(showTitles: true, reservedSize: 24, interval: 2, maxIncluded: false),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text('Veces estudiado', style: theme.textTheme.labelSmall),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    interval: max(1, (maxX / 5).ceilToDouble()),
                  ),
                ),
              ),
              scatterSpots: [
                for (final s in points)
                  ScatterSpot(
                    s.studyCount.toDouble(),
                    s.avgCoherence!,
                    dotPainter: FlDotCirclePainter(
                      radius: 4 + min(8, s.praxisCount.toDouble()),
                      color: context.dimensionColor(s.topic.dimensionId).withValues(alpha: 0.75),
                    ),
                  ),
              ],
              scatterTouchData: ScatterTouchData(
                touchTooltipData: ScatterTouchTooltipData(
                  getTooltipItems: (spot) {
                    final s = points.firstWhere(
                      (p) => p.studyCount.toDouble() == spot.x && p.avgCoherence == spot.y,
                      orElse: () => points.first,
                    );
                    return ScatterTooltipItem(
                      '${s.topic.name}\n${s.studyCount} estudios · coherencia ${s.avgCoherence!.toStringAsFixed(1)}',
                      textStyle: theme.textTheme.labelSmall,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          correlation.sufficient
              ? '${correlation.strength} (ρ de Spearman = ${correlation.rho!.toStringAsFixed(2)}, n = ${correlation.n} tópicos)'
              : 'Datos insuficientes: hacen falta ${Statistics.minPairs} tópicos con coherencia evaluada (hay ${correlation.n}).',
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Es una correlación entre tus autoevaluaciones, no una prueba de causa y efecto.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Heatmap tipo GitHub de las últimas [weeks] semanas.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({super.key, required this.activity, this.weeks = 20});

  final Map<DateTime, int> activity;
  final int weeks;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = AnalyticsService.day(DateTime.now());
    final start = AnalyticsService.weekStart(today).subtract(Duration(days: 7 * (weeks - 1)));
    final maxV = activity.values.fold(0, max);
    return LayoutBuilder(
      builder: (context, c) {
        final cell = min(18.0, (c.maxWidth - 24) / weeks - 3);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                for (final d in ['L', '', 'X', '', 'V', '', 'D'])
                  SizedBox(
                    height: cell + 3,
                    width: 20,
                    child: Text(d, style: Theme.of(context).textTheme.labelSmall),
                  ),
              ],
            ),
            for (var w = 0; w < weeks; w++)
              Column(
                children: [
                  for (var d = 0; d < 7; d++)
                    () {
                      final date = start.add(Duration(days: w * 7 + d));
                      final v = activity[date] ?? 0;
                      final future = date.isAfter(today);
                      return Tooltip(
                        message: '${Formatters.shortDate(date)}: $v',
                        child: Container(
                          width: cell,
                          height: cell,
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: future
                                ? Colors.transparent
                                : (v == 0
                                      ? scheme.surfaceContainerHighest
                                      : scheme.primary.withValues(alpha: 0.25 + 0.75 * v / max(1, maxV))),
                          ),
                        ),
                      );
                    }(),
                ],
              ),
          ],
        );
      },
    );
  }
}
