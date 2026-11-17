import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../shared/widgets/common_widgets.dart';
import 'domain/analytics_data.dart';
import 'domain/analytics_service.dart';
import 'presentation/charts.dart';
import 'presentation/ejes_providers.dart';

class EjesScreen extends ConsumerWidget {
  const EjesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(analyticsPeriodProvider);
    final data = ref.watch(periodAnalyticsProvider);
    final all = ref.watch(allAnalyticsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejes'),
        actions: [
          IconButton(
            key: const Key('open-mind'),
            tooltip: 'Mente de Cristo por temática',
            icon: const Icon(Icons.join_inner),
            onPressed: () => context.go(Routes.mente),
          ),
          IconButton(
            key: const Key('open-coherence'),
            tooltip: 'Coherencia medida',
            icon: const Icon(Icons.account_tree_outlined),
            onPressed: () => context.go(Routes.coherencia),
          ),
          IconButton(
            tooltip: 'Grafo de personalidad',
            icon: const Icon(Icons.hub_outlined),
            onPressed: () => context.go(Routes.grafo),
          ),
          IconButton(
            tooltip: 'Aluvión emoción → filtro → paz',
            icon: const Icon(Icons.waterfall_chart),
            onPressed: () => context.go(Routes.aluvion),
          ),
        ],
      ),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (d) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                SegmentedButton<AnalyticsPeriod>(
                  showSelectedIcon: false,
                  segments: [for (final p in AnalyticsPeriod.values) ButtonSegment(value: p, label: Text(p.label))],
                  selected: {period},
                  onSelectionChanged: (s) => ref.read(analyticsPeriodProvider.notifier).set(s.first),
                ),
                const SizedBox(height: 16),
                if (d.isEmpty)
                  const EmptyState(
                    icon: Icons.insights,
                    title: 'Aún no hay datos en este período',
                    message: 'Escribe devocionales y registra tu praxis: aquí verás cómo se relacionan.',
                  )
                else
                  ..._sections(context, ref, d, all ?? d),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, WidgetRef ref, AnalyticsData d, AnalyticsData all) {
    final theme = Theme.of(context);
    final summary = AnalyticsService.summary(d);
    final stats = AnalyticsService.topicStats(d);
    final correlation = AnalyticsService.studyVsCoherence(stats);
    // Puntos ciegos y sombras miran siempre la ventana reciente, sin importar el período elegido.
    final now = DateTime.now();
    final blind = AnalyticsService.blindSpots(all, now: now);
    final shadows = AnalyticsService.shadowCandidates(all, now: now);
    final ranked = [
      for (final s in stats)
        if (s.iet != null && s.praxisCount >= 3) s,
    ]..sort((a, b) => b.iet!.compareTo(a.iet!));

    return [
      Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          key: const Key('mind-entry'),
          leading: Icon(Icons.join_inner, color: theme.colorScheme.primary),
          title: const Text('Mente de Cristo frente a mi mente'),
          subtitle: const Text(
            'Busca una temática (amor, perdón, dinero…) y compara tu bitácora con lo que afirman tus devocionales.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(Routes.mente),
        ),
      ),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _Kpi(label: 'Devocionales', value: '${summary.studies}', icon: Icons.menu_book_outlined),
          _Kpi(label: 'Registros', value: '${summary.praxis}', icon: Icons.edit_note),
          _Kpi(label: 'Oraciones', value: '${summary.prayers}', icon: Icons.mic_none),
          _Kpi(
            label: 'Paz promedio',
            value: summary.avgPeace == null ? '—' : summary.avgPeace!.toStringAsFixed(1),
            icon: Icons.spa_outlined,
          ),
        ],
      ),
      const SizedBox(height: 12),
      for (final b in blind)
        Card(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
          child: ListTile(
            leading: Icon(Icons.visibility_off_outlined, color: theme.colorScheme.error),
            title: Text('Punto ciego: ${b.trigger}'),
            subtitle: Text(
              '${b.failures} reacciones por ${b.trigger.toLowerCase()} esta semana'
              '${b.daysSinceStudy == null ? ', y aún no has estudiado' : ', y no estudias desde hace ${b.daysSinceStudy} días'} '
              '${b.suggestedTopics.join(' o ')}. ¿Un estudio sobre esto en tu próximo devocional?',
            ),
            isThreeLine: true,
          ),
        ),
      for (final s in shadows)
        Card(
          child: ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: Text('«${s.name}» se repite en tus fallas'),
            subtitle: const Text('Está en incubación, sin estudio que la respalde. ¿Marcarla como sombra?'),
            trailing: TextButton(
              onPressed: () async {
                try {
                  await ref.read(markShadowProvider)(s.id);
                } catch (e) {
                  if (context.mounted) showError(context, e);
                }
              },
              child: const Text('Marcar'),
            ),
          ),
        ),
      SectionCard(
        title: 'Balance de dimensiones',
        subtitle: '¿Muy teórico o muy práctico? Veces que estudiaste cada dimensión.',
        child: DimensionRadar(balance: AnalyticsService.dimensionBalance(d)),
      ),
      SectionCard(
        title: 'Constancia',
        subtitle: 'Estudios, registros y oraciones por día (últimas 20 semanas)',
        child: ActivityHeatmap(activity: AnalyticsService.activityByDay(all)),
      ),
      if (d.praxis.isNotEmpty)
        SectionCard(
          title: 'Paz semanal',
          subtitle: 'Promedio de la paz después de cada situación registrada',
          child: PeaceTrend(points: AnalyticsService.weeklyPeace(d)),
        ),
      SectionCard(
        title: '¿Estudiar se refleja en vivir?',
        subtitle: 'Cada punto es un tópico: veces estudiado vs coherencia al vivirlo',
        child: StudyCoherenceScatter(stats: stats, correlation: correlation),
      ),
      if (ranked.isNotEmpty)
        SectionCard(
          title: 'Índice de efectividad por tópico',
          subtitle: 'IET = coherencia × paz (0 a 1), tópicos con 3 o más registros evaluados',
          child: Column(
            children: [
              for (final s in ranked.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(s.topic.name)),
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: s.iet,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 44, child: Text(s.iet!.toStringAsFixed(2), textAlign: TextAlign.end)),
                      SizedBox(
                        width: 64,
                        child: Text(
                          s.lagDaysMedian == null ? '' : '${s.lagDaysMedian!.toStringAsFixed(0)} d',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                'La última columna es el desfase: días típicos entre estudiar el tópico y vivirlo.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
    ];
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 150,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.headlineSmall),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
