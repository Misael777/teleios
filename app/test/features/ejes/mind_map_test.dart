import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/coherencia/domain/coherence_judge.dart';
import 'package:teleios/features/ejes/domain/mind_map.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';

Float32List v(List<double> x) {
  final n = sqrt(x.fold<double>(0, (a, b) => a + b * b));
  return Float32List.fromList([for (final e in x) e / n]);
}

MindItem item(String id, MindSide side, {FilterType? filter, int? peace}) => MindItem(
  id: id,
  side: side,
  source: side == MindSide.cristo ? MindSource.creencia : MindSource.bitacora,
  text: id,
  refId: id,
  filter: filter,
  peace: peace,
);

/// Juez simulado: contradice si la reacción contiene "grité", confirma si contiene "perdoné".
class _RuleJudge implements CoherenceJudge {
  final seen = <(String, String)>[];

  @override
  String get id => 'reglas';

  @override
  String get version => 'reglas-1';

  @override
  Future<List<NliJudgment>> judge(List<(String, String)> pairs) async {
    seen.addAll(pairs);
    return [
      for (final (p, _) in pairs)
        p.contains('grité')
            ? const NliJudgment(0.02, 0.03, 0.95)
            : p.contains('perdoné')
            ? const NliJudgment(0.95, 0.03, 0.02)
            : const NliJudgment(0.2, 0.6, 0.2),
    ];
  }
}

void main() {
  // Eje 0 = amor, eje 1 = dinero.
  final index = MindIndex(
    [
      item('el amor no busca lo suyo', MindSide.cristo),
      item('el amor todo lo sufre', MindSide.cristo),
      item('no os hagáis tesoros en la tierra', MindSide.cristo),
      item('le grité a mi esposa', MindSide.mia, filter: FilterType.impulso, peace: 2),
      item('perdoné a mi hermano', MindSide.mia, filter: FilterType.biblico, peace: 8),
      item('compré una tele a crédito', MindSide.mia, filter: FilterType.cosmovision, peace: 5),
    ],
    [
      v([1, 0.1]),
      v([1, 0.2]),
      v([0, 1]),
      v([1, 0.3]),
      v([1, 0.05]),
      v([0.05, 1]),
    ],
  );

  test('la temática filtra las dos mentes por cercanía en el embedding', () {
    final hits = MindMap.search(index, v([1, 0]), minScore: 0.5);
    expect(hits.christ.map((h) => h.item.id), ['el amor no busca lo suyo', 'el amor todo lo sufre']);
    expect(hits.mine.map((h) => h.item.id), ['perdoné a mi hermano', 'le grité a mi esposa']);
  });

  test('el juez decide la postura; lo neutral o incierto no cuenta', () async {
    final judge = _RuleJudge();
    final c = await MindMap.compare(
      'amor',
      MindMap.search(index, v([1, 0]), minScore: 0.5),
      CascadeJudge(judge, threshold: 0.9),
      neighbors: 2,
    );
    expect(judge.seen, hasLength(4)); // 2 reacciones × 2 vecinas
    expect(judge.seen.first.$1, 'perdoné a mi hermano'); // la reacción es la premisa
    expect(c.contradictions.single.mine.item.id, 'le grité a mi esposa');
    expect(c.confirmations.single.mine.item.id, 'perdoné a mi hermano');
    expect(c.posture!.value, closeTo(0, 1e-9)); // +0.93 y −0.93
    expect(c.filterMix, {FilterType.biblico: 1, FilterType.impulso: 1});
    expect(c.peace!.value, 5);
    expect(c.blindSpots, isEmpty);
    expect(c.layout.keys, hasLength(4));
    for (final (x, y) in c.layout.values) {
      expect(x.abs() <= 1 && y.abs() <= 1, isTrue);
    }
  });

  test('sin reacciones decididas no hay postura y todo lo de Cristo es punto ciego', () async {
    final c = await MindMap.compare(
      'dinero',
      MindMap.search(index, v([0, 1]), minScore: 0.5),
      CascadeJudge(_RuleJudge(), threshold: 0.9),
    );
    expect(c.posture, isNull);
    expect(c.links.single.decided, isFalse);
    expect(c.blindSpots.single.item.id, 'no os hagáis tesoros en la tierra');
  });

  test('la temática la confirma el juez: el embedding solo preselecciona', () async {
    final judge = _TopicJudge({'el amor todo lo sufre', 'perdoné a mi hermano', 'compré una tele a crédito'});
    final hits = await MindMap.rerank('el amor', MindMap.search(index, v([1, 0]), minScore: -1), judge);
    expect(judge.seen.every((p) => p.$2 == 'Este texto trata sobre el amor.'), isTrue);
    expect(hits.christ.map((h) => h.item.id), ['el amor todo lo sufre']);
    // La tele está lejos en el embedding, pero si el juez dice que trata del tema, entra.
    expect(hits.mine.map((h) => h.item.id), unorderedEquals(['perdoné a mi hermano', 'compré una tele a crédito']));
    expect(hits.mine.first.score, 0.9);
  });

  test('la postura pregunta si actué conforme a la afirmación de Cristo', () async {
    final judge = _RuleJudge();
    await MindMap.compare('amor', MindMap.search(index, v([1, 0]), minScore: 0.5), CascadeJudge(judge, threshold: 0.9));
    expect(judge.seen.first.$2, startsWith('Esta persona actuó conforme a esto: el amor'));
  });

  test('la proyección separa lo que está lejos y es determinista', () {
    final hits = MindMap.search(index, v([1, 1]), minScore: -1);
    final all = [...hits.christ, ...hits.mine];
    final a = MindMap.project(all), b = MindMap.project(all);
    expect(a, b);
    final love = a['el amor no busca lo suyo']!, money = a['no os hagáis tesoros en la tierra']!;
    final near = a['el amor todo lo sufre']!;
    double d((double, double) p, (double, double) q) => sqrt(pow(p.$1 - q.$1, 2) + pow(p.$2 - q.$2, 2));
    expect(d(love, near), lessThan(d(love, money)));
  });

  test('de un devocional se toman frases con al menos cinco palabras ("Dios es amor." queda fuera)', () {
    expect(MindMap.sentences('Dios es amor. Sí. El amor no busca lo suyo!\nOra siempre sin cesar hoy mismo'), [
      'El amor no busca lo suyo!',
      'Ora siempre sin cesar hoy mismo',
    ]);
  });
}

/// Juez de temática simulado: confirma la temática solo para los textos de [relevant].
class _TopicJudge implements CoherenceJudge {
  _TopicJudge(this.relevant);

  final Set<String> relevant;
  final seen = <(String, String)>[];

  @override
  String get id => 'tema';

  @override
  String get version => 'tema-1';

  @override
  Future<List<NliJudgment>> judge(List<(String, String)> pairs) async {
    seen.addAll(pairs);
    return [
      for (final (p, _) in pairs)
        relevant.contains(p) ? const NliJudgment(0.9, 0.08, 0.02) : const NliJudgment(0.1, 0.8, 0.1),
    ];
  }
}
