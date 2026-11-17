import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../shared/domain/entities/prayer_entry.dart';
import '../../shared/widgets/common_widgets.dart';
import 'domain/prayer.dart';
import 'presentation/altar_providers.dart';

class AltarScreen extends ConsumerWidget {
  const AltarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayerListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Altar')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-altar',
        key: const Key('new-prayer'),
        onPressed: () => context.push(Routes.orar),
        icon: const Icon(Icons.mic),
        label: const Text('Orar'),
      ),
      body: prayers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? const EmptyState(
                icon: Icons.mic_none,
                title: 'Derrama tu corazón',
                message: 'Dicta o escribe tu oración. Se transcribe en tu dispositivo y el audio nunca se guarda.',
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                itemCount: list.length,
                itemBuilder: (_, i) => _PrayerCard(record: list[i]),
              ),
      ),
    );
  }
}

IconData intentIcon(PrayerIntent i) => switch (i) {
  PrayerIntent.agradecimiento => Icons.volunteer_activism_outlined,
  PrayerIntent.peticion => Icons.front_hand_outlined,
  PrayerIntent.lamentacion => Icons.water_drop_outlined,
};

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({required this.record});

  final PrayerRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final e = record.entry;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go(Routes.oracion(record.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(intentIcon(e.intent), size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(e.intent.label, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                  const Spacer(),
                  Text(Formatters.shortDate(e.date), style: theme.textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(e.transcript, maxLines: 3, overflow: TextOverflow.ellipsis),
              if (record.topics.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in record.topics.take(5))
                      DimensionChip(label: t.name, dimensionId: t.dimensionId, status: t.status, dense: true),
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
