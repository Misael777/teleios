import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/domain/guided_reflection.dart';
import 'package:teleios/features/estudio/domain/passage_network.dart';
import 'package:teleios/shared/domain/catalogs/historical_catalog.dart';
import 'package:teleios/shared/domain/entities/historical_context.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';

DevotionalEntry entry(String id, PassageRef passage, Map<String, String> answers) => DevotionalEntry(
  id: id,
  date: DateTime(2026),
  passage: passage,
  content: GuidedReflection(answers: answers).encode(),
  context: const HistoricalContext(),
  topics: const [],
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  const gal = PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22);
  const jhn = PassageRef(bookCode: 'JOH', chapter: 15, verseStart: 1);

  final entries = [
    entry('a', gal, {
      'exegesis.resumen': 'Fruto {Juan 15:5}',
      'homiletica.idea': 'Permanecer {Juan 15:5} {Salmos 1:3}',
    }),
    entry('b', jhn, {'aplicacion.cambio': 'Orar {Juan 15:5}'}),
    entry('c', gal, {'exegesis.resumen': 'Sin vínculos'}),
  ];

  test('cada hilo lleva el devocional de origen y la sección donde se citó', () {
    final network = PassageNetwork.build(entries);
    expect(network.links.map((l) => (l.source.id, l.target.label, l.sectionId)), [
      ('a', 'Juan 15:5', 'exegesis'),
      ('a', 'Juan 15:5', 'homiletica'),
      ('a', 'Salmos 1:3', 'homiletica'),
      ('b', 'Juan 15:5', 'aplicacion'),
    ]);
    expect(network.countBySection, {'exegesis': 1, 'homiletica': 2, 'aplicacion': 1});
    expect(network.linksFrom('c'), isEmpty);
  });

  test('los pasajes se ordenan por cuántas veces se citaron', () {
    final network = PassageNetwork.build(entries);
    final jn = network.passages.first;
    expect(jn.ref.label, 'Juan 15:5');
    expect(jn.links, hasLength(3));
    expect(jn.sourceIds, {'a', 'b'});
    expect(network.passage('PSA.1.3')!.dominantSectionId, 'homiletica');
  });

  test('cada pasaje se ubica en la época de su libro', () {
    int yearOf(String code, int chapter) => PassageNetwork.yearOf(PassageRef(bookCode: code, chapter: chapter));
    HistoricalPeriodMatcher.check(yearOf('JOH', 15), 'vida_jesus');
    HistoricalPeriodMatcher.check(yearOf('GAL', 5), 'iglesia_primitiva');
    HistoricalPeriodMatcher.check(yearOf('GEN', 3), 'creacion');
    // Libros de la misma época, en orden canónico.
    expect(yearOf('MAT', 1), lessThan(yearOf('JOH', 1)));
  });

  test('reconoce cuando el versículo vinculado está en un capítulo que también estudiaste', () {
    expect(PassageNetwork.studying(entries, jhn).map((e) => e.id), ['b']);
  });
}

abstract final class HistoricalPeriodMatcher {
  static void check(int year, String periodId) {
    final p = HistoricalCatalog.period(periodId)!;
    expect(year, inInclusiveRange(p.startYear, p.endYear - 1), reason: periodId);
  }
}
