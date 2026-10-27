import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/shared/domain/catalogs/bible_books.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';

void main() {
  test('catálogo con 66 libros y códigos únicos', () {
    expect(BibleBooks.all, hasLength(66));
    expect(BibleBooks.all.map((b) => b.code).toSet(), hasLength(66));
    expect(BibleBooks.all.where((b) => b.testament == Testament.nuevo), hasLength(27));
  });

  group('label', () {
    test('rango, versículo y capítulo', () {
      expect(const PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22, verseEnd: 23).label, 'Gálatas 5:22-23');
      expect(const PassageRef(bookCode: 'JOH', chapter: 3, verseStart: 16).label, 'Juan 3:16');
      expect(const PassageRef(bookCode: 'ROM', chapter: 8).label, 'Romanos 8');
    });
  });

  group('encode/decode', () {
    for (final ref in const [
      PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22, verseEnd: 23),
      PassageRef(bookCode: '1CO', chapter: 13, verseStart: 4),
      PassageRef(bookCode: 'PSA', chapter: 119),
    ]) {
      test('ida y vuelta ${ref.encode()}', () => expect(PassageRef.decode(ref.encode()), ref));
    }
  });

  group('tryParse', () {
    test('abreviaturas, tildes y separadores', () {
      expect(
        PassageRef.tryParse('gal 5:22-23'),
        const PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22, verseEnd: 23),
      );
      expect(PassageRef.tryParse('Gá 5:22'), const PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22));
      expect(PassageRef.tryParse('1 Co 13:4'), const PassageRef(bookCode: '1CO', chapter: 13, verseStart: 4));
      expect(
        PassageRef.tryParse('1co 13.4-7'),
        const PassageRef(bookCode: '1CO', chapter: 13, verseStart: 4, verseEnd: 7),
      );
      expect(PassageRef.tryParse('Romanos 8'), const PassageRef(bookCode: 'ROM', chapter: 8));
      expect(PassageRef.tryParse('genesis 1:1'), const PassageRef(bookCode: 'GEN', chapter: 1, verseStart: 1));
      expect(PassageRef.tryParse('filip 4:6'), const PassageRef(bookCode: 'PHI', chapter: 4, verseStart: 6));
    });

    test('rechaza entradas ambiguas o inválidas', () {
      expect(PassageRef.tryParse('paciencia'), isNull);
      expect(PassageRef.tryParse('Jn 3:16-10'), isNull);
      // "J" es prefijo de varios libros (Josué, Jueces, Job, Juan...).
      expect(PassageRef.tryParse('J 3:16'), isNull);
    });
  });
}
