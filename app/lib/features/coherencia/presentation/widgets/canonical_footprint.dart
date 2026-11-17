import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../shared/domain/catalogs/bible_books.dart';
import '../../../../shared/domain/entities/passage_ref.dart';
import '../../domain/belief.dart';

/// Gráfico 1 · Huella canónica: ¿la interpretación se sostiene en toda la Escritura o en un versículo?
///
/// Eje horizontal con los 66 libros (Gn → Ap). Arcos desde el pasaje base: arriba, sólidos, los
/// soportes (grosor = peso); abajo, punteados, las tensiones sin resolver. Franja inferior: soporte
/// acumulado por libro.
class CanonicalFootprint extends StatelessWidget {
  const CanonicalFootprint({super.key, required this.evidence, this.base, this.height = 230});

  final List<BeliefEvidence> evidence;
  final PassageRef? base;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label:
          'Huella canónica: ${evidence.where((e) => e.supportWeight > 0).length} soportes y '
          '${evidence.where((e) => e.tensionWeight > 0).length} tensiones en '
          '${evidence.map((e) => e.passage.bookCode).toSet().length} libros',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _FootprintPainter(
            evidence: evidence,
            base: base,
            support: scheme.primary,
            tension: scheme.error,
            axis: scheme.outline,
            muted: scheme.outlineVariant,
            label: Theme.of(context).textTheme.labelSmall!.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _FootprintPainter extends CustomPainter {
  _FootprintPainter({
    required this.evidence,
    required this.base,
    required this.support,
    required this.tension,
    required this.axis,
    required this.muted,
    required this.label,
  });

  final List<BeliefEvidence> evidence;
  final PassageRef? base;
  final Color support;
  final Color tension;
  final Color axis;
  final Color muted;
  final TextStyle label;

  static const _pad = 8.0;
  static final _index = {for (final (i, b) in BibleBooks.all.indexed) b.code: i};

  double _x(PassageRef r, double width) {
    final i = _index[r.bookCode] ?? 0;
    final within = min(r.chapter, 150) / 151;
    return _pad + (i + within) / BibleBooks.all.length * (width - 2 * _pad);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final axisY = size.height * 0.55;
    final stripTop = size.height - 30;
    final bookW = (w - 2 * _pad) / BibleBooks.all.length;

    // Eje: AT y NT como dos tramos; marcas por libro.
    final ntStart = _index['MAT']!;
    final axisPaint = Paint()
      ..color = axis
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(_pad, axisY), Offset(w - _pad, axisY), axisPaint);
    for (var i = 0; i <= BibleBooks.all.length; i++) {
      final x = _pad + i * bookW;
      final tall = i == 0 || i == ntStart || i == BibleBooks.all.length;
      canvas.drawLine(Offset(x, axisY - (tall ? 5 : 2)), Offset(x, axisY + (tall ? 5 : 2)), axisPaint);
    }
    _text(canvas, 'Antiguo Testamento', Offset(_pad + ntStart * bookW / 2, axisY + 8), center: true);
    _text(
      canvas,
      'Nuevo',
      Offset(_pad + (ntStart + (BibleBooks.all.length - ntStart) / 2) * bookW, axisY + 8),
      center: true,
    );

    // Franja inferior: soporte por libro.
    final byBook = <String, double>{};
    for (final e in evidence) {
      final s = e.supportWeight;
      if (s > 0) byBook.update(e.passage.bookCode, (v) => v + s, ifAbsent: () => s);
    }
    final maxBook = byBook.values.fold(0.0, max);
    final stripPaint = Paint()..color = support.withValues(alpha: 0.75);
    canvas.drawRect(Rect.fromLTWH(_pad, stripTop, w - 2 * _pad, 22), Paint()..color = muted.withValues(alpha: 0.25));
    for (final MapEntry(key: code, value: v) in byBook.entries) {
      final i = _index[code] ?? 0;
      final h = maxBook == 0 ? 0.0 : 22 * v / maxBook;
      canvas.drawRect(Rect.fromLTWH(_pad + i * bookW + 0.5, stripTop + 22 - h, max(1, bookW - 1), h), stripPaint);
    }

    final b = base;
    if (b == null) return;
    final bx = _x(b, w);

    // Arcos de soporte (arriba) y de tensión (abajo, punteados).
    final sorted = [...evidence]..sort((a, c) => a.supportWeight.compareTo(c.supportWeight));
    for (final e in sorted) {
      final ex = _x(e.passage, w);
      final s = e.supportWeight;
      final t = e.tensionWeight;
      if (s > 0) {
        final path = _arc(bx, ex, axisY, up: true, maxH: axisY - 14);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8 + 2.4 * s
            ..color = support.withValues(alpha: 0.25 + 0.6 * s),
        );
      } else if (t > 0) {
        final path = _arc(bx, ex, axisY, up: false, maxH: stripTop - axisY - 26);
        _dashed(
          canvas,
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1 + 2 * t
            ..color = tension.withValues(alpha: 0.4 + 0.5 * t),
        );
      } else {
        // Sin peso todavía (sin revisar ni juzgar): punto tenue en el eje.
        canvas.drawCircle(Offset(ex, axisY), 2, Paint()..color = muted);
      }
    }
    canvas.drawCircle(Offset(bx, axisY), 6, Paint()..color = support);
    canvas.drawCircle(
      Offset(bx, axisY),
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  Path _arc(double x0, double x1, double y, {required bool up, required double maxH}) {
    final h = min(maxH, max(12.0, (x1 - x0).abs() * 0.45)) * (up ? -1 : 1);
    return Path()
      ..moveTo(x0, y)
      ..cubicTo(x0, y + h, x1, y + h, x1, y);
  }

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 7) {
        canvas.drawPath(metric.extractPath(d, min(d + 4, metric.length)), paint);
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
  bool shouldRepaint(covariant _FootprintPainter old) => old.evidence != evidence || old.base != base;
}
