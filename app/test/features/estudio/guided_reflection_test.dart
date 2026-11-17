import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/estudio/domain/guided_reflection.dart';
import 'package:teleios/shared/domain/catalogs/historical_catalog.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/scripture_links.dart';

void main() {
  group('GuidedReflection', () {
    const full = GuidedReflection(
      answers: {
        'exegesis.resumen': 'Dios crea con su palabra.',
        'exegesis.palabras': 'bara: crear de la nada. También en {Isaías 43:1}.',
        'hermeneutica.original': 'Frente a los mitos paganos.',
        'teologia.dios': 'Ama la obra de sus manos.',
        'aplicacion.cambio': 'Trabajar con excelencia\ncomo para el Señor {Colosenses 3:23}.',
      },
    );

    test('cinco secciones, cada una con una sola pregunta clave', () {
      expect(GuidedReflection.sections.map((s) => s.name), [
        'Exégesis',
        'Hermenéutica',
        'Teología',
        'Homilética',
        'Aplicación',
      ]);
      for (final s in GuidedReflection.sections) {
        expect(s.questions.where((q) => q.key), hasLength(1), reason: s.name);
        expect(s.questions.every((q) => q.id.startsWith('${s.id}.')), isTrue, reason: s.name);
      }
      final ids = GuidedReflection.questions.map((q) => q.id).toList();
      expect(ids.toSet(), hasLength(ids.length), reason: 'ids únicos');
    });

    test('ida y vuelta conserva cada respuesta, incluso con varias líneas', () {
      final parsed = GuidedReflection.parse(full.encode());
      for (final q in GuidedReflection.questions) {
        expect(parsed.answer(q.id), full.answer(q.id), reason: q.id);
      }
      expect(parsed.notes, isEmpty);
    });

    test('obligatorias: la pregunta clave de cada sección salvo Homilética', () {
      expect(full.missing, isEmpty);
      const partial = GuidedReflection(answers: {'exegesis.resumen': 'x', 'exegesis.contexto': 'y'});
      expect(partial.missing.map((q) => q.id), ['hermeneutica.original', 'teologia.dios', 'aplicacion.cambio']);
      expect(partial.answeredIn(GuidedReflection.sections.first), 2);
    });

    test('las reflexiones de la guía anterior (4 preguntas) se reubican', () {
      const legacy =
          '## Observa · ¿Qué dice el texto?\nA\n\n'
          '## Interpreta · ¿Qué significó para sus primeros lectores?\nB\n\n'
          '## Contempla · ¿Qué revela de Dios?\nC\n\n'
          '## Aplica · ¿Qué vas a hacer distinto?\nD';
      final r = GuidedReflection.parse(legacy);
      expect(r.answer('exegesis.resumen'), 'A');
      expect(r.answer('hermeneutica.original'), 'B');
      expect(r.answer('teologia.dios'), 'C');
      expect(r.answer('aplicacion.cambio'), 'D');
      expect(r.missing, isEmpty);
    });

    test('una reflexión libre anterior a la guía queda como notas', () {
      final parsed = GuidedReflection.parse('Este texto me enseña que debemos trabajar con excelencia.');
      expect(parsed.notes, 'Este texto me enseña que debemos trabajar con excelencia.');
      expect(parsed.answeredCount, 0);
    });

    test('pasajes vinculados de todas las secciones, sin repetir', () {
      final linked = full.linkedPassages.map((l) => l.ref.label).toList();
      expect(linked, ['Isaías 43:1', 'Colosenses 3:23']);
    });

    test('cada cita recuerda la sección donde se escribió', () {
      const r = GuidedReflection(
        answers: {
          'exegesis.resumen': '{Juan 15:5} y otra vez {Juan 15:5}',
          'homiletica.idea': 'Permanecer {Juan 15:5}',
        },
        notes: 'Antes: {Salmos 1:3}',
      );
      expect(r.citations.map((c) => (c.ref.label, c.section?.id)), [
        ('Salmos 1:3', null),
        ('Juan 15:5', 'exegesis'),
        ('Juan 15:5', 'homiletica'),
      ]);
      expect(r.linkedPassages, hasLength(2));
    });

    test('el texto plano no incluye encabezados ni citas (para sugerir tópicos)', () {
      expect(full.plainText.contains('¿Qué revela de Dios?'), isFalse);
      expect(full.plainText.contains('Colosenses'), isFalse);
      expect(full.plainText, contains('Ama la obra de sus manos.'));
    });
  });

  group('ScriptureLinks', () {
    test('reconoce citas válidas y deja como texto las que no lo son', () {
      const text = 'Ver {Juan 3:16} y {1 Co 13:4-7}, pero no {una nota}.';
      expect(ScriptureLinks.refs(text).map((l) => l.ref.encode()), ['JOH.3.16', '1CO.13.4-7']);
      final parts = ScriptureLinks.split(text);
      expect(parts.where((p) => p.ref != null).map((p) => p.text), ['Juan 3:16', '1 Corintios 13:4-7']);
      expect(parts.last.text, ', pero no {una nota}.');
    });

    test('el token usa la etiqueta legible y se vuelve a leer igual', () {
      const ref = PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22, verseEnd: 23);
      final token = ScriptureLinks.token(ref);
      expect(token, '{Gálatas 5:22-23}');
      expect(ScriptureLinks.refs(token).single.ref, ref);
    });
  });

  group('épocas', () {
    test('incluye lo anterior a Abraham', () {
      final ids = HistoricalCatalog.periods.map((p) => p.id).toList();
      expect(ids.take(3), ['creacion', 'diluvio_babel', 'patriarcal']);
    });

    test('Génesis se ubica por capítulo', () {
      expect(HistoricalCatalog.periodForChapter('GEN', 1), 'creacion');
      expect(HistoricalCatalog.periodForChapter('GEN', 7), 'diluvio_babel');
      expect(HistoricalCatalog.periodForChapter('GEN', 12), isNull, reason: 'usa la época del libro');
      expect(HistoricalCatalog.periodForChapter('EXO', 1), isNull);
    });
  });
}
