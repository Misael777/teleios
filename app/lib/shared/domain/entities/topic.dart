import '../../../core/errors/failure.dart';
import 'passage_ref.dart';

enum TopicStatus {
  /// Conectado a la Escritura (nodo sólido).
  validado,

  /// Cosmovisión o conducta aprendida pendiente de validar (línea punteada).
  incubacion,

  /// Tópico recurrente de falla sin estudio asociado (alerta).
  sombra,

  /// Cosmovisión examinada y descartada a la luz del estudio.
  refutado;

  String get label => switch (this) {
    validado => 'Validado',
    incubacion => 'En incubación',
    sombra => 'Sombra',
    refutado => 'Refutado',
  };
}

enum TopicOrigin { usuario, sugerido }

/// Tópico orgánico: lo crea el usuario o lo sugiere la IA con su aprobación.
class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.dimensionId,
    required this.status,
    required this.origin,
    required this.createdAt,
    required this.updatedAt,
    this.confidence,
    this.note,
    this.validationPassage,
  });

  final String id;
  final String name;
  final String dimensionId;
  final TopicStatus status;
  final TopicOrigin origin;
  final double? confidence;
  final String? note;

  /// Pasaje con el que se validó (o refutó) el tópico.
  final PassageRef? validationPassage;
  final DateTime createdAt;
  final DateTime updatedAt;

  static const maxNameLength = 60;

  /// Limpia y valida el nombre antes de crear un tópico.
  static String cleanName(String raw) {
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) throw const ValidationFailure('El tópico necesita un nombre.');
    if (name.length > maxNameLength) {
      throw const ValidationFailure('El nombre del tópico es demasiado largo (máx. 60).');
    }
    return name[0].toUpperCase() + name.substring(1);
  }

  /// incubación/sombra → validado, anclado a un pasaje.
  Topic validate(PassageRef passage, {String? note, required DateTime at}) {
    if (status == TopicStatus.validado) {
      throw const ValidationFailure('El tópico ya está validado.');
    }
    if (status == TopicStatus.refutado) {
      throw const ValidationFailure('Un tópico refutado debe reabrirse antes de validarse.');
    }
    return _copy(status: TopicStatus.validado, validationPassage: passage, note: note ?? this.note, updatedAt: at);
  }

  /// incubación → refutado. Se conserva como registro del proceso de discernimiento.
  Topic refute({required String reason, PassageRef? passage, required DateTime at}) {
    if (status != TopicStatus.incubacion) {
      throw const ValidationFailure('Solo se puede refutar una cosmovisión en incubación.');
    }
    if (reason.trim().isEmpty) {
      throw const ValidationFailure('Explica brevemente por qué la refutas.');
    }
    return _copy(status: TopicStatus.refutado, note: reason.trim(), validationPassage: passage, updatedAt: at);
  }

  /// refutado → incubación (quiero volver a examinarlo).
  Topic reopen({required DateTime at}) {
    if (status != TopicStatus.refutado) {
      throw const ValidationFailure('Solo se puede reabrir un tópico refutado.');
    }
    return _copy(status: TopicStatus.incubacion, updatedAt: at, clearPassage: true);
  }

  Topic moveTo(String dimensionId, {required DateTime at}) => _copy(dimensionId: dimensionId, updatedAt: at);

  Topic _copy({
    String? dimensionId,
    TopicStatus? status,
    String? note,
    PassageRef? validationPassage,
    bool clearPassage = false,
    required DateTime updatedAt,
  }) => Topic(
    id: id,
    name: name,
    dimensionId: dimensionId ?? this.dimensionId,
    status: status ?? this.status,
    origin: origin,
    confidence: confidence,
    note: note ?? this.note,
    validationPassage: clearPassage ? null : (validationPassage ?? this.validationPassage),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
