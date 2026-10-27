import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:teleios/features/estudio/data/sqlite_bible_repository.dart';
import 'package:teleios/shared/domain/catalogs/bible_books.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';

void main() {
  late Directory dir;
  late SqliteBibleRepository bible;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('teleios_bible_');
    final file = File('${dir.path}/rv1909.sqlite');
    await file.writeAsBytes(gzip.decode(await File('assets/bible/rv1909.sqlite.gz').readAsBytes()));
    bible = SqliteBibleRepository(sqlite3.open(file.path, mode: OpenMode.readOnly));
  });

  tearDownAll(() async {
    bible.dispose();
    await dir.delete(recursive: true);
  });

  test('todos los libros del catálogo existen en el asset', () async {
    for (final book in BibleBooks.all) {
      expect(await bible.chapterCount(book.code), greaterThan(0), reason: book.name);
    }
    expect(await bible.chapterCount('GEN'), 50);
    expect(await bible.chapterCount('PSA'), 150);
    expect(await bible.chapterCount('REV'), 22);
    expect(await bible.verseCount('PSA', 119), 176);
  });

  test('lee un pasaje con rango', () async {
    final verses = await bible.passage(const PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22, verseEnd: 23));
    expect(verses.map((v) => v.verse), [22, 23]);
    expect(verses.first.text.toLowerCase(), contains('caridad'));
  });

  test('lee Juan 3:16', () async {
    final v = await bible.passage(const PassageRef(bookCode: 'JOH', chapter: 3, verseStart: 16));
    expect(v.single.text, contains('de tal manera amó Dios al mundo'));
  });

  test('búsqueda FTS insensible a tildes, con prefijos y resaltado', () async {
    final hits = await bible.search('tribulacion paciencia');
    expect(hits, isNotEmpty);
    expect(hits.any((h) => h.verse.bookCode == 'ROM' && h.verse.chapter == 5 && h.verse.verse == 3), isTrue);
    expect(hits.first.snippet, contains('['));
  });

  test('consultas vacías o con símbolos no rompen FTS', () async {
    expect(await bible.search(''), isEmpty);
    expect(await bible.search('"*()'), isEmpty);
    expect(await bible.search('amor" OR "odio'), isA<List<Object>>());
    expect(SqliteBibleRepository.toFtsQuery('Él es AMOR'), '"el"* "es"* "amor"*');
  });
}
