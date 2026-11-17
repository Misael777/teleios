import '../../../shared/domain/entities/passage_ref.dart';

/// Ciclo de una creencia operativa: igual que los tópicos (incubación → validada o refutada).
enum BeliefStatus {
  incubacion,
  validada,
  refutada;

  String get label => switch (this) {
    incubacion => 'En incubación',
    validada => 'Validada',
    refutada => 'Refutada',
  };
}

/// De dónde nació la creencia.
enum BeliefOrigin {
  /// Escrita por el usuario a partir de su vida ("si no controlo todo, sale mal").
  vida,

  /// Sale del principio de un devocional (Hermenéutica / Teología / Aplicación).
  devocional,

  /// Propuesta por un modelo o una regla; solo cuenta cuando el usuario la confirma.
  sugerida;

  String get label => switch (this) {
    vida => 'Nació de la vida',
    devocional => 'Nació de un estudio',
    sugerida => 'Sugerida',
  };
}

/// Creencia operativa: la proposición que guía la conducta (docs/PLAN-COHERENCIA.md §2).
class Belief {
  const Belief({
    required this.id,
    required this.proposition,
    required this.status,
    required this.origin,
    required this.createdAt,
    required this.updatedAt,
    this.dimensionId,
    this.devotionalId,
    this.basePassage,
    this.note,
  });

  final String id;

  /// Interpretación explícita: "Dios provee → puedo dar aunque falte".
  final String proposition;
  final BeliefStatus status;
  final BeliefOrigin origin;
  final String? dimensionId;

  /// Devocional del que salió la interpretación (si aplica).
  final String? devotionalId;

  /// Pasaje base: ancla de la huella canónica.
  final PassageRef? basePassage;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isConfirmed => status != BeliefStatus.incubacion || origin != BeliefOrigin.sugerida;

  Belief copyWith({
    String? proposition,
    BeliefStatus? status,
    String? dimensionId,
    PassageRef? basePassage,
    String? note,
    DateTime? updatedAt,
  }) => Belief(
    id: id,
    proposition: proposition ?? this.proposition,
    status: status ?? this.status,
    origin: origin,
    dimensionId: dimensionId ?? this.dimensionId,
    devotionalId: devotionalId,
    basePassage: basePassage ?? this.basePassage,
    note: note ?? this.note,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

/// Un pasaje que sostiene o tensiona una creencia.
enum EvidenceKind {
  soporte,
  tension;

  String get label => switch (this) {
    soporte => 'Soporte',
    tension => 'Tensión',
  };
}

enum EvidenceSource {
  /// Citado por el usuario con `{…}` en el devocional.
  cita,

  /// Referencia cruzada de OpenBible (con votos).
  referenciaCruzada,

  /// Agregado a mano por el usuario.
  usuario,

  /// Juzgado por un modelo (con su versión); solo cuenta al confirmarse.
  modelo;

  String get label => switch (this) {
    cita => 'Tu cita',
    referenciaCruzada => 'Referencia cruzada',
    usuario => 'Agregado por ti',
    modelo => 'Sugerido por el modelo',
  };
}

class BeliefEvidence {
  const BeliefEvidence({
    required this.id,
    required this.beliefId,
    required this.passage,
    required this.kind,
    required this.source,
    required this.createdAt,
    this.votes,
    this.probEntail,
    this.probContra,
    this.modelVersion,
    this.resolved = false,
    this.confirmed = false,
    this.note,
  });

  final String id;
  final String beliefId;
  final PassageRef passage;
  final EvidenceKind kind;
  final EvidenceSource source;

  /// Votos de OpenBible (solo referencias cruzadas).
  final int? votes;

  /// Probabilidades del juez (premisa = pasaje, hipótesis = creencia).
  final double? probEntail;
  final double? probContra;
  final String? modelVersion;

  /// Tensión que el usuario marcó como "resuelta por el contexto": no suma a T.
  final bool resolved;

  /// El usuario revisó la evidencia y la aceptó.
  final bool confirmed;
  final String? note;
  final DateTime createdAt;

  /// p_e de §4.1. Fase sin ML: 1 para citas y evidencia confirmada; votos normalizados para las
  /// referencias cruzadas sin revisar; la probabilidad del juez cuando existe.
  double get supportWeight {
    if (kind != EvidenceKind.soporte) return 0;
    if (confirmed || source == EvidenceSource.cita || source == EvidenceSource.usuario) return 1;
    if (probEntail != null) return probEntail!;
    if (votes != null) return votes! / (votes! + 20);
    return 0;
  }

  /// p_c de §4.1: solo tensiones sin resolver.
  double get tensionWeight {
    if (kind != EvidenceKind.tension || resolved) return 0;
    if (confirmed || source == EvidenceSource.usuario) return 1;
    return probContra ?? 0;
  }

  BeliefEvidence copyWith({bool? resolved, bool? confirmed, EvidenceKind? kind, String? note}) => BeliefEvidence(
    id: id,
    beliefId: beliefId,
    passage: passage,
    kind: kind ?? this.kind,
    source: source,
    votes: votes,
    probEntail: probEntail,
    probContra: probContra,
    modelVersion: modelVersion,
    resolved: resolved ?? this.resolved,
    confirmed: confirmed ?? this.confirmed,
    note: note ?? this.note,
    createdAt: createdAt,
  );
}

/// Dirección de una acción respecto de una creencia (a ∈ {−1, 0, 1}).
enum ActionAlignment {
  desde(1),
  neutral(0),
  contra(-1);

  const ActionAlignment(this.value);

  final int value;

  String get label => switch (this) {
    desde => 'Actué desde ella',
    neutral => 'Neutral',
    contra => 'Actué contra ella',
  };

  String get shortLabel => switch (this) {
    desde => 'Alineada',
    neutral => 'Neutral',
    contra => 'Contraria',
  };
}

enum LinkOrigin {
  usuario,

  /// Regla de supervisión débil (§10.2).
  regla,

  /// Juez automático.
  modelo,
}

/// Tipo de registro de acción.
enum ActionKind { praxis, oracion }

/// Vínculo Acción → Creencia con dirección. Solo cuenta en estadísticas si [confirmed].
class ActionLink {
  const ActionLink({
    required this.actionKind,
    required this.actionId,
    required this.beliefId,
    required this.alignment,
    required this.origin,
    required this.createdAt,
    this.confidence,
    this.source,
    this.confirmed = false,
  });

  final ActionKind actionKind;
  final String actionId;
  final String beliefId;
  final ActionAlignment alignment;
  final LinkOrigin origin;

  /// Probabilidad de la dirección (reglas y modelo).
  final double? confidence;

  /// Id de la regla o versión del modelo que lo produjo.
  final String? source;
  final bool confirmed;
  final DateTime createdAt;

  String get key => '${actionKind.name}:$actionId:$beliefId';
}
