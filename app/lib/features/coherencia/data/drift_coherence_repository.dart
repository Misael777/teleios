import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../../shared/data/database/app_database.dart';
import '../../../shared/domain/entities/passage_ref.dart';
import '../domain/belief.dart';
import '../domain/coherence_data.dart';
import '../domain/labeling.dart';

/// Persistencia de la coherencia medida (esquema v4). Todo vive en la base cifrada del teléfono.
class DriftCoherenceRepository {
  DriftCoherenceRepository(this._db);

  final AppDatabase _db;

  /// Conjunto completo, re-emitido ante cualquier cambio en creencias, acciones o tópicos.
  /// Se escucha `tableUpdates` (no una consulta constante): Drift no re-emite resultados iguales.
  Stream<CoherenceDataset> watch() async* {
    yield await load();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables([
        _db.beliefs,
        _db.beliefTopics,
        _db.beliefEvidenceTable,
        _db.actionBeliefs,
        _db.praxisEntries,
        _db.praxisTopics,
        _db.prayers,
        _db.prayerTopics,
        _db.devotionals,
        _db.devotionalTopics,
      ]),
    )) {
      yield await load();
    }
  }

  Future<CoherenceDataset> load() async {
    final beliefs = [for (final r in await _db.select(_db.beliefs).get()) _toBelief(r)];
    final evidence = groupBy([
      for (final r in await _db.select(_db.beliefEvidenceTable).get()) _toEvidence(r),
    ], (e) => e.beliefId);
    final devotionals = await _db.select(_db.devotionals).get();
    final devTopics = groupBy(await _db.select(_db.devotionalTopics).get(), (r) => r.devotionalId);
    final ownTopics = groupBy(await _db.select(_db.beliefTopics).get(), (r) => r.beliefId);
    final pxTopics = groupBy(await _db.select(_db.praxisTopics).get(), (r) => r.praxisId);
    final prTopics = groupBy(await _db.select(_db.prayerTopics).get(), (r) => r.prayerId);

    final actions = <String, ActionRecord>{
      for (final p in await _db.select(_db.praxisEntries).get())
        'praxis:${p.id}': ActionRecord(
          kind: ActionKind.praxis,
          id: p.id,
          date: p.date,
          text: '${p.circumstance}\n${p.action}'.trim(),
          peace: p.peace,
          coherence: p.coherence,
          filter: p.filter,
          passage: p.passage == null ? null : PassageRef.decode(p.passage!),
          topicIds: [...?pxTopics[p.id]?.map((t) => t.topicId)],
        ),
      for (final p in await _db.select(_db.prayers).get())
        'oracion:${p.id}': ActionRecord(
          kind: ActionKind.oracion,
          id: p.id,
          date: p.date,
          text: p.transcript,
          topicIds: [...?prTopics[p.id]?.map((t) => t.topicId)],
        ),
    };
    final links = [
      for (final r in await _db.select(_db.actionBeliefs).get())
        if (actions.containsKey('${r.actionKind.name}:${r.actionId}')) _toLink(r),
    ];
    return CoherenceDataset(
      beliefs: beliefs,
      evidence: evidence,
      links: links,
      actions: actions,
      beliefTopics: {
        for (final b in beliefs)
          b.id: {
            ...?ownTopics[b.id]?.map((t) => t.topicId),
            if (b.devotionalId != null) ...?devTopics[b.devotionalId]?.map((t) => t.topicId),
          },
      },
      devotionalTitles: {for (final d in devotionals) d.id: d.title ?? '${d.bookCode} ${d.chapter}'},
    );
  }

  // ─── Creencias ──────────────────────────────────────────────────────────

  Future<void> upsertBelief(Belief b, {List<String>? topicIds}) => _db.transaction(() async {
    await _db
        .into(_db.beliefs)
        .insertOnConflictUpdate(
          BeliefsCompanion.insert(
            id: b.id,
            proposition: b.proposition,
            status: b.status,
            origin: b.origin,
            dimensionId: Value(b.dimensionId),
            devotionalId: Value(b.devotionalId),
            basePassage: Value(b.basePassage?.encode()),
            note: Value(b.note),
            createdAt: b.createdAt,
            updatedAt: b.updatedAt,
          ),
        );
    if (topicIds != null) {
      await (_db.delete(_db.beliefTopics)..where((t) => t.beliefId.equals(b.id))).go();
      await _db.batch(
        (batch) => batch.insertAll(_db.beliefTopics, [
          for (final t in topicIds) BeliefTopicsCompanion.insert(beliefId: b.id, topicId: t),
        ]),
      );
    }
  });

  Future<void> deleteBelief(String id) => (_db.delete(_db.beliefs)..where((b) => b.id.equals(id))).go();

  Future<List<String>> topicsOf(String beliefId) async => [
    for (final r in await (_db.select(_db.beliefTopics)..where((t) => t.beliefId.equals(beliefId))).get()) r.topicId,
  ];

  // ─── Evidencia ──────────────────────────────────────────────────────────

  /// Inserta o reemplaza por (creencia, pasaje): una evidencia por pasaje.
  Future<void> putEvidence(BeliefEvidence e) => _db
      .into(_db.beliefEvidenceTable)
      .insert(
        BeliefEvidenceTableCompanion.insert(
          id: e.id,
          beliefId: e.beliefId,
          passage: e.passage.encode(),
          kind: e.kind,
          source: e.source,
          votes: Value(e.votes),
          probEntail: Value(e.probEntail),
          probContra: Value(e.probContra),
          modelVersion: Value(e.modelVersion),
          resolved: Value(e.resolved),
          confirmed: Value(e.confirmed),
          note: Value(e.note),
          createdAt: e.createdAt,
        ),
        onConflict: DoUpdate.withExcluded(
          (old, ex) => BeliefEvidenceTableCompanion.custom(
            kind: ex.kind,
            source: ex.source,
            votes: ex.votes,
            probEntail: ex.probEntail,
            probContra: ex.probContra,
            modelVersion: ex.modelVersion,
            resolved: ex.resolved,
            confirmed: ex.confirmed,
            note: ex.note,
          ),
          target: [_db.beliefEvidenceTable.beliefId, _db.beliefEvidenceTable.passage],
        ),
      );

  /// Agrega sin pisar lo que el usuario ya revisó (útil al importar referencias cruzadas).
  Future<int> addEvidenceIfAbsent(List<BeliefEvidence> items) async {
    var added = 0;
    await _db.transaction(() async {
      for (final e in items) {
        added +=
            await _db
                    .into(_db.beliefEvidenceTable)
                    .insert(
                      BeliefEvidenceTableCompanion.insert(
                        id: e.id,
                        beliefId: e.beliefId,
                        passage: e.passage.encode(),
                        kind: e.kind,
                        source: e.source,
                        votes: Value(e.votes),
                        probEntail: Value(e.probEntail),
                        probContra: Value(e.probContra),
                        modelVersion: Value(e.modelVersion),
                        createdAt: e.createdAt,
                      ),
                      mode: InsertMode.insertOrIgnore,
                    ) >
                0
            ? 1
            : 0;
      }
    });
    return added;
  }

  Future<void> removeEvidence(String id) => (_db.delete(_db.beliefEvidenceTable)..where((e) => e.id.equals(id))).go();

  // ─── Vínculos acción → creencia ─────────────────────────────────────────

  Future<void> putLink(ActionLink l) => _db
      .into(_db.actionBeliefs)
      .insertOnConflictUpdate(
        ActionBeliefsCompanion.insert(
          actionKind: l.actionKind,
          actionId: l.actionId,
          beliefId: l.beliefId,
          alignment: l.alignment,
          origin: l.origin,
          confidence: Value(l.confidence),
          source: Value(l.source),
          confirmed: Value(l.confirmed),
          createdAt: l.createdAt,
        ),
      );

  Future<void> removeLink(ActionKind kind, String actionId, String beliefId) => (_db.delete(
    _db.actionBeliefs,
  )..where((l) => l.actionKind.equalsValue(kind) & l.actionId.equals(actionId) & l.beliefId.equals(beliefId))).go();

  // ─── Retroalimentación del juez (gráfico 8) ─────────────────────────────

  Future<void> recordFeedback(JudgeFeedbackEntry f) => _db
      .into(_db.judgeFeedback)
      .insert(
        JudgeFeedbackCompanion.insert(
          id: f.id,
          judgeVersion: f.judgeVersion,
          task: f.task,
          predicted: f.predicted,
          probability: f.probability,
          userLabel: f.userLabel,
          createdAt: f.createdAt,
        ),
      );

  Stream<List<JudgeFeedbackEntry>> watchFeedback() => _db
      .select(_db.judgeFeedback)
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            JudgeFeedbackEntry(
              id: r.id,
              judgeVersion: r.judgeVersion,
              task: r.task,
              predicted: r.predicted,
              probability: r.probability,
              userLabel: r.userLabel,
              createdAt: r.createdAt,
            ),
        ],
      );

  // ─── Etiquetado compartido (§10) ────────────────────────────────────────

  Future<void> putSharedLabel(SharedLabel l) => _db
      .into(_db.sharedLabels)
      .insertOnConflictUpdate(
        SharedLabelsCompanion.insert(
          itemId: l.itemId,
          label: l.label,
          isGold: l.isGold,
          correct: Value(l.correct),
          durationMs: l.durationMs,
          answeredAt: l.answeredAt,
        ),
      );

  Stream<List<SharedLabel>> watchSharedLabels() => _db
      .select(_db.sharedLabels)
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            SharedLabel(
              itemId: r.itemId,
              label: r.label,
              isGold: r.isGold,
              correct: r.correct,
              durationMs: r.durationMs,
              answeredAt: r.answeredAt,
            ),
        ],
      );

  // ─── Patrones de pensamiento (§11.2) ────────────────────────────────────

  Future<void> putPattern(PatternAssignmentRecord a) => _db
      .into(_db.thoughtPatterns)
      .insertOnConflictUpdate(
        ThoughtPatternsCompanion.insert(
          actionKind: a.actionKind,
          actionId: a.actionId,
          prototypeId: a.prototypeId,
          similarity: a.similarity,
          modelVersion: a.modelVersion,
          confirmed: Value(a.confirmed),
          createdAt: a.createdAt,
        ),
      );

  Stream<List<PatternAssignmentRecord>> watchPatterns() => _db
      .select(_db.thoughtPatterns)
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            PatternAssignmentRecord(
              actionKind: r.actionKind,
              actionId: r.actionId,
              prototypeId: r.prototypeId,
              similarity: r.similarity,
              modelVersion: r.modelVersion,
              confirmed: r.confirmed,
              createdAt: r.createdAt,
            ),
        ],
      );

  // ─── Mapeo ──────────────────────────────────────────────────────────────

  static Belief _toBelief(BeliefRow r) => Belief(
    id: r.id,
    proposition: r.proposition,
    status: r.status,
    origin: r.origin,
    dimensionId: r.dimensionId,
    devotionalId: r.devotionalId,
    basePassage: r.basePassage == null ? null : PassageRef.decode(r.basePassage!),
    note: r.note,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  static BeliefEvidence _toEvidence(BeliefEvidenceRow r) => BeliefEvidence(
    id: r.id,
    beliefId: r.beliefId,
    passage: PassageRef.decode(r.passage),
    kind: r.kind,
    source: r.source,
    votes: r.votes,
    probEntail: r.probEntail,
    probContra: r.probContra,
    modelVersion: r.modelVersion,
    resolved: r.resolved,
    confirmed: r.confirmed,
    note: r.note,
    createdAt: r.createdAt,
  );

  static ActionLink _toLink(ActionBeliefRow r) => ActionLink(
    actionKind: r.actionKind,
    actionId: r.actionId,
    beliefId: r.beliefId,
    alignment: r.alignment,
    origin: r.origin,
    confidence: r.confidence,
    source: r.source,
    confirmed: r.confirmed,
    createdAt: r.createdAt,
  );
}
