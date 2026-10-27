import '../../../shared/domain/entities/historical_context.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import 'devotional.dart';

abstract interface class DevotionalRepository {
  Stream<List<DevotionalEntry>> watch([DevotionalFilter filter = const DevotionalFilter()]);

  Stream<DevotionalEntry?> watchById(String id);

  Future<DevotionalEntry?> getById(String id);

  Future<void> upsert({
    required String id,
    required DateTime date,
    required PassageRef passage,
    required String content,
    required HistoricalContext context,
    required List<TopicLink> topics,
  });

  Future<void> delete(String id);
}

class BibleVerse {
  const BibleVerse(this.bookCode, this.chapter, this.verse, this.text);

  final String bookCode;
  final int chapter;
  final int verse;
  final String text;

  PassageRef get ref => PassageRef(bookCode: bookCode, chapter: chapter, verseStart: verse);
}

class BibleSearchHit {
  const BibleSearchHit(this.verse, this.snippet);

  final BibleVerse verse;

  /// Fragmento con las coincidencias marcadas entre [ y ].
  final String snippet;
}

/// Texto bíblico de solo lectura (RV1909, dominio público).
abstract interface class BibleRepository {
  String get translation;

  Future<int> chapterCount(String bookCode);

  Future<int> verseCount(String bookCode, int chapter);

  Future<List<BibleVerse>> chapter(String bookCode, int chapter);

  Future<List<BibleVerse>> passage(PassageRef ref);

  Future<List<BibleSearchHit>> search(String query, {int limit = 50});
}
