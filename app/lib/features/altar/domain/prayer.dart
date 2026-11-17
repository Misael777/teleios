import '../../../core/errors/failure.dart';
import '../../../core/utils/ids.dart';
import '../../../infrastructure/ai/lexical_classifier.dart';
import '../../../shared/domain/entities/prayer_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/entities/topic_draft.dart';
import '../../../shared/domain/repositories/topic_repository.dart';
import '../../../shared/domain/usecases/topic_usecases.dart';

/// Resumen de un registro de bitácora vinculado a una oración.
class LinkedPraxis {
  const LinkedPraxis({required this.id, required this.date, required this.circumstance});

  final String id;
  final DateTime date;
  final String circumstance;
}

/// Oración con tópicos y praxis vinculadas (modelo de lectura).
class PrayerRecord {
  const PrayerRecord({required this.entry, required this.topics, required this.linkedPraxis, required this.createdAt});

  final PrayerEntry entry;
  final List<Topic> topics;
  final List<LinkedPraxis> linkedPraxis;
  final DateTime createdAt;

  String get id => entry.id;
}

class PrayerDraft {
  const PrayerDraft({
    this.id,
    required this.date,
    required this.transcript,
    required this.intent,
    this.topics = const [],
    this.praxisIds = const [],
  });

  final String? id;
  final DateTime date;
  final String transcript;
  final PrayerIntent intent;
  final List<TopicDraft> topics;
  final List<String> praxisIds;
}

abstract interface class PrayerRepository {
  Stream<List<PrayerRecord>> watch();

  Stream<PrayerRecord?> watchById(String id);

  Future<PrayerRecord?> getById(String id);

  Future<void> upsert(PrayerEntry entry);

  Future<void> delete(String id);
}

/// Guarda una oración. Los tópicos nuevos nacen en incubación (no hay pasaje que los ancle).
/// El audio nunca se guarda: solo la transcripción, editada y aprobada por el usuario.
class SavePrayer {
  SavePrayer({
    required PrayerRepository prayers,
    required TopicRepository topics,
    required TransactionRunner transaction,
    Clock? clock,
  }) : _prayers = prayers,
       _transaction = transaction,
       _resolve = ResolveTopicDraft(topics, clock: clock);

  final PrayerRepository _prayers;
  final TransactionRunner _transaction;
  final ResolveTopicDraft _resolve;

  static const maxLength = 20000;

  Future<String> call(PrayerDraft draft) async {
    final text = draft.transcript.trim();
    if (text.isEmpty) throw const ValidationFailure('La oración está vacía.');
    if (text.length > maxLength) throw const ValidationFailure('La oración supera los 20.000 caracteres.');
    final id = draft.id ?? newId();
    await _transaction.run(() async {
      final topicIds = <String>{
        for (final t in draft.topics) (await _resolve(t, statusForNew: TopicStatus.incubacion)).id,
      };
      await _prayers.upsert(
        PrayerEntry(
          id: id,
          date: draft.date,
          transcript: text,
          intent: draft.intent,
          topicIds: topicIds.toList(),
          praxisLinkedIds: draft.praxisIds.toSet().toList(),
        ),
      );
    });
    return id;
  }
}

/// Sugiere la intención de la oración a partir de palabras clave (nivel 0, en el dispositivo).
class PrayerIntentClassifier {
  const PrayerIntentClassifier();

  static const keywords = <PrayerIntent, List<String>>{
    PrayerIntent.agradecimiento: [
      'gracias',
      'agradezco',
      'agradecido',
      'agradecida',
      'bendito',
      'alabo',
      'alabanza',
      'te alabo',
      'gloria',
      'bendigo',
      'gozo',
      'celebro',
      'reconozco tu',
    ],
    PrayerIntent.peticion: [
      'te pido',
      'pido',
      'ayúdame',
      'ayuda',
      'dame',
      'concédeme',
      'ruego',
      'sana',
      'provee',
      'guía',
      'guíame',
      'protege',
      'necesito',
      'por favor',
      'intercedo',
      'bendice',
      'fortalece',
      'perdóname',
      'perdona',
    ],
    PrayerIntent.lamentacion: [
      'por qué',
      'hasta cuándo',
      'duele',
      'dolor',
      'lloro',
      'llanto',
      'triste',
      'tristeza',
      'angustia',
      'clamo',
      'abandonado',
      'abandonada',
      'solo',
      'sola',
      'cansado',
      'cansada',
      'no entiendo',
      'quebrantado',
    ],
  };

  /// null si no hay evidencia suficiente: el usuario elige.
  ({PrayerIntent intent, double confidence, List<String> reasons})? classify(String transcript) {
    final matcher = LexicalMatcher(transcript);
    ({PrayerIntent intent, double confidence, List<String> reasons})? best;
    for (final entry in keywords.entries) {
      final hits = matcher.matches(entry.value);
      if (hits.isEmpty) continue;
      if (best == null || hits.length > best.reasons.length) {
        best = (intent: entry.key, confidence: LexicalClassifier.confidenceFor(hits.length), reasons: hits);
      }
    }
    return best;
  }
}
