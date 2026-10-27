import 'package:sqlite3/sqlite3.dart';

import '../../../core/utils/text_normalizer.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../domain/repositories.dart';

/// Lee la Biblia RV1909 desde un SQLite de solo lectura con índice FTS5.
///
/// Las consultas son de milisegundos (31k versículos), por eso se ejecutan de forma
/// síncrona envueltas en `Future`.
class SqliteBibleRepository implements BibleRepository {
  SqliteBibleRepository(this._db);

  final Database _db;

  @override
  String get translation => 'RV1909';

  @override
  Future<int> chapterCount(String bookCode) async =>
      _db.select('SELECT MAX(chapter) AS n FROM verses WHERE book = ?', [bookCode]).first['n'] as int? ?? 0;

  @override
  Future<int> verseCount(String bookCode, int chapter) async =>
      _db.select('SELECT MAX(verse) AS n FROM verses WHERE book = ? AND chapter = ?', [bookCode, chapter]).first['n']
          as int? ??
      0;

  @override
  Future<List<BibleVerse>> chapter(String bookCode, int chapter) async => _db
      .select('SELECT book, chapter, verse, text FROM verses WHERE book = ? AND chapter = ? ORDER BY verse', [
        bookCode,
        chapter,
      ])
      .map(_toVerse)
      .toList();

  @override
  Future<List<BibleVerse>> passage(PassageRef ref) async {
    if (ref.verseStart == null) return chapter(ref.bookCode, ref.chapter);
    return _db
        .select(
          'SELECT book, chapter, verse, text FROM verses '
          'WHERE book = ? AND chapter = ? AND verse BETWEEN ? AND ? ORDER BY verse',
          [ref.bookCode, ref.chapter, ref.verseStart, ref.verseEnd ?? ref.verseStart],
        )
        .map(_toVerse)
        .toList();
  }

  @override
  Future<List<BibleSearchHit>> search(String query, {int limit = 50}) async {
    final match = toFtsQuery(query);
    if (match == null) return const [];
    return _db
        .select(
          'SELECT v.book, v.chapter, v.verse, v.text, '
          "snippet(verses_fts, 0, '[', ']', '…', 14) AS snip "
          'FROM verses_fts JOIN verses v ON v.id = verses_fts.rowid '
          'WHERE verses_fts MATCH ? ORDER BY rank LIMIT ?',
          [match, limit],
        )
        .map((r) => BibleSearchHit(_toVerse(r), r['snip'] as String))
        .toList();
  }

  /// Convierte texto libre en una consulta FTS5 segura: cada palabra como prefijo, todas requeridas.
  static String? toFtsQuery(String input) {
    final terms = TextNormalizer.normalize(
      input,
    ).split(RegExp(r'[^a-z0-9]+')).where((t) => t.length > 1).take(8).map((t) => '"$t"*').toList();
    return terms.isEmpty ? null : terms.join(' ');
  }

  static BibleVerse _toVerse(Row r) =>
      BibleVerse(r['book'] as String, r['chapter'] as int, r['verse'] as int, r['text'] as String);

  void dispose() => _db.close();
}
