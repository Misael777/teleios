import '../../../core/errors/failure.dart';
import '../../../core/utils/ids.dart';
import '../entities/dimension.dart';
import '../entities/passage_ref.dart';
import '../entities/topic.dart';
import '../repositories/topic_repository.dart';

typedef Clock = DateTime Function();

/// Crea un tópico o devuelve el existente con el mismo nombre en esa dimensión.
class CreateTopic {
  CreateTopic(this._topics, {Clock? clock}) : _now = clock ?? DateTime.now;

  final TopicRepository _topics;
  final Clock _now;

  Future<Topic> call({
    required String name,
    required String dimensionId,
    TopicStatus status = TopicStatus.validado,
    TopicOrigin origin = TopicOrigin.usuario,
    double? confidence,
    String? note,
  }) async {
    final clean = Topic.cleanName(name);
    if (!Dimension.all.any((d) => d.id == dimensionId)) {
      throw ValidationFailure('Dimensión desconocida: $dimensionId');
    }
    final existing = await _topics.findByName(clean, dimensionId);
    if (existing != null) return existing;

    final now = _now();
    final topic = Topic(
      id: newId(),
      name: clean,
      dimensionId: dimensionId,
      status: status,
      origin: origin,
      confidence: origin == TopicOrigin.sugerido ? confidence : null,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _topics.insert(topic);
    return topic;
  }
}

/// Cosmovisión o conducta aprendida que aún no tiene fundamento bíblico identificado.
class CreateIncubationTopic {
  CreateIncubationTopic(this._create);

  final CreateTopic _create;

  Future<Topic> call({required String name, required String dimensionId, String? note}) =>
      _create(name: name, dimensionId: dimensionId, status: TopicStatus.incubacion, note: note);
}

class ValidateTopic {
  ValidateTopic(this._topics, {Clock? clock}) : _now = clock ?? DateTime.now;

  final TopicRepository _topics;
  final Clock _now;

  Future<Topic> call(String topicId, PassageRef passage, {String? note}) async {
    final topic = await _require(_topics, topicId);
    final validated = topic.validate(passage, note: note, at: _now());
    await _topics.update(validated);
    return validated;
  }
}

class RefuteTopic {
  RefuteTopic(this._topics, {Clock? clock}) : _now = clock ?? DateTime.now;

  final TopicRepository _topics;
  final Clock _now;

  Future<Topic> call(String topicId, {required String reason, PassageRef? passage}) async {
    final topic = await _require(_topics, topicId);
    final refuted = topic.refute(reason: reason, passage: passage, at: _now());
    await _topics.update(refuted);
    return refuted;
  }
}

class ReopenTopic {
  ReopenTopic(this._topics, {Clock? clock}) : _now = clock ?? DateTime.now;

  final TopicRepository _topics;
  final Clock _now;

  Future<Topic> call(String topicId) async {
    final topic = await _require(_topics, topicId);
    final reopened = topic.reopen(at: _now());
    await _topics.update(reopened);
    return reopened;
  }
}

Future<Topic> _require(TopicRepository repo, String id) async =>
    await repo.findById(id) ?? (throw NotFoundFailure('Tópico no encontrado: $id'));
