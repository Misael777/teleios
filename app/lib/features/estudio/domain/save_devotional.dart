import '../../../core/errors/failure.dart';
import '../../../core/utils/ids.dart';
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
       _transaction = transaction,
       _resolveTopic = ResolveTopicDraft(topics);

  final DevotionalRepository _devotionals;
  final TransactionRunner _transaction;
  final ResolveTopicDraft _resolveTopic;

  static const maxContentLength = 20000;
  static const maxTitleLength = 120;

  Future<String> call(DevotionalDraft draft) async {
    final content = draft.content.trim();
    if (content.isEmpty) {
      throw const ValidationFailure('Escribe tu reflexión antes de guardar.');
    }
    if (content.length > maxContentLength) {
      throw const ValidationFailure('La reflexión supera el máximo de 20.000 caracteres.');
    }
    final title = draft.title?.trim();
    if ((title?.length ?? 0) > maxTitleLength) {
      throw const ValidationFailure('El título supera los 120 caracteres.');
    }

    return _transaction.run(() async {
      final links = <String, TopicLink>{};
      for (final draftTopic in draft.topics) {
        final topic = await _resolveTopic(draftTopic);
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
        title: title == null || title.isEmpty ? null : title,
        keyVerse: draft.keyVerse,
      );
      return id;
    });
  }
}
