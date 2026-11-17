import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../ejes/presentation/sankey_screen.dart';
import '../domain/belief.dart';
import '../domain/coherence_charts.dart';
import '../domain/coherence_data.dart';
import '../domain/weak_supervision.dart';
import 'belief_editor.dart';
import 'coherence_providers.dart';
import 'labeling_tab.dart';
import 'model_tab.dart';
import 'widgets/coherence_chart_widgets.dart';

/// Coherencia medida (docs/PLAN-COHERENCIA.md): de la coherencia declarada a la medida, con su
/// evidencia y su margen de error. Nunca un puntaje global.
class CoherenceScreen extends ConsumerWidget {
  const CoherenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(coherenceDatasetProvider);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coherencia'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(key: Key('tab-creencias'), text: 'Creencias'),
              Tab(key: Key('tab-graficos'), text: 'Gráficos'),
              Tab(key: Key('tab-etiquetar'), text: 'Etiquetar'),
              Tab(key: Key('tab-modelo'), text: 'Modelo'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('new-belief'),
          icon: const Icon(Icons.add),
          label: const Text('Creencia'),
          onPressed: () => showBeliefEditor(context),
        ),
        body: data.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (d) => TabBarView(
            children: [
              _BeliefsTab(data: d),
              _ChartsTab(data: d),
              const LabelingTab(),
              const ModelTab(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _page(List<Widget> children) => Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 900),
    child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: children),
  ),
);

class _BeliefsTab extends ConsumerWidget {
  const _BeliefsTab({required this.data});

  final CoherenceDataset data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (data.isEmpty) {
      return const EmptyState(
        icon: Icons.account_tree_outlined,
        title: 'Aún no hay creencias',
        message:
            'Una creencia es una frase que guía lo que haces. Créala desde un devocional ("Convertir en creencia") '
            'o desde tu vida, y vincula tus registros a ella: así se mide cuánto vives lo que interpretas.',
      );
    }
    final suggestions = WeakSupervision.propose(data, now: DateTime.now());
    final precision = WeakSupervision.precision(data);
    final beliefs = [...data.beliefs]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return _page([
      for (final b in beliefs)
        Card(
          key: Key('belief-${b.id}'),
          child: ListTile(
            title: Text(b.proposition, maxLines: 3, overflow: TextOverflow.ellipsis),
            subtitle: Text(_summary(b)),
            trailing: Icon(switch (b.status) {
              BeliefStatus.validada => Icons.verified_outlined,
              BeliefStatus.refutada => Icons.block,
              BeliefStatus.incubacion => Icons.egg_outlined,
            }),
            onTap: () => context.push(Routes.creencia(b.id)),
          ),
        ),
      const SizedBox(height: 12),
      SectionCard(
        title: 'Vínculos sugeridos (${suggestions.length})',
        subtitle: 'Reglas sobre lo que ya registraste. No cuentan hasta que los confirmes.',
        child: suggestions.isEmpty
            ? const Text('Sin sugerencias por ahora.')
            : Column(
                children: [
                  for (final s in suggestions.take(10))
                    if (data.actionOf(s) case final a?)
                      _SuggestionTile(link: s, action: a, belief: data.beliefById[s.beliefId]!),
                ],
              ),
      ),
      SectionCard(
        title: 'Precisión de las reglas',
        subtitle: 'Cuántas veces acertó cada regla frente a lo que tú confirmaste.',
        child: Column(
          children: [
            for (final p in precision)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(p.rule.description, style: theme.textTheme.bodySmall),
                trailing: Text(
                  p.checked == 0 ? 'sin datos' : '${(p.precision! * 100).round()} % (n = ${p.checked})',
                  style: theme.textTheme.labelMedium,
                ),
              ),
          ],
        ),
      ),
    ]);
  }

  String _summary(Belief b) {
    final cc = data.coherence[b.id]!;
    final links = data.confirmedLinks.where((l) => l.beliefId == b.id).length;
    return '${b.status.label} · S ${cc.support.value.toStringAsFixed(1)} · D ${cc.diversity.value.toStringAsFixed(1)} · '
        'T ${cc.tension.value.toStringAsFixed(1)} · $links acciones';
  }
}

class _SuggestionTile extends ConsumerWidget {
  const _SuggestionTile({required this.link, required this.action, required this.belief});

  final ActionLink link;
  final ActionRecord action;
  final Belief belief;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(coherenceRepositoryProvider);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.rule, color: alignmentColor(context, link.alignment)),
      title: Text(action.text.split('\n').first, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${Formatters.date(action.date)} · ${link.alignment.shortLabel} con «${belief.proposition}» · '
        '${(link.confidence! * 100).round()} %',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Confirmar',
            icon: const Icon(Icons.check),
            onPressed: () => repo.putLink(
              ActionLink(
                actionKind: link.actionKind,
                actionId: link.actionId,
                beliefId: link.beliefId,
                alignment: link.alignment,
                origin: link.origin,
                confidence: link.confidence,
                source: link.source,
                confirmed: true,
                createdAt: DateTime.now(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'No se relacionan',
            icon: const Icon(Icons.close),
            // Se guarda como neutral confirmado: la regla no vuelve a proponerlo y cuenta para su precisión.
            onPressed: () => repo.putLink(
              ActionLink(
                actionKind: link.actionKind,
                actionId: link.actionId,
                beliefId: link.beliefId,
                alignment: ActionAlignment.neutral,
                origin: LinkOrigin.usuario,
                source: link.source,
                confirmed: true,
                createdAt: DateTime.now(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartsTab extends ConsumerStatefulWidget {
  const _ChartsTab({required this.data});

  final CoherenceDataset data;

  @override
  ConsumerState<_ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends ConsumerState<_ChartsTab> {
  CoherenceTercile _tercile = CoherenceTercile.todas;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.data;
    final map = CoherenceCharts.beliefMap(d);
    final ap = CoherenceCharts.alignmentPeace(d, tercile: _tercile);
    final allPairs = CoherenceCharts.alignmentPeace(d).points.length;
    final weekly = CoherenceCharts.weekly(d);
    final weeks = CoherenceCharts.weeksWithData(weekly);
    final perBelief = CoherenceCharts.perBelief(d);
    const alluviumHeight = 360.0;
    final alluvium = CoherenceCharts.alluvium(d, height: alluviumHeight);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return _page([
      SectionCard(
        title: '3 · Mapa de creencias',
        subtitle: '¿Qué interpretaciones gobiernan realmente tus acciones?',
        child: map.isEmpty
            ? const NotEnoughData(n: 0, min: ChartMinimums.beliefMap, unit: 'creencias confirmadas')
            : BeliefMapView(rows: map, onTap: (b) => context.push(Routes.creencia(b.id))),
      ),
      SectionCard(
        key: const Key('chart-alignment-peace'),
        title: '4 · Alineación vs paz',
        subtitle: '¿Vivir lo que entiendes se asocia a más paz? Filtra por coherencia canónica (H3).',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<CoherenceTercile>(
              showSelectedIcon: false,
              segments: [for (final t in CoherenceTercile.values) ButtonSegment(value: t, label: Text(t.label))],
              selected: {_tercile},
              onSelectionChanged: (s) => setState(() => _tercile = s.first),
            ),
            const SizedBox(height: 8),
            if (allPairs < ChartMinimums.alignmentPeace)
              NotEnoughData(n: allPairs, min: ChartMinimums.alignmentPeace, unit: 'acciones vinculadas con paz')
            else
              AlignmentPeaceChart(data: ap),
          ],
        ),
      ),
      SectionCard(
        title: '5 · Serie semanal',
        subtitle: 'Alineación y paz semana a semana, con su intervalo de confianza.',
        child: weeks < ChartMinimums.weeklyWeeks
            ? NotEnoughData(n: weeks, min: ChartMinimums.weeklyWeeks, unit: 'semanas')
            : WeeklyCoherencePanels(points: weekly),
      ),
      SectionCard(
        key: const Key('chart-lag'),
        title: '6 · Correlación con rezago',
        subtitle: '¿La alineación precede a la paz, o al revés?',
        child: weeks < ChartMinimums.lagWeeks
            ? NotEnoughData(n: weeks, min: ChartMinimums.lagWeeks, unit: 'semanas')
            : LagBars(lags: CoherenceCharts.lagged(weekly)),
      ),
      SectionCard(
        title: '7 · Aluvión extendido',
        subtitle: '¿Qué pasa con tu paz cuando actúas contra una creencia?',
        child: alluvium.total < ChartMinimums.alluvium
            ? NotEnoughData(n: alluvium.total.round(), min: ChartMinimums.alluvium, unit: 'acciones')
            : Column(
                children: [
                  Row(
                    children: [
                      for (final s in CoherenceCharts.alluviumStages)
                        Expanded(
                          child: Text(s, textAlign: TextAlign.center, style: theme.textTheme.labelLarge),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: alluviumHeight,
                    child: CustomPaint(
                      painter: SankeyPainter(alluvium, theme),
                      size: const Size(double.infinity, alluviumHeight),
                    ),
                  ),
                ],
              ),
      ),
      SectionCard(
        title: 'Por creencia (N-of-1)',
        subtitle: 'Correlación alineación-paz de cada creencia, corregida por comparaciones múltiples (BH).',
        child: perBelief.isEmpty
            ? Text('Cada creencia necesita al menos 8 acciones vinculadas con paz.', style: muted)
            : Column(
                children: [
                  for (final r in perBelief)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.belief.proposition, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(formatCorrelation(r.correlation)),
                      trailing: Text(
                        'q = ${r.q.toStringAsFixed(3)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: r.q < 0.05 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
      ),
      Text('Asociaciones dentro de tu propio diario, no causas. Solo cuentan vínculos que confirmaste.', style: muted),
    ]);
  }
}
