import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../shared/domain/entities/praxis_entry.dart';
import '../../shared/widgets/common_widgets.dart';
import 'domain/praxis.dart';
import 'presentation/bitacora_providers.dart';
import 'presentation/bitacora_widgets.dart';

class BitacoraScreen extends ConsumerWidget {
  const BitacoraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(praxisFilterProvider);
    final list = ref.watch(praxisListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de Praxis')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            key: const Key('quick-praxis'),
            heroTag: 'fab-bitacora-rapido',
            tooltip: 'Registro rápido (< 30 s)',
            onPressed: () => context.push(Routes.registroRapido),
            child: const Icon(Icons.flash_on),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            key: const Key('new-praxis'),
            heroTag: 'fab-bitacora',
            onPressed: () => context.push(Routes.nuevoRegistro),
            icon: const Icon(Icons.add),
            label: const Text('Registro'),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                for (final f in FilterType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      avatar: Icon(FilterBadge.iconOf(f), size: 16, color: FilterBadge.colorOf(context, f)),
                      label: Text(f.shortLabel),
                      selected: filter == f,
                      onSelected: (on) => ref.read(praxisFilterProvider.notifier).set(on ? f : null),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: list.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) => records.isEmpty
                  ? EmptyState(
                      icon: Icons.edit_note,
                      title: filter == null ? 'Tu primera praxis' : 'Sin registros con este filtro',
                      message: filter == null
                          ? 'Registra una circunstancia, cómo te hizo sentir, en qué te apoyaste y qué hiciste. '
                                'Las fallas también cuentan: son las que más enseñan.'
                          : null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 140),
                      itemCount: records.length,
                      itemBuilder: (_, i) => _PraxisCard(record: records[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PraxisCard extends StatelessWidget {
  const _PraxisCard({required this.record});

  final PraxisRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = record.entry;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.registro(record.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilterBadge(e.filter),
                  if (e.isQuick) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.flash_on, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ],
                  if (record.attachments.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.image_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ],
                  const Spacer(),
                  Text(Formatters.shortDate(e.date), style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(e.circumstance, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 6),
              Text(
                record.emotions.map((x) => x.name).join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 10),
              ScoreBar(label: 'Paz', value: e.peace),
              if (e.coherence != null) ...[
                const SizedBox(height: 4),
                ScoreBar(label: 'Coherencia', value: e.coherence),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
