enum PrayerIntent {
  agradecimiento,
  peticion,
  lamentacion;

  String get label => switch (this) {
    agradecimiento => 'Agradecimiento',
    peticion => 'Petición',
    lamentacion => 'Lamentación',
  };
}

/// Oración transcrita (UI en Sprint 6; el esquema existe desde el Sprint 1).
class PrayerEntry {
  const PrayerEntry({
    required this.id,
    required this.date,
    required this.transcript,
    required this.intent,
    this.topicIds = const [],
    this.praxisLinkedIds = const [],
  });

  final String id;
  final DateTime date;
  final String transcript;
  final PrayerIntent intent;
  final List<String> topicIds;
  final List<String> praxisLinkedIds;
}
