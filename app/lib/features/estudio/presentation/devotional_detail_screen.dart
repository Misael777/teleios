import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/catalogs/historical_catalog.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/devotional.dart';
import 'estudio_providers.dart';

class DevotionalDetailScreen extends ConsumerWidget {
  const DevotionalDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar devocional?'),
        content: const Text('Los tópicos se conservan; solo se elimina esta entrada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(devotionalRepositoryProvider).delete(id);
    if (context.mounted) context.go(Routes.estudio);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(devotionalByIdProvider(id));
    return entry.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (entry) {
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.search_off, title: 'Este devocional ya no existe'),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(entry.passage.label),
            actions: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(Routes.editarDevocional(id)),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(Formatters.date(entry.date), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  _PassageCard(entry: entry),
                  SectionCard(title: 'Reflexión', child: SelectableText(entry.content)),
                  SectionCard(
                    title: 'Tópicos',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final d in Dimension.all)
                          if (entry.topicsOf(d.id).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(radius: 5, backgroundColor: context.dimensionColor(d.id)),
                                      const SizedBox(width: 6),
                                      Text(d.name, style: Theme.of(context).textTheme.labelLarge),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final t in entry.topicsOf(d.id))
                                        DimensionChip(label: t.name, dimensionId: d.id, status: t.status, dense: true),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        if (entry.topics.isEmpty) const Text('Sin tópicos asignados.'),
                      ],
                    ),
                  ),
                  if (!entry.context.isEmpty) _ContextCard(entry: entry),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PassageCard extends ConsumerWidget {
  const _PassageCard({required this.entry});

  final DevotionalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = ref.watch(passageTextProvider(entry.passage));
    final translation = ref.watch(bibleRepositoryProvider).translation;
    return SectionCard(
      title: entry.passage.label,
      subtitle: translation,
      child: verses.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('No se pudo cargar el texto: $e'),
        data: (list) => SelectableText.rich(
          TextSpan(
            children: [
              for (final v in list.where((v) => v.text.isNotEmpty)) ...[
                TextSpan(text: '${v.verse} ', style: context.scripture.verseNumber),
                TextSpan(text: '${v.text} '),
              ],
            ],
          ),
          style: context.scripture.body,
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.entry});

  final DevotionalEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = entry.context;
    final rows = <(String, String)>[
      if (HistoricalCatalog.period(c.periodId) case final p?) ('Época', p.name),
      if (HistoricalCatalog.empire(c.empireId) case final e?) ('Imperio / poder', e.name),
      if (HistoricalCatalog.region(c.regionId) case final r?) ('Región', r.name),
      if (c.author != null) ('Autor', c.author!),
      if (c.approxYear != null) ('Año aproximado', Formatters.year(c.approxYear!)),
    ];
    return SectionCard(
      title: 'Contexto histórico',
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(width: 140, child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
                  Expanded(child: Text(value)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
