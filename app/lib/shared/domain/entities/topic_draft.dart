import 'topic.dart';

/// Tópico elegido en un editor (devocional, bitácora, oración), existente o por crear.
class TopicDraft {
  const TopicDraft({
    required this.name,
    required this.dimensionId,
    this.existingId,
    this.origin = TopicOrigin.usuario,
    this.confidence,
  });

  final String? existingId;
  final String name;
  final String dimensionId;
  final TopicOrigin origin;
  final double? confidence;

  /// Al cambiar de dimensión se resuelve de nuevo por nombre.
  TopicDraft movedTo(String dimensionId) =>
      TopicDraft(name: name, dimensionId: dimensionId, origin: origin, confidence: confidence);
}
