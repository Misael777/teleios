import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/ids.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../estudio/presentation/passage_picker.dart';
import '../domain/belief.dart';
import '../domain/canonical_coherence.dart';
import '../domain/coherence_data.dart';
import '../domain/coherence_statistics.dart';
import 'belief_editor.dart';
import 'coherence_providers.dart';
import 'judge_actions.dart';
import 'widgets/canonical_footprint.dart';
import 'widgets/coherence_chart_widgets.dart';

/// Una creencia con su evidencia canónica (gráficos 1 y 2) y las acciones que la viven o la contradicen.
class BeliefDetailScreen extends ConsumerWidget {
  const BeliefDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(coherenceDatasetProvider);
    return data.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (d) {
        final belief = d.beliefById[id];
        if (belief == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.search_off, title: 'Esta creencia ya no existe'),
          );
        }
        return _BeliefView(belief: belief, data: d);
      },
    );
  }
}

class _BeliefView extends ConsumerWidget {
  const _BeliefView({required this.belief, required this.data});

  final Belief belief;
  final CoherenceDataset data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final evidence = data.evidence[belief.id] ?? const <BeliefEvidence>[];
    final cc = data.coherence[belief.id] ?? CanonicalCoherence.empty;
    final tensions = [
      for (final e in evidence)
        if (e.kind == EvidenceKind.tension) e,
    ];
    final supports = [
      for (final e in evidence)
        if (e.kind == EvidenceKind.soporte) e,
    ]..sort((a, b) => b.supportWeight.compareTo(a.supportWeight));
    final links = [
      for (final l in data.links)
        if (l.beliefId == belief.id) l,
    ]..sort((a, b) => (data.actionOf(b)?.date ?? DateTime(0)).compareTo(data.actionOf(a)?.date ?? DateTime(0)));
    final repo = ref.read(coherenceRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creencia'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showBeliefEditor(context, belief: belief),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('¿Eliminar la creencia?'),
                  content: const Text('Se borran su evidencia y sus vínculos con acciones. Los registros no se tocan.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Eliminar')),
                  ],
                ),
              );
              if (ok == true) {
                await repo.deleteBelief(belief.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(belief.proposition, style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(belief.origin.label)),
                  if (belief.devotionalId != null)
                    ActionChip(
                      avatar: const Icon(Icons.menu_book_outlined, size: 18),
                      label: Text(data.devotionalTitles[belief.devotionalId] ?? 'Devocional'),
                      onPressed: () => context.push(Routes.devocional(belief.devotionalId!)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SegmentedButton<BeliefStatus>(
                showSelectedIcon: false,
                segments: [for (final s in BeliefStatus.values) ButtonSegment(value: s, label: Text(s.label))],
                selected: {belief.status},
                onSelectionChanged: (s) =>
                    repo.upsertBelief(belief.copyWith(status: s.first, updatedAt: DateTime.now())),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Huella canónica',
                subtitle: belief.basePassage == null
                    ? 'Elige un pasaje base (editar) para ver de dónde viene el soporte.'
                    : 'Desde ${belief.basePassage!.label}: arriba lo que la sostiene, abajo lo que la tensiona.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CanonicalFootprint(evidence: evidence, base: belief.basePassage),
                    const SizedBox(height: 8),
                    _VectorTable(cc: cc),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          key: const Key('import-crossrefs'),
                          icon: const Icon(Icons.call_split),
                          label: const Text('Traer referencias cruzadas'),
                          onPressed: () async {
                            final n = await ref.read(importCanonicalEvidenceProvider)(belief);
                            if (context.mounted) {
                              showMessage(context, n == 0 ? 'No hay pasajes nuevos.' : '$n pasajes agregados.');
                            }
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_link),
                          label: const Text('Agregar pasaje'),
                          onPressed: () => _addPassage(context, ref),
                        ),
                        JudgeEvidenceButton(belief: belief, evidence: evidence),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Referencias de OpenBible.info (CC-BY), ponderadas por sus votos hasta que las revises. '
                      'Llevan el sesgo de su tradición: es sostén intertextual, no verdad.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SectionCard(
                title: 'Fichas de tensión',
                subtitle: '¿Dónde choca tu interpretación con otro texto? Marca las que el contexto resuelve.',
                child: tensions.isEmpty
                    ? const Text(
                        'Sin tensiones registradas. Si un pasaje parece decir lo contrario, agrégalo como tensión.',
                      )
                    : Column(
                        children: [for (final t in tensions) _EvidenceTile(belief: belief, evidence: t)],
                      ),
              ),
              SectionCard(
                title: 'Soporte (${supports.length})',
                subtitle: 'Confirma los que de verdad la sostienen; los demás pesan según sus votos o el juez.',
                child: supports.isEmpty
                    ? const Text('Aún no hay soporte.')
                    : Column(
                        children: [for (final s in supports.take(40)) _EvidenceTile(belief: belief, evidence: s)],
                      ),
              ),
              SectionCard(
                title: 'Acciones vinculadas (${links.length})',
                subtitle: 'Registros y oraciones donde actuaste desde esta creencia o contra ella.',
                child: links.isEmpty
                    ? const Text(
                        'Vincula registros de la bitácora desde su detalle, o acepta sugerencias en Coherencia.',
                      )
                    : Column(
                        children: [
                          for (final l in links)
                            if (data.actionOf(l) case final a?)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  a.kind == ActionKind.praxis ? Icons.edit_note : Icons.mic_none,
                                  color: alignmentColor(context, l.alignment),
                                ),
                                title: Text(a.text.split('\n').first, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  '${Formatters.date(a.date)} · ${l.alignment.shortLabel}'
                                  '${a.peace == null ? '' : ' · paz ${a.peace}'}'
                                  '${l.confirmed ? '' : ' · sin confirmar'}',
                                ),
                                onTap: () => context.push(
                                  a.kind == ActionKind.praxis ? Routes.registro(a.id) : Routes.oracion(a.id),
                                ),
                              ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPassage(BuildContext context, WidgetRef ref) async {
    final passage = await showPassagePicker(context);
    if (passage == null || !context.mounted) return;
    final kind = await showModalBottomSheet<EvidenceKind>(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(passage.label), subtitle: const Text('¿Qué hace este pasaje con tu creencia?')),
            ListTile(
              leading: const Icon(Icons.thumb_up_alt_outlined),
              title: const Text('La sostiene'),
              onTap: () => Navigator.pop(c, EvidenceKind.soporte),
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('La tensiona'),
              onTap: () => Navigator.pop(c, EvidenceKind.tension),
            ),
          ],
        ),
      ),
    );
    if (kind == null) return;
    await ref
        .read(coherenceRepositoryProvider)
        .putEvidence(
          BeliefEvidence(
            id: newId(),
            beliefId: belief.id,
            passage: passage,
            kind: kind,
            source: EvidenceSource.usuario,
            confirmed: true,
            createdAt: DateTime.now(),
          ),
        );
  }
}

class _VectorTable extends StatelessWidget {
  const _VectorTable({required this.cc});

  final CanonicalCoherence cc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget cell(String symbol, String name, String value, String help) => Expanded(
      child: Tooltip(
        message: help,
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleMedium),
            Text('$symbol · $name', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
    String est(Estimate e) => '${e.value.toStringAsFixed(1)} [${e.lo.toStringAsFixed(1)}–${e.hi.toStringAsFixed(1)}]';
    return Row(
      key: const Key('coherence-vector'),
      children: [
        cell('S', 'soporte', est(cc.support), 'Suma del peso de los pasajes que la sostienen (IC bootstrap 95 %)'),
        cell('D', 'libros efectivos', est(cc.diversity), '1 = todo viene de un solo lugar; 5 = cinco libros parejos'),
        cell('T', 'tensión', est(cc.tension), 'Tensiones sin resolver'),
        cell(
          'F',
          'fidelidad',
          cc.fidelity == null ? '—' : cc.fidelity!.toStringAsFixed(2),
          'Juez local: ¿el pasaje base confirma (1) o contradice (−1) la creencia? Requiere el modelo',
        ),
        cell('n', 'pasajes', '${cc.n}', 'Pasajes evaluados'),
      ],
    );
  }
}

class _EvidenceTile extends ConsumerWidget {
  const _EvidenceTile({required this.belief, required this.evidence});

  final Belief belief;
  final BeliefEvidence evidence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final e = evidence;
    final repo = ref.read(coherenceRepositoryProvider);
    final verse = ref.watch(_verseTextProvider(e.passage));
    final weight = e.kind == EvidenceKind.soporte ? e.supportWeight : e.tensionWeight;
    final details = [
      e.source.label,
      if (e.votes != null) '${e.votes} votos',
      if (e.probEntail != null) 'P(confirma) ${(e.probEntail! * 100).round()} %',
      if (e.probContra != null) 'P(contradice) ${(e.probContra! * 100).round()} %',
      'peso ${weight.toStringAsFixed(2)}',
      if (e.kind == EvidenceKind.tension) e.resolved ? 'resuelta por el contexto' : 'pendiente',
    ];
    return Padding(
      key: Key('evidence-${e.passage.encode()}'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                e.kind == EvidenceKind.soporte ? Icons.thumb_up_alt_outlined : Icons.compare_arrows,
                size: 18,
                color: e.kind == EvidenceKind.soporte ? theme.colorScheme.primary : theme.colorScheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(e.passage.label, style: theme.textTheme.titleSmall)),
              if (e.confirmed) Icon(Icons.verified_outlined, size: 18, color: theme.colorScheme.primary),
              PopupMenuButton<String>(
                tooltip: 'Revisar',
                onSelected: (v) async {
                  // Veredicto del usuario sobre lo que dijo el juez (gráfico 8).
                  final verdict = switch (v) {
                    'confirm' => e.kind == EvidenceKind.soporte ? 'entailment' : 'contradiction',
                    'support' => 'entailment',
                    'tension' => 'contradiction',
                    'remove' => 'neutral',
                    _ => null,
                  };
                  if (verdict != null && !e.confirmed) await recordEvidenceVerdict(ref, e, verdict);
                  await switch (v) {
                    'confirm' => repo.putEvidence(e.copyWith(confirmed: true)),
                    'support' => repo.putEvidence(e.copyWith(kind: EvidenceKind.soporte, confirmed: true)),
                    'tension' => repo.putEvidence(e.copyWith(kind: EvidenceKind.tension, confirmed: true)),
                    'resolve' => repo.putEvidence(e.copyWith(resolved: !e.resolved)),
                    _ => repo.removeEvidence(e.id),
                  };
                },
                itemBuilder: (_) => [
                  if (!e.confirmed) const PopupMenuItem(value: 'confirm', child: Text('Confirmar')),
                  if (e.kind == EvidenceKind.tension)
                    const PopupMenuItem(value: 'support', child: Text('En realidad la sostiene')),
                  if (e.kind == EvidenceKind.soporte)
                    const PopupMenuItem(value: 'tension', child: Text('En realidad la tensiona')),
                  if (e.kind == EvidenceKind.tension)
                    PopupMenuItem(
                      value: 'resolve',
                      child: Text(e.resolved ? 'Marcar como pendiente' : 'Resuelta por el contexto'),
                    ),
                  const PopupMenuItem(value: 'remove', child: Text('Quitar')),
                ],
              ),
            ],
          ),
          if (verse.value case final text? when text.isNotEmpty)
            Text(text, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          if (e.kind == EvidenceKind.tension)
            Text('Tu principio: ${belief.proposition}', style: theme.textTheme.bodySmall),
          Text(
            details.join(' · '),
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

final _verseTextProvider = FutureProvider.family<String, PassageRef>((ref, p) async {
  final verses = await ref.watch(bibleRepositoryProvider).passage(p);
  return verses.map((v) => v.text).join(' ');
});
