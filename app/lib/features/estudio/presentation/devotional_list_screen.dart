import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/teleios_logo.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/catalogs/bible_books.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../domain/devotional.dart';
import 'estudio_providers.dart';

class DevotionalListScreen extends ConsumerWidget {
  const DevotionalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(devotionalFilterProvider);
    final devotionals = ref.watch(filteredDevotionalsProvider);
    final allBooks = {
      for (final d in ref.watch(allDevotionalsProvider).value ?? const <DevotionalEntry>[]) d.passage.bookCode,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [TeleiosMark(size: 30), SizedBox(width: 12), Text('Estudio')]),
        actions: [
          IconButton(
            tooltip: 'Biblia RV1909',
            icon: const Icon(Icons.auto_stories_outlined),
            onPressed: () => context.go(Routes.biblia),
          ),
          IconButton(
            tooltip: 'Línea de tiempo',
            icon: const Icon(Icons.timeline),
            onPressed: () => context.go(Routes.lineaDeTiempo),
          ),
          IconButton(
            tooltip: 'Incubación teológica',
            icon: const Icon(Icons.hourglass_top),
            onPressed: () => context.go(Routes.incubacion),
          ),
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new-devotional'),
        onPressed: () => context.push(Routes.nuevoDevocional),
        icon: const Icon(Icons.add),
        label: const Text('Devocional'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final d in Dimension.all)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(d.name),
                      selected: filter.dimensionId == d.id,
                      avatar: CircleAvatar(radius: 6, backgroundColor: context.dimensionColor(d.id)),
                      onSelected: (on) => ref.read(devotionalFilterProvider.notifier).setDimension(on ? d.id : null),
                    ),
                  ),
                if (allBooks.isNotEmpty)
                  PopupMenuButton<String?>(
                    tooltip: 'Filtrar por libro',
                    onSelected: (code) => ref.read(devotionalFilterProvider.notifier).setBook(code),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: null, child: Text('Todos los libros')),
                      for (final b in BibleBooks.all.where((b) => allBooks.contains(b.code)))
                        PopupMenuItem(value: b.code, child: Text(b.name)),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.filter_list, size: 18),
                      label: Text(filter.bookCode == null ? 'Libro' : BibleBooks.byCode(filter.bookCode!).name),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: devotionals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return filter.isEmpty
                      ? EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: 'Tu primer devocional',
                          message: 'Elige un pasaje, escribe tu reflexión y clasifícala en las 4 dimensiones.',
                          action: FilledButton.icon(
                            onPressed: () => context.push(Routes.nuevoDevocional),
                            icon: const Icon(Icons.add),
                            label: const Text('Escribir devocional'),
                          ),
                        )
                      : EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'Sin resultados con este filtro',
                          action: TextButton(
                            onPressed: () => ref.read(devotionalFilterProvider.notifier).clear(),
                            child: const Text('Quitar filtros'),
                          ),
                        );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _DevotionalCard(entry: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DevotionalCard extends StatelessWidget {
  const _DevotionalCard({required this.entry});

  final DevotionalEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.devocional(entry.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(entry.passage.label, style: theme.textTheme.titleMedium)),
                  Text(Formatters.shortDate(entry.date), style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 6),
              Text(entry.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (entry.topics.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in entry.topics.take(6))
                      DimensionChip(label: t.name, dimensionId: t.dimensionId, status: t.status, dense: true),
                    if (entry.topics.length > 6)
                      Chip(label: Text('+${entry.topics.length - 6}'), visualDensity: VisualDensity.compact),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
