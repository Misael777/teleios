import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/coherencia/domain/coherence_judge.dart';
import 'package:teleios/infrastructure/ml/nli_judge_bundle.dart';

/// Prueba de humo del juez grande real sobre el paquete de ml/scripts/nli_export.py.
/// Requiere TELEIOS_NLI_DIR=ml/out/nli_bundle y onnxruntime.dll al alcance del proceso.
void main() {
  final dir = Platform.environment['TELEIOS_NLI_DIR'];
  final skip = dir == null ? 'TELEIOS_NLI_DIR no definido' : false;

  test('separa paráfrasis, contradicción por caso particular y lo neutral', () async {
    final judge = await OnnxNliJudge.open(Directory(dir!));
    final pairs = [
      ('Si no controlo mi trabajo, todo se va a derrumbar.', 'Cuando suelto el control de mi trabajo, viene el desastre.'),
      ('Nunca falto a la iglesia.', 'El domingo pasado no fui a la iglesia.'),
      ('Dios provee lo necesario.', 'Mi vecino compró un auto nuevo.'),
    ];
    final watch = Stopwatch()..start();
    final [para, contra, neutral] = await judge.judge(pairs);
    // ignore: avoid_print
    print('juez grande: ${watch.elapsedMilliseconds} ms para ${pairs.length} pares');
    expect(para.label, 'entailment');
    expect(contra.label, 'contradiction');
    expect(neutral.label, 'neutral');
    expect(judge, isA<DeepJudge>());
    judge.dispose();
  }, skip: skip, timeout: const Timeout(Duration(minutes: 3)));
}
