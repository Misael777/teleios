import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../domain/labeling.dart';
import 'coherence_providers.dart';

/// Protocolo de etiquetado (§10): ítems compartidos con ítems de oro intercalados. Las respuestas
/// quedan en el teléfono; el archivo exportable no contiene texto privado.
class LabelingTab extends ConsumerStatefulWidget {
  const LabelingTab({super.key, this.random});

  final Random? random;

  @override
  ConsumerState<LabelingTab> createState() => _LabelingTabState();
}

class _LabelingTabState extends ConsumerState<LabelingTab> {
  SharedItem? _current;
  final _watch = Stopwatch()..start();
  late final Random _random = widget.random ?? Random();

  Future<void> _answer(SharedItem item, String label) async {
    await ref
        .read(coherenceRepositoryProvider)
        .putSharedLabel(
          SharedLabel(
            itemId: item.id,
            label: label,
            isGold: item.isGold,
            correct: item.isGold ? item.gold == label : null,
            durationMs: _watch.elapsedMilliseconds,
            answeredAt: DateTime.now(),
          ),
        );
    _watch.reset();
    setState(() => _current = null);
  }

  Future<void> _export(String version, List<SharedLabel> labels) async {
    final repo = ref.read(coherenceRepositoryProvider);
    final json = exportLabels(
      annotatorId: ref.read(annotatorIdProvider),
      itemsVersion: version,
      labels: labels,
      feedback: await repo.watchFeedback().first,
      patterns: await repo.watchPatterns().first,
    );
    await SharePlus.instance.share(
      ShareParams(
        text: const JsonEncoder.withIndent('  ').convert(json),
        subject: 'TELEIOS · etiquetas confirmadas (sin texto privado)',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(sharedItemsProvider);
    final labels = ref.watch(sharedLabelsProvider).value ?? const <SharedLabel>[];
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('No se pudieron cargar los ítems: $e')),
      data: (bundle) {
        final answered = {for (final l in labels) l.itemId};
        _current ??= nextItem(bundle.items, answered, random: _random);
        final item = _current;
        final gold = goldAccuracy(labels);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                Text(
                  'Ayuda a medir con rigor: responde ítems compartidos. Algunos tienen respuesta conocida y '
                  'miden la fiabilidad de cada etiquetador. Tus diarios nunca se usan aquí.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: bundle.items.isEmpty ? 0 : answered.length / bundle.items.length,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '${answered.length} de ${bundle.items.length} respondidos · '
                  '${gold.accuracy == null ? 'fiabilidad aún sin medir' : 'fiabilidad ${(gold.accuracy! * 100).round()} % en ${gold.n} ítems de control'}',
                  key: const Key('labeling-progress'),
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 16),
                if (item == null)
                  const EmptyState(
                    icon: Icons.task_alt,
                    title: 'Terminaste esta tanda',
                    message: 'Exporta tus etiquetas para que el laboratorio las agregue con las de otras personas.',
                  )
                else
                  Card(
                    key: Key('shared-item-${item.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(item.prompt, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _Quote(text: item.a),
                          const SizedBox(height: 8),
                          _Quote(text: item.b),
                          const SizedBox(height: 16),
                          for (final MapEntry(key: value, value: text) in item.options.entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton(
                                key: Key('answer-$value'),
                                onPressed: () => _answer(item, value),
                                child: Text(text),
                              ),
                            ),
                          TextButton(onPressed: () => _answer(item, 'no_se'), child: const Text('No estoy seguro')),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('export-labels'),
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Exportar etiquetas confirmadas'),
                  onPressed: labels.isEmpty ? null : () => _export(bundle.version, labels),
                ),
                const SizedBox(height: 4),
                Text(
                  'Incluye solo: tus respuestas a ítems compartidos, tus veredictos sobre el juez (sin texto) y '
                  'confirmaciones de patrones. Un id anónimo permite medir tu fiabilidad sin identificarte.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.bodyLarge),
    );
  }
}
