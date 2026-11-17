import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import '../../../shared/domain/entities/topic.dart';
import '../../../shared/domain/entities/topic_draft.dart';

/// Registro de bitácora con sus catálogos y tópicos resueltos (modelo de lectura).
class PraxisRecord {
  const PraxisRecord({
    required this.entry,
    required this.emotions,
    required this.triggers,
    required this.topics,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  final PraxisEntry entry;
  final List<CatalogEntry> emotions;
  final List<CatalogEntry> triggers;
  final List<Topic> topics;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get id => entry.id;
}

/// Lo que el editor envía para crear o actualizar un registro.
class PraxisDraft {
  const PraxisDraft({
    this.id,
    required this.date,
    required this.circumstance,
    required this.emotionIds,
    required this.intensity,
    required this.filter,
    required this.peace,
    this.action = '',
    this.coherence,
    this.foundationDetail,
    this.passage,
    this.triggerIds = const [],
    this.topics = const [],
    this.worldview,
    this.newImages = const [],
    this.removedAttachmentIds = const [],
  });

  final String? id;
  final DateTime date;
  final String circumstance;
  final List<String> emotionIds;
  final int intensity;
  final FilterType filter;
  final String? foundationDetail;
  final PassageRef? passage;
  final List<String> triggerIds;
  final List<TopicDraft> topics;

  /// Con filtro "cosmovisión": nombre de la creencia; se crea/vincula en Incubación.
  final String? worldview;
  final String action;
  final int peace;
  final int? coherence;
  final List<PendingImage> newImages;
  final List<String> removedAttachmentIds;
}

class PraxisFilter {
  const PraxisFilter({this.filter, this.since});

  final FilterType? filter;
  final DateTime? since;
}
