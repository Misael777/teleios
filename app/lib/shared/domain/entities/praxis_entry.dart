import 'passage_ref.dart';

/// Filtro cognitivo (B) del modelo A-B-C.
enum FilterType {
  biblico,
  cosmovision,
  impulso;

  String get label => switch (this) {
    biblico => 'Principio bíblico',
    cosmovision => 'Cosmovisión (por validar)',
    impulso => 'Impulso / emoción del momento',
  };
}

/// Entrada de la Bitácora de Praxis (UI en Sprint 5; el esquema existe desde el Sprint 1).
class PraxisEntry {
  const PraxisEntry({
    required this.id,
    required this.date,
    required this.circumstance,
    required this.emotionIds,
    required this.intensity,
    required this.filter,
    required this.action,
    required this.peace,
    required this.coherence,
    this.foundationDetail,
    this.passage,
    this.triggerIds = const [],
    this.topicIds = const [],
  });

  final String id;
  final DateTime date;

  // A — Acontecimiento
  final String circumstance;
  final List<String> emotionIds;
  final int intensity;

  // B — Filtro
  final FilterType filter;
  final String? foundationDetail;
  final PassageRef? passage;
  final List<String> triggerIds;
  final List<String> topicIds;

  // C — Consecuencia
  final String action;
  final int peace;
  final int coherence;
}
