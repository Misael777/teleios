import 'package:teleios/core/security/app_lock.dart';
import 'package:teleios/features/estudio/domain/repositories.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';

class FakeAuthenticator implements DeviceAuthenticator {
  FakeAuthenticator({this.supported = false, this.succeed = true});

  final bool supported;
  final bool succeed;
  int calls = 0;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> authenticate(String reason) async {
    calls++;
    return succeed;
  }
}

/// Biblia mínima en memoria para tests de UI.
class FakeBible implements BibleRepository {
  static const _verses = {
    ('GAL', 5): [
      'Mas el fruto del Espíritu es: caridad, gozo, paz, tolerancia, benignidad, bondad, fe,',
      'Mansedumbre, templanza: contra tales cosas no hay ley.',
    ],
  };

  @override
  String get translation => 'FAKE';

  @override
  Future<int> chapterCount(String bookCode) async => 6;

  @override
  Future<int> verseCount(String bookCode, int chapter) async => 26;

  @override
  Future<List<BibleVerse>> chapter(String bookCode, int chapter) async => [
    for (final (i, text) in (_verses[(bookCode, chapter)] ?? const <String>[]).indexed)
      BibleVerse(bookCode, chapter, 22 + i, text),
  ];

  @override
  Future<List<BibleVerse>> passage(PassageRef ref) async => (await chapter(ref.bookCode, ref.chapter))
      .where(
        (v) => ref.verseStart == null || (v.verse >= ref.verseStart! && v.verse <= (ref.verseEnd ?? ref.verseStart!)),
      )
      .toList();

  @override
  Future<List<BibleSearchHit>> search(String query, {int limit = 50}) async => const [];
}
