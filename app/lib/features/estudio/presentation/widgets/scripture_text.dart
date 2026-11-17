import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/entities/passage_ref.dart';
import '../../../../shared/domain/entities/scripture_links.dart';
import '../estudio_providers.dart';
import '../passage_picker.dart';

/// Controlador que resalta las citas `{Juan 3:16}` mientras se escribe y avisa cuando se teclea `{`.
class ScriptureLinkController extends TextEditingController {
  ScriptureLinkController({super.text});

  /// Se llama (fuera del ciclo de edición) con la posición de la `{` recién escrita.
  void Function(int braceOffset)? onBrace;

  @override
  set value(TextEditingValue newValue) {
    final old = super.value;
    super.value = newValue;
    final cursor = newValue.selection.baseOffset;
    final typedBrace =
        newValue.selection.isCollapsed &&
        cursor > 0 &&
        newValue.text.length == old.text.length + 1 &&
        newValue.text[cursor - 1] == '{' &&
        newValue.text.replaceRange(cursor - 1, cursor, '') == old.text;
    if (typedBrace && onBrace != null) scheduleMicrotask(() => onBrace?.call(cursor - 1));
  }

  /// Inserta la cita reemplazando la `{` escrita en [braceOffset], o en el cursor si no hay llave.
  void insertLink(PassageRef ref, {int? braceOffset}) {
    final t = text;
    final hasBrace = braceOffset != null && braceOffset < t.length && t[braceOffset] == '{';
    final sel = selection;
    final start = hasBrace ? braceOffset : (sel.isValid ? sel.start : t.length);
    final end = hasBrace ? braceOffset + 1 : (sel.isValid ? sel.end : t.length);
    final needsSpace = end >= t.length || !RegExp(r'[\s.,;:)!?]').hasMatch(t[end]);
    final insert = '${ScriptureLinks.token(ref)}${needsSpace ? ' ' : ''}';
    value = TextEditingValue(
      text: t.replaceRange(start, end, insert),
      selection: TextSelection.collapsed(offset: start + insert.length),
    );
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final links = ScriptureLinks.refs(text);
    if (links.isEmpty) return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    final linkStyle = TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600);
    final children = <TextSpan>[];
    var last = 0;
    for (final l in links) {
      if (l.start > last) children.add(TextSpan(text: text.substring(last, l.start)));
      children.add(TextSpan(text: text.substring(l.start, l.end), style: linkStyle));
      last = l.end;
    }
    if (last < text.length) children.add(TextSpan(text: text.substring(last)));
    return TextSpan(style: style, children: children);
  }
}

/// Abre el selector de pasaje y vincula el resultado en [controller].
Future<void> pickAndLinkPassage(BuildContext context, ScriptureLinkController controller, {int? braceOffset}) async {
  final ref = await showPassagePicker(context);
  if (ref != null) controller.insertLink(ref, braceOffset: braceOffset);
}

/// Texto de solo lectura donde cada cita `{…}` se puede tocar para leer el pasaje.
class ScriptureLinkedText extends StatefulWidget {
  const ScriptureLinkedText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<ScriptureLinkedText> createState() => _ScriptureLinkedTextState();
}

class _ScriptureLinkedTextState extends State<ScriptureLinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final theme = Theme.of(context);
    final linkStyle = TextStyle(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary.withValues(alpha: 0.4),
    );
    final children = <TextSpan>[];
    for (final part in ScriptureLinks.split(widget.text)) {
      final ref = part.ref;
      if (ref == null) {
        children.add(TextSpan(text: part.text));
        continue;
      }
      final tap = TapGestureRecognizer()..onTap = () => showPassageSheet(context, ref);
      _recognizers.add(tap);
      children.add(TextSpan(text: part.text, style: linkStyle, recognizer: tap));
    }
    return Text.rich(TextSpan(style: widget.style, children: children));
  }
}

/// Hoja inferior con el texto de un pasaje citado.
Future<void> showPassageSheet(BuildContext context, PassageRef passage) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _PassageSheet(passage: passage),
);

class _PassageSheet extends ConsumerWidget {
  const _PassageSheet({required this.passage});

  final PassageRef passage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = ref.watch(passageTextProvider(passage));
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(passage.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            verses.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const Text('No se pudo cargar el pasaje.'),
              data: (list) => Text(
                list.where((v) => v.text.isNotEmpty).map((v) => '${v.verse} ${v.text}').join(' '),
                style: context.scripture.body.copyWith(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
