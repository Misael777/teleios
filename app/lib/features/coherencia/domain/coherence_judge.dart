import 'dart:math';
import 'dart:typed_data';

import 'thought_prototypes.dart';

/// Probabilidades calibradas del juez para un par (premisa, hipótesis).
class NliJudgment {
  const NliJudgment(this.entail, this.neutral, this.contra);

  final double entail;
  final double neutral;
  final double contra;

  /// a = P(confirma) − P(contradice) ∈ [−1, 1] (§4.2).
  double get alignment => entail - contra;

  double get confidence => max(entail, max(neutral, contra));

  String get label =>
      entail >= neutral && entail >= contra ? 'entailment' : (contra >= neutral ? 'contradiction' : 'neutral');
}

/// Estructura de un pensamiento según las cabezas tipadas del System One (§11.1).
/// Cabeza → etiqueta → probabilidad calibrada.
class ThoughtStructure {
  const ThoughtStructure(this.heads, this.embedding);

  final Map<String, Map<String, double>> heads;

  /// Vector normalizado (L2) del codificador, entrenado con negativos duros.
  final Float32List embedding;

  (String, double)? top(String head) {
    final h = heads[head];
    if (h == null || h.isEmpty) return null;
    final best = h.entries.reduce((a, b) => b.value > a.value ? b : a);
    return (best.key, best.value);
  }
}

/// Juez de coherencia agnóstico (§7): cada implementación declara su id y versión, y cada juicio
/// guardado conserva esa versión (§9).
abstract interface class CoherenceJudge {
  String get id;
  String get version;

  Future<List<NliJudgment>> judge(List<(String premise, String hypothesis)> pairs);
}

/// Codificador del System One: embeddings + cabezas tipadas en una sola pasada.
abstract interface class ThoughtAnalyzer {
  String get version;

  Future<List<ThoughtStructure>> analyze(List<String> texts, {bool asPassage = false});
}

enum JudgeRoute { automatico, usuario }

class CascadeDecision {
  const CascadeDecision(this.judgment, this.route, this.version);

  final NliJudgment judgment;

  /// automatico: confianza ≥ umbral calibrado → se sugiere; usuario: se escala a la persona.
  final JudgeRoute route;

  /// Versión del juez que dio [judgment] (se guarda con el juicio, §9).
  final String version;
}

/// Juez NLI grande y opcional (mDeBERTa recortado, §12.5): más lento, pero el único que cumple el criterio
/// de pares mínimos. Solo juzga pares; no tiene cabezas ni embeddings.
abstract interface class DeepJudge implements CoherenceJudge {
  /// Umbral calibrado del ruteador para este juez.
  double get routeThreshold;

  /// Tarjeta del laboratorio (pares mínimos, calibración).
  Map<String, dynamic> get card;
}

/// Juez en cascada (§7): decide rápido lo fácil y escala lo incierto. No hay nube aquí: lo que el
/// System One no resuelve con confianza pasa al juez grande si está instalado, y lo que ninguno resuelve
/// lo decide el usuario.
class CascadeJudge implements CoherenceJudge {
  const CascadeJudge(this.local, {required this.threshold, this.deep, this.deepThreshold = 0.9});

  final CoherenceJudge local;

  /// Umbral calibrado en el laboratorio (manifest del modelo).
  final double threshold;

  final CoherenceJudge? deep;
  final double deepThreshold;

  @override
  String get id => deep == null ? local.id : '${local.id}+${deep!.id}';

  @override
  String get version => deep == null ? local.version : '${local.version}+${deep!.version}';

  Future<List<CascadeDecision>> decide(List<(String, String)> pairs) async {
    final first = await local.judge(pairs);
    final out = [
      for (final j in first)
        CascadeDecision(j, j.confidence >= threshold ? JudgeRoute.automatico : JudgeRoute.usuario, local.version),
    ];
    final deep = this.deep;
    final unsure = [
      for (final (i, d) in out.indexed)
        if (d.route == JudgeRoute.usuario) i,
    ];
    if (deep == null || unsure.isEmpty) return out;
    final second = await deep.judge([for (final i in unsure) pairs[i]]);
    for (final (k, i) in unsure.indexed) {
      final j = second[k];
      out[i] = CascadeDecision(
        j,
        j.confidence >= deepThreshold ? JudgeRoute.automatico : JudgeRoute.usuario,
        deep.version,
      );
    }
    return out;
  }

  /// Juicios de la cascada (lo incierto del System One lo vuelve a juzgar el juez grande).
  @override
  Future<List<NliJudgment>> judge(List<(String, String)> pairs) async => [
    for (final d in await decide(pairs)) d.judgment,
  ];
}

double cosine(Float32List a, Float32List b) {
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += a[i] * b[i];
  }
  return s;
}

/// El System One instalado en el teléfono, visto desde el dominio (las pruebas usan un doble).
abstract interface class SystemOneModel implements CoherenceJudge, ThoughtAnalyzer {
  /// Umbral calibrado del ruteador de la cascada.
  double get routeThreshold;

  /// Tarjeta del laboratorio para el gráfico 8 (pares mínimos, calibración, confusión).
  Map<String, dynamic> get card;

  /// Versículos más cercanos a un vector de consulta: (id de versículo, coseno).
  Future<List<(int, double)>> nearestVerses(Float32List query, {int k = 20});

  Future<PrototypeCatalog?> get prototypeCatalog;
}
