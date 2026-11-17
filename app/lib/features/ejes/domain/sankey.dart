import 'dart:math';

import 'analytics_data.dart';

class SankeyNode {
  SankeyNode(this.id, this.label, this.stage);

  final String id;
  final String label;
  final int stage;
  double value = 0;
  double y0 = 0;
  double y1 = 0;
}

class SankeyLink {
  SankeyLink(this.from, this.to, this.value);

  final String from;
  final String to;
  final double value;
  double sourceY0 = 0;
  double sourceY1 = 0;
  double targetY0 = 0;
  double targetY1 = 0;
}

class SankeyDiagram {
  const SankeyDiagram({required this.stages, required this.nodes, required this.links, required this.total});

  final List<String> stages;
  final List<SankeyNode> nodes;
  final List<SankeyLink> links;
  final double total;

  bool get isEmpty => total == 0;
}

/// Diagrama de aluvión de la bitácora: Emoción (primaria) → Filtro → Paz resultante.
abstract final class SankeyBuilder {
  static const stages = ['Emoción', 'Filtro', 'Paz'];

  static String peaceBand(int peace) =>
      peace <= 4 ? 'Paz baja (1-4)' : (peace <= 7 ? 'Paz media (5-7)' : 'Paz alta (8-10)');

  static SankeyDiagram build(AnalyticsData data, {double height = 400, double padding = 10}) {
    final nodes = <String, SankeyNode>{};
    final flows = <(String, String), double>{};
    SankeyNode node(String id, String label, int stage) => nodes.putIfAbsent(id, () => SankeyNode(id, label, stage));

    for (final p in data.praxis) {
      // Cada registro aporta 1, repartido entre sus emociones primarias distintas.
      final primaries = {for (final e in p.emotionIds) data.emotions[e]?.parentId ?? e};
      if (primaries.isEmpty) continue;
      final share = 1 / primaries.length;
      final filter = node('f:${p.filter.name}', p.filter.shortLabel, 1);
      final band = peaceBand(p.peace);
      final peace = node('p:$band', band, 2);
      for (final e in primaries) {
        final emo = node('e:$e', data.emotions[e]?.name ?? e, 0);
        flows.update((emo.id, filter.id), (v) => v + share, ifAbsent: () => share);
        flows.update((filter.id, peace.id), (v) => v + share, ifAbsent: () => share);
      }
    }
    final links = [for (final MapEntry(key: (a, b), value: v) in flows.entries) SankeyLink(a, b, v)];
    return layout(nodes.values.toList(), links, height: height, padding: padding);
  }

  /// Apila nodos por etapa y asigna las franjas de cada enlace (sin cruces innecesarios).
  static SankeyDiagram layout(
    List<SankeyNode> nodes,
    List<SankeyLink> links, {
    required double height,
    double padding = 10,
  }) {
    final byId = {for (final n in nodes) n.id: n};
    for (final n in nodes) {
      final inV = links.where((l) => l.to == n.id).fold<double>(0, (a, l) => a + l.value);
      final outV = links.where((l) => l.from == n.id).fold<double>(0, (a, l) => a + l.value);
      n.value = max(inV, outV);
    }
    final stageCount = nodes.isEmpty ? 0 : nodes.map((n) => n.stage).reduce(max) + 1;
    final columns = [
      for (var s = 0; s < stageCount; s++)
        nodes.where((n) => n.stage == s).toList()..sort((a, b) => _order(a).compareTo(_order(b))),
    ];
    final total = columns.isEmpty ? 0.0 : columns.map((c) => c.fold<double>(0, (a, n) => a + n.value)).reduce(max);
    if (total == 0) return SankeyDiagram(stages: stages, nodes: nodes, links: links, total: 0);
    final maxNodes = columns.map((c) => c.length).reduce(max);
    final scale = (height - padding * (maxNodes - 1)) / total;

    for (final col in columns) {
      var y = 0.0;
      for (final n in col) {
        n.y0 = y;
        n.y1 = y + n.value * scale;
        y = n.y1 + padding;
      }
    }
    final outOffset = {for (final n in nodes) n.id: n.y0};
    final inOffset = {for (final n in nodes) n.id: n.y0};
    final sorted = [...links]..sort((a, b) => byId[a.to]!.y0.compareTo(byId[b.to]!.y0));
    for (final l in sorted) {
      final h = l.value * scale;
      l.sourceY0 = outOffset[l.from]!;
      l.sourceY1 = l.sourceY0 + h;
      outOffset[l.from] = l.sourceY1;
    }
    sorted.sort((a, b) => byId[a.from]!.y0.compareTo(byId[b.from]!.y0));
    for (final l in sorted) {
      final h = l.value * scale;
      l.targetY0 = inOffset[l.to]!;
      l.targetY1 = l.targetY0 + h;
      inOffset[l.to] = l.targetY1;
    }
    return SankeyDiagram(stages: stages, nodes: nodes, links: links, total: total);
  }

  /// Orden estable: filtros y bandas de paz en orden lógico, emociones por peso.
  static double _order(SankeyNode n) => switch (n.id) {
    'f:biblico' => 0,
    'f:cosmovision' => 1,
    'f:impulso' => 2,
    'f:desde' => 0,
    'f:neutral' => 1,
    'f:contra' => 2,
    final id when id.startsWith('p:Paz alta') => 0,
    final id when id.startsWith('p:Paz media') => 1,
    final id when id.startsWith('p:Paz baja') => 2,
    _ => -n.value,
  };
}
