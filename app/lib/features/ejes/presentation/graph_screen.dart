import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/analytics_data.dart';
import '../domain/personality_graph.dart';
import 'ejes_providers.dart';

/// Mapa mental: dimensiones (fijas) → tópicos → emociones de la bitácora.
class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> with SingleTickerProviderStateMixin {
  static const canvas = 1000.0;

  Set<String> _dims = Dimension.all.map((d) => d.id).toSet();
  AnalyticsData? _source;
  PersonalityGraph? _graph;
  Map<String, Vec>? _positions;
  final _transform = TransformationController();
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _transform.dispose();
    super.dispose();
  }

  Future<void> _rebuild(AnalyticsData data) async {
    _source = data;
    final graph = PersonalityGraphBuilder.build(data, dimensions: _dims);
    final positions = await _layoutInIsolate(graph);
    if (!mounted || !identical(_source, data)) return;
    setState(() {
      _graph = graph;
      _positions = positions;
    });
  }

  /// Estático a propósito: un closure creado en un método de instancia arrastra su contexto
  /// (incluido el widget) y no se puede enviar a otro isolate.
  static Future<Map<String, Vec>> _layoutInIsolate(PersonalityGraph graph) =>
      Isolate.run(() => ForceLayout.compute(graph, width: canvas, height: canvas));

  GraphNode? _hit(Offset local) {
    final graph = _graph, pos = _positions;
    if (graph == null || pos == null) return null;
    final p = _transform.toScene(local);
    GraphNode? best;
    var bestD = double.infinity;
    for (final n in graph.nodes) {
      final v = pos[n.id]!;
      final d = (Offset(v.x, v.y) - p).distance;
      if (d < _GraphPainter.radiusOf(n) + 10 && d < bestD) {
        best = n;
        bestD = d;
      }
    }
    return best;
  }

  void _showNode(GraphNode n) {
    final graph = _graph!;
    final names = {for (final x in graph.nodes) x.id: x.label};
    final links = graph.edges.where((e) => e.from == n.id || e.to == n.id).toList();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Text(n.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(switch (n.kind) {
              NodeKind.dimension => 'Dimensión',
              NodeKind.topic => 'Tópico · ${n.status?.label ?? ''} · ${n.weight.toInt()} usos',
              NodeKind.emotion =>
                'Emoción · intensidad promedio ${n.avgIntensity?.toStringAsFixed(1) ?? '—'} · ${n.weight.toInt()} registros',
            }),
            const Divider(height: 24),
            for (final e in links)
              if (e.avgPeace != null)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(radius: 6, backgroundColor: _GraphPainter.peaceColor(e.avgPeace!)),
                  title: Text(names[e.from == n.id ? e.to : e.from] ?? ''),
                  subtitle: Text('${e.weight.toInt()} veces · paz promedio ${e.avgPeace!.toStringAsFixed(1)}'),
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(periodAnalyticsProvider);
    data.whenData((d) {
      if (!identical(d, _source)) WidgetsBinding.instance.addPostFrameCallback((_) => _rebuild(d));
    });
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafo de personalidad'),
        actions: [
          IconButton(
            tooltip: 'Centrar',
            icon: const Icon(Icons.center_focus_strong),
            onPressed: () => _transform.value = Matrix4.identity(),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final d in Dimension.all)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: CircleAvatar(radius: 6, backgroundColor: context.dimensionColor(d.id)),
                      label: Text(d.name),
                      selected: _dims.contains(d.id),
                      onSelected: (on) {
                        setState(() => _dims = on ? {..._dims, d.id} : ({..._dims}..remove(d.id)));
                        if (_source != null) _rebuild(_source!);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: switch ((_graph, _positions)) {
              (final g?, final p?) when !g.isEmpty => LayoutBuilder(
                builder: (context, c) {
                  if (_transform.value == Matrix4.identity()) {
                    final s = min(c.maxWidth, c.maxHeight) / canvas;
                    _transform.value = Matrix4.identity()
                      ..translateByDouble((c.maxWidth - canvas * s) / 2, (c.maxHeight - canvas * s) / 2, 0, 1)
                      ..scaleByDouble(s, s, 1, 1);
                  }
                  return GestureDetector(
                    onTapUp: (d) {
                      final n = _hit(d.localPosition);
                      if (n != null) _showNode(n);
                    },
                    child: InteractiveViewer(
                      transformationController: _transform,
                      constrained: false,
                      minScale: 0.2,
                      maxScale: 4,
                      boundaryMargin: const EdgeInsets.all(400),
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) => CustomPaint(
                          size: const Size(canvas, canvas),
                          painter: _GraphPainter(
                            graph: g,
                            positions: p,
                            theme: theme,
                            dimensionColor: context.dimensionColor,
                            pulse: _pulse.value,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              (final g?, _) when g.isEmpty => const EmptyState(
                icon: Icons.hub_outlined,
                title: 'Tu mapa aparecerá aquí',
                message: 'Cada tópico que estudias, vives u oras se conecta con sus dimensiones y emociones.',
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                _Legend(color: _GraphPainter.peaceColor(1), label: 'Paz baja'),
                _Legend(color: _GraphPainter.peaceColor(10), label: 'Paz alta'),
                const _Legend(icon: Icons.radio_button_unchecked, label: 'En incubación (punteado)'),
                _Legend(color: theme.colorScheme.error, label: 'Sombra'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({this.color, this.icon, required this.label});

  final Color? color;
  final IconData? icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (color != null) CircleAvatar(radius: 5, backgroundColor: color) else Icon(icon, size: 12),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.graph,
    required this.positions,
    required this.theme,
    required this.dimensionColor,
    required this.pulse,
  });

  final PersonalityGraph graph;
  final Map<String, Vec> positions;
  final ThemeData theme;
  final Color Function(String) dimensionColor;
  final double pulse;

  static double radiusOf(GraphNode n) => switch (n.kind) {
    NodeKind.dimension => 26,
    NodeKind.topic => 6 + min(14, sqrt(n.weight) * 3),
    NodeKind.emotion => 5 + min(8, sqrt(n.weight) * 2),
  };

  static Color peaceColor(double peace) =>
      Color.lerp(const Color(0xFFE5534B), const Color(0xFF6DBB8A), ((peace - 1) / 9).clamp(0, 1))!;

  Offset _at(String id) => Offset(positions[id]!.x, positions[id]!.y);

  @override
  void paint(Canvas canvas, Size size) {
    final scheme = theme.colorScheme;
    final byId = {for (final n in graph.nodes) n.id: n};

    for (final e in graph.edges) {
      if (!positions.containsKey(e.from) || !positions.containsKey(e.to)) continue;
      final paint = Paint()
        ..strokeWidth = e.avgPeace == null ? 1 : 1 + min(5, e.weight)
        ..color = e.avgPeace == null ? scheme.outlineVariant : peaceColor(e.avgPeace!).withValues(alpha: 0.75);
      canvas.drawLine(_at(e.from), _at(e.to), paint);
    }

    for (final n in graph.nodes) {
      final c = _at(n.id);
      final r = radiusOf(n);
      final color = n.dimensionId != null ? dimensionColor(n.dimensionId!) : scheme.secondary;
      switch (n.kind) {
        case NodeKind.dimension:
          canvas.drawCircle(c, r + 6, Paint()..color = color.withValues(alpha: 0.18));
          canvas.drawCircle(c, r, Paint()..color = color);
        case NodeKind.topic:
          canvas.drawCircle(
            c,
            r,
            Paint()..color = color.withValues(alpha: n.status == TopicStatus.incubacion ? 0.25 : 0.9),
          );
          final ring = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = n.status == TopicStatus.sombra ? scheme.error : color;
          if (n.status == TopicStatus.incubacion) {
            _dashedCircle(canvas, c, r, ring);
          } else {
            canvas.drawCircle(c, r, ring);
          }
        case NodeKind.emotion:
          if (n.pulses) {
            canvas.drawCircle(
              c,
              r + 4 + pulse * 8,
              Paint()..color = scheme.error.withValues(alpha: 0.25 * (1 - pulse)),
            );
          }
          final rect = RRect.fromRectAndRadius(Rect.fromCircle(center: c, radius: r), const Radius.circular(4));
          canvas.drawRRect(rect, Paint()..color = scheme.secondary.withValues(alpha: 0.9));
      }
      _label(canvas, n, c, r, byId.length);
    }
  }

  void _dashedCircle(Canvas canvas, Offset c, double r, Paint paint) {
    const segments = 12;
    for (var i = 0; i < segments; i++) {
      final start = i * 2 * pi / segments;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, pi / segments, false, paint);
    }
  }

  void _label(Canvas canvas, GraphNode n, Offset c, double r, int count) {
    final style = switch (n.kind) {
      NodeKind.dimension => theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      NodeKind.topic => theme.textTheme.labelMedium,
      NodeKind.emotion => theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    };
    final tp = TextPainter(
      text: TextSpan(text: n.label, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: 140);
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy + r + 3));
  }

  @override
  bool shouldRepaint(_GraphPainter old) => old.pulse != pulse || old.graph != graph || old.positions != positions;
}
