import 'dart:math';

import 'belief.dart';
import 'coherence_statistics.dart';

/// Vector de coherencia canónica de una interpretación (docs/PLAN-COHERENCIA.md §4.1).
/// Nunca se resume en un solo número: cada componente va con su intervalo y su evidencia.
class CanonicalCoherence {
  const CanonicalCoherence({
    required this.support,
    required this.diversity,
    required this.tension,
    required this.supportByBook,
    required this.n,
    this.fidelity,
  });

  /// S = Σ p_e(r).
  final Estimate support;

  /// D = exp(entropía del soporte por libro): número efectivo de libros.
  final Estimate diversity;

  /// T = Σ p_c(r) de tensiones sin resolver.
  final Estimate tension;

  /// F ∈ [−1, 1]: fidelidad al contexto inmediato (requiere juez; null en la fase sin ML).
  final double? fidelity;

  /// Código de libro → soporte acumulado (franja inferior de la huella canónica).
  final Map<String, double> supportByBook;

  /// Pasajes evaluados (|R(I)|).
  final int n;

  bool get isEmpty => n == 0;

  static const empty = CanonicalCoherence(
    support: Estimate.zero,
    diversity: Estimate.zero,
    tension: Estimate.zero,
    supportByBook: {},
    n: 0,
  );

  static CanonicalCoherence compute(List<BeliefEvidence> evidence, {double? fidelity, int resamples = 500}) {
    if (evidence.isEmpty) return empty;
    final s = _support(evidence);
    final d = _diversity(evidence);
    final t = _tension(evidence);
    final rng = Random(evidence.length * 7919 + 17);
    final sb = <double>[], db = <double>[], tb = <double>[];
    for (var i = 0; i < resamples; i++) {
      final sample = [for (var j = 0; j < evidence.length; j++) evidence[rng.nextInt(evidence.length)]];
      sb.add(_support(sample));
      db.add(_diversity(sample));
      tb.add(_tension(sample));
    }
    return CanonicalCoherence(
      support: Estimate.fromBootstrap(s, sb),
      diversity: Estimate.fromBootstrap(d, db),
      tension: Estimate.fromBootstrap(t, tb),
      fidelity: fidelity,
      supportByBook: _byBook(evidence),
      n: evidence.length,
    );
  }

  static double _support(List<BeliefEvidence> e) => e.fold(0.0, (a, x) => a + x.supportWeight);

  static double _tension(List<BeliefEvidence> e) => e.fold(0.0, (a, x) => a + x.tensionWeight);

  static Map<String, double> _byBook(List<BeliefEvidence> e) {
    final map = <String, double>{};
    for (final x in e) {
      final w = x.supportWeight;
      if (w > 0) map.update(x.passage.bookCode, (v) => v + w, ifAbsent: () => w);
    }
    return map;
  }

  /// exp(−Σ q_b ln q_b): 10 versículos de un capítulo ≈ 1; 5 libros parejos ≈ 5.
  static double _diversity(List<BeliefEvidence> e) {
    final byBook = _byBook(e);
    final total = byBook.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return 0;
    var h = 0.0;
    for (final v in byBook.values) {
      final q = v / total;
      h -= q * log(q);
    }
    return exp(h);
  }

  /// Solo ordena creencias en terciles para el selector H3 del gráfico 4; nunca se muestra como nota
  /// (§9: sin puntaje global). Premia el soporte diverso y descuenta la tensión.
  double get rankKey => support.value * max(1, diversity.value) - tension.value;
}
