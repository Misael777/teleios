import 'dart:math';

import '../../ejes/domain/statistics.dart';

/// Valor con intervalo de confianza del 95 %.
class Estimate {
  const Estimate(this.value, this.lo, this.hi);

  static const zero = Estimate(0, 0, 0);

  final double value;
  final double lo;
  final double hi;

  /// Percentiles 2.5 y 97.5 de las réplicas bootstrap.
  factory Estimate.fromBootstrap(double value, List<double> replicas) {
    if (replicas.isEmpty) return Estimate(value, value, value);
    final sorted = [...replicas]..sort();
    double q(double p) => sorted[min(sorted.length - 1, max(0, (p * (sorted.length - 1)).round()))];
    return Estimate(value, q(0.025), q(0.975));
  }

  /// Media con IC t de Student (aprox. normal para n ≥ 30).
  static Estimate? mean(List<num> values) {
    if (values.isEmpty) return null;
    final m = Statistics.mean(values)!;
    if (values.length < 2) return Estimate(m, m, m);
    final sd = sqrt(values.fold<double>(0, (a, v) => a + pow(v - m, 2)) / (values.length - 1));
    final half = CoherenceStatistics.tCritical(values.length - 1) * sd / sqrt(values.length);
    return Estimate(m, m - half, m + half);
  }
}

/// Correlación con intervalo, n y valor p (asociación, nunca causa).
class Correlation {
  const Correlation({required this.rho, required this.lo, required this.hi, required this.p, required this.n});

  final double rho;
  final double lo;
  final double hi;
  final double p;
  final int n;
}

/// Estadística del plan de coherencia en Dart puro (sin dependencias): §4.2-4.3.
abstract final class CoherenceStatistics {
  /// Spearman con IC por transformación de Fisher (error estándar de Bonett-Wright: √(1.06/(n−3))).
  static Correlation? spearman(List<double> x, List<double> y, {int minN = Statistics.minPairs}) {
    if (x.length != y.length || x.length < max(minN, 4)) return null;
    final rho = Statistics.spearman(x, y);
    if (rho == null) return null;
    final n = x.length;
    final r = rho.clamp(-0.9999, 0.9999);
    final z = _atanh(r);
    final se = sqrt(1.06 / (n - 3));
    final p = 2 * (1 - normalCdf((z / se).abs()));
    return Correlation(rho: rho, lo: _tanh(z - 1.96 * se), hi: _tanh(z + 1.96 * se), p: p, n: n);
  }

  /// Correlación cruzada con rezago: lag > 0 compara x(t) con y(t + lag) (¿x precede a y?).
  static Map<int, Correlation?> laggedCorrelation(
    List<double?> x,
    List<double?> y, {
    int maxLag = 2,
    int minN = Statistics.minPairs,
  }) => {
    for (var lag = -maxLag; lag <= maxLag; lag++)
      lag: () {
        final xs = <double>[], ys = <double>[];
        for (var t = 0; t < x.length; t++) {
          final u = t + lag;
          if (u < 0 || u >= y.length || x[t] == null || y[u] == null) continue;
          xs.add(x[t]!);
          ys.add(y[u]!);
        }
        return spearman(xs, ys, minN: minN);
      }(),
  };

  /// Benjamini-Hochberg: devuelve los valores q (FDR) en el mismo orden que [pValues].
  static List<double> benjaminiHochberg(List<double> pValues) {
    final m = pValues.length;
    if (m == 0) return const [];
    final order = [for (var i = 0; i < m; i++) i]..sort((a, b) => pValues[a].compareTo(pValues[b]));
    final q = List<double>.filled(m, 1);
    var running = 1.0;
    for (var k = m - 1; k >= 0; k--) {
      final i = order[k];
      running = min(running, pValues[i] * m / (k + 1));
      q[i] = min(1, running);
    }
    return q;
  }

  /// Φ(x) con la aproximación de Abramowitz-Stegun 7.1.26 (error < 1.5e-7).
  static double normalCdf(double x) {
    final t = 1 / (1 + 0.3275911 * x.abs() / sqrt2);
    final poly = t * (0.254829592 + t * (-0.284496736 + t * (1.421413741 + t * (-1.453152027 + t * 1.061405429))));
    final erf = 1 - poly * exp(-x * x / 2);
    return x >= 0 ? (1 + erf) / 2 : (1 - erf) / 2;
  }

  /// Valor crítico t de dos colas al 95 % (tabla para gl pequeños; 1.96 desde 30).
  static double tCritical(int df) {
    const table = [12.706, 4.303, 3.182, 2.776, 2.571, 2.447, 2.365, 2.306, 2.262, 2.228, 2.201, 2.179, 2.160, 2.145];
    if (df <= 0) return double.nan;
    if (df <= table.length) return table[df - 1];
    if (df < 20) return 2.12;
    if (df < 30) return 2.06;
    return 1.96;
  }

  static double _atanh(double x) => 0.5 * log((1 + x) / (1 - x));

  static double _tanh(double x) => (exp(2 * x) - 1) / (exp(2 * x) + 1);
}
