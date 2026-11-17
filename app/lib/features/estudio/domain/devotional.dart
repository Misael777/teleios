import '../../../shared/domain/entities/historical_context.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/entities/topic_draft.dart';

export '../../../shared/domain/entities/topic_draft.dart';

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
    this.title,
    this.keyVerse,
  });

  final String id;
  final DateTime date;
  final PassageRef passage;
  final String content;

  /// Portada: título del estudio y versículo lema (opcionales).
  final String? title;
  final PassageRef? keyVerse;
  final HistoricalContext context;
  final List<Topic> topics;
  final DateTime createdAt;
  final DateTime updatedAt;

  Iterable<Topic> topicsOf(String dimensionId) => topics.where((t) => t.dimensionId == dimensionId);
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
    this.title,
    this.keyVerse,
  });

  final String? id;
  final DateTime date;
  final PassageRef passage;
  final String content;
  final String? title;
  final PassageRef? keyVerse;
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
