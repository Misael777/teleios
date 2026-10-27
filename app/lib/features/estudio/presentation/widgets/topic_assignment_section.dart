import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../../../infrastructure/ai/topic_suggester.dart';
import '../../../../shared/domain/entities/dimension.dart';
import '../../../../shared/domain/entities/topic.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../domain/devotional.dart';

/// Tópicos del devocional agrupados por las 4 dimensiones.
///
/// El usuario tiene el control: acepta sugerencias (✨), las descarta, mueve
/// tópicos entre dimensiones o crea los suyos.
class TopicAssignmentSection extends StatelessWidget {
  const TopicAssignmentSection({
    super.key,
    required this.selected,
    required this.suggestions,
    required this.userTopics,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
    required this.onAccept,
    required this.onDismiss,
  });

  final List<TopicDraft> selected;
  final List<TopicSuggestion> suggestions;
  final List<Topic> userTopics;
  final ValueChanged<TopicDraft> onAdd;
  final ValueChanged<TopicDraft> onRemove;
  final void Function(TopicDraft draft, String dimensionId) onMove;
  final ValueChanged<TopicSuggestion> onAccept;
  final ValueChanged<TopicSuggestion> onDismiss;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final dimension in Dimension.all)
        _DimensionRow(
          dimension: dimension,
          selected: selected.where((t) => t.dimensionId == dimension.id).toList(),
          suggestions: suggestions.where((s) => s.dimensionId == dimension.id).toList(),
          parent: this,
        ),
    ],
  );
}

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({
    required this.dimension,
    required this.selected,
    required this.suggestions,
    required this.parent,
  });

  final Dimension dimension;
  final List<TopicDraft> selected;
  final List<TopicSuggestion> suggestions;
  final TopicAssignmentSection parent;

  Future<void> _showMoveMenu(BuildContext context, TopicDraft draft) async {
    final target = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text('Mover «${draft.name}» a…')),
            for (final d in Dimension.all.where((d) => d.id != draft.dimensionId))
              ListTile(
                leading: CircleAvatar(radius: 8, backgroundColor: context.dimensionColor(d.id)),
                title: Text(d.name),
                onTap: () => Navigator.pop(context, d.id),
              ),
          ],
        ),
      ),
    );
    if (target != null) parent.onMove(draft, target);
  }

  Future<void> _add(BuildContext context) async {
    final draft = await showDialog<TopicDraft>(
      context: context,
      builder: (_) => _AddTopicDialog(dimension: dimension, userTopics: parent.userTopics),
    );
    if (draft != null) parent.onAdd(draft);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = context.dimensionColor(dimension.id);
    final statusById = {for (final t in parent.userTopics) t.id: t.status};
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 6, backgroundColor: color),
              const SizedBox(width: 8),
              Expanded(child: Text(dimension.name, style: theme.textTheme.titleSmall)),
              IconButton(
                tooltip: 'Añadir tópico en ${dimension.name}',
                icon: const Icon(Icons.add),
                onPressed: () => _add(context),
              ),
            ],
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final draft in selected)
                DimensionChip(
                  key: ValueKey('sel-${draft.dimensionId}-${draft.name}'),
                  label: draft.name,
                  dimensionId: draft.dimensionId,
                  status: statusById[draft.existingId] ?? TopicStatus.validado,
                  onDeleted: () => parent.onRemove(draft),
                  onPressed: () => _showMoveMenu(context, draft),
                ),
              for (final s in suggestions)
                Tooltip(
                  message: 'Sugerido por: ${s.reasons.join(', ')}',
                  child: InputChip(
                    key: ValueKey('sug-${s.key}'),
                    avatar: Icon(Icons.auto_awesome, size: 16, color: color),
                    label: Text(s.name),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    backgroundColor: theme.colorScheme.surface,
                    onPressed: () => parent.onAccept(s),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteButtonTooltipMessage: 'Descartar sugerencia',
                    onDeleted: () => parent.onDismiss(s),
                  ),
                ),
              if (selected.isEmpty && suggestions.isEmpty)
                Text('Sin tópicos', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddTopicDialog extends StatefulWidget {
  const _AddTopicDialog({required this.dimension, required this.userTopics});

  final Dimension dimension;
  final List<Topic> userTopics;

  @override
  State<_AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<_AddTopicDialog> {
  String _text = '';

  List<Topic> get _options =>
      widget.userTopics.where((t) => t.dimensionId == widget.dimension.id && t.status != TopicStatus.refutado).toList();

  void _submit([Topic? existing]) {
    final name = existing?.name ?? _text;
    try {
      final clean = Topic.cleanName(name);
      final match =
          existing ?? _options.where((t) => TextNormalizer.key(t.name) == TextNormalizer.key(clean)).firstOrNull;
      Navigator.pop(
        context,
        TopicDraft(name: match?.name ?? clean, dimensionId: widget.dimension.id, existingId: match?.id),
      );
    } catch (e) {
      showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.dimension.name),
    content: SizedBox(
      width: 400,
      child: Autocomplete<Topic>(
        displayStringForOption: (t) => t.name,
        optionsBuilder: (value) {
          final q = TextNormalizer.key(value.text);
          if (q.isEmpty) return _options;
          return _options.where((t) => TextNormalizer.key(t.name).contains(q));
        },
        onSelected: _submit,
        fieldViewBuilder: (context, controller, focus, onSubmit) => TextField(
          controller: controller,
          focusNode: focus,
          autofocus: true,
          maxLength: Topic.maxNameLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Tópico', helperText: 'Elige uno tuyo o escribe uno nuevo'),
          onChanged: (v) => _text = v,
          onSubmitted: (_) => _submit(),
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(onPressed: _submit, child: const Text('Añadir')),
    ],
  );
}
