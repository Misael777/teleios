import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/entities/dimension.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/providers.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'estudio_providers.dart';
import 'passage_picker.dart';

/// Cosmovisiones y conductas aprendidas que aún no pasaron por el filtro de la Escritura.
///
/// «Examinadlo todo; retened lo bueno.» — 1 Tesalonicenses 5:21
class IncubationScreen extends ConsumerWidget {
  const IncubationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Incubación teológica'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Por validar'),
            Tab(text: 'Validadas'),
            Tab(text: 'Refutadas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Cosmovisión'),
      ),
      body: const TabBarView(
        children: [
          _TopicList(
            status: TopicStatus.incubacion,
            empty: EmptyState(
              icon: Icons.hourglass_empty,
              title: 'Nada en incubación',
              message:
                  'Registra aquí creencias o conductas que consideras correctas pero '
                  'cuyo fundamento bíblico aún no identificas. Al estudiar, las validarás o refutarás.',
            ),
          ),
          _TopicList(
            status: TopicStatus.validado,
            onlyWithValidation: true,
            empty: EmptyState(icon: Icons.verified_outlined, title: 'Aún no validaste ninguna cosmovisión'),
          ),
          _TopicList(
            status: TopicStatus.refutado,
            empty: EmptyState(icon: Icons.block, title: 'Ninguna cosmovisión refutada'),
          ),
        ],
      ),
    ),
  );

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<(String, String, String)>(
      context: context,
      builder: (_) => const _NewIncubationDialog(),
    );
    if (result == null) return;
    final (name, dimensionId, note) = result;
    try {
      await ref.read(createIncubationTopicProvider)(name: name, dimensionId: dimensionId, note: note);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }
}

class _TopicList extends ConsumerWidget {
  const _TopicList({required this.status, required this.empty, this.onlyWithValidation = false});

  final TopicStatus status;
  final Widget empty;

  /// En "Validadas" solo se muestran las que se validaron desde incubación (con pasaje).
  final bool onlyWithValidation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsByStatusProvider(status));
    return topics.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) {
        final visible = onlyWithValidation ? list.where((t) => t.validationPassage != null).toList() : list;
        if (visible.isEmpty) return empty;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
          itemCount: visible.length,
          itemBuilder: (_, i) => _IncubationCard(topic: visible[i]),
        );
      },
    );
  }
}

class _IncubationCard extends ConsumerWidget {
  const _IncubationCard({required this.topic});

  final Topic topic;

  Future<void> _validate(BuildContext context, WidgetRef ref) async {
    final passage = await showPassagePicker(context);
    if (passage == null || !context.mounted) return;
    final note = await _askText(
      context,
      title: 'Validar con ${passage.label}',
      label: '¿Cómo respalda este pasaje la cosmovisión? (opcional)',
      required: false,
    );
    if (note == null) return;
    try {
      await ref.read(validateTopicProvider)(topic.id, passage, note: note.isEmpty ? null : note);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _refute(BuildContext context, WidgetRef ref) async {
    final reason = await _askText(
      context,
      title: 'Refutar «${topic.name}»',
      label: '¿Qué aprendiste que la contradice?',
      required: true,
    );
    if (reason == null || !context.mounted) return;
    final withPassage = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('¿Quieres anclar la refutación a un pasaje?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Elegir pasaje')),
        ],
      ),
    );
    PassageRef? passage;
    if (withPassage == true && context.mounted) passage = await showPassagePicker(context);
    try {
      await ref.read(refuteTopicProvider)(topic.id, reason: reason, passage: passage);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = context.dimensionColor(topic.dimensionId);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 6, backgroundColor: color),
                const SizedBox(width: 8),
                Expanded(child: Text(topic.name, style: theme.textTheme.titleMedium)),
                Text(Formatters.shortDate(topic.updatedAt), style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(Dimension.byId(topic.dimensionId).name, style: theme.textTheme.labelSmall?.copyWith(color: color)),
            if (topic.note != null) ...[const SizedBox(height: 8), Text(topic.note!)],
            if (topic.validationPassage != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(topic.validationPassage!.label, style: theme.textTheme.labelLarge),
                ],
              ),
            ],
            const SizedBox(height: 8),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: switch (topic.status) {
                TopicStatus.incubacion => [
                  TextButton.icon(
                    onPressed: () => _refute(context, ref),
                    icon: const Icon(Icons.block),
                    label: const Text('Refutar'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _validate(context, ref),
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Validar con pasaje'),
                  ),
                ],
                TopicStatus.refutado => [
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        await ref.read(reopenTopicProvider)(topic.id);
                      } catch (e) {
                        if (context.mounted) showError(context, e);
                      }
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Volver a examinar'),
                  ),
                ],
                _ => const <Widget>[],
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Devuelve null si se cancela; '' si [required] es false y se deja vacío.
Future<String?> _askText(BuildContext context, {required String title, required String label, required bool required}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: required && controller.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  ).whenComplete(controller.dispose);
}

class _NewIncubationDialog extends StatefulWidget {
  const _NewIncubationDialog();

  @override
  State<_NewIncubationDialog> createState() => _NewIncubationDialogState();
}

class _NewIncubationDialogState extends State<_NewIncubationDialog> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  String _dimensionId = Dimension.vidaPractica;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Nueva cosmovisión por validar'),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: Topic.maxNameLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Creencia o conducta',
              hintText: 'Ej. "No prestar dinero a amigos desordenados"',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _dimensionId,
            decoration: const InputDecoration(labelText: 'Dimensión'),
            items: [for (final d in Dimension.all) DropdownMenuItem(value: d.id, child: Text(d.name))],
            onChanged: (v) => setState(() => _dimensionId = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: '¿De dónde viene? (crianza, cultura, experiencia…)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(
        onPressed: _name.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, (_name.text, _dimensionId, _note.text)),
        child: const Text('Guardar'),
      ),
    ],
  );
}
