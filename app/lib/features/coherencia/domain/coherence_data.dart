import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import 'belief.dart';
import 'canonical_coherence.dart';

/// Una acción registrada (bitácora u oración), reducida a lo que la coherencia necesita.
class ActionRecord {
  const ActionRecord({
    required this.kind,
    required this.id,
    required this.date,
    required this.text,
    this.peace,
    this.coherence,
    this.filter,
    this.passage,
    this.topicIds = const [],
  });

  final ActionKind kind;
  final String id;
  final DateTime date;

  /// Circunstancia + acción (praxis) o transcripción (oración). Privado: nunca sale del teléfono.
  final String text;

  /// Solo la praxis tiene paz momentánea.
  final int? peace;
  final int? coherence;
  final FilterType? filter;
  final PassageRef? passage;
  final List<String> topicIds;

  String get key => '${kind.name}:$id';
}

/// Todo lo que usa la coherencia medida, en memoria (un diario personal es pequeño).
class CoherenceDataset {
  CoherenceDataset({
    required this.beliefs,
    required this.evidence,
    required this.links,
    required this.actions,
    this.beliefTopics = const {},
    this.devotionalTitles = const {},
  });

  static final empty = CoherenceDataset(beliefs: const [], evidence: const {}, links: const [], actions: const {});

  final List<Belief> beliefs;

  /// beliefId → evidencia canónica.
  final Map<String, List<BeliefEvidence>> evidence;
  final List<ActionLink> links;

  /// ActionRecord.key → registro.
  final Map<String, ActionRecord> actions;

  /// beliefId → tópicos (propios + los del devocional de origen). Alimenta las reglas.
  final Map<String, Set<String>> beliefTopics;

  /// devotionalId → título visible.
  final Map<String, String> devotionalTitles;

  late final Map<String, Belief> beliefById = {for (final b in beliefs) b.id: b};

  late final Map<String, CanonicalCoherence> coherence = {
    for (final b in beliefs) b.id: CanonicalCoherence.compute(evidence[b.id] ?? const [], fidelity: fidelityOf(b)),
  };

  /// F (§4.1): juicio del modelo entre el pasaje base y la creencia, P(confirma) − P(contradice).
  double? fidelityOf(Belief b) {
    final base = b.basePassage;
    if (base == null) return null;
    for (final e in evidence[b.id] ?? const <BeliefEvidence>[]) {
      if (e.passage == base && e.probEntail != null && e.probContra != null) return e.probEntail! - e.probContra!;
    }
    return null;
  }

  /// Solo vínculos confirmados por el usuario cuentan en la estadística (§9).
  late final List<ActionLink> confirmedLinks = [
    for (final l in links)
      if (l.confirmed) l,
  ];

  ActionRecord? actionOf(ActionLink l) => actions['${l.actionKind.name}:${l.actionId}'];

  /// Pares (alineación, paz) de la praxis con vínculo confirmado.
  List<({ActionLink link, ActionRecord action})> get confirmedPraxis => [
    for (final l in confirmedLinks)
      if (actionOf(l) case final a? when a.peace != null) (link: l, action: a),
  ];

  bool get isEmpty => beliefs.isEmpty;
}
