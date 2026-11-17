import 'dart:math';

import 'package:flutter/material.dart';

/// Normaliza niveles de sonido (cada plataforma usa otra escala) a [0, 1] con min/max adaptativos.
class LevelNormalizer {
  double _min = double.infinity;
  double _max = double.negativeInfinity;

  double add(double raw) {
    _min = min(_min, raw);
    _max = max(_max, raw);
    final span = _max - _min;
    return span < 1e-6 ? 0 : ((raw - _min) / span).clamp(0, 1).toDouble();
  }
}

/// Onda de barras simétricas, coloreada con el degradado de marca.
class Waveform extends StatelessWidget {
  const Waveform({super.key, required this.levels, this.height = 72, this.active = true});

  /// Valores en [0, 1], el más reciente al final.
  final List<double> levels;
  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(
      painter: _WaveformPainter(
        levels: levels,
        color: Theme.of(context).colorScheme.primary,
        idle: Theme.of(context).colorScheme.outlineVariant,
        active: active,
      ),
    ),
  );
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.levels, required this.color, required this.idle, required this.active});

  final List<double> levels;
  final Color color;
  final Color idle;
  final bool active;

  static const barWidth = 4.0;
  static const gap = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final count = (size.width / (barWidth + gap)).floor();
    final mid = size.height / 2;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;
    for (var i = 0; i < count; i++) {
      final idx = levels.length - count + i;
      final v = idx >= 0 ? levels[idx] : 0.0;
      final h = max(2.0, v * (size.height - 6) / 2);
      final x = size.width - (count - i) * (barWidth + gap) + barWidth / 2;
      // Las barras recientes (a la derecha) más intensas.
      final t = i / max(1, count - 1);
      paint.color = active ? Color.lerp(color.withValues(alpha: 0.35), color, t)! : idle;
      canvas.drawLine(Offset(x, mid - h), Offset(x, mid + h), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.levels != levels || old.active != active || old.color != color;
}
