import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/ids.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/belief.dart';
import '../domain/coherence_data.dart';
import '../domain/coherence_judge.dart';
import '../domain/labeling.dart';
import 'coherence_providers.dart';
import 'widgets/coherence_chart_widgets.dart';

/// En el detalle de un registro o una oración: ¿desde qué creencia actuaste, o contra cuál?
/// Con el System One instalado, sugiere la dirección y el patrón de pensamiento; el usuario confirma.
class ActionBeliefsSection extends ConsumerWidget {
  const ActionBeliefsSection({super.key, required this.kind, required this.actionId});

  final ActionKind kind;
  final String actionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(coherenceDatasetProvider).value;
    if (data == null) return const SizedBox.shrink();
    final action = data.actions['${kind.name}:$actionId'];
    final links = [
      for (final l in data.links)
        if (l.actionKind == kind && l.actionId == actionId) l,
    ];
    final repo = ref.read(coherenceRepositoryProvider);
    return SectionCard(
      key: const Key('action-beliefs'),
      title: 'Creencias',
      subtitle: '¿Desde qué creencia actuaste, o contra cuál?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final l in links)
            if (data.beliefById[l.beliefId] case final b?)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.circle, size: 14, color: alignmentColor(context, l.alignment)),
                title: Text(b.proposition, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${l.alignment.label}${l.confirmed ? '' : ' · sugerido (${((l.confidence ?? 0) * 100).round()} %)'}',
                ),
                onTap: () => context.push(Routes.creencia(b.id)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!l.confirmed)
                      IconButton(
                        tooltip: 'Confirmar',
                        icon: const Icon(Icons.check),
                        onPressed: () => _confirm(ref, l, l.alignment),
                      ),
                    IconButton(
                      tooltip: 'Quitar',
                      icon: const Icon(Icons.link_off),
                      onPressed: () => repo.removeLink(kind, actionId, b.id),
                    ),
                  ],
                ),
              ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('link-belief'),
                icon: const Icon(Icons.add_link),
                label: const Text('Vincular creencia'),
                onPressed: data.beliefs.isEmpty
                    ? () => showMessage(context, 'Primero crea una creencia en Ejes → Coherencia.')
                    : () => _pick(context, ref, data, links),
              ),
              if (action != null) _JudgeSuggest(action: action, data: data, links: links),
            ],
          ),
          if (action != null) _PatternRow(action: action),
        ],
      ),
    );
  }

  Future<void> _confirm(WidgetRef ref, ActionLink l, ActionAlignment alignment) async {
    final repo = ref.read(coherenceRepositoryProvider);
    if (l.origin == LinkOrigin.modelo && l.source != null) {
      await repo.recordFeedback(
        JudgeFeedbackEntry(
          id: newId(),
          judgeVersion: l.source!,
          task: 'alineacion',
          predicted: l.alignment.name,
          probability: l.confidence ?? 0,
          userLabel: alignment.name,
          createdAt: DateTime.now(),
        ),
      );
    }
    await repo.putLink(
      ActionLink(
        actionKind: l.actionKind,
        actionId: l.actionId,
        beliefId: l.beliefId,
        alignment: alignment,
        origin: alignment == l.alignment ? l.origin : LinkOrigin.usuario,
        confidence: l.confidence,
        source: l.source,
        confirmed: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref, CoherenceDataset data, List<ActionLink> links) async {
    final linked = {for (final l in links) l.beliefId};
    final result = await showModalBottomSheet<(Belief, ActionAlignment)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => _BeliefPicker(
        beliefs: [
          for (final b in data.beliefs)
            if (!linked.contains(b.id) && b.status != BeliefStatus.refutada) b,
        ],
      ),
    );
    if (result == null) return;
    await ref
        .read(coherenceRepositoryProvider)
        .putLink(
          ActionLink(
            actionKind: kind,
            actionId: actionId,
            beliefId: result.$1.id,
            alignment: result.$2,
            origin: LinkOrigin.usuario,
            confirmed: true,
            createdAt: DateTime.now(),
          ),
        );
  }
}

class _BeliefPicker extends StatefulWidget {
  const _BeliefPicker({required this.beliefs});

  final List<Belief> beliefs;

  @override
  State<_BeliefPicker> createState() => _BeliefPickerState();
}

class _BeliefPickerState extends State<_BeliefPicker> {
  Belief? _belief;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _belief == null ? 'Elige la creencia' : '¿Cómo actuaste respecto de ella?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_belief == null)
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final b in widget.beliefs)
                    ListTile(
                      key: Key('pick-belief-${b.id}'),
                      title: Text(b.proposition),
                      onTap: () => setState(() => _belief = b),
                    ),
                ],
              ),
            )
          else ...[
            Text('«${_belief!.proposition}»', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            for (final a in ActionAlignment.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  key: Key('alignment-${a.name}'),
                  icon: Icon(Icons.circle, size: 12, color: alignmentColor(context, a)),
                  label: Text(a.label),
                  onPressed: () => Navigator.pop(context, (_belief!, a)),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Juez en cascada sobre la acción: propone la dirección para cada creencia solo si la confianza
/// calibrada supera el umbral; lo demás queda para el usuario.
class _JudgeSuggest extends ConsumerWidget {
  const _JudgeSuggest({required this.action, required this.data, required this.links});

  final ActionRecord action;
  final CoherenceDataset data;
  final List<ActionLink> links;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cascade = ref.watch(cascadeJudgeProvider).value;
    if (cascade == null) return const SizedBox.shrink();
    return TextButton.icon(
      key: const Key('judge-suggest'),
      icon: const Icon(Icons.psychology_alt_outlined),
      label: const Text('Sugerir con el juez'),
      onPressed: () async {
        final linked = {for (final l in links) l.beliefId};
        final candidates = [
          for (final b in data.beliefs)
            if (!linked.contains(b.id) && b.status != BeliefStatus.refutada) b,
        ];
        final decisions = await cascade.decide([for (final b in candidates) (action.text, b.proposition)]);
        var suggested = 0;
        for (final (i, d) in decisions.indexed) {
          if (d.route != JudgeRoute.automatico || d.judgment.label == 'neutral') continue;
          suggested++;
          await ref
              .read(coherenceRepositoryProvider)
              .putLink(
                ActionLink(
                  actionKind: action.kind,
                  actionId: action.id,
                  beliefId: candidates[i].id,
                  alignment: d.judgment.label == 'entailment' ? ActionAlignment.desde : ActionAlignment.contra,
                  origin: LinkOrigin.modelo,
                  confidence: d.judgment.confidence,
                  source: d.version,
                  createdAt: DateTime.now(),
                ),
              );
        }
        if (context.mounted) {
          showMessage(
            context,
            suggested == 0
                ? 'El juez no tiene suficiente confianza: decide tú.'
                : '$suggested sugerencias. Confírmalas para que cuenten.',
          );
        }
      },
    );
  }
}

/// S15 · Patrón de pensamiento: se asigna el prototipo más cercano en el teléfono (no se clusteriza).
class _PatternRow extends ConsumerWidget {
  const _PatternRow({required this.action});

  final ActionRecord action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(prototypeCatalogProvider).value;
    final model = ref.watch(systemOneProvider).value;
    if (catalog == null || model == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final assigned = (ref.watch(patternAssignmentsProvider).value ?? const <PatternAssignmentRecord>[])
        .where((p) => p.actionKind == action.kind && p.actionId == action.id)
        .firstOrNull;
    final repo = ref.read(coherenceRepositoryProvider);
    final proto = assigned == null ? null : catalog.byId[assigned.prototypeId];
    final anti = proto == null ? null : catalog.antagonistOf(proto);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Patrón de pensamiento', style: theme.textTheme.titleSmall),
          if (assigned == null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('assign-pattern'),
                icon: const Icon(Icons.hub_outlined),
                label: const Text('Identificar patrón'),
                onPressed: () async {
                  final s = (await model.analyze([action.text])).single;
                  final a = catalog.assign(s.embedding);
                  if (a == null) {
                    if (context.mounted) showMessage(context, 'No se parece con suficiente claridad a ningún patrón.');
                    return;
                  }
                  await repo.putPattern(
                    PatternAssignmentRecord(
                      actionKind: action.kind,
                      actionId: action.id,
                      prototypeId: a.prototype.id,
                      similarity: a.similarity,
                      modelVersion: model.version,
                      createdAt: DateTime.now(),
                    ),
                  );
                },
              ),
            )
          else if (proto != null) ...[
            Text(
              '${proto.displayName} · similitud ${assigned.similarity.toStringAsFixed(2)}'
              '${assigned.confirmed == null ? ' · ¿es así?' : (assigned.confirmed! ? ' · confirmado' : ' · rechazado')}',
            ),
            if (proto.definition.isNotEmpty) Text(proto.definition, style: theme.textTheme.bodySmall),
            if (anti != null)
              Text(
                'Patrón opuesto: ${anti.displayName}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
              ),
            if (assigned.confirmed == null)
              Row(
                children: [
                  TextButton(onPressed: () => repo.putPattern(_with(assigned, true)), child: const Text('Sí, es este')),
                  TextButton(onPressed: () => repo.putPattern(_with(assigned, false)), child: const Text('No')),
                ],
              ),
          ],
        ],
      ),
    );
  }

  PatternAssignmentRecord _with(PatternAssignmentRecord a, bool confirmed) => PatternAssignmentRecord(
    actionKind: a.actionKind,
    actionId: a.actionId,
    prototypeId: a.prototypeId,
    similarity: a.similarity,
    modelVersion: a.modelVersion,
    confirmed: confirmed,
    createdAt: a.createdAt,
  );
}
