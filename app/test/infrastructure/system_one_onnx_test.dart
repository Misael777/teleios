import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/features/coherencia/presentation/judge_actions.dart';
import 'package:teleios/infrastructure/ml/system_one_bundle.dart';

/// Prueba de humo del System One real (ONNX Runtime + tokenizador en Dart) sobre el paquete exportado
/// por el laboratorio. Requiere TELEIOS_MODEL_DIR=ml/out/bundle y onnxruntime.dll al alcance del proceso.
void main() {
  final dir = Platform.environment['TELEIOS_MODEL_DIR'];
  final skip = dir == null ? 'TELEIOS_MODEL_DIR no definido' : false;

  test('juzga paráfrasis y negación, analiza y recupera versículos', () async {
    final model = await OnnxSystemOne.open(Directory(dir!));
    final [para, neg] = await model.judge([
      ('Si no controlo mi trabajo, todo se va a derrumbar.', 'Cuando suelto el control de mi trabajo, viene el desastre.'),
      ('Si no controlo mi trabajo, todo se va a derrumbar.', 'Aunque no controle mi trabajo, Dios sigue obrando.'),
    ]);
    expect(para.label, 'entailment');
    expect(neg.label, 'contradiction');
    final s = (await model.analyze(['Dios provee, por eso puedo compartir mi dinero.'])).single;
    expect(s.embedding.length, model.manifest.dim);
    expect(s.top('agente')!.$1, 'dios');
    final verses = await model.nearestVerses(s.embedding, k: 5);
    expect(verses, hasLength(5));
    // ignore: avoid_print
    print([for (final (id, score) in verses) '${verseRef(id).label} ${score.toStringAsFixed(2)}']);
    model.dispose();
  }, skip: skip, timeout: const Timeout(Duration(minutes: 3)));
}
