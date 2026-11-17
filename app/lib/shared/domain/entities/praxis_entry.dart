import 'dart:typed_data';

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

  String get shortLabel => switch (this) {
    biblico => 'Bíblico',
    cosmovision => 'Cosmovisión',
    impulso => 'Impulso',
  };
}

/// Entrada de la Bitácora de Praxis.
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
    this.coherence,
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

  /// null en registros rápidos: no se inventa un valor (ensuciaría la estadística).
  final int? coherence;

  bool get isQuick => coherence == null;

  /// Falla de coherencia: actuar por impulso o con coherencia baja.
  bool get isFailure => filter == FilterType.impulso || (coherence != null && coherence! <= 3);
}

/// Emoción o detonante de catálogo (sistema o creado por el usuario).
class CatalogEntry {
  const CatalogEntry({required this.id, required this.name, this.parentId, this.isSystem = true});

  final String id;
  final String name;

  /// Solo emociones: null = primaria.
  final String? parentId;
  final bool isSystem;
}

/// Imagen privada adjunta a un registro.
class Attachment {
  const Attachment({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    this.width,
    this.height,
  });

  static const ownerPraxis = 'praxis';

  final String id;
  final String ownerType;
  final String ownerId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final int? width;
  final int? height;
  final DateTime createdAt;
}

/// Imagen ya comprimida en la UI, pendiente de guardarse.
class PendingImage {
  const PendingImage({required this.bytes, required this.width, required this.height, this.mimeType = 'image/jpeg'});

  final Uint8List bytes;
  final int width;
  final int height;
  final String mimeType;
}
