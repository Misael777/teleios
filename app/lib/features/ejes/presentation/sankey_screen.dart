import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../domain/sankey.dart';
import 'ejes_providers.dart';

/// Aluvión: de qué emoción partes, en qué te apoyas y con cuánta paz terminas.
class SankeyScreen extends ConsumerWidget {
  const SankeyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(periodAnalyticsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Aluvión de la praxis')),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) {
          const height = 420.0;
          final diagram = SankeyBuilder.build(d, height: height);
          if (diagram.isEmpty) {
            return const EmptyState(
              icon: Icons.waterfall_chart,
              title: 'Sin registros en este período',
              message: 'Registra situaciones en la Bitácora para ver hacia dónde te llevan tus emociones.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Emoción → Filtro → Paz. El grosor es la cantidad de registros (${diagram.total.toStringAsFixed(0)}).',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final s in SankeyBuilder.stages)
                    Expanded(
                      child: Text(s, textAlign: TextAlign.center, style: theme.textTheme.labelLarge),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: height,
                child: CustomPaint(painter: SankeyPainter(diagram, theme), size: const Size(double.infinity, height)),
              ),
              const SizedBox(height: 16),
              Text(
                'Busca los caminos gruesos hacia "Paz baja": ahí están los patrones que más vale estudiar.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SankeyPainter extends CustomPainter {
  SankeyPainter(this.diagram, this.theme);

  final SankeyDiagram diagram;
  final ThemeData theme;

  static const nodeWidth = 14.0;

  Color _color(SankeyNode n) {
    final s = theme.colorScheme;
    return switch (n.id) {
      'f:biblico' => s.primary,
      'f:cosmovision' => s.secondary,
      'f:impulso' => s.error,
      'f:desde' => s.primary,
      'f:neutral' => s.outline,
      'f:contra' => s.error,
      final id when id.startsWith('p:Paz alta') => const Color(0xFF6DBB8A),
      final id when id.startsWith('p:Paz media') => const Color(0xFFE0B04A),
      final id when id.startsWith('p:Paz baja') => const Color(0xFFE5534B),
      _ => s.tertiary,
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final stages = diagram.stages.length;
    double xOf(int stage) => (size.width - nodeWidth) * stage / (stages - 1);
    final byId = {for (final n in diagram.nodes) n.id: n};

    for (final l in diagram.links) {
      final a = byId[l.from]!, b = byId[l.to]!;
      final x0 = xOf(a.stage) + nodeWidth, x1 = xOf(b.stage);
      final mx = (x0 + x1) / 2;
      final path = Path()
        ..moveTo(x0, l.sourceY0)
        ..cubicTo(mx, l.sourceY0, mx, l.targetY0, x1, l.targetY0)
        ..lineTo(x1, l.targetY1)
        ..cubicTo(mx, l.targetY1, mx, l.sourceY1, x0, l.sourceY1)
        ..close();
      canvas.drawPath(path, Paint()..color = _color(b).withValues(alpha: 0.28));
    }

    for (final n in diagram.nodes) {
      final x = xOf(n.stage);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, n.y0, nodeWidth, n.y1 - n.y0), const Radius.circular(3)),
        Paint()..color = _color(n),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${n.label} (${n.value.toStringAsFixed(n.value % 1 == 0 ? 0 : 1)})',
          style: theme.textTheme.labelSmall,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: 110);
      final last = n.stage == stages - 1;
      final dx = last ? x - tp.width - 4 : x + nodeWidth + 4;
      tp.paint(canvas, Offset(dx, (n.y0 + n.y1) / 2 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(SankeyPainter old) => old.diagram != diagram || old.theme != theme;
}
