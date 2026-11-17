import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:onnxruntime/onnxruntime.dart';

import '../../features/coherencia/domain/coherence_judge.dart';
import 'system_one_bundle.dart';
import 'unigram_tokenizer.dart';

/// manifest.json del paquete del juez grande (ml/scripts/nli_export.py, kind "nli-judge").
class NliJudgeManifest {
  NliJudgeManifest(this.json);

  final Map<String, dynamic> json;

  String get version => json['version'] as String;
  int get maxLength => json['max_length'] as int? ?? 128;
  TokenizerFormat get format => TokenizerFormat.parse(json['tokenizer'] as String?);

  /// Etiqueta de cada salida del ONNX, en orden.
  List<String> get labels => [for (final l in json['labels'] as List) l as String];
  double get temperature => (json['temperature'] as num?)?.toDouble() ?? 1;
  double get threshold => (json['route_threshold'] as num?)?.toDouble() ?? 0.9;
  int get threads => json['threads'] as int? ?? 4;
  Map<String, String> get files => {for (final e in (json['files'] as Map).entries) e.key as String: e.value as String};
  Map<String, dynamic> get card => (json['card'] as Map<String, dynamic>?) ?? const {};
}

/// Juez grande local: mDeBERTa recortado a español, pesos int8 (DequantizeLinear → MatMul en fp32, porque la
/// cuantización dinámica destruye a DeBERTa). ~140 MB en disco, ~260 MB de RAM y ~0.1–0.5 s por par según el
/// teléfono: por eso solo ve lo que el System One no resuelve con confianza (CascadeJudge).
class OnnxNliJudge implements DeepJudge {
  OnnxNliJudge._(this.manifest, this._tokenizer, this._session);

  static Future<OnnxNliJudge> open(Directory dir) async {
    final manifest = NliJudgeManifest(
      jsonDecode(await File('${dir.path}/manifest.json').readAsString()) as Map<String, dynamic>,
    );
    final tsv = File('${dir.path}/${manifest.files['vocab']}');
    final format = manifest.format;
    final tokenizer = await Isolate.run(() => UnigramTokenizer.fromTsv(tsv.readAsLinesSync(), format: format));
    OrtEnv.instance.init();
    final options = OrtSessionOptions()
      ..setIntraOpNumThreads(manifest.threads)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    final modelFile = File('${dir.path}/${manifest.files['model']}');
    // Igual que el System One: en Windows se carga desde memoria (la ruta UTF-8 no llega bien a ORT).
    final session = Platform.isWindows
        ? OrtSession.fromBuffer(await modelFile.readAsBytes(), options)
        : OrtSession.fromFile(modelFile, options);
    return OnnxNliJudge._(manifest, tokenizer, session);
  }

  final NliJudgeManifest manifest;
  final UnigramTokenizer _tokenizer;
  final OrtSession _session;

  @override
  String get id => 'nli-judge-local';

  @override
  String get version => manifest.version;

  @override
  double get routeThreshold => manifest.threshold;

  @override
  Map<String, dynamic> get card => manifest.card;

  /// Pares por llamada: los pesos se descuantizan una vez por llamada, así que lotes grandes rinden más.
  static const batch = 16;

  @override
  Future<List<NliJudgment>> judge(List<(String, String)> pairs) async {
    final labels = manifest.labels;
    final out = <NliJudgment>[];
    for (var i = 0; i < pairs.length; i += batch) {
      final chunk = pairs.sublist(i, min(i + batch, pairs.length));
      final seqs = [for (final (p, h) in chunk) _tokenizer.encode(p, b: h, maxLength: manifest.maxLength)];
      for (final logits in await _run(seqs)) {
        final p = OnnxSystemOne.softmax(logits, manifest.temperature);
        final at = {for (final (k, l) in labels.indexed) l: p[k]};
        out.add(NliJudgment(at['entailment']!, at['neutral']!, at['contradiction']!));
      }
    }
    return out;
  }

  Future<List<List<double>>> _run(List<List<int>> batch) async {
    final len = batch.map((x) => x.length).reduce(max);
    final ids = Int64List(batch.length * len)..fillRange(0, batch.length * len, _tokenizer.format.pad);
    final mask = Int64List(batch.length * len);
    for (var i = 0; i < batch.length; i++) {
      for (var j = 0; j < batch[i].length; j++) {
        ids[i * len + j] = batch[i][j];
        mask[i * len + j] = 1;
      }
    }
    final inputs = {
      'input_ids': OrtValueTensor.createTensorWithDataList(ids, [batch.length, len]),
      'attention_mask': OrtValueTensor.createTensorWithDataList(mask, [batch.length, len]),
    };
    final runOptions = OrtRunOptions();
    final outputs = await _session.runAsync(runOptions, inputs) ?? const [];
    final v = outputs.firstOrNull?.value as List?;
    final logits = [for (final row in v ?? const []) (row as List).cast<num>().map((x) => x.toDouble()).toList()];
    for (final o in outputs) {
      o?.release();
    }
    for (final t in inputs.values) {
      t.release();
    }
    runOptions.release();
    return logits;
  }

  void dispose() => _session.release();
}
