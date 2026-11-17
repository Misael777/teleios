import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/coherencia/domain/belief.dart';
import 'package:teleios/features/coherencia/domain/canonical_coherence.dart';
import 'package:teleios/features/coherencia/domain/coherence_charts.dart';
import 'package:teleios/features/coherencia/domain/coherence_data.dart';
import 'package:teleios/features/coherencia/domain/coherence_judge.dart';
import 'package:teleios/features/coherencia/domain/coherence_statistics.dart';
import 'package:teleios/features/coherencia/domain/labeling.dart';
import 'package:teleios/features/coherencia/domain/thought_prototypes.dart';
import 'package:teleios/features/coherencia/domain/weak_supervision.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';

final _t0 = DateTime(2026, 6, 1);

BeliefEvidence ev(
  String book,
  int ch, {
  EvidenceKind kind = EvidenceKind.soporte,
  EvidenceSource source = EvidenceSource.cita,
  int? votes,
  bool resolved = false,
  bool confirmed = false,
}) => BeliefEvidence(
  id: '$book$ch$kind',
  beliefId: 'b1',
  passage: PassageRef(bookCode: book, chapter: ch, verseStart: 1),
  kind: kind,
  source: source,
  votes: votes,
  resolved: resolved,
  confirmed: confirmed,
  createdAt: _t0,
);

Belief belief(String id, {BeliefStatus status = BeliefStatus.validada, PassageRef? base}) => Belief(
  id: id,
  proposition: 'Creencia $id',
  status: status,
  origin: BeliefOrigin.vida,
  basePassage: base,
  createdAt: _t0,
  updatedAt: _t0,
);

ActionRecord praxis(
  String id,
  DateTime date,
  int peace, {
  int? coherence,
  FilterType filter = FilterType.biblico,
  List<String> topics = const [],
}) => ActionRecord(
  kind: ActionKind.praxis,
  id: id,
  date: date,
  text: 'situación $id',
  peace: peace,
  coherence: coherence,
  filter: filter,
  topicIds: topics,
);

ActionLink link(String actionId, String beliefId, ActionAlignment a, {bool confirmed = true}) => ActionLink(
  actionKind: ActionKind.praxis,
  actionId: actionId,
  beliefId: beliefId,
  alignment: a,
  origin: LinkOrigin.usuario,
  confirmed: confirmed,
  createdAt: _t0,
);

void main() {
  group('coherencia canónica (§4.1)', () {
    test('D es el número efectivo de libros: un capítulo ≈ 1, cinco libros parejos ≈ 5', () {
      final one = CanonicalCoherence.compute([for (var i = 1; i <= 10; i++) ev('ROM', 8)..toString()]);
      expect(one.diversity.value, closeTo(1, 1e-9));
      final five = CanonicalCoherence.compute([
        for (final b in ['GEN', 'PSA', 'ISA', 'ROM', 'HEB']) ev(b, 1),
      ]);
      expect(five.diversity.value, closeTo(5, 1e-9));
      expect(five.support.value, 5);
      expect(five.support.lo, lessThanOrEqualTo(5));
    });

    test('las tensiones resueltas no suman a T y las referencias sin revisar pesan por votos', () {
      final cc = CanonicalCoherence.compute([
        ev('JAM', 2, kind: EvidenceKind.tension, source: EvidenceSource.usuario),
        ev('ROM', 4, kind: EvidenceKind.tension, source: EvidenceSource.usuario, resolved: true),
        ev('EPH', 2, source: EvidenceSource.referenciaCruzada, votes: 20),
      ]);
      expect(cc.tension.value, 1);
      expect(cc.support.value, closeTo(0.5, 1e-9)); // 20 / (20 + 20)
      expect(CanonicalCoherence.compute(const []).isEmpty, isTrue);
    });
  });

  group('estadística', () {
    test('Φ y Benjamini-Hochberg', () {
      expect(CoherenceStatistics.normalCdf(0), closeTo(0.5, 1e-7));
      expect(CoherenceStatistics.normalCdf(1.96), closeTo(0.975, 1e-4));
      final q = CoherenceStatistics.benjaminiHochberg([0.01, 0.04, 0.03, 0.5]);
      expect(q, [closeTo(0.04, 1e-9), closeTo(0.0533, 1e-3), closeTo(0.0533, 1e-3), closeTo(0.5, 1e-9)]);
    });

    test('Spearman con IC: perfecto y bajo el mínimo', () {
      final x = [for (var i = 0; i < 12; i++) i.toDouble()];
      final c = CoherenceStatistics.spearman(x, [for (final v in x) v * 2])!;
      expect(c.rho, closeTo(1, 1e-9));
      expect(c.p, lessThan(0.001));
      expect(CoherenceStatistics.spearman([1, 2, 3], [1, 2, 3]), isNull);
    });

    test('el rezago +1 detecta que x precede a y', () {
      final rng = Random(3);
      final x = [for (var i = 0; i < 30; i++) rng.nextDouble()];
      final y = [0.0, ...x.take(29)]; // y(t) = x(t − 1)
      final lags = CoherenceStatistics.laggedCorrelation(x, y, minN: 6);
      expect(lags[1]!.rho, closeTo(1, 1e-9));
      expect(lags[0]!.rho.abs(), lessThan(0.6));
    });
  });

  group('gráficos', () {
    CoherenceDataset dataset() {
      final actions = <String, ActionRecord>{};
      final links = <ActionLink>[];
      // 12 semanas: actuar desde la creencia → paz alta; contra → paz baja.
      for (var w = 0; w < 12; w++) {
        for (var k = 0; k < 2; k++) {
          final id = 'p$w$k';
          final aligned = (w + k).isEven;
          actions['praxis:$id'] = praxis(id, _t0.add(Duration(days: 7 * w + k)), aligned ? 8 : 3);
          links.add(link(id, w.isEven ? 'b1' : 'b2', aligned ? ActionAlignment.desde : ActionAlignment.contra));
        }
      }
      return CoherenceDataset(
        beliefs: [
          belief('b1'),
          belief('b2'),
          belief('b3', status: BeliefStatus.refutada),
        ],
        evidence: {
          'b1': [ev('GEN', 1), ev('PSA', 1), ev('ROM', 1)],
        },
        links: [...links, link('p00', 'b3', ActionAlignment.desde, confirmed: false)],
        actions: actions,
      );
    }

    test('gráfico 4: correlación positiva e IC por grupo, solo vínculos confirmados', () {
      final d = dataset();
      final ap = CoherenceCharts.alignmentPeace(d);
      expect(ap.points, hasLength(24));
      expect(ap.correlation!.rho, greaterThan(0.9));
      expect(ap.meanByAlignment[ActionAlignment.desde]!.value, 8);
      expect(ap.meanByAlignment[ActionAlignment.neutral], isNull);
      // Terciles: b1 tiene más soporte canónico que b2 (y b3 está refutada pero confirmada).
      expect(CoherenceCharts.beliefsInTercile(d, CoherenceTercile.alta), {'b1'});
    });

    test('gráficos 5 y 6: serie semanal continua y rezagos', () {
      final weekly = CoherenceCharts.weekly(dataset());
      expect(weekly, hasLength(12));
      expect(CoherenceCharts.weeksWithData(weekly), 12);
      expect(CoherenceCharts.lagged(weekly).keys, [-2, -1, 0, 1, 2]);
    });

    test('gráfico 3 excluye refutadas y gráfico 7 suma todas las acciones', () {
      final d = dataset();
      expect(CoherenceCharts.beliefMap(d).map((r) => r.belief.id), unorderedEquals(['b1', 'b2']));
      expect(CoherenceCharts.alluvium(d).total, 24);
      expect(CoherenceCharts.perBelief(d), hasLength(2));
    });
  });

  group('supervisión débil (§10.2)', () {
    test('propone por tópico compartido y mide su precisión contra lo confirmado', () {
      final d = CoherenceDataset(
        beliefs: [belief('b1')],
        evidence: const {},
        links: [link('a1', 'b1', ActionAlignment.desde)],
        actions: {
          'praxis:a1': praxis('a1', _t0, 9, coherence: 9, topics: ['t1']),
          'praxis:a2': praxis('a2', _t0, 2, filter: FilterType.impulso, topics: ['t1']),
          'praxis:a3': praxis('a3', _t0, 5, topics: ['t9']),
        },
        beliefTopics: {
          'b1': {'t1'},
        },
      );
      final proposals = WeakSupervision.propose(d, now: _t0);
      expect(proposals.single.actionId, 'a2');
      expect(proposals.single.alignment, ActionAlignment.contra);
      expect(proposals.single.confirmed, isFalse);
      final high = WeakSupervision.precision(d).firstWhere((p) => p.rule.id == 'topico-coherencia-alta');
      expect((high.fired, high.checked, high.precision), (1, 1, 1.0));
    });
  });

  group('etiquetado y calibración (§10, gráfico 8)', () {
    const items = [
      SharedItem(id: 'g1', type: 'nli', prompt: '', a: '', b: '', options: {'e': 'Sí'}, gold: 'e'),
      SharedItem(id: 'i1', type: 'nli', prompt: '', a: '', b: '', options: {'e': 'Sí'}),
    ];

    test('nextItem prioriza pendientes y no repite', () {
      expect(nextItem(items, {'g1', 'i1'}), isNull);
      expect(nextItem(items, {'i1'})!.id, 'g1');
      expect(nextItem(items, {'g1'})!.id, 'i1');
    });

    test('la exportación no contiene texto privado y mide la fiabilidad con oro', () {
      final labels = [
        SharedLabel(itemId: 'g1', label: 'e', isGold: true, correct: true, durationMs: 900, answeredAt: _t0),
        SharedLabel(itemId: 'i1', label: 'c', isGold: false, durationMs: 1200, answeredAt: _t0),
      ];
      expect(goldAccuracy(labels).accuracy, 1);
      final json = exportLabels(
        annotatorId: 'anon-x',
        itemsVersion: 'v1',
        labels: labels,
        feedback: const [],
        patterns: const [],
      );
      expect(json['shared_labels'], hasLength(2));
      expect((json['shared_labels'] as List).first, isNot(contains('text')));
    });

    test('ECE de un juez perfectamente calibrado es ~0 y la confusión cuadra', () {
      final entries = [
        for (var i = 0; i < 100; i++)
          JudgeFeedbackEntry(
            id: '$i',
            judgeVersion: 'v',
            task: 'nli',
            predicted: 'entailment',
            probability: 0.75,
            userLabel: i % 4 == 0 ? 'contradiction' : 'entailment',
            createdAt: _t0,
          ),
      ];
      final r = CalibrationReport.of(entries);
      expect(r.ece, closeTo(0, 1e-9));
      expect(r.accuracy, 0.75);
      expect(r.confusion[r.labels.indexOf('contradiction')][r.labels.indexOf('entailment')], 25);
    });
  });

  group('System One (S13-S15)', () {
    Float32List v(List<double> xs) {
      final n = sqrt(xs.fold(0.0, (a, x) => a + x * x));
      return Float32List.fromList([for (final x in xs) x / n]);
    }

    test('asigna al prototipo más cercano solo con umbral y margen', () {
      final catalog = PrototypeCatalog('v1', [
        ThoughtPrototype(
          id: 'control',
          name: 'Control propio → catástrofe',
          definition: '',
          centroid: v([1, 0, 0]),
          examples: const [],
          antagonistId: 'descanso',
        ),
        ThoughtPrototype(
          id: 'descanso',
          name: 'Dios gobierna → descanso',
          definition: '',
          centroid: v([0, 1, 0]),
          examples: const [],
          antagonistId: 'control',
        ),
      ], threshold: 0.6);
      final a = catalog.assign(v([0.9, 0.1, 0]))!;
      expect(a.prototype.id, 'control');
      expect(catalog.antagonistOf(a.prototype)!.id, 'descanso');
      expect(catalog.assign(v([0.5, 0.5, 0])), isNull); // sin margen
      expect(catalog.assign(v([0, 0, 1])), isNull); // bajo el umbral
    });

    test('la cascada escala lo incierto al usuario', () async {
      final judge = _FixedJudge([const NliJudgment(0.9, 0.05, 0.05), const NliJudgment(0.4, 0.3, 0.3)]);
      final d = await CascadeJudge(judge, threshold: 0.8).decide([('a', 'b'), ('c', 'd')]);
      expect(d.map((x) => x.route), [JudgeRoute.automatico, JudgeRoute.usuario]);
      expect(d.first.judgment.alignment, closeTo(0.85, 1e-9));
      expect(d.map((x) => x.version), ['fijo-1', 'fijo-1']);
    });

    test('con juez grande, solo lo incierto del System One pasa al segundo nivel', () async {
      final local = _FixedJudge([
        const NliJudgment(0.9, 0.05, 0.05),
        const NliJudgment(0.4, 0.3, 0.3),
        const NliJudgment(0.4, 0.3, 0.3),
      ]);
      final deep = _FixedJudge([const NliJudgment(0.02, 0.03, 0.95), const NliJudgment(0.5, 0.3, 0.2)], v: 'grande-1');
      final cascade = CascadeJudge(local, threshold: 0.8, deep: deep, deepThreshold: 0.9);
      final d = await cascade.decide([('a', 'b'), ('c', 'd'), ('e', 'f')]);
      expect(deep.seen, [('c', 'd'), ('e', 'f')]);
      expect(d.map((x) => x.route), [JudgeRoute.automatico, JudgeRoute.automatico, JudgeRoute.usuario]);
      expect(d.map((x) => x.version), ['fijo-1', 'grande-1', 'grande-1']);
      expect(d[1].judgment.label, 'contradiction');
      expect(cascade.version, 'fijo-1+grande-1');
    });
  });
}

class _FixedJudge implements CoherenceJudge {
  _FixedJudge(this.out, {this.v = 'fijo-1'});

  final List<NliJudgment> out;
  final String v;
  final seen = <(String, String)>[];

  @override
  String get id => 'fijo';

  @override
  String get version => v;

  @override
  Future<List<NliJudgment>> judge(List<(String, String)> pairs) async {
    seen.addAll(pairs);
    return out;
  }
}
