/// Reflexión guiada en cinco secciones, cada una con su batería de preguntas:
/// exégesis → hermenéutica → teología → homilética → aplicación.
///
/// Se guarda en la columna `content` como texto legible con un encabezado por pregunta
/// (`## Sección · Pregunta`), así el respaldo, la exportación y las búsquedas siguen funcionando.
/// **No cambies el texto de una pregunta publicada**: es la clave con la que se lee lo guardado.
/// Si hace falta, agrega el encabezado viejo a [_legacyHeadings].
library;

import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/scripture_links.dart';

/// Un versículo citado y la sección de la reflexión donde se citó (`null`: notas libres).
typedef SectionCitation = ({PassageRef ref, ReflectionSection? section});

class ReflectionQuestion {
  const ReflectionQuestion(this.id, this.text, this.hint, {this.key = false});

  final String id;
  final String text;
  final String hint;

  /// Pregunta clave de la sección: obligatoria si la sección lo es.
  final bool key;
}

class ReflectionSection {
  const ReflectionSection(this.id, this.name, this.purpose, this.questions, {this.optional = false});

  final String id;
  final String name;

  /// Qué busca la sección, en una línea.
  final String purpose;
  final List<ReflectionQuestion> questions;
  final bool optional;

  ReflectionQuestion get keyQuestion => questions.firstWhere((q) => q.key);
}

class GuidedReflection {
  const GuidedReflection({this.answers = const {}, this.notes = ''});

  static const sections = <ReflectionSection>[
    ReflectionSection('exegesis', 'Exégesis', 'Lo que el texto dice. Observa antes de interpretar.', [
      ReflectionQuestion(
        'exegesis.resumen',
        '¿Qué dice el texto? Resúmelo con tus palabras.',
        'Quién habla, a quién, qué sucede. Todavía sin interpretar.',
        key: true,
      ),
      ReflectionQuestion(
        'exegesis.autor',
        '¿Quién escribe, a quién y en qué circunstancia?',
        'Usa el contexto histórico: época, lugar, situación de los destinatarios.',
      ),
      ReflectionQuestion(
        'exegesis.contexto',
        '¿Qué dicen los versículos de antes y de después?',
        'Un texto fuera de contexto es un pretexto.',
      ),
      ReflectionQuestion(
        'exegesis.palabras',
        '¿Qué palabras clave o repetidas aparecen? ¿Qué significan en el original?',
        'Anota la palabra en griego o hebreo si la conoces. Escribe { para citar dónde más aparece.',
      ),
      ReflectionQuestion(
        'exegesis.estructura',
        '¿Qué conectores, contrastes, mandatos o promesas encuentras?',
        '«Pero», «por tanto», «para que», «como»… marcan el hilo del argumento.',
      ),
    ]),
    ReflectionSection('hermeneutica', 'Hermenéutica', 'Lo que el texto significa, entonces y ahora.', [
      ReflectionQuestion(
        'hermeneutica.original',
        '¿Qué significó para sus primeros lectores?',
        'Piensa en su época, su cultura y su situación.',
        key: true,
      ),
      ReflectionQuestion(
        'hermeneutica.genero',
        '¿Qué género literario es y cómo cambia la forma de leerlo?',
        'Narrativa, ley, poesía, sabiduría, profecía, evangelio, epístola o apocalíptica.',
      ),
      ReflectionQuestion(
        'hermeneutica.escritura',
        '¿Qué otros pasajes lo aclaran o lo equilibran?',
        'La Escritura interpreta a la Escritura. Escribe { para vincularlos.',
      ),
      ReflectionQuestion(
        'hermeneutica.principio',
        '¿Cuál es el principio atemporal?',
        'Una verdad válida para ellos y para nosotros.',
      ),
      ReflectionQuestion(
        'hermeneutica.cristo',
        '¿Cómo apunta a Cristo y al evangelio?',
        'Promesa, figura, cumplimiento o necesidad de un Salvador.',
      ),
    ]),
    ReflectionSection('teologia', 'Teología', 'Lo que el texto revela de Dios y del ser humano.', [
      ReflectionQuestion(
        'teologia.dios',
        '¿Qué revela de Dios?',
        'Su carácter, sus promesas, su forma de obrar.',
        key: true,
      ),
      ReflectionQuestion(
        'teologia.humano',
        '¿Qué revela del ser humano?',
        'Su condición, su necesidad, ejemplos a seguir o a evitar.',
      ),
      ReflectionQuestion(
        'teologia.promesa',
        '¿Hay una promesa que creer o un mandato que obedecer?',
        '¿Es para todos los creyentes o para alguien en particular?',
      ),
    ]),
    ReflectionSection('homiletica', 'Homilética', 'Cómo lo enseñarías a otros.', optional: true, [
      ReflectionQuestion(
        'homiletica.idea',
        'Idea central: resume el mensaje en una sola oración.',
        'Si no cabe en una oración, aún no está claro.',
        key: true,
      ),
      ReflectionQuestion(
        'homiletica.bosquejo',
        'Bosquejo: ¿qué 2 a 4 puntos salen del texto?',
        'Cada punto debe nacer del pasaje, no imponerse sobre él.',
      ),
      ReflectionQuestion(
        'homiletica.ilustracion',
        '¿Qué ilustración o ejemplo lo haría claro?',
        'Una historia, una imagen o una experiencia propia.',
      ),
      ReflectionQuestion(
        'homiletica.audiencia',
        '¿A quién se lo enseñarías y qué necesita escuchar?',
        'Tu familia, tu grupo, un amigo…',
      ),
    ]),
    ReflectionSection('aplicacion', 'Aplicación', 'Lo que vas a vivir.', [
      ReflectionQuestion(
        'aplicacion.cambio',
        '¿Qué vas a hacer distinto?',
        'Algo concreto para esta semana: con quién, cuándo y cómo.',
        key: true,
      ),
      ReflectionQuestion(
        'aplicacion.confesion',
        '¿Hay algo que confesar, abandonar o agradecer?',
        'Sé honesto: nadie más lo leerá.',
      ),
      ReflectionQuestion(
        'aplicacion.oracion',
        'Escribe una oración breve a partir del texto.',
        'Habla con Dios con sus propias palabras.',
      ),
    ]),
  ];

  static Iterable<ReflectionQuestion> get questions => sections.expand((s) => s.questions);

  static ReflectionSection sectionOf(String questionId) =>
      sections.firstWhere((s) => questionId.startsWith('${s.id}.'));

  static String headingOf(ReflectionQuestion q) => '## ${sectionOf(q.id).name} · ${q.text}';

  /// Encabezados de la primera versión de la guía (4 preguntas) → pregunta equivalente.
  static const _legacyHeadings = {
    '## Observa · ¿Qué dice el texto?': 'exegesis.resumen',
    '## Interpreta · ¿Qué significó para sus primeros lectores?': 'hermeneutica.original',
    '## Contempla · ¿Qué revela de Dios?': 'teologia.dios',
    '## Aplica · ¿Qué vas a hacer distinto?': 'aplicacion.cambio',
  };

  /// Respuestas por `ReflectionQuestion.id`.
  final Map<String, String> answers;

  /// Texto libre que no pertenece a ninguna pregunta (p. ej. reflexiones escritas antes de la guía).
  final String notes;

  String answer(String id) => (answers[id] ?? '').trim();

  bool answered(String id) => answer(id).isNotEmpty;

  /// Preguntas clave sin responder de las secciones obligatorias.
  List<ReflectionQuestion> get missing => [
    for (final s in sections)
      if (!s.optional && !answered(s.keyQuestion.id)) s.keyQuestion,
  ];

  int answeredIn(ReflectionSection s) => s.questions.where((q) => answered(q.id)).length;

  int get answeredCount => questions.where((q) => answered(q.id)).length;

  /// Cada cita con la sección donde se escribió (`null`: notas libres). Una cita repetida
  /// dentro de la misma sección cuenta una sola vez; en secciones distintas, una vez por sección.
  List<SectionCitation> get citations {
    final seen = <String>{};
    return [
      for (final link in ScriptureLinks.refs(notes))
        if (seen.add('.${link.ref.encode()}')) (ref: link.ref, section: null),
      for (final s in sections)
        for (final q in s.questions)
          for (final link in ScriptureLinks.refs(answer(q.id)))
            if (seen.add('${s.id}.${link.ref.encode()}')) (ref: link.ref, section: s),
    ];
  }

  /// Versículos citados con `{…}` en toda la reflexión, sin repetir y en orden de aparición.
  List<PassageRefLink> get linkedPassages {
    final seen = <String>{};
    return [
      for (final text in [notes, for (final q in questions) answer(q.id)])
        for (final link in ScriptureLinks.refs(text))
          if (seen.add(link.ref.encode())) link,
    ];
  }

  /// Texto para sugerir tópicos y para vistas previas: solo lo escrito, sin encabezados ni citas.
  String get plainText => [
    notes,
    for (final q in questions) answer(q.id),
  ].map(ScriptureLinks.strip).map((s) => s.trim()).where((s) => s.isNotEmpty).join('\n');

  String encode() => [
    if (notes.trim().isNotEmpty) notes.trim(),
    for (final q in questions)
      if (answered(q.id)) '${headingOf(q)}\n${answer(q.id)}',
  ].join('\n\n');

  static GuidedReflection parse(String content) {
    final byHeading = {for (final q in questions) headingOf(q): q.id, ..._legacyHeadings};
    final answers = <String, List<String>>{};
    final notes = <String>[];
    String? current;
    for (final line in content.split('\n')) {
      final id = byHeading[line.trim()];
      if (id != null) {
        current = id;
        answers.putIfAbsent(id, () => []);
      } else {
        (current == null ? notes : answers[current]!).add(line);
      }
    }
    return GuidedReflection(
      answers: {for (final e in answers.entries) e.key: e.value.join('\n').trim()},
      notes: notes.join('\n').trim(),
    );
  }
}
