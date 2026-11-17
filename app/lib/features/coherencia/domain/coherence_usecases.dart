import '../../../core/errors/failure.dart';
import '../../../core/utils/ids.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../../estudio/domain/devotional.dart';
import '../../estudio/domain/guided_reflection.dart';
import '../../estudio/domain/repositories.dart';
import '../data/drift_coherence_repository.dart';
import 'belief.dart';

/// Preguntas de la reflexión que expresan la interpretación (§2): de ahí sale la proposición.
const interpretationQuestions = ['hermeneutica.principio', 'teologia.dios', 'teologia.promesa', 'aplicacion.cambio'];

/// Texto inicial de una creencia a partir de un devocional: el principio atemporal, si existe.
String proposeFromDevotional(DevotionalEntry d) {
  final r = GuidedReflection.parse(d.content);
  for (final q in interpretationQuestions) {
    final text = r.answer(q).replaceAll(RegExp(r'\{[^}]*\}'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (text.isNotEmpty) return text.length > 280 ? '${text.substring(0, 277)}…' : text;
  }
  return '';
}

class SaveBelief {
  SaveBelief(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DriftCoherenceRepository _repo;
  final DateTime Function() _clock;

  Future<Belief> call({
    String? id,
    required String proposition,
    required BeliefOrigin origin,
    BeliefStatus status = BeliefStatus.incubacion,
    String? devotionalId,
    String? dimensionId,
    List<String> topicIds = const [],
    Belief? previous,
    String? note,
    PassageRef? basePassage,
  }) async {
    final text = proposition.trim();
    if (text.isEmpty) throw const ValidationFailure('Escribe la creencia como una frase completa.');
    if (text.length > 280) throw const ValidationFailure('La creencia debe caber en 280 caracteres.');
    final now = _clock();
    final belief = Belief(
      id: previous?.id ?? id ?? newId(),
      proposition: text,
      status: status,
      origin: previous?.origin ?? origin,
      dimensionId: dimensionId,
      devotionalId: previous?.devotionalId ?? devotionalId,
      basePassage: basePassage,
      note: note,
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
    );
    await _repo.upsertBelief(belief, topicIds: topicIds);
    return belief;
  }
}

/// Recupera R(I) sin ML (§4.1, fase O4): las citas `{…}` del devocional de origen como soporte
/// confirmado y las referencias cruzadas del pasaje base, ponderadas por sus votos y sin revisar.
class ImportCanonicalEvidence {
  ImportCanonicalEvidence({
    required DriftCoherenceRepository repo,
    required BibleRepository bible,
    required DevotionalRepository devotionals,
    DateTime Function()? clock,
  }) : _repo = repo,
       _bible = bible,
       _devotionals = devotionals,
       _clock = clock ?? DateTime.now;

  final DriftCoherenceRepository _repo;
  final BibleRepository _bible;
  final DevotionalRepository _devotionals;
  final DateTime Function() _clock;

  /// Devuelve cuántos pasajes nuevos se agregaron.
  Future<int> call(Belief belief, {int crossRefLimit = 25}) async {
    final now = _clock();
    final items = <BeliefEvidence>[];
    final devotional = belief.devotionalId == null ? null : await _devotionals.getById(belief.devotionalId!);
    if (devotional != null) {
      for (final c in GuidedReflection.parse(devotional.content).citations) {
        items.add(
          BeliefEvidence(
            id: newId(),
            beliefId: belief.id,
            passage: c.ref,
            kind: EvidenceKind.soporte,
            source: EvidenceSource.cita,
            confirmed: true,
            createdAt: now,
          ),
        );
      }
    }
    final base = belief.basePassage ?? devotional?.passage;
    if (base != null) {
      for (final x in await _bible.crossReferences(base, limit: crossRefLimit)) {
        items.add(
          BeliefEvidence(
            id: newId(),
            beliefId: belief.id,
            passage: x.target,
            kind: EvidenceKind.soporte,
            source: EvidenceSource.referenciaCruzada,
            votes: x.votes,
            createdAt: now,
          ),
        );
      }
    }
    return _repo.addEvidenceIfAbsent(items);
  }
}
