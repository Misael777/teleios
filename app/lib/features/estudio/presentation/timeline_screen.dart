import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/devotional.dart';
import '../domain/timeline_layout.dart';
import 'estudio_providers.dart';

enum _ScaleMode { byPeriod, linear }

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  _ScaleMode _mode = _ScaleMode.byPeriod;
  double _zoom = 1;

  TimelineScale get _scale => switch (_mode) {
    _ScaleMode.byPeriod => PeriodTimelineScale(periodWidth: 150 * _zoom),
    _ScaleMode.linear => LinearTimelineScale(
      minYear: TimelineLayout.defaultMinYear,
      maxYear: TimelineLayout.defaultMaxYear,
      pxPerYear: 0.8 * _zoom,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final devotionals = ref.watch(allDevotionalsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Línea de tiempo'),
        actions: [
          IconButton(
            tooltip: 'Alejar',
            icon: const Icon(Icons.zoom_out),
            onPressed: _zoom > 0.5 ? () => setState(() => _zoom /= 1.5) : null,
          ),
          IconButton(
            tooltip: 'Acercar',
            icon: const Icon(Icons.zoom_in),
            onPressed: _zoom < 6 ? () => setState(() => _zoom *= 1.5) : null,
          ),
        ],
      ),
      body: devotionals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          final scale = _scale;
          final datable = TimelineLayout.datable(entries);
          final dots = TimelineLayout.placeInLanes(datable, scale, minGapPx: 18);
          final milestones = TimelineLayout.placeInLanes(
            [for (final m in HistoricalCatalog.milestones) (m, m.year)],
            scale,
            minGapPx: 110,
            maxLanes: 4,
          );
          final density = TimelineLayout.densityByPeriod(entries);
          final undated = entries.length - datable.length;
          final dotColors = {for (final d in dots) d.item.id: _colorFor(context, d.item)};

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SegmentedButton<_ScaleMode>(
                  segments: const [
                    ButtonSegment(value: _ScaleMode.byPeriod, label: Text('Por épocas')),
                    ButtonSegment(value: _ScaleMode.linear, label: Text('Escala real')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: GestureDetector(
                  onTapUp: (details) {
                    final hit = _hitTest(dots, details.localPosition);
                    if (hit != null) context.go(Routes.devocional(hit.id));
                  },
                  child: CustomPaint(
                    size: Size(scale.width, _TimelinePainter.height),
                    painter: _TimelinePainter(
                      scale: scale,
                      dots: dots,
                      dotColors: dotColors,
                      milestones: milestones,
                      density: density,
                      theme: Theme.of(context),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Arriba: hitos bíblicos · Abajo: tus devocionales (toca un punto para abrirlo). '
                  'Fechas aproximadas según cronología conservadora.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (undated > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Text(
                    '$undated devocional(es) sin contexto cronológico no aparecen en la línea.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SectionCard(
                  title: 'Densidad por época',
                  subtitle: 'Qué partes de la historia de la redención estás estudiando y cuáles no.',
                  child: _DensityList(density: density),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _colorFor(BuildContext context, DevotionalEntry entry) {
    if (entry.topics.isEmpty) return Theme.of(context).colorScheme.primary;
    // Color de la dimensión con más tópicos en ese devocional.
    final counts = <String, int>{};
    for (final t in entry.topics) {
      counts[t.dimensionId] = (counts[t.dimensionId] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return context.dimensionColor(top);
  }

  DevotionalEntry? _hitTest(List<PlacedItem<DevotionalEntry>> dots, Offset p) {
    for (final d in dots) {
      final center = Offset(d.x, _TimelinePainter.dotY(d.lane));
      if ((center - p).distance <= 14) return d.item;
    }
    return null;
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.scale,
    required this.dots,
    required this.dotColors,
    required this.milestones,
    required this.density,
    required this.theme,
  });

  final TimelineScale scale;
  final List<PlacedItem<DevotionalEntry>> dots;
  final Map<String, Color> dotColors;
  final List<PlacedItem<Milestone>> milestones;
  final Map<String, int> density;
  final ThemeData theme;

  static const height = 380.0;
  static const axisY = 190.0;

  static double dotY(int lane) => axisY + 30 + lane * 22;

  static double milestoneY(int lane) => axisY - 40 - lane * 30;

  @override
  void paint(Canvas canvas, Size size) {
    final scheme = theme.colorScheme;

    // Bandas de épocas (alternadas) con nombre y conteo.
    for (final (i, period) in HistoricalCatalog.periods.indexed) {
      final left = scale.x(period.startYear);
      final right = scale.x(period.endYear);
      final band = Rect.fromLTRB(left, 0, right, size.height);
      canvas.drawRect(
        band,
        Paint()
          ..color = (i.isEven ? scheme.surfaceContainerHighest : scheme.surfaceContainerLow).withValues(alpha: 0.6),
      );
      final count = density[period.id] ?? 0;
      _text(
        canvas,
        '${period.name}${count > 0 ? ' · $count' : ''}',
        Offset(left + 6, 6),
        maxWidth: (right - left - 12).clamp(20, 400),
        style: theme.textTheme.labelSmall?.copyWith(
          color: count == 0 ? scheme.outline : scheme.onSurface,
          fontWeight: count > 0 ? FontWeight.bold : null,
        ),
      );
    }

    // Eje.
    final axis = Paint()
      ..color = scheme.outline
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(0, axisY), Offset(size.width, axisY), axis);
    for (final period in HistoricalCatalog.periods) {
      final x = scale.x(period.startYear);
      canvas.drawLine(Offset(x, axisY - 6), Offset(x, axisY + 6), axis);
      _text(
        canvas,
        Formatters.year(period.startYear),
        Offset(x + 3, axisY + 8),
        style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline, fontSize: 9),
      );
    }

    // Hitos bíblicos (arriba).
    final tick = Paint()
      ..color = scheme.tertiary
      ..strokeWidth = 1;
    for (final m in milestones) {
      final y = milestoneY(m.lane);
      canvas.drawLine(Offset(m.x, y + 14), Offset(m.x, axisY), tick);
      canvas.drawCircle(Offset(m.x, axisY), 3, Paint()..color = scheme.tertiary);
      _text(
        canvas,
        m.item.title,
        Offset(m.x - 50, y),
        maxWidth: 100,
        center: true,
        style: theme.textTheme.labelSmall?.copyWith(color: scheme.tertiary),
      );
    }

    // Devocionales (abajo).
    for (final d in dots) {
      final center = Offset(d.x, dotY(d.lane));
      canvas.drawLine(Offset(d.x, axisY), center, Paint()..color = scheme.outlineVariant);
      canvas.drawCircle(center, 8, Paint()..color = dotColors[d.item.id]!);
      canvas.drawCircle(
        center,
        8,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = scheme.surface
          ..strokeWidth = 2,
      );
    }
  }

  void _text(Canvas canvas, String text, Offset at, {TextStyle? style, double maxWidth = 200, bool center = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    final dx = center ? at.dx + (maxWidth - painter.width) / 2 : at.dx;
    painter.paint(canvas, Offset(dx, at.dy));
  }

  @override
  bool shouldRepaint(_TimelinePainter old) =>
      old.scale != scale || old.dots != dots || old.theme != theme || old.density != density;
}

class _DensityList extends StatelessWidget {
  const _DensityList({required this.density});

  final Map<String, int> density;

  @override
  Widget build(BuildContext context) {
    final max = density.values.fold(0, (a, b) => a > b ? a : b);
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final p in HistoricalCatalog.periods)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 170, child: Text(p.name, style: theme.textTheme.bodySmall)),
                Expanded(
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : (density[p.id] ?? 0) / max,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: context.dimensionColor(Dimension.contextoHistorico),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text('${density[p.id] ?? 0}', textAlign: TextAlign.end, style: theme.textTheme.labelMedium),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
