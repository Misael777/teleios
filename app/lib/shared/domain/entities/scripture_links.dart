import 'passage_ref.dart';

/// Una cita `{Romanos 8:28}` dentro de un texto: posición del token completo (llaves incluidas).
typedef PassageRefLink = ({PassageRef ref, int start, int end});

/// Versículos vinculados en texto libre escribiendo la referencia entre llaves: `{Juan 3:16}`.
///
/// Se guardan como texto legible (la etiqueta del pasaje) para que la exportación y el respaldo
/// sigan siendo comprensibles sin la app. Un `{…}` que no es una referencia válida queda como texto.
abstract final class ScriptureLinks {
  static final _token = RegExp(r'\{([^{}\n]{2,60})\}');

  static String token(PassageRef ref) => '{${ref.label}}';

  static List<PassageRefLink> refs(String text) => [
    for (final m in _token.allMatches(text))
      if (PassageRef.tryParse(m.group(1)!) case final ref?) (ref: ref, start: m.start, end: m.end),
  ];

  /// Trozos del texto en orden: texto plano (`ref == null`) o cita.
  static List<({String text, PassageRef? ref})> split(String text) {
    final parts = <({String text, PassageRef? ref})>[];
    var last = 0;
    for (final link in refs(text)) {
      if (link.start > last) parts.add((text: text.substring(last, link.start), ref: null));
      parts.add((text: link.ref.label, ref: link.ref));
      last = link.end;
    }
    if (last < text.length) parts.add((text: text.substring(last), ref: null));
    return parts;
  }

  /// El texto sin las citas (para sugerir tópicos sin que los nombres de libros interfieran).
  static String strip(String text) =>
      text.replaceAllMapped(_token, (m) => PassageRef.tryParse(m.group(1)!) == null ? m.group(0)! : '');
}
