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
import '../../coherencia/presentation/belief_editor.dart';
import '../domain/devotional.dart';
import '../domain/guided_reflection.dart';
import 'estudio_providers.dart';
import 'widgets/devotional_cover.dart';
import 'widgets/scripture_text.dart';
import 'widgets/section_style.dart';

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
                  DevotionalCover(entry: entry),
                  _PassageCard(entry: entry),
                  _ReflectionCard(reflection: GuidedReflection.parse(entry.content)),
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
                  Card(
                    child: ListTile(
                      key: const Key('devotional-to-belief'),
                      leading: const Icon(Icons.account_tree_outlined),
                      title: const Text('Convertir en creencia'),
                      subtitle: const Text(
                        'Tu principio pasa a ser una creencia operativa: verás qué tanto lo sostiene la Escritura '
                        'y cuánto lo vives.',
                      ),
                      onTap: () async {
                        final belief = await showBeliefEditor(context, from: entry);
                        if (belief != null && context.mounted) await context.push(Routes.creencia(belief.id));
                      },
                    ),
                  ),
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

/// Un punto por cada sección desde la que se citó un versículo, en el color de la sección.
class _SectionDots extends StatelessWidget {
  const _SectionDots({required this.sectionIds});

  final List<String?> sectionIds;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: sectionIds.map(SectionStyle.name).join(' · '),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in sectionIds)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(color: SectionStyle.color(context, id), shape: BoxShape.circle),
          ),
      ],
    ),
  );
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.reflection});

  final GuidedReflection reflection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linked = reflection.linkedPassages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (reflection.notes.isNotEmpty) SectionCard(title: 'Reflexión', child: ScriptureLinkedText(reflection.notes)),
        for (final section in GuidedReflection.sections)
          if (reflection.answeredIn(section) > 0)
            SectionCard(
              title: section.name,
              subtitle: section.purpose,
              trailing: Icon(SectionStyle.icon(section.id), color: SectionStyle.color(context, section.id)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, q) in section.questions.where((q) => reflection.answered(q.id)).indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    Text(q.text, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 4),
                    ScriptureLinkedText(reflection.answer(q.id)),
                  ],
                ],
              ),
            ),
        if (linked.isNotEmpty)
          SectionCard(
            title: 'Pasajes vinculados',
            subtitle: 'El color indica la sección donde lo citaste. Toca uno para leerlo.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final l in linked)
                      ActionChip(
                        avatar: _SectionDots(
                          sectionIds: [
                            for (final c in reflection.citations)
                              if (c.ref == l.ref) c.section?.id,
                          ],
                        ),
                        label: Text(l.ref.label),
                        onPressed: () => showPassageSheet(context, l.ref),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => context.go(Routes.lineaDeTiempo),
                    icon: const Icon(Icons.timeline, size: 18),
                    label: const Text('Ver la red en la línea de tiempo'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
