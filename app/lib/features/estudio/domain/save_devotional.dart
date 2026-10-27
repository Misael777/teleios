import '../../../core/errors/failure.dart';
import '../../../core/utils/ids.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/repositories/topic_repository.dart';
import '../../../shared/domain/usecases/topic_usecases.dart';
import 'devotional.dart';
import 'repositories.dart';

/// Guarda un devocional y resuelve sus tópicos (crea los nuevos) en una sola transacción.
///
/// Los tópicos nacidos en un devocional quedan *validados*: están anclados a un pasaje.
/// Si el usuario vincula una cosmovisión en incubación, NO se valida automáticamente:
/// validar es un acto explícito desde la pantalla de Incubación.
class SaveDevotional {
  SaveDevotional({
    required DevotionalRepository devotionals,
    required TopicRepository topics,
    required TransactionRunner transaction,
  }) : _devotionals = devotionals,
       _topics = topics,
       _transaction = transaction,
       _createTopic = CreateTopic(topics);

  final DevotionalRepository _devotionals;
  final TopicRepository _topics;
  final TransactionRunner _transaction;
  final CreateTopic _createTopic;

  static const maxContentLength = 20000;

  Future<String> call(DevotionalDraft draft) async {
    final content = draft.content.trim();
    if (content.isEmpty) {
      throw const ValidationFailure('Escribe tu reflexión antes de guardar.');
    }
    if (content.length > maxContentLength) {
      throw const ValidationFailure('La reflexión supera el máximo de 20.000 caracteres.');
    }

    return _transaction.run(() async {
      final links = <String, TopicLink>{};
      for (final draftTopic in draft.topics) {
        final topic = await _resolve(draftTopic);
        links[topic.id] = (topicId: topic.id, origin: draftTopic.origin);
      }
      final id = draft.id ?? newId();
      await _devotionals.upsert(
        id: id,
        date: draft.date,
        passage: draft.passage,
        content: content,
        context: draft.context,
        topics: links.values.toList(),
      );
      return id;
    });
  }

  Future<Topic> _resolve(TopicDraft draft) async {
    if (draft.existingId != null) {
      final existing = await _topics.findById(draft.existingId!);
      if (existing != null && existing.dimensionId == draft.dimensionId) return existing;
    }
    return _createTopic(
      name: draft.name,
      dimensionId: draft.dimensionId,
      origin: draft.origin,
      confidence: draft.confidence,
    );
  }
}
