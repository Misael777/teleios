import '../../../core/utils/text_normalizer.dart';
import '../catalogs/bible_books.dart';

/// Referencia bíblica: libro + capítulo + rango opcional de versículos.
class PassageRef {
  const PassageRef({required this.bookCode, required this.chapter, this.verseStart, this.verseEnd})
    : assert(verseEnd == null || verseStart != null);

  final String bookCode;
  final int chapter;
  final int? verseStart;
  final int? verseEnd;

  BibleBook get book => BibleBooks.byCode(bookCode);

  bool get isWholeChapter => verseStart == null;

  /// "Gálatas 5:22-23"
  String get label {
    final base = '${book.name} $chapter';
    if (verseStart == null) return base;
    if (verseEnd == null || verseEnd == verseStart) return '$base:$verseStart';
    return '$base:$verseStart-$verseEnd';
  }

  /// Forma compacta para persistir: "GAL.5.22-23", "GAL.5.22", "GAL.5".
  String encode() {
    final base = '$bookCode.$chapter';
    if (verseStart == null) return base;
    if (verseEnd == null || verseEnd == verseStart) return '$base.$verseStart';
    return '$base.$verseStart-$verseEnd';
  }

  static PassageRef decode(String value) {
    final parts = value.split('.');
    if (parts.length < 2) throw FormatException('Referencia inválida: $value');
    final chapter = int.parse(parts[1]);
    if (parts.length == 2) return PassageRef(bookCode: parts[0], chapter: chapter);
    final range = parts[2].split('-').map(int.parse).toList();
    return PassageRef(
      bookCode: parts[0],
      chapter: chapter,
      verseStart: range.first,
      verseEnd: range.length > 1 ? range[1] : null,
    );
  }

  /// Interpreta texto libre: "gal 5:22-23", "Romanos 8", "1 Co 13:4", "Juan 3.16".
  static PassageRef? tryParse(String input) {
    final match = RegExp(r'^\s*(.+?)\s+(\d+)(?:\s*[:.]\s*(\d+)(?:\s*-\s*(\d+))?)?\s*$').firstMatch(input);
    if (match == null) return null;
    final book = BibleBooks.find(TextNormalizer.normalize(match.group(1)!));
    if (book == null) return null;
    final start = match.group(3) == null ? null : int.parse(match.group(3)!);
    final end = match.group(4) == null ? null : int.parse(match.group(4)!);
    if (end != null && start != null && end < start) return null;
    return PassageRef(bookCode: book.code, chapter: int.parse(match.group(2)!), verseStart: start, verseEnd: end);
  }

  @override
  bool operator ==(Object other) =>
      other is PassageRef &&
      other.bookCode == bookCode &&
      other.chapter == chapter &&
      other.verseStart == verseStart &&
      other.verseEnd == verseEnd;

  @override
  int get hashCode => Object.hash(bookCode, chapter, verseStart, verseEnd);

  @override
  String toString() => encode();
}
