import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../estudio/domain/devotional.dart';
import '../../estudio/presentation/passage_picker.dart';
import '../domain/belief.dart';
import '../domain/coherence_usecases.dart';
import 'coherence_providers.dart';

/// Crea o edita una creencia. Desde un devocional, propone el principio atemporal como texto inicial.
Future<Belief?> showBeliefEditor(BuildContext context, {Belief? belief, DevotionalEntry? from}) =>
    showModalBottomSheet<Belief>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BeliefEditor(belief: belief, from: from),
    );

class _BeliefEditor extends ConsumerStatefulWidget {
  const _BeliefEditor({this.belief, this.from});

  final Belief? belief;
  final DevotionalEntry? from;

  @override
  ConsumerState<_BeliefEditor> createState() => _BeliefEditorState();
}

class _BeliefEditorState extends ConsumerState<_BeliefEditor> {
  late final _text = TextEditingController(
    text: widget.belief?.proposition ?? (widget.from == null ? '' : proposeFromDevotional(widget.from!)),
  );
  late PassageRef? _base = widget.belief?.basePassage ?? widget.from?.passage;
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final previous = widget.belief;
      final saved = await ref.read(saveBeliefProvider)(
        proposition: _text.text,
        origin: widget.from != null ? BeliefOrigin.devocional : BeliefOrigin.vida,
        status: previous?.status ?? BeliefStatus.incubacion,
        devotionalId: widget.from?.id,
        dimensionId: previous?.dimensionId,
        topicIds: previous == null
            ? [for (final t in widget.from?.topics ?? const <Topic>[]) t.id]
            : await ref.read(coherenceRepositoryProvider).topicsOf(previous.id),
        previous: previous,
        note: previous?.note,
        basePassage: _base,
      );
      // La huella canónica arranca con las citas y las referencias cruzadas del pasaje base.
      if (previous == null || previous.basePassage != _base) {
        await ref.read(importCanonicalEvidenceProvider)(saved);
      }
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      if (mounted) showError(context, e);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.belief == null ? 'Nueva creencia' : 'Editar creencia', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Escríbela como una frase que guía lo que haces: "Dios provee, por eso puedo dar aunque falte".',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('belief-proposition'),
            controller: _text,
            maxLength: 280,
            minLines: 2,
            maxLines: 5,
            autofocus: widget.from == null,
            decoration: const InputDecoration(labelText: 'Creencia', border: OutlineInputBorder()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.anchor),
            title: Text(_base?.label ?? 'Sin pasaje base'),
            subtitle: const Text('Ancla de la huella canónica: de aquí salen las referencias cruzadas'),
            trailing: TextButton(
              onPressed: () async {
                final p = await showPassagePicker(context, initial: _base);
                if (p != null) setState(() => _base = p);
              },
              child: const Text('Elegir'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('save-belief'),
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Guardando…' : 'Guardar'),
          ),
        ],
      ),
    );
  }
}
