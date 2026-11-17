import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/ids.dart';
import '../../../shared/domain/catalogs/bible_books.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/belief.dart';
import '../domain/coherence_judge.dart';
import '../domain/labeling.dart';
import 'coherence_providers.dart';

/// Versículo de la Biblia de la app a partir de su id (libro×10⁶ + capítulo×10³ + versículo).
PassageRef verseRef(int id) =>
    PassageRef(bookCode: BibleBooks.all[id ~/ 1000000 - 1].code, chapter: id ~/ 1000 % 1000, verseStart: id % 1000);

/// Etiqueta NLI que el juez daría a una evidencia ya juzgada.
String? predictedLabel(BeliefEvidence e) {
  if (e.probEntail == null || e.probContra == null) return null;
  return NliJudgment(e.probEntail!, (1 - e.probEntail! - e.probContra!).clamp(0, 1), e.probContra!).label;
}

/// Al revisar una evidencia juzgada, se guarda qué dijo el juez y qué decidió el usuario (gráfico 8).
Future<void> recordEvidenceVerdict(WidgetRef ref, BeliefEvidence e, String userLabel) async {
  final predicted = predictedLabel(e);
  if (predicted == null || e.modelVersion == null) return;
  final p = switch (predicted) {
    'entailment' => e.probEntail!,
    'contradiction' => e.probContra!,
    _ => (1 - e.probEntail! - e.probContra!).clamp(0.0, 1.0),
  };
  await ref
      .read(coherenceRepositoryProvider)
      .recordFeedback(
        JudgeFeedbackEntry(
          id: newId(),
          judgeVersion: e.modelVersion!,
          task: 'nli',
          predicted: predicted,
          probability: p,
          userLabel: userLabel,
          createdAt: DateTime.now(),
        ),
      );
}

/// Juzga cada pasaje (premisa) contra la creencia (hipótesis) con la cascada local (System One y, si está
/// instalado, el juez grande para lo incierto) y guarda las probabilidades con la versión del juez que las
/// dio. Nada cuenta como confirmado hasta que el usuario lo revise.
Future<int> judgeEvidence(WidgetRef ref, Belief belief, List<BeliefEvidence> evidence) async {
  final cascade = await ref.read(cascadeJudgeProvider.future);
  if (cascade == null) return 0;
  final bible = ref.read(bibleRepositoryProvider);
  final repo = ref.read(coherenceRepositoryProvider);
  final items = [...evidence];
  // F: el pasaje base también se juzga (fidelidad al contexto inmediato).
  final base = belief.basePassage;
  if (base != null && !items.any((e) => e.passage == base)) {
    items.add(
      BeliefEvidence(
        id: newId(),
        beliefId: belief.id,
        passage: base,
        kind: EvidenceKind.soporte,
        source: EvidenceSource.modelo,
        createdAt: DateTime.now(),
      ),
    );
  }
  final texts = [for (final e in items) (await bible.passage(e.passage)).map((v) => v.text).join(' ')];
  final decided = await cascade.decide([for (final t in texts) (t, belief.proposition)]);
  for (var i = 0; i < items.length; i++) {
    final e = items[i], j = decided[i].judgment;
    // Las revisiones del usuario mandan: el juez solo cambia el tipo de lo no revisado.
    final kind = e.confirmed || e.source == EvidenceSource.usuario || e.source == EvidenceSource.cita
        ? e.kind
        : (j.contra > j.entail && j.contra > 0.5 ? EvidenceKind.tension : EvidenceKind.soporte);
    await repo.putEvidence(
      BeliefEvidence(
        id: e.id,
        beliefId: e.beliefId,
        passage: e.passage,
        kind: kind,
        source: e.source,
        votes: e.votes,
        probEntail: j.entail,
        probContra: j.contra,
        modelVersion: decided[i].version,
        resolved: e.resolved,
        confirmed: e.confirmed,
        note: e.note,
        createdAt: e.createdAt,
      ),
    );
  }
  return items.length;
}

/// S13 · Recuperación canónica: los k versículos más cercanos a la creencia en el espacio del
/// System One (entrenado con negativos duros) entran como candidatos sin revisar y se juzgan.
Future<int> searchScripture(WidgetRef ref, Belief belief, List<BeliefEvidence> existing, {int k = 15}) async {
  final model = await ref.read(systemOneProvider.future);
  if (model == null) return 0;
  final query = (await model.analyze([belief.proposition])).single.embedding;
  final have = {for (final e in existing) e.passage.encode()};
  final now = DateTime.now();
  final fresh = [
    for (final (id, _) in await model.nearestVerses(query, k: k))
      if (!have.contains(verseRef(id).encode()))
        BeliefEvidence(
          id: newId(),
          beliefId: belief.id,
          passage: verseRef(id),
          kind: EvidenceKind.soporte,
          source: EvidenceSource.modelo,
          createdAt: now,
        ),
  ];
  await ref.read(coherenceRepositoryProvider).addEvidenceIfAbsent(fresh);
  await judgeEvidence(ref, belief, fresh);
  return fresh.length;
}

/// Botones del juez local en el detalle de una creencia. Sin modelo instalado no se muestran.
class JudgeEvidenceButton extends ConsumerStatefulWidget {
  const JudgeEvidenceButton({super.key, required this.belief, required this.evidence});

  final Belief belief;
  final List<BeliefEvidence> evidence;

  @override
  ConsumerState<JudgeEvidenceButton> createState() => _JudgeEvidenceButtonState();
}

class _JudgeEvidenceButtonState extends ConsumerState<JudgeEvidenceButton> {
  bool _busy = false;

  Future<void> _run(Future<int> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      final n = await action();
      if (mounted) showMessage(context, done.replaceAll('{n}', '$n'));
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(systemOneProvider).value;
    if (model == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonalIcon(
          key: const Key('judge-evidence'),
          icon: _busy
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.psychology_alt_outlined),
          label: const Text('Evaluar con el juez local'),
          onPressed: _busy
              ? null
              : () => _run(() => judgeEvidence(ref, widget.belief, widget.evidence), '{n} pasajes evaluados.'),
        ),
        OutlinedButton.icon(
          key: const Key('search-scripture'),
          icon: const Icon(Icons.travel_explore),
          label: const Text('Buscar en toda la Escritura'),
          onPressed: _busy
              ? null
              : () => _run(
                  () => searchScripture(ref, widget.belief, widget.evidence),
                  '{n} pasajes candidatos (sin revisar).',
                ),
        ),
      ],
    );
  }
}
