import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../coherencia/domain/belief.dart';
import '../../coherencia/presentation/action_beliefs_section.dart';
import '../altar_screen.dart';
import 'altar_providers.dart';

class PrayerDetailScreen extends ConsumerWidget {
  const PrayerDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar oración?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(prayerRepositoryProvider).delete(id);
    if (context.mounted) context.go(Routes.altar);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ref
        .watch(prayerByIdProvider(id))
        .when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Error: $e')),
          ),
          data: (r) {
            if (r == null) {
              return Scaffold(
                appBar: AppBar(),
                body: const EmptyState(icon: Icons.search_off, title: 'Esta oración ya no existe'),
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
                    onPressed: () => context.push(Routes.editarOracion(id)),
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
                      SectionCard(
                        title: e.intent.label,
                        trailing: Icon(intentIcon(e.intent), color: theme.colorScheme.primary),
                        child: SelectableText(e.transcript, style: context.scripture.body),
                      ),
                      ActionBeliefsSection(kind: ActionKind.oracion, actionId: e.id),
                      if (r.topics.isNotEmpty)
                        SectionCard(
                          title: 'Tópicos',
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final t in r.topics)
                                DimensionChip(label: t.name, dimensionId: t.dimensionId, status: t.status, dense: true),
                            ],
                          ),
                        ),
                      if (r.linkedPraxis.isNotEmpty)
                        SectionCard(
                          title: 'Praxis vinculada',
                          child: Column(
                            children: [
                              for (final p in r.linkedPraxis)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.edit_note),
                                  title: Text(p.circumstance, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  subtitle: Text(Formatters.shortDate(p.date)),
                                  onTap: () => context.go(Routes.registro(p.id)),
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
