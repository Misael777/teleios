import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/private_image.dart';
import '../../coherencia/domain/belief.dart';
import '../../coherencia/presentation/action_beliefs_section.dart';
import 'bitacora_providers.dart';
import 'bitacora_widgets.dart';

class PraxisDetailScreen extends ConsumerWidget {
  const PraxisDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar registro?'),
        content: const Text('También se eliminarán sus fotos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(deletePraxisProvider)(id);
    if (context.mounted) context.go(Routes.bitacora);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(praxisByIdProvider(id));
    final theme = Theme.of(context);
    return record.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (r) {
        if (r == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(icon: Icons.search_off, title: 'Este registro ya no existe'),
          );
        }
        final e = r.entry;
        return Scaffold(
          appBar: AppBar(
            title: Text(Formatters.date(e.date)),
            actions: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(Routes.editarRegistro(id)),
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
                  if (e.isQuick)
                    Card(
                      color: theme.colorScheme.secondaryContainer,
                      child: ListTile(
                        leading: const Icon(Icons.flash_on),
                        title: const Text('Registro rápido'),
                        subtitle: const Text('Completa la acción y la coherencia cuando puedas.'),
                        trailing: TextButton(
                          onPressed: () => context.push(Routes.editarRegistro(id)),
                          child: const Text('Completar'),
                        ),
                      ),
                    ),
                  SectionCard(
                    title: 'A · Acontecimiento',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(e.circumstance, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [for (final x in r.emotions) Chip(label: Text(x.name))],
                        ),
                        const SizedBox(height: 10),
                        ScoreBar(label: 'Intensidad', value: e.intensity, invert: true),
                      ],
                    ),
                  ),
                  SectionCard(
                    title: 'B · Filtro',
                    trailing: FilterBadge(e.filter),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.filter.label),
                        if (e.foundationDetail != null) ...[const SizedBox(height: 8), Text(e.foundationDetail!)],
                        if (e.passage != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.menu_book_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(e.passage!.label, style: theme.textTheme.labelLarge),
                            ],
                          ),
                        ],
                        if (r.triggers.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text('Detonantes', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final t in r.triggers)
                                Chip(avatar: const Icon(Icons.bolt, size: 16), label: Text(t.name)),
                            ],
                          ),
                        ],
                        if (r.topics.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text('Tópicos', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final t in r.topics)
                                DimensionChip(label: t.name, dimensionId: t.dimensionId, status: t.status, dense: true),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SectionCard(
                    title: 'C · Consecuencia',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (e.action.isNotEmpty) ...[SelectableText(e.action), const SizedBox(height: 10)],
                        ScoreBar(label: 'Paz', value: e.peace),
                        const SizedBox(height: 4),
                        ScoreBar(label: 'Coherencia', value: e.coherence),
                      ],
                    ),
                  ),
                  ActionBeliefsSection(kind: ActionKind.praxis, actionId: e.id),
                  if (r.attachments.isNotEmpty)
                    SectionCard(
                      title: 'Fotos',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final Attachment a in r.attachments)
                            GestureDetector(
                              onTap: () => showPrivateImage(context, a.fileName),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox.square(dimension: 110, child: PrivateImage(fileName: a.fileName)),
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
      },
    );
  }
}
