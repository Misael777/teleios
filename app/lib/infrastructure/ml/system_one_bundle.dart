import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:onnxruntime/onnxruntime.dart';

import '../../features/coherencia/domain/coherence_judge.dart';
import '../../features/coherencia/domain/thought_prototypes.dart';
import 'unigram_tokenizer.dart';

/// Cabeza tipada del System One, con su temperatura de calibración (§11.1).
class HeadSpec {
  const HeadSpec(this.name, this.labels, this.temperature);

  factory HeadSpec.fromJson(String name, Map<String, dynamic> j) =>
      HeadSpec(name, [for (final l in j['labels'] as List) l as String], (j['temperature'] as num?)?.toDouble() ?? 1);

  final String name;
  final List<String> labels;
  final double temperature;
}

/// manifest.json del paquete que exporta el laboratorio (ml/scripts/s14_export.py).
class SystemOneManifest {
  SystemOneManifest(this.json);

  final Map<String, dynamic> json;

  String get version => json['version'] as String;
  int get maxLength => json['max_length'] as int? ?? 128;
  int get dim => json['embedding_dim'] as int;
  String get queryPrefix => json['query_prefix'] as String? ?? 'query: ';
  String get passagePrefix => json['passage_prefix'] as String? ?? 'passage: ';
  double get threshold => (json['route_threshold'] as num?)?.toDouble() ?? 0.8;
  double get prototypeThreshold => (json['prototype_threshold'] as num?)?.toDouble() ?? 0.6;
  Map<String, String> get files => {for (final e in (json['files'] as Map).entries) e.key as String: e.value as String};
  Map<String, HeadSpec> get heads => {
    for (final e in (json['heads'] as Map<String, dynamic>).entries)
      e.key: HeadSpec.fromJson(e.key, e.value as Map<String, dynamic>),
  };

  /// Tarjeta del modelo para el gráfico 8: pares mínimos, calibración y confusión del laboratorio.
  Map<String, dynamic> get card => (json['card'] as Map<String, dynamic>?) ?? const {};
}

/// System One local: un codificador (multilingual-e5-small ajustado) con salida de embeddings y
/// seis cabezas. Una sesión ONNX int8 sirve como juez NLI (pares) y como analizador (textos sueltos).
class OnnxSystemOne implements SystemOneModel {
  OnnxSystemOne._(this.dir, this.manifest, this._tokenizer, this._session);

  static Future<OnnxSystemOne> open(Directory dir) async {
    final manifest = SystemOneManifest(
      jsonDecode(await File('${dir.path}/manifest.json').readAsString()) as Map<String, dynamic>,
    );
    final tsv = File('${dir.path}/${manifest.files['vocab']}');
    final tokenizer = await Isolate.run(() => UnigramTokenizer.fromTsv(tsv.readAsLinesSync()));
    OrtEnv.instance.init();
    final options = OrtSessionOptions()
      ..setIntraOpNumThreads(2)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    final modelFile = File('${dir.path}/${manifest.files['model']}');
    // En Windows el plugin pasa la ruta en UTF-8 a una API de caracteres anchos: se carga desde memoria.
    final session = Platform.isWindows
        ? OrtSession.fromBuffer(await modelFile.readAsBytes(), options)
        : OrtSession.fromFile(modelFile, options);
    return OnnxSystemOne._(dir, manifest, tokenizer, session);
  }

  final Directory dir;
  final SystemOneManifest manifest;
  final UnigramTokenizer _tokenizer;
  final OrtSession _session;

  @override
  String get id => 'system-one-local';

  @override
  String get version => manifest.version;

  Future<Map<String, List<List<double>>>> _run(List<List<int>> batch) async {
    final len = batch.map((x) => x.length).reduce(max);
    final ids = Int64List(batch.length * len)..fillRange(0, batch.length * len, UnigramTokenizer.pad);
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
    final result = <String, List<List<double>>>{};
    for (final (i, name) in _session.outputNames.indexed) {
      final v = outputs[i]?.value as List?;
      if (v != null) result[name] = [for (final row in v) (row as List).cast<num>().map((x) => x.toDouble()).toList()];
      outputs[i]?.release();
    }
    for (final t in inputs.values) {
      t.release();
    }
    runOptions.release();
    return result;
  }

  static List<double> softmax(List<double> logits, double t) {
    final m = logits.reduce(max);
    final e = [for (final l in logits) exp((l - m) / t)];
    final s = e.reduce((a, b) => a + b);
    return [for (final x in e) x / s];
  }

  @override
  Future<List<NliJudgment>> judge(List<(String, String)> pairs) async {
    final head = manifest.heads['nli']!;
    final out = <NliJudgment>[];
    for (var i = 0; i < pairs.length; i += 16) {
      final chunk = pairs.sublist(i, min(i + 16, pairs.length));
      final r = await _run([for (final (p, h) in chunk) _tokenizer.encode(p, b: h, maxLength: manifest.maxLength)]);
      for (final logits in r['nli_logits']!) {
        final p = softmax(logits, head.temperature);
        final at = {for (final (k, l) in head.labels.indexed) l: p[k]};
        out.add(NliJudgment(at['entailment']!, at['neutral']!, at['contradiction']!));
      }
    }
    return out;
  }

  @override
  Future<List<ThoughtStructure>> analyze(List<String> texts, {bool asPassage = false}) async {
    final prefix = asPassage ? manifest.passagePrefix : manifest.queryPrefix;
    final heads = manifest.heads;
    final out = <ThoughtStructure>[];
    for (var i = 0; i < texts.length; i += 16) {
      final chunk = texts.sublist(i, min(i + 16, texts.length));
      final r = await _run([for (final t in chunk) _tokenizer.encode('$prefix$t', maxLength: manifest.maxLength)]);
      for (var k = 0; k < chunk.length; k++) {
        out.add(
          ThoughtStructure({
            for (final h in heads.values)
              if (h.name != 'nli' && r['${h.name}_logits'] != null)
                h.name: () {
                  final p = softmax(r['${h.name}_logits']![k], h.temperature);
                  return {for (final (j, l) in h.labels.indexed) l: p[j]};
                }(),
          }, Float32List.fromList(r['embedding']![k])),
        );
      }
    }
    return out;
  }

  /// Índice de versículos pre-calculado (int8 normalizado) para la recuperación canónica (S13).
  late final Future<VerseIndex?> verses = VerseIndex.open(dir, manifest);

  /// Catálogo de prototipos de pensamiento (S13/S15), si el paquete lo trae.
  late final Future<PrototypeCatalog?> prototypes = () async {
    final name = manifest.files['prototypes'];
    final f = name == null ? null : File('${dir.path}/$name');
    if (f == null || !await f.exists()) return null;
    return PrototypeCatalog.fromJson(
      jsonDecode(await f.readAsString()) as Map<String, dynamic>,
      threshold: manifest.prototypeThreshold,
    );
  }();

  @override
  double get routeThreshold => manifest.threshold;

  @override
  Map<String, dynamic> get card => manifest.card;

  @override
  Future<List<(int, double)>> nearestVerses(Float32List query, {int k = 20}) async =>
      await (await verses)?.nearest(query, k: k) ?? const [];

  @override
  Future<PrototypeCatalog?> get prototypeCatalog => prototypes;

  void dispose() => _session.release();
}

/// Embeddings de los ~31 000 versículos (int8, un vector por fila) y sus ids (uint32).
class VerseIndex {
  VerseIndex(this.vectors, this.ids, this.dim);

  final Int8List vectors;
  final Uint32List ids;
  final int dim;

  static Future<VerseIndex?> open(Directory dir, SystemOneManifest m) async {
    final v = m.files['verse_vectors'], i = m.files['verse_ids'];
    if (v == null || i == null) return null;
    final vf = File('${dir.path}/$v'), idf = File('${dir.path}/$i');
    if (!await vf.exists() || !await idf.exists()) return null;
    final vectors = Int8List.view((await vf.readAsBytes()).buffer);
    final ids = Uint32List.view(Uint8List.fromList(await idf.readAsBytes()).buffer);
    return VerseIndex(vectors, ids, m.dim);
  }

  /// k versículos más cercanos por coseno (fuerza bruta en un isolate: ~31k × 384 int8).
  Future<List<(int verseId, double score)>> nearest(Float32List query, {int k = 20}) {
    final vectors = this.vectors, ids = this.ids, dim = this.dim;
    return Isolate.run(() {
      final n = ids.length;
      final scores = Float32List(n);
      for (var r = 0; r < n; r++) {
        var s = 0.0;
        final base = r * dim;
        for (var c = 0; c < dim; c++) {
          s += vectors[base + c] * query[c];
        }
        scores[r] = s / 127;
      }
      final order = List<int>.generate(n, (i) => i)..sort((a, b) => scores[b].compareTo(scores[a]));
      return [for (final r in order.take(k)) (ids[r], scores[r].toDouble())];
    });
  }
}
