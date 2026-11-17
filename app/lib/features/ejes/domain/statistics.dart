import 'dart:math';

/// Estadística honesta: correlación (no causa), con tamaño de muestra explícito.
abstract final class Statistics {
  /// Mínimo de pares para mostrar una correlación (por debajo es ruido).
  static const minPairs = 8;

  static double? mean(Iterable<num> values) {
    if (values.isEmpty) return null;
    return values.fold<double>(0, (a, b) => a + b) / values.length;
  }

  static double? median(Iterable<num> values) {
    if (values.isEmpty) return null;
    final sorted = values.map((v) => v.toDouble()).toList()..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Rangos con promedio para empates (1-based).
  static List<double> ranks(List<double> values) {
    final indexed = [for (var i = 0; i < values.length; i++) (i, values[i])]..sort((a, b) => a.$2.compareTo(b.$2));
    final ranks = List<double>.filled(values.length, 0);
    var i = 0;
    while (i < indexed.length) {
      var j = i;
      while (j + 1 < indexed.length && indexed[j + 1].$2 == indexed[i].$2) {
        j++;
      }
      final avg = (i + j) / 2 + 1;
      for (var k = i; k <= j; k++) {
        ranks[indexed[k].$1] = avg;
      }
      i = j + 1;
    }
    return ranks;
  }

  static double? pearson(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return null;
    final mx = mean(x)!, my = mean(y)!;
    var num = 0.0, dx = 0.0, dy = 0.0;
    for (var i = 0; i < x.length; i++) {
      num += (x[i] - mx) * (y[i] - my);
      dx += pow(x[i] - mx, 2);
      dy += pow(y[i] - my, 2);
    }
    if (dx == 0 || dy == 0) return null;
    return num / sqrt(dx * dy);
  }

  /// Spearman ρ: Pearson sobre rangos. Adecuado para escalas ordinales 1-10.
  static double? spearman(List<double> x, List<double> y) => pearson(ranks(x), ranks(y));

  /// Índice de Efectividad Teológica normalizado: Σ(coherencia·paz) / (100·n) ∈ [0, 1].
  static double? iet(Iterable<(int coherence, int peace)> pairs) {
    if (pairs.isEmpty) return null;
    return pairs.fold<double>(0, (a, p) => a + p.$1 * p.$2) / (100 * pairs.length);
  }
}

class CorrelationResult {
  const CorrelationResult({required this.rho, required this.n});

  final double? rho;
  final int n;

  bool get sufficient => n >= Statistics.minPairs && rho != null;

  String get strength {
    if (!sufficient) return 'Datos insuficientes';
    final a = rho!.abs();
    final dir = rho! >= 0 ? 'positiva' : 'negativa';
    if (a < 0.2) return 'Sin correlación apreciable';
    if (a < 0.4) return 'Correlación $dir débil';
    if (a < 0.6) return 'Correlación $dir moderada';
    return 'Correlación $dir fuerte';
  }
}
