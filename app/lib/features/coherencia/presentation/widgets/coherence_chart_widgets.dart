import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/belief.dart';
import '../../domain/coherence_charts.dart';
import '../../domain/coherence_statistics.dart';

/// Debajo del mínimo de datos, un aviso honesto en vez de una tendencia engañosa (§5).
class NotEnoughData extends StatelessWidget {
  const NotEnoughData({super.key, required this.n, required this.min, this.unit = 'registros'});

  final int n;
  final int min;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty, color: theme.colorScheme.outline),
          const SizedBox(height: 6),
          Text(
            'Aún no hay suficientes datos (n = $n de $min $unit)',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: (n / min).clamp(0, 1), borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}

Color alignmentColor(BuildContext context, ActionAlignment a) {
  final s = Theme.of(context).colorScheme;
  return switch (a) {
    ActionAlignment.desde => s.primary,
    ActionAlignment.neutral => s.outline,
    ActionAlignment.contra => s.error,
  };
}

String formatEstimate(Estimate? e, {int digits = 1}) => e == null
    ? '—'
    : '${e.value.toStringAsFixed(digits)} [${e.lo.toStringAsFixed(digits)}, ${e.hi.toStringAsFixed(digits)}]';

String formatCorrelation(Correlation c) =>
    'ρ = ${c.rho.toStringAsFixed(2)} (IC 95 % ${c.lo.toStringAsFixed(2)} a ${c.hi.toStringAsFixed(2)}), n = ${c.n}, '
    'p = ${c.p < 0.001 ? '< 0.001' : c.p.toStringAsFixed(3)}';

// ─── Gráfico 3 ─────────────────────────────────────────────────────────────

/// Mapa de creencias por capas: Interpretación → Creencia → Acciones (grosor = frecuencia,
/// color = alineación) → Paz media.
class BeliefMapView extends StatelessWidget {
  const BeliefMapView({super.key, required this.rows, this.onTap});

  final List<BeliefMapRow> rows;
  final void Function(Belief belief)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = rows.fold<int>(1, (m, r) => max(m, r.counts.values.fold(0, max)));
    return Column(
      children: [
        Row(
          children: [
            for (final h in ['Interpretación', 'Creencia', 'Acciones', 'Paz media'])
              Expanded(
                flex: h == 'Creencia' ? 3 : 2,
                child: Text(h, style: theme.textTheme.labelMedium),
              ),
          ],
        ),
        const Divider(),
        for (final r in rows)
          InkWell(
            key: Key('belief-map-${r.belief.id}'),
            onTap: onTap == null ? null : () => onTap!(r.belief),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      r.source,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(flex: 3, child: Text(r.belief.proposition, maxLines: 3, overflow: TextOverflow.ellipsis)),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final a in ActionAlignment.values)
                          if (r.counts[a]! > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 1),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6 + 50 * r.counts[a]! / maxCount,
                                    height: 2 + 8 * r.counts[a]! / maxCount,
                                    decoration: BoxDecoration(
                                      color: alignmentColor(context, a),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${r.counts[a]}', style: theme.textTheme.labelSmall),
                                ],
                              ),
                            ),
                        if (r.total == 0) Text('Sin acciones', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final a in ActionAlignment.values)
                          if (r.peace[a] != null)
                            Text(
                              '${a.shortLabel}: ${r.peace[a]!.value.toStringAsFixed(1)}',
                              style: theme.textTheme.labelSmall?.copyWith(color: alignmentColor(context, a)),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Gráfico 4 ─────────────────────────────────────────────────────────────

/// Dispersión alineación (−1, 0, 1, con jitter) vs paz, media ± IC por grupo y recta de tendencia.
class AlignmentPeaceChart extends StatelessWidget {
  const AlignmentPeaceChart({super.key, required this.data});

  final AlignmentPeace data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: CustomPaint(
            painter: _AlignmentPeacePainter(
              data,
              colors: {for (final a in ActionAlignment.values) a: alignmentColor(context, a)},
              grid: theme.colorScheme.outlineVariant,
              label: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ink: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data.correlation == null
              ? 'Correlación: aún no hay suficientes pares.'
              : formatCorrelation(data.correlation!),
          style: theme.textTheme.bodySmall,
        ),
        for (final a in ActionAlignment.values)
          if (data.meanByAlignment[a] != null)
            Text(
              '${a.shortLabel}: paz media ${formatEstimate(data.meanByAlignment[a])}',
              style: theme.textTheme.bodySmall?.copyWith(color: alignmentColor(context, a)),
            ),
      ],
    );
  }
}

class _AlignmentPeacePainter extends CustomPainter {
  _AlignmentPeacePainter(this.data, {required this.colors, required this.grid, required this.label, required this.ink});

  final AlignmentPeace data;
  final Map<ActionAlignment, Color> colors;
  final Color grid;
  final TextStyle label;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0, bottom = 22.0, top = 6.0;
    final w = size.width - left - 8, h = size.height - bottom - top;
    double x(double a) => left + (a + 1.4) / 2.8 * w;
    double y(double p) => top + h - (p - 1) / 9 * h;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 0.6;
    for (final p in [1, 4, 7, 10]) {
      canvas.drawLine(Offset(left, y(p.toDouble())), Offset(size.width - 8, y(p.toDouble())), gridPaint);
      _text(canvas, '$p', Offset(4, y(p.toDouble()) - 6));
    }
    for (final a in ActionAlignment.values) {
      _text(canvas, a.shortLabel, Offset(x(a.value.toDouble()), size.height - 16), center: true);
    }
    final rng = Random(42);
    for (final p in data.points) {
      final a = ActionAlignment.values.firstWhere((v) => v.value == p.alignment);
      canvas.drawCircle(
        Offset(x(p.alignment + (rng.nextDouble() - 0.5) * 0.5), y(p.peace + (rng.nextDouble() - 0.5) * 0.3)),
        3,
        Paint()..color = colors[a]!.withValues(alpha: 0.45),
      );
    }
    for (final MapEntry(key: a, value: e) in data.meanByAlignment.entries) {
      if (e == null) continue;
      final cx = x(a.value.toDouble());
      final stroke = Paint()
        ..color = ink
        ..strokeWidth = 2;
      canvas.drawLine(Offset(cx, y(e.lo.clamp(1, 10))), Offset(cx, y(e.hi.clamp(1, 10))), stroke);
      canvas.drawLine(Offset(cx - 10, y(e.value)), Offset(cx + 10, y(e.value)), stroke..strokeWidth = 3);
    }
    // Tendencia por mínimos cuadrados (descriptiva; la inferencia usa Spearman).
    if (data.points.length >= 3) {
      final xs = data.points.map((p) => p.alignment).toList();
      final ys = data.points.map((p) => p.peace.toDouble()).toList();
      final mx = xs.reduce((a, b) => a + b) / xs.length, my = ys.reduce((a, b) => a + b) / ys.length;
      var num = 0.0, den = 0.0;
      for (var i = 0; i < xs.length; i++) {
        num += (xs[i] - mx) * (ys[i] - my);
        den += pow(xs[i] - mx, 2);
      }
      if (den > 0) {
        final slope = num / den;
        canvas.drawLine(
          Offset(x(-1.2), y((my + slope * (-1.2 - mx)).clamp(1, 10))),
          Offset(x(1.2), y((my + slope * (1.2 - mx)).clamp(1, 10))),
          Paint()
            ..color = ink.withValues(alpha: 0.5)
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _text(Canvas canvas, String s, Offset at, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: label),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at.translate(-tp.width / 2, 0) : at);
  }

  @override
  bool shouldRepaint(covariant _AlignmentPeacePainter old) => old.data != data;
}

// ─── Gráfico 5 ─────────────────────────────────────────────────────────────

/// Dos paneles alineados (alineación arriba, paz abajo) con bandas de IC. Sin doble eje.
class WeeklyCoherencePanels extends StatelessWidget {
  const WeeklyCoherencePanels({super.key, required this.points});

  final List<WeeklyCoherencePoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant);
    Widget panel(String title, Estimate? Function(WeeklyCoherencePoint) pick, double lo, double hi, Color color) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelMedium),
            SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _BandPainter(
                  [for (final p in points) pick(p)],
                  lo,
                  hi,
                  color,
                  theme.colorScheme.outlineVariant,
                  label,
                ),
              ),
            ),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        panel('Alineación media (−1 a 1)', (p) => p.alignment, -1, 1, theme.colorScheme.primary),
        const SizedBox(height: 8),
        panel('Paz media (1 a 10)', (p) => p.peace, 1, 10, const Color(0xFF6DBB8A)),
        const SizedBox(height: 4),
        if (points.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Formatters.date(points.first.weekStart), style: label),
              Text(Formatters.date(points.last.weekStart), style: label),
            ],
          ),
      ],
    );
  }
}

class _BandPainter extends CustomPainter {
  _BandPainter(this.values, this.lo, this.hi, this.color, this.grid, this.label);

  final List<Estimate?> values;
  final double lo;
  final double hi;
  final Color color;
  final Color grid;
  final TextStyle label;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    final w = size.width - left - 4;
    double x(int i) => left + (values.length == 1 ? w / 2 : i / (values.length - 1) * w);
    double y(double v) => size.height - 4 - (v.clamp(lo, hi) - lo) / (hi - lo) * (size.height - 8);
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 0.6;
    for (final v in [lo, (lo + hi) / 2, hi]) {
      canvas.drawLine(Offset(left, y(v)), Offset(size.width, y(v)), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1), style: label),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, y(v) - tp.height / 2));
    }
    // Banda y línea por tramos contiguos (las semanas sin datos cortan la serie).
    final band = Paint()..color = color.withValues(alpha: 0.18);
    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    var segment = <int>[];
    void flush() {
      if (segment.isEmpty) return;
      final upper = [for (final i in segment) Offset(x(i), y(values[i]!.hi))];
      final lower = [for (final i in segment.reversed) Offset(x(i), y(values[i]!.lo))];
      if (segment.length > 1) {
        canvas.drawPath(Path()..addPolygon([...upper, ...lower], true), band);
        canvas.drawPath(Path()..addPolygon([for (final i in segment) Offset(x(i), y(values[i]!.value))], false), line);
      }
      for (final i in segment) {
        canvas.drawCircle(Offset(x(i), y(values[i]!.value)), 2.5, Paint()..color = color);
      }
      segment = [];
    }

    for (var i = 0; i < values.length; i++) {
      if (values[i] == null) {
        flush();
      } else {
        segment.add(i);
      }
    }
    flush();
  }

  @override
  bool shouldRepaint(covariant _BandPainter old) => old.values != values;
}

// ─── Gráfico 6 ─────────────────────────────────────────────────────────────

/// Barras por rezago −2…+2 con IC: ¿la alineación precede a la paz o al revés?
class LagBars extends StatelessWidget {
  const LagBars({super.key, required this.lags});

  final Map<int, Correlation?> lags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(
            painter: _LagPainter(
              lags,
              theme.colorScheme.primary,
              theme.colorScheme.outlineVariant,
              theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        Text(
          'Rezago +k: la alineación de una semana frente a la paz k semanas después. '
          'Rezago −k: la paz precede a la alineación. Asociación, no causa.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _LagPainter extends CustomPainter {
  _LagPainter(this.lags, this.color, this.grid, this.label);

  final Map<int, Correlation?> lags;
  final Color color;
  final Color grid;
  final TextStyle label;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0, bottom = 18.0;
    final keys = lags.keys.toList()..sort();
    final h = size.height - bottom;
    double y(double r) => h / 2 - r * (h / 2 - 4);
    final slot = (size.width - left) / keys.length;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 0.6;
    for (final r in [-1.0, 0.0, 1.0]) {
      canvas.drawLine(Offset(left, y(r)), Offset(size.width, y(r)), gridPaint..strokeWidth = r == 0 ? 1.2 : 0.6);
      _text(canvas, r.toStringAsFixed(0), Offset(6, y(r) - 6));
    }
    for (final (i, k) in keys.indexed) {
      final cx = left + slot * (i + 0.5);
      _text(canvas, k > 0 ? '+$k' : '$k', Offset(cx, size.height - 14), center: true);
      final c = lags[k];
      if (c == null) {
        _text(canvas, 'n<', Offset(cx, y(0) - 16), center: true);
        continue;
      }
      canvas.drawRect(
        Rect.fromPoints(Offset(cx - slot * 0.25, y(0)), Offset(cx + slot * 0.25, y(c.rho))),
        Paint()..color = color.withValues(alpha: k == 0 ? 0.9 : 0.6),
      );
      final whisker = Paint()
        ..color = color
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(cx, y(c.lo)), Offset(cx, y(c.hi)), whisker);
      canvas.drawLine(Offset(cx - 5, y(c.lo)), Offset(cx + 5, y(c.lo)), whisker);
      canvas.drawLine(Offset(cx - 5, y(c.hi)), Offset(cx + 5, y(c.hi)), whisker);
    }
  }

  void _text(Canvas canvas, String s, Offset at, {bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: label),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center ? at.translate(-tp.width / 2, 0) : at);
  }

  @override
  bool shouldRepaint(covariant _LagPainter old) => old.lags != lags;
}
