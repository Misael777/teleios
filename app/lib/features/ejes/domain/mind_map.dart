import 'dart:math';
import 'dart:typed_data';

import '../../../shared/domain/entities/praxis_entry.dart';
import '../../coherencia/domain/coherence_judge.dart';
import '../../coherencia/domain/coherence_statistics.dart';

/// Mente de Cristo frente a mi mente, por temática (docs/PLAN-COHERENCIA.md §13).
///
/// - Mente de Cristo: lo que la lectura de la Escritura afirma. Por ahora, las creencias no refutadas y las
///   frases de los devocionales de este teléfono; luego, las creencias compartidas de todos y las del
///   laboratorio (sin cambiar nada de aquí).
/// - Mi mente: cómo reacciono de verdad, según la bitácora (circunstancia y acción).
///
/// La temática no es una etiqueta fija: es una búsqueda en el espacio de embeddings del System One que
/// trae candidatos de las dos mentes, y el juez grande confirma de qué trata cada uno ([topicTemplate]). La
/// cercanía semántica solo dice *de qué* habla cada cosa; *si mi reacción encarna o contradice* lo decide el
/// juez con [alignTemplate] (dos frases opuestas sobre lo mismo quedan cerca en el embedding).
///
/// Medido el 17-11-2026 (§13): el System One no sirve para estas dos preguntas (siempre neutral en la temática,
/// y errores con confianza alta en la postura), así que solo las responde el juez grande. Aun así falla casos
/// como "la perdoné" frente al amor: hace falta entrenarlo en la tarea acción ↔ principio.
enum MindSide { cristo, mia }

enum MindSource {
  creencia,
  devocional,
  bitacora;

  String get label => switch (this) {
    creencia => 'Creencia',
    devocional => 'Devocional',
    bitacora => 'Bitácora',
  };
}

class MindItem {
  const MindItem({
    required this.id,
    required this.side,
    required this.source,
    required this.text,
    required this.refId,
    this.date,
    this.filter,
    this.peace,
  });

  /// Único en el índice (p. ej. `devocional:<id>:3`).
  final String id;
  final MindSide side;
  final MindSource source;
  final String text;

  /// Id de la creencia, el devocional o la praxis de origen (para navegar).
  final String refId;
  final DateTime? date;

  /// Solo bitácora: filtro con el que se reaccionó y paz posterior (1–10).
  final FilterType? filter;
  final int? peace;
}

/// Ítems de las dos mentes con su embedding (L2 normalizado) del System One.
class MindIndex {
  MindIndex(this.items, this.vectors) : assert(items.length == vectors.length);

  final List<MindItem> items;
  final List<Float32List> vectors;

  bool get isEmpty => items.isEmpty;

  int count(MindSide side) => items.where((i) => i.side == side).length;
}

class MindHit {
  const MindHit(this.item, this.vector, this.score);

  final MindItem item;
  final Float32List vector;

  /// Coseno con la temática buscada.
  final double score;
}

/// Relación juzgada entre una reacción mía (premisa) y una afirmación de la mente de Cristo (hipótesis).
class MindLink {
  const MindLink(this.mine, this.christ, this.decision);

  final MindHit mine;
  final MindHit christ;
  final CascadeDecision decision;

  /// a = P(confirma) − P(contradice) ∈ [−1, 1].
  double get alignment => decision.judgment.alignment;

  /// Cuenta como evidencia solo si el juez decidió con confianza y no fue neutral.
  bool get decided => decision.route == JudgeRoute.automatico && decision.judgment.label != 'neutral';
}

class ThemeComparison {
  const ThemeComparison({
    required this.theme,
    required this.christ,
    required this.mine,
    required this.links,
    required this.posture,
    required this.blindSpots,
    required this.filterMix,
    required this.peace,
    required this.layout,
    this.judged = true,
  });

  /// Sin juez grande: solo lo cercano en el embedding, sin postura ni puntos ciegos.
  ThemeComparison.unjudged(this.theme, ({List<MindHit> christ, List<MindHit> mine}) hits, this.layout)
    : christ = hits.christ,
      mine = hits.mine,
      links = const [],
      posture = null,
      blindSpots = const [],
      filterMix = const {},
      peace = null,
      judged = false;

  final String theme;

  /// Si el juez grande revisó temática y postura.
  final bool judged;
  final List<MindHit> christ;
  final List<MindHit> mine;

  /// Para cada reacción mía, su relación más clara con la mente de Cristo (si el juez decidió).
  final List<MindLink> links;

  /// Postura media en la temática (IC 95 %): +1 mi vida confirma, −1 contradice. Null sin evidencia.
  final Estimate? posture;

  /// Afirmaciones de la mente de Cristo en esta temática que ninguna reacción mía toca.
  final List<MindHit> blindSpots;

  /// Con qué filtro reaccioné en esta temática.
  final Map<FilterType, int> filterMix;

  /// Paz posterior media (1–10) en esta temática.
  final Estimate? peace;

  /// Proyección 2D (PCA de los embeddings encontrados), en [−1, 1]: solo para el ojo, las distancias reales
  /// se calculan en todas las dimensiones.
  final Map<String, (double, double)> layout;

  Iterable<MindLink> get confirmations => links.where((l) => l.decided && l.alignment > 0);
  Iterable<MindLink> get contradictions => links.where((l) => l.decided && l.alignment < 0);

  bool get isEmpty => christ.isEmpty && mine.isEmpty;
}

abstract final class MindMap {
  /// Resultados por mente.
  static const k = 20;

  /// Afirmaciones de Cristo contra las que se juzga cada reacción mía.
  static const neighbors = 3;

  /// Coseno mínimo con la temática para ser candidato (el embedding solo preselecciona).
  static const minScore = 0.15;

  /// Candidatos por mente que el juez revisa con [topicTemplate].
  static const candidates = 30;

  /// P(confirma) mínima de "Este texto trata sobre …" para quedar en la temática.
  static const minRelevance = 0.5;

  /// Pregunta de temática al juez (premisa = el texto).
  static String topicTemplate(String theme) => 'Este texto trata sobre $theme.';

  /// Pregunta de postura al juez (premisa = mi reacción): ¿actué conforme a esta afirmación de Cristo?
  static String alignTemplate(String christ) => 'Esta persona actuó conforme a esto: $christ';

  static double cosine(Float32List a, Float32List b) {
    var s = 0.0;
    for (var i = 0; i < a.length; i++) {
      s += a[i] * b[i];
    }
    return s;
  }

  /// Los [k] ítems más cercanos a la temática en cada mente, con coseno ≥ [minScore].
  static ({List<MindHit> christ, List<MindHit> mine}) search(
    MindIndex index,
    Float32List query, {
    int k = k,
    double minScore = minScore,
  }) {
    List<MindHit> top(MindSide side) {
      final hits = [
        for (final (i, item) in index.items.indexed)
          if (item.side == side) MindHit(item, index.vectors[i], cosine(query, index.vectors[i])),
      ].where((h) => h.score >= minScore).toList()..sort((a, b) => b.score.compareTo(a.score));
      return hits.take(k).toList();
    }

    return (christ: top(MindSide.cristo), mine: top(MindSide.mia));
  }

  /// Deja en la temática solo los candidatos que el juez confirma con [topicTemplate]; [MindHit.score] pasa a
  /// ser esa probabilidad. Se ordenan de más a menos relevante y se quedan [k] por mente.
  static Future<({List<MindHit> christ, List<MindHit> mine})> rerank(
    String theme,
    ({List<MindHit> christ, List<MindHit> mine}) hits,
    CoherenceJudge judge, {
    int k = k,
    double minRelevance = minRelevance,
  }) async {
    final all = [...hits.christ, ...hits.mine];
    if (all.isEmpty) return hits;
    final hypothesis = topicTemplate(theme);
    final judged = await judge.judge([for (final h in all) (h.item.text, hypothesis)]);
    final kept = [
      for (final (i, h) in all.indexed)
        if (judged[i].entail >= minRelevance) MindHit(h.item, h.vector, judged[i].entail),
    ]..sort((a, b) => b.score.compareTo(a.score));
    List<MindHit> side(MindSide s) => kept.where((h) => h.item.side == s).take(k).toList();
    return (christ: side(MindSide.cristo), mine: side(MindSide.mia));
  }

  /// Juzga cada reacción mía contra sus [neighbors] afirmaciones de Cristo más cercanas y resume la temática.
  static Future<ThemeComparison> compare(
    String theme,
    ({List<MindHit> christ, List<MindHit> mine}) hits,
    CascadeJudge judge, {
    int neighbors = neighbors,
  }) async {
    final candidates = <(MindHit, MindHit)>[
      for (final m in hits.mine)
        ...([...hits.christ]..sort((a, b) => cosine(m.vector, b.vector).compareTo(cosine(m.vector, a.vector))))
            .take(neighbors)
            .map((c) => (m, c)),
    ];
    final decisions = candidates.isEmpty
        ? const <CascadeDecision>[]
        : await judge.decide([for (final (m, c) in candidates) (m.item.text, alignTemplate(c.item.text))]);

    // Por reacción: la relación decidida más fuerte; si ninguna se decidió, la más cercana (sin evidencia).
    final best = <String, MindLink>{};
    for (final (i, (m, c)) in candidates.indexed) {
      final link = MindLink(m, c, decisions[i]);
      final prev = best[m.item.id];
      double strength(MindLink l) => l.decided ? 1 + l.alignment.abs() : 0;
      if (prev == null || strength(link) > strength(prev)) best[m.item.id] = link;
    }
    final links = best.values.toList();
    final decided = links.where((l) => l.decided).toList();
    final touched = {for (final l in decided) l.christ.item.id};

    final mix = <FilterType, int>{};
    for (final m in hits.mine) {
      if (m.item.filter case final f?) mix.update(f, (v) => v + 1, ifAbsent: () => 1);
    }
    return ThemeComparison(
      theme: theme,
      christ: hits.christ,
      mine: hits.mine,
      links: links,
      posture: Estimate.mean([for (final l in decided) l.alignment]),
      blindSpots: [
        for (final c in hits.christ)
          if (!touched.contains(c.item.id)) c,
      ],
      filterMix: mix,
      peace: Estimate.mean([for (final m in hits.mine) ?m.item.peace]),
      layout: project([...hits.christ, ...hits.mine]),
    );
  }

  /// PCA a 2D por iteración de potencia (n ≤ 2k puntos): suficiente para ver qué queda cerca de qué.
  static Map<String, (double, double)> project(List<MindHit> hits) {
    if (hits.isEmpty) return const {};
    if (hits.length == 1) return {hits.single.item.id: (0, 0)};
    final d = hits.first.vector.length;
    final mean = Float64List(d);
    for (final h in hits) {
      for (var j = 0; j < d; j++) {
        mean[j] += h.vector[j] / hits.length;
      }
    }
    final x = [
      for (final h in hits) Float64List.fromList([for (var j = 0; j < d; j++) h.vector[j] - mean[j]]),
    ];
    final axes = <Float64List>[];
    for (var a = 0; a < 2; a++) {
      // Semilla determinista para que el mapa no salte entre búsquedas iguales.
      var v = Float64List.fromList([for (var j = 0; j < d; j++) sin(j * (a + 1.7)) + 0.01]);
      for (var it = 0; it < 60; it++) {
        final next = Float64List(d);
        for (final row in x) {
          var p = 0.0;
          for (var j = 0; j < d; j++) {
            p += row[j] * v[j];
          }
          for (var j = 0; j < d; j++) {
            next[j] += p * row[j];
          }
        }
        for (final u in axes) {
          var p = 0.0;
          for (var j = 0; j < d; j++) {
            p += next[j] * u[j];
          }
          for (var j = 0; j < d; j++) {
            next[j] -= p * u[j];
          }
        }
        var norm = 0.0;
        for (var j = 0; j < d; j++) {
          norm += next[j] * next[j];
        }
        norm = sqrt(norm);
        if (norm < 1e-12) break;
        v = Float64List.fromList([for (var j = 0; j < d; j++) next[j] / norm]);
      }
      axes.add(v);
    }
    final coords = [
      for (final row in x)
        [
          for (final u in axes)
            () {
              var p = 0.0;
              for (var j = 0; j < d; j++) {
                p += row[j] * u[j];
              }
              return p;
            }(),
        ],
    ];
    final scale = max(1e-9, coords.expand((c) => c).map((v) => v.abs()).reduce(max));
    return {for (final (i, h) in hits.indexed) h.item.id: (coords[i][0] / scale, coords[i][1] / scale)};
  }

  /// Frases de un devocional que pueden expresar una afirmación (≥ 5 palabras), hasta [limit].
  static List<String> sentences(String content, {int limit = 30}) => content
      .split(RegExp(r'(?<=[.!?¡¿;:])\s+|\n+'))
      .map((s) => s.trim())
      .where((s) => s.split(RegExp(r'\s+')).length >= 5)
      .take(limit)
      .toList();
}
