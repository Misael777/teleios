import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/coherencia/domain/coherence_judge.dart';
import 'package:teleios/features/ejes/domain/mind_map.dart';
import 'package:teleios/infrastructure/ml/nli_judge_bundle.dart';
import 'package:teleios/infrastructure/ml/system_one_bundle.dart';

/// Mente de Cristo frente a mi mente con los modelos reales: la temática filtra por embedding y el juez
/// decide. Requiere TELEIOS_MODEL_DIR (System One) y TELEIOS_NLI_DIR (juez grande), y onnxruntime.dll.
void main() {
  final s1 = Platform.environment['TELEIOS_MODEL_DIR'], nli = Platform.environment['TELEIOS_NLI_DIR'];
  final skip = s1 == null || nli == null ? 'TELEIOS_MODEL_DIR / TELEIOS_NLI_DIR no definidos' : false;

  test(
    '«amor» trae lo de amor de las dos mentes y el juez separa confirmar de contradecir',
    () async {
      final model = await OnnxSystemOne.open(Directory(s1!));
      final deep = await OnnxNliJudge.open(Directory(nli!));
      final christ = [
        'El amor es sufrido y benigno, no busca lo suyo.',
        'Amad a vuestros enemigos y orad por los que os persiguen.',
        'No os hagáis tesoros en la tierra, donde la polilla y el orín corrompen.',
        'Dios provee lo necesario a quien confía en él.',
      ];
      final mine = [
        'Mi esposa llegó tarde. Le grité y la humillé delante de los niños.',
        'Mi compañero me ofendió en la reunión. Oré por él y lo traté con paciencia.',
        'Me llegó la factura de la luz. Gasté el ahorro en una tele nueva.',
      ];
      final texts = [...christ, ...mine];
      final vecs = [for (final s in await model.analyze(texts)) s.embedding];
      final index = MindIndex([
        for (final (i, t) in texts.indexed)
          MindItem(
            id: t,
            side: i < christ.length ? MindSide.cristo : MindSide.mia,
            source: i < christ.length ? MindSource.creencia : MindSource.bitacora,
            text: t,
            refId: '$i',
          ),
      ], vecs);
      final query = (await model.analyze(['amor'])).single.embedding;
      final hits = MindMap.search(index, query, minScore: -1, k: 2);
      // ignore: avoid_print
      print([
        for (final h in [...hits.christ, ...hits.mine]) '${h.score.toStringAsFixed(2)} ${h.item.text}',
      ]);
      expect(hits.christ.map((h) => h.item.text), contains(christ[0]));

      final relevant = await MindMap.rerank('el amor', MindMap.search(index, query, minScore: -1), deep);
      // ignore: avoid_print
      print([
        for (final h in [...relevant.christ, ...relevant.mine]) 'tema ${h.score.toStringAsFixed(2)} ${h.item.text}',
      ]);
      final c = await MindMap.compare('el amor', relevant, CascadeJudge(deep, threshold: deep.routeThreshold));
      for (final l in c.links) {
        // ignore: avoid_print
        print(
          '${l.decided ? (l.alignment >= 0 ? 'CONFIRMA ' : 'CONTRADICE') : 'sin decidir'} '
          '${l.alignment.toStringAsFixed(2)} [${l.decision.version}] ${l.mine.item.text} ⟷ ${l.christ.item.text}',
        );
      }
      final shout = c.links.firstWhere((l) => l.mine.item.text.contains('grité'));
      expect(shout.decided && shout.alignment < 0, isTrue, reason: 'gritar contradice el amor');
      model.dispose();
      deep.dispose();
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
