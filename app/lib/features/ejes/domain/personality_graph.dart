import 'dart:math';

import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/domain/entities/topic.dart';
import 'analytics_data.dart';
import 'statistics.dart';

enum NodeKind { dimension, topic, emotion }

class GraphNode {
  const GraphNode({
    required this.id,
    required this.label,
    required this.kind,
    required this.weight,
    this.dimensionId,
    this.status,
    this.avgIntensity,
  });

  final String id;
  final String label;
  final NodeKind kind;

  /// Uso total (define el tamaño).
  final double weight;
  final String? dimensionId;
  final TopicStatus? status;

  /// Solo emociones: intensidad promedio (≥ 8 → pulsa).
  final double? avgIntensity;

  bool get pulses => (avgIntensity ?? 0) >= 8;
}

class GraphEdge {
  const GraphEdge({required this.from, required this.to, required this.weight, this.avgPeace});

  final String from;
  final String to;
  final double weight;

  /// Paz promedio de las praxis que unen tópico y emoción (color rojo → verde). null = estructural.
  final double? avgPeace;
}

class PersonalityGraph {
  const PersonalityGraph({required this.nodes, required this.edges});

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  bool get isEmpty => nodes.every((n) => n.kind == NodeKind.dimension);
}

/// Construye el mapa mental: dimensión → tópico → emoción.
abstract final class PersonalityGraphBuilder {
  static const maxTopics = 60;

  static PersonalityGraph build(AnalyticsData data, {Set<String>? dimensions}) {
    final dims = dimensions ?? Dimension.all.map((d) => d.id).toSet();
    final usage = <String, double>{};
    void use(String id) => usage.update(id, (v) => v + 1, ifAbsent: () => 1);
    for (final s in data.studies) {
      s.topicIds.forEach(use);
    }
    for (final p in data.praxis) {
      p.topicIds.forEach(use);
    }
    for (final p in data.prayers) {
      p.topicIds.forEach(use);
    }

    final topics = [
      for (final MapEntry(key: id, value: w) in usage.entries)
        if (data.topics[id] case final t? when dims.contains(t.dimensionId)) (t, w),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    final kept = topics.take(maxTopics).toList();
    final keptIds = {for (final (t, _) in kept) t.id};

    final nodes = <GraphNode>[
      for (final d in Dimension.all)
        if (dims.contains(d.id))
          GraphNode(id: 'dim:${d.id}', label: d.name, kind: NodeKind.dimension, weight: 1, dimensionId: d.id),
      for (final (t, w) in kept)
        GraphNode(
          id: t.id,
          label: t.name,
          kind: NodeKind.topic,
          weight: w,
          dimensionId: t.dimensionId,
          status: t.status,
        ),
    ];
    final edges = <GraphEdge>[for (final (t, _) in kept) GraphEdge(from: 'dim:${t.dimensionId}', to: t.id, weight: 1)];

    // Tópico ↔ emoción por co-ocurrencia en la bitácora.
    final peaceByPair = <(String, String), List<int>>{};
    final intensityByEmotion = <String, List<int>>{};
    for (final p in data.praxis) {
      for (final e in p.emotionIds) {
        intensityByEmotion.putIfAbsent(e, () => []).add(p.intensity);
        for (final t in p.topicIds.where(keptIds.contains)) {
          peaceByPair.putIfAbsent((t, e), () => []).add(p.peace);
        }
      }
    }
    final emotionIds = {for (final (_, e) in peaceByPair.keys) e};
    for (final e in emotionIds) {
      final entry = data.emotions[e];
      nodes.add(
        GraphNode(
          id: 'emo:$e',
          label: entry?.name ?? e,
          kind: NodeKind.emotion,
          weight: intensityByEmotion[e]!.length.toDouble(),
          avgIntensity: Statistics.mean(intensityByEmotion[e]!),
        ),
      );
    }
    for (final MapEntry(key: (t, e), value: peaces) in peaceByPair.entries) {
      edges.add(GraphEdge(from: t, to: 'emo:$e', weight: peaces.length.toDouble(), avgPeace: Statistics.mean(peaces)));
    }
    return PersonalityGraph(nodes: nodes, edges: edges);
  }
}

typedef Vec = ({double x, double y});

/// Fruchterman–Reingold determinista. Las dimensiones quedan fijas en los cuatro puntos
/// cardinales para que el mapa mental sea estable entre visitas.
abstract final class ForceLayout {
  static Map<String, Vec> compute(
    PersonalityGraph graph, {
    double width = 1000,
    double height = 1000,
    int iterations = 300,
    int seed = 7,
  }) {
    final rng = Random(seed);
    final pos = <String, Vec>{};
    final fixed = <String>{};
    final cx = width / 2, cy = height / 2;
    final anchors = <String, Vec>{
      Dimension.caracterDios: (x: cx, y: height * 0.12),
      Dimension.contextoHistorico: (x: width * 0.12, y: cy),
      Dimension.vidaPractica: (x: cx, y: height * 0.88),
      Dimension.estructuraPensamiento: (x: width * 0.88, y: cy),
    };
    for (final n in graph.nodes) {
      if (n.kind == NodeKind.dimension) {
        pos[n.id] = anchors[n.dimensionId]!;
        fixed.add(n.id);
      } else {
        pos[n.id] = (x: cx + (rng.nextDouble() - 0.5) * width * 0.6, y: cy + (rng.nextDouble() - 0.5) * height * 0.6);
      }
    }
    if (pos.length < 2) return pos;

    final ids = pos.keys.toList();
    final k = sqrt(width * height / ids.length) * 0.75;
    var temperature = width / 10;
    final cool = temperature / (iterations + 1);

    for (var it = 0; it < iterations; it++) {
      final disp = {for (final id in ids) id: (x: 0.0, y: 0.0)};
      for (var i = 0; i < ids.length; i++) {
        for (var j = i + 1; j < ids.length; j++) {
          final a = pos[ids[i]]!, b = pos[ids[j]]!;
          var dx = a.x - b.x, dy = a.y - b.y;
          var d = sqrt(dx * dx + dy * dy);
          if (d < 0.01) {
            dx = rng.nextDouble() - 0.5;
            dy = rng.nextDouble() - 0.5;
            d = 0.01;
          }
          final f = k * k / d;
          final fx = dx / d * f, fy = dy / d * f;
          final di = disp[ids[i]]!, dj = disp[ids[j]]!;
          disp[ids[i]] = (x: di.x + fx, y: di.y + fy);
          disp[ids[j]] = (x: dj.x - fx, y: dj.y - fy);
        }
      }
      for (final e in graph.edges) {
        final a = pos[e.from], b = pos[e.to];
        if (a == null || b == null) continue;
        final dx = a.x - b.x, dy = a.y - b.y;
        final d = max(0.01, sqrt(dx * dx + dy * dy));
        final f = d * d / k * min(3.0, sqrt(e.weight));
        final fx = dx / d * f, fy = dy / d * f;
        final da = disp[e.from]!, db = disp[e.to]!;
        disp[e.from] = (x: da.x - fx, y: da.y - fy);
        disp[e.to] = (x: db.x + fx, y: db.y + fy);
      }
      for (final id in ids) {
        if (fixed.contains(id)) continue;
        final d = disp[id]!;
        final len = max(0.01, sqrt(d.x * d.x + d.y * d.y));
        final step = min(len, temperature);
        final p = pos[id]!;
        pos[id] = (
          x: (p.x + d.x / len * step).clamp(width * 0.04, width * 0.96),
          y: (p.y + d.y / len * step).clamp(height * 0.04, height * 0.96),
        );
      }
      temperature -= cool;
    }
    return pos;
  }
}
