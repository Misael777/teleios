import '../../../shared/domain/entities/historical_context.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/topic.dart';

/// Devocional guardado, con sus tópicos ya resueltos (modelo de lectura).
class DevotionalEntry {
  const DevotionalEntry({
    required this.id,
    required this.date,
    required this.passage,
    required this.content,
    required this.context,
    required this.topics,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime date;
  final PassageRef passage;
  final String content;
  final HistoricalContext context;
  final List<Topic> topics;
  final DateTime createdAt;
  final DateTime updatedAt;

  Iterable<Topic> topicsOf(String dimensionId) => topics.where((t) => t.dimensionId == dimensionId);
}

/// Tópico elegido en el editor, existente o por crear.
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

  TopicDraft movedTo(String dimensionId) => TopicDraft(
    name: name,
    dimensionId: dimensionId,
    // Al cambiar de dimensión se resuelve de nuevo por nombre.
    origin: origin,
    confidence: confidence,
  );
}

/// Lo que el editor envía para crear o actualizar un devocional.
class DevotionalDraft {
  const DevotionalDraft({
    this.id,
    required this.date,
    required this.passage,
    required this.content,
    this.context = const HistoricalContext(),
    this.topics = const [],
  });

  final String? id;
  final DateTime date;
  final PassageRef passage;
  final String content;
  final HistoricalContext context;
  final List<TopicDraft> topics;
}

class DevotionalFilter {
  const DevotionalFilter({this.dimensionId, this.bookCode});

  final String? dimensionId;
  final String? bookCode;

  bool get isEmpty => dimensionId == null && bookCode == null;
}

/// Enlace devocional → tópico con su origen.
typedef TopicLink = ({String topicId, TopicOrigin origin});
