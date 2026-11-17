import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../coherencia/presentation/coherence_providers.dart';
import '../domain/mind_map.dart';
import 'mind_providers.dart';

/// "No ves las cosas como las ve Dios, sino como los hombres" (Mt 16:23), por temática: la mente de Cristo
/// (creencias y devocionales) frente a mi mente (bitácora), filtradas con una búsqueda en el espacio del
/// System One y comparadas con el juez NLI.
class MindMapScreen extends ConsumerStatefulWidget {
  const MindMapScreen({super.key});

  @override
  ConsumerState<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends ConsumerState<MindMapScreen> {
  static const suggestions = ['amor', 'perdón', 'dinero', 'familia', 'trabajo', 'miedo', 'orgullo', 'servicio'];

  final _query = TextEditingController();
  String _theme = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search(String theme) {
    _query.text = theme;
    setState(() => _theme = theme.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = ref.watch(systemOneProvider);
    final index = ref.watch(mindIndexProvider);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Scaffold(
      appBar: AppBar(title: const Text('Mente de Cristo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: model.value == null && !model.isLoading
              ? const EmptyState(
                  icon: Icons.psychology_alt_outlined,
                  title: 'Hace falta el juez local',
                  message:
                      'Instala el System One en Coherencia → Modelo: la búsqueda por temática y la comparación '
                      'corren en tu teléfono.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    TextField(
                      key: const Key('mind-theme'),
                      controller: _query,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Temática: amor, mi suegra, el dinero…',
                      ),
                      onSubmitted: _search,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final s in suggestions) ActionChip(label: Text(s), onPressed: () => _search(s))],
                    ),
                    const SizedBox(height: 6),
                    if (index.value case final i?)
                      Text(
                        'Mente de Cristo: ${i.count(MindSide.cristo)} afirmaciones (tus creencias y devocionales) · '
                        'Mi mente: ${i.count(MindSide.mia)} registros de la bitácora',
                        style: muted,
                      ),
                    if (index.isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                      Text('Llevando las dos mentes al espacio del modelo…', style: muted),
                    ],
                    if (index.hasError) Text('No se pudo armar el índice: ${index.error}', style: muted),
                    const SizedBox(height: 12),
                    if (_theme.isNotEmpty) _ThemeView(theme: _theme),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ThemeView extends ConsumerWidget {
  const _ThemeView({required this.theme});

  final String theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(themeComparisonProvider(theme));
    return result.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [CircularProgressIndicator(), SizedBox(height: 8), Text('Buscando y comparando con el juez…')],
        ),
      ),
      error: (e, _) => Text('Error: $e'),
      data: (c) => c == null || c.isEmpty
          ? EmptyState(
              icon: Icons.travel_explore,
              title: 'Nada sobre «$theme»',
              message: 'Ninguna creencia, devocional ni registro de la bitácora habla de esto todavía.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (c.judged)
                  _Summary(c: c)
                else
                  const SectionCard(
                    key: Key('mind-unjudged'),
                    title: 'Falta el juez grande para comparar',
                    subtitle:
                        'Estos resultados son solo cercanía en el embedding: no dicen de qué trata cada texto ni '
                        'si tu reacción confirma o contradice. Instálalo en Coherencia → Modelo.',
                    child: SizedBox.shrink(),
                  ),
                SectionCard(
                  key: const Key('mind-graph'),
                  title: 'Mapa de «${c.theme}»',
                  subtitle:
                      'Dorado: mente de Cristo · azul: mi mente. Verde confirma, rojo contradice. '
                      'Cerca = hablan de lo mismo (proyección 2D del espacio del modelo).',
                  child: SizedBox(height: 320, child: _MindGraph(c: c)),
                ),
                _LinkList(
                  title: 'Donde mi vida contradice',
                  subtitle: '«No ves las cosas como las ve Dios» (Mt 16:23)',
                  links: c.contradictions.toList(),
                ),
                _LinkList(
                  title: 'Donde mi vida confirma',
                  subtitle: 'Reacciones que encarnan la mente de Cristo',
                  links: c.confirmations.toList(),
                ),
                _BlindSpots(c: c),
              ],
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.c});

  final ThemeComparison c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final p = c.posture;
    final decided = c.links.where((l) => l.decided).length;
    final totalFilter = c.filterMix.values.fold(0, (a, b) => a + b);
    String pct(int n) => totalFilter == 0 ? '—' : '${(n * 100 / totalFilter).round()} %';
    return SectionCard(
      key: const Key('mind-summary'),
      title: '«${c.theme}»: mi mente frente a la de Cristo',
      subtitle:
          'Por componente, nunca un solo número. Solo cuenta lo que el juez decidió con confianza. '
          'Experimental: el juez aún no está entrenado para comparar acciones con principios.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Row(
            label: 'Postura',
            value: p == null
                ? 'Sin evidencia (n = 0)'
                : '${p.value >= 0 ? '+' : ''}${p.value.toStringAsFixed(2)}  [${p.lo.toStringAsFixed(2)}, ${p.hi.toStringAsFixed(2)}] · n = $decided',
            help: '+1: lo que hago confirma lo que se afirma de Cristo; −1: lo contradice.',
          ),
          if (p != null) _PostureBar(p.value, p.lo, p.hi),
          _Row(
            label: 'Contradicciones',
            value: '${c.contradictions.length} de ${c.mine.length} reacciones',
            help: 'Lo que el juez no pudo decidir queda para ti.',
          ),
          _Row(
            label: 'Puntos ciegos',
            value: '${c.blindSpots.length} de ${c.christ.length} afirmaciones',
            help: 'Lo que la mente de Cristo afirma aquí y mi vida no toca.',
          ),
          _Row(
            label: 'Filtro',
            value: [for (final f in FilterType.values) '${f.shortLabel} ${pct(c.filterMix[f] ?? 0)}'].join(' · '),
            help: 'Con qué filtro reaccioné en esta temática (bitácora).',
          ),
          _Row(
            label: 'Fruto',
            value: c.peace == null ? '—' : 'paz ${c.peace!.value.toStringAsFixed(1)} / 10',
            help: 'Paz posterior media.',
          ),
          if (c.mine.isEmpty)
            Text('Tu bitácora aún no tiene registros sobre esto: no hay con qué comparar.', style: muted),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, required this.help});

  final String label;
  final String value;
  final String help;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label: ', style: theme.textTheme.titleSmall),
                TextSpan(text: value),
              ],
            ),
          ),
          Text(help, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Barra de −1 a +1 con el intervalo de confianza.
class _PostureBar extends StatelessWidget {
  const _PostureBar(this.value, this.lo, this.hi);

  final double value;
  final double lo;
  final double hi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 18,
        child: CustomPaint(painter: _BarPainter(value, lo, hi, scheme.outlineVariant, _green, scheme.error)),
      ),
    );
  }
}

const _green = Color(0xFF2F7D4E);

class _BarPainter extends CustomPainter {
  _BarPainter(this.value, this.lo, this.hi, this.track, this.good, this.bad);

  final double value, lo, hi;
  final Color track, good, bad;

  @override
  void paint(Canvas canvas, Size size) {
    double x(double v) => (v.clamp(-1, 1) + 1) / 2 * size.width;
    final mid = size.height / 2;
    canvas.drawLine(
      Offset(0, mid),
      Offset(size.width, mid),
      Paint()
        ..color = track
        ..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(x(0), 0),
      Offset(x(0), size.height),
      Paint()
        ..color = track
        ..strokeWidth = 1,
    );
    final color = value >= 0 ? good : bad;
    canvas.drawLine(
      Offset(x(lo), mid),
      Offset(x(hi), mid),
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..strokeWidth = 8,
    );
    canvas.drawCircle(Offset(x(value), mid), 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => old.value != value || old.lo != lo || old.hi != hi;
}

class _MindGraph extends StatelessWidget {
  const _MindGraph({required this.c});

  final ThemeComparison c;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size.infinite,
      painter: _MindGraphPainter(c, scheme.primary, scheme.tertiary, scheme.outlineVariant, scheme.error),
    );
  }
}

class _MindGraphPainter extends CustomPainter {
  _MindGraphPainter(this.c, this.christ, this.mine, this.grid, this.bad);

  final ThemeComparison c;
  final Color christ, mine, grid, bad;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 18.0;
    Offset at(String id) {
      final (x, y) = c.layout[id] ?? (0, 0);
      return Offset(pad + (x + 1) / 2 * (size.width - 2 * pad), pad + (y + 1) / 2 * (size.height - 2 * pad));
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = grid
        ..style = PaintingStyle.stroke,
    );
    for (final l in c.links) {
      final color = !l.decided ? grid : (l.alignment >= 0 ? _green : bad);
      canvas.drawLine(
        at(l.mine.item.id),
        at(l.christ.item.id),
        Paint()
          ..color = color.withValues(alpha: l.decided ? 0.8 : 0.4)
          ..strokeWidth = l.decided ? 1 + 2 * l.alignment.abs() : 1,
      );
    }
    for (final h in c.christ) {
      canvas.drawCircle(at(h.item.id), 3 + 5 * h.score.clamp(0, 1), Paint()..color = christ);
    }
    for (final h in c.mine) {
      canvas.drawCircle(at(h.item.id), 3 + 5 * h.score.clamp(0, 1), Paint()..color = mine);
    }
  }

  @override
  bool shouldRepaint(covariant _MindGraphPainter old) => !identical(old.c, c);
}

class _LinkList extends StatelessWidget {
  const _LinkList({required this.title, required this.subtitle, required this.links});

  final String title;
  final String subtitle;
  final List<MindLink> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final sorted = [...links]..sort((a, b) => b.alignment.abs().compareTo(a.alignment.abs()));
    return SectionCard(
      title: '$title (${links.length})',
      subtitle: subtitle,
      child: Column(
        children: [
          for (final l in sorted)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                l.alignment >= 0 ? Icons.check_circle_outline : Icons.highlight_off,
                color: l.alignment >= 0 ? _green : theme.colorScheme.error,
              ),
              title: Text(l.mine.item.text, maxLines: 3, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${l.alignment >= 0 ? 'confirma' : 'contradice'} «${l.christ.item.text}» · '
                '${l.christ.item.source.label} · confianza ${(l.decision.judgment.confidence * 100).round()} %',
              ),
              onTap: () => context.go(Routes.registro(l.mine.item.refId)),
            ),
        ],
      ),
    );
  }
}

class _BlindSpots extends StatelessWidget {
  const _BlindSpots({required this.c});

  final ThemeComparison c;

  @override
  Widget build(BuildContext context) {
    if (c.blindSpots.isEmpty) return const SizedBox.shrink();
    return SectionCard(
      title: 'Puntos ciegos (${c.blindSpots.length})',
      subtitle: 'Lo que la mente de Cristo afirma sobre «${c.theme}» y mi bitácora no muestra',
      child: Column(
        children: [
          for (final h in c.blindSpots)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.visibility_off_outlined),
              title: Text(h.item.text, maxLines: 3, overflow: TextOverflow.ellipsis),
              subtitle: Text(h.item.source.label),
              onTap: () => context.go(
                h.item.source == MindSource.creencia ? Routes.creencia(h.item.refId) : Routes.devocional(h.item.refId),
              ),
            ),
        ],
      ),
    );
  }
}
