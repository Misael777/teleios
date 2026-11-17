import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/praxis_entry.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../bitacora_providers.dart';

/// Emociones primarias como chips; al tocar una se despliegan sus secundarias.
class EmotionPicker extends ConsumerStatefulWidget {
  const EmotionPicker({super.key, required this.selected, required this.onChanged});

  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  ConsumerState<EmotionPicker> createState() => _EmotionPickerState();
}

class _EmotionPickerState extends ConsumerState<EmotionPicker> {
  String? _expanded;

  void _toggle(String id) {
    final next = {...widget.selected};
    next.contains(id) ? next.remove(id) : next.add(id);
    widget.onChanged(next);
  }

  Future<void> _addOwn(List<CatalogEntry> primaries) async {
    // Sin TextEditingController: destruirlo al volver de showDialog rompe el árbol mientras
    // el diálogo aún anima su salida (crash "_dependents.isEmpty" con el teclado abierto).
    var name = '';
    String? parent = _expanded;
    final result = await showDialog<(String, String?)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva emoción'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('new-emotion-name'),
                autofocus: true,
                onChanged: (v) => name = v,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: parent,
                decoration: const InputDecoration(labelText: 'Familia (opcional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('— Primaria —')),
                  for (final p in primaries) DropdownMenuItem(value: p.id, child: Text(p.name)),
                ],
                onChanged: (v) => setState(() => parent = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, (name, parent)), child: const Text('Agregar')),
          ],
        ),
      ),
    );
    if (result == null || result.$1.trim().isEmpty) return;
    try {
      final emotion = await ref.read(praxisCatalogProvider).addEmotion(result.$1, parentId: result.$2);
      _toggle(emotion.id);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(emotionsProvider).value ?? const <CatalogEntry>[];
    final primaries = all.where((e) => e.parentId == null).toList();
    final theme = Theme.of(context);
    final byParent = <String, List<CatalogEntry>>{};
    for (final e in all.where((e) => e.parentId != null)) {
      byParent.putIfAbsent(e.parentId!, () => []).add(e);
    }
    final selectedNames = [
      for (final e in all)
        if (widget.selected.contains(e.id)) e,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final p in primaries)
              FilterChip(
                label: Text(p.name),
                selected: widget.selected.contains(p.id),
                onSelected: (_) {
                  _toggle(p.id);
                  setState(() => _expanded = p.id);
                },
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: const Text('Otra'),
              onPressed: () => _addOwn(primaries),
            ),
          ],
        ),
        if (_expanded != null && (byParent[_expanded] ?? const []).isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('Más precisa:', style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in byParent[_expanded]!)
                FilterChip(
                  label: Text(s.name),
                  selected: widget.selected.contains(s.id),
                  onSelected: (_) => _toggle(s.id),
                ),
            ],
          ),
        ],
        if (selectedNames.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Sentí: ${selectedNames.map((e) => e.name.toLowerCase()).join(', ')}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
          ),
        ],
      ],
    );
  }
}
