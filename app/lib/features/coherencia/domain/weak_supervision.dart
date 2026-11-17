import '../../../shared/domain/entities/passage_ref.dart';
import '../../../shared/domain/entities/praxis_entry.dart';
import 'belief.dart';
import 'coherence_data.dart';

/// Regla de supervisión débil (§10.2): reutiliza lo que la app ya sabe para proponer vínculos
/// acción → creencia. Las propuestas son ruidosas: no cuentan hasta que el usuario las confirma,
/// y de cada regla se mide su precisión contra esas confirmaciones.
class WeakRule {
  const WeakRule(this.id, this.description, this.confidence, this.apply);

  final String id;
  final String description;

  /// Probabilidad a priori de acierto; se reemplaza por la precisión medida cuando hay n suficiente.
  final double confidence;

  /// Dirección propuesta, o null si la regla no aplica a ese par.
  final ActionAlignment? Function(ActionRecord action, Belief belief, CoherenceDataset data) apply;
}

class RulePrecision {
  const RulePrecision(this.rule, this.fired, this.hits, this.checked);

  final WeakRule rule;

  /// Veces que la regla propuso algo.
  final int fired;

  /// Coincidencias con la etiqueta del usuario, entre las [checked] verificables.
  final int hits;
  final int checked;

  double? get precision => checked == 0 ? null : hits / checked;
}

abstract final class WeakSupervision {
  static bool _sharesTopic(ActionRecord a, Belief b, CoherenceDataset d) {
    final topics = d.beliefTopics[b.id];
    return topics != null && a.topicIds.any(topics.contains);
  }

  static bool _citesEvidence(ActionRecord a, Belief b, CoherenceDataset d) {
    final p = a.passage;
    if (p == null) return false;
    bool same(PassageRef? r) => r != null && r.bookCode == p.bookCode && r.chapter == p.chapter;
    return same(b.basePassage) ||
        (d.evidence[b.id] ?? const <BeliefEvidence>[]).any((e) => e.kind == EvidenceKind.soporte && same(e.passage));
  }

  static final rules = <WeakRule>[
    WeakRule(
      'pasaje-biblico',
      'Te apoyaste en un pasaje que sostiene la creencia, con filtro bíblico → alineada',
      0.8,
      (a, b, d) => a.filter == FilterType.biblico && _citesEvidence(a, b, d) ? ActionAlignment.desde : null,
    ),
    WeakRule(
      'topico-coherencia-alta',
      'Comparte un tópico con la creencia y coherencia ≥ 8 → alineada',
      0.75,
      (a, b, d) => _sharesTopic(a, b, d) && (a.coherence ?? 0) >= 8 ? ActionAlignment.desde : null,
    ),
    WeakRule(
      'topico-impulso',
      'Comparte un tópico con la creencia y actuaste por impulso o con coherencia ≤ 3 → contraria',
      0.7,
      (a, b, d) =>
          _sharesTopic(a, b, d) && (a.filter == FilterType.impulso || (a.coherence != null && a.coherence! <= 3))
          ? ActionAlignment.contra
          : null,
    ),
    WeakRule(
      'topico-refutado',
      'Creencia refutada y actuaste en ese tópico con filtro de cosmovisión → actuaste desde ella',
      0.55,
      (a, b, d) => b.status == BeliefStatus.refutada && _sharesTopic(a, b, d) && a.filter == FilterType.cosmovision
          ? ActionAlignment.desde
          : null,
    ),
  ];

  /// Propuestas para pares acción-creencia que aún no tienen vínculo. Una por par: la regla más confiable.
  static List<ActionLink> propose(CoherenceDataset data, {required DateTime now}) {
    final existing = {for (final l in data.links) l.key};
    final measured = {for (final p in precision(data)) p.rule.id: p};
    final result = <ActionLink>[];
    for (final a in data.actions.values) {
      for (final b in data.beliefs) {
        if (b.status == BeliefStatus.incubacion && b.origin == BeliefOrigin.sugerida) continue;
        final key = '${a.kind.name}:${a.id}:${b.id}';
        if (existing.contains(key)) continue;
        ActionLink? best;
        for (final r in rules) {
          final alignment = r.apply(a, b, data);
          if (alignment == null) continue;
          final m = measured[r.id];
          final conf = (m != null && m.checked >= 5) ? m.precision! : r.confidence;
          if (best == null || conf > best.confidence!) {
            best = ActionLink(
              actionKind: a.kind,
              actionId: a.id,
              beliefId: b.id,
              alignment: alignment,
              origin: LinkOrigin.regla,
              confidence: conf,
              source: r.id,
              createdAt: now,
            );
          }
        }
        if (best != null) result.add(best);
      }
    }
    return result..sort((x, y) => y.confidence!.compareTo(x.confidence!));
  }

  /// Precisión de cada regla contra los vínculos que el usuario confirmó.
  static List<RulePrecision> precision(CoherenceDataset data) => [
    for (final r in rules)
      () {
        var fired = 0, hits = 0, checked = 0;
        final confirmed = {for (final l in data.confirmedLinks) l.key: l.alignment};
        for (final a in data.actions.values) {
          for (final b in data.beliefs) {
            final alignment = r.apply(a, b, data);
            if (alignment == null) continue;
            fired++;
            final truth = confirmed['${a.kind.name}:${a.id}:${b.id}'];
            if (truth == null) continue;
            checked++;
            if (truth == alignment) hits++;
          }
        }
        return RulePrecision(r, fired, hits, checked);
      }(),
  ];
}
