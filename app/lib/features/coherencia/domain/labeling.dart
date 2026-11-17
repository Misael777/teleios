import 'dart:math';

import 'belief.dart';

/// Ítem compartido del protocolo de etiquetado (§10.1). Viene del laboratorio
/// (assets/ml/shared_items_v1.json): nunca contiene texto de diarios.
class SharedItem {
  const SharedItem({
    required this.id,
    required this.type,
    required this.prompt,
    required this.a,
    required this.b,
    required this.options,
    this.gold,
  });

  factory SharedItem.fromJson(Map<String, dynamic> j) => SharedItem(
    id: j['id'] as String,
    type: j['type'] as String,
    prompt: j['prompt'] as String,
    a: j['a'] as String,
    b: j['b'] as String,
    options: {for (final e in (j['options'] as Map).entries) e.key as String: e.value as String},
    gold: j['gold'] as String?,
  );

  final String id;

  /// 'nli' (proposición ↔ versículo o pensamiento ↔ pensamiento) | 'escenario' (acción ↔ creencia).
  final String type;
  final String prompt;
  final String a;
  final String b;

  /// valor guardado → texto del botón.
  final Map<String, String> options;

  /// Respuesta conocida (ítem de oro), o null.
  final String? gold;

  bool get isGold => gold != null;
}

class SharedLabel {
  const SharedLabel({
    required this.itemId,
    required this.label,
    required this.isGold,
    required this.durationMs,
    required this.answeredAt,
    this.correct,
  });

  final String itemId;
  final String label;
  final bool isGold;
  final bool? correct;
  final int durationMs;
  final DateTime answeredAt;

  Map<String, dynamic> toJson() => {
    'item': itemId,
    'label': label,
    'gold': isGold,
    if (correct != null) 'correct': correct,
    'ms': durationMs,
    // Solo el día: la hora exacta no aporta al modelo y es un dato de comportamiento.
    'day': answeredAt.toIso8601String().substring(0, 10),
  };
}

/// Predicción del juez y lo que el usuario decidió (alimenta el gráfico 8).
class JudgeFeedbackEntry {
  const JudgeFeedbackEntry({
    required this.id,
    required this.judgeVersion,
    required this.task,
    required this.predicted,
    required this.probability,
    required this.userLabel,
    required this.createdAt,
  });

  final String id;
  final String judgeVersion;
  final String task;
  final String predicted;

  /// Probabilidad que el juez dio a [predicted].
  final double probability;
  final String userLabel;
  final DateTime createdAt;

  bool get agrees => predicted == userLabel;

  Map<String, dynamic> toJson() => {
    'judge': judgeVersion,
    'task': task,
    'predicted': predicted,
    'p': double.parse(probability.toStringAsFixed(4)),
    'user': userLabel,
  };
}

class PatternAssignmentRecord {
  const PatternAssignmentRecord({
    required this.actionKind,
    required this.actionId,
    required this.prototypeId,
    required this.similarity,
    required this.modelVersion,
    required this.createdAt,
    this.confirmed,
  });

  final ActionKind actionKind;
  final String actionId;
  final String prototypeId;
  final double similarity;
  final String modelVersion;
  final bool? confirmed;
  final DateTime createdAt;
}

/// Siguiente ítem: primero los no respondidos; los de oro intercalados ~1 de cada 5 (§10.3).
SharedItem? nextItem(List<SharedItem> items, Set<String> answered, {Random? random}) {
  final pending = [
    for (final i in items)
      if (!answered.contains(i.id)) i,
  ];
  if (pending.isEmpty) return null;
  final gold = pending.where((i) => i.isGold).toList();
  final regular = pending.where((i) => !i.isGold).toList();
  final r = random ?? Random();
  if (gold.isNotEmpty && (regular.isEmpty || r.nextDouble() < 0.2)) return gold[r.nextInt(gold.length)];
  return regular.first;
}

/// Fiabilidad propia medida con los ítems de oro.
({int n, int correct, double? accuracy}) goldAccuracy(Iterable<SharedLabel> labels) {
  final gold = labels.where((l) => l.isGold && l.correct != null).toList();
  final ok = gold.where((l) => l.correct!).length;
  return (n: gold.length, correct: ok, accuracy: gold.isEmpty ? null : ok / gold.length);
}

/// Archivo exportable de etiquetas confirmadas (§10): solo ítems compartidos, veredictos sobre el juez y
/// confirmaciones de prototipos. Ningún texto privado sale del teléfono.
Map<String, dynamic> exportLabels({
  required String annotatorId,
  required String itemsVersion,
  required List<SharedLabel> labels,
  required List<JudgeFeedbackEntry> feedback,
  required List<PatternAssignmentRecord> patterns,
}) => {
  'schema': 1,
  'annotator': annotatorId,
  'items_version': itemsVersion,
  'shared_labels': [for (final l in labels) l.toJson()],
  'judge_feedback': [for (final f in feedback) f.toJson()],
  'pattern_confirmations': [
    for (final p in patterns)
      if (p.confirmed != null) {'prototype': p.prototypeId, 'confirmed': p.confirmed, 'model': p.modelVersion},
  ],
};

// ─── Gráfico 8: calibración y confusión ─────────────────────────────────────

class ReliabilityBin {
  const ReliabilityBin(this.lo, this.hi, this.n, this.meanConfidence, this.accuracy);

  final double lo;
  final double hi;
  final int n;
  final double meanConfidence;
  final double accuracy;
}

class CalibrationReport {
  const CalibrationReport({
    required this.bins,
    required this.ece,
    required this.brier,
    required this.n,
    required this.confusion,
    required this.labels,
  });

  final List<ReliabilityBin> bins;

  /// Error de calibración esperado (ponderado por n).
  final double ece;

  /// Brier binario de "el juez acertó".
  final double brier;
  final int n;

  /// confusion[real][predicho], en el orden de [labels].
  final List<List<int>> confusion;
  final List<String> labels;

  double get accuracy =>
      n == 0 ? 0 : [for (var i = 0; i < labels.length; i++) confusion[i][i]].fold(0, (a, b) => a + b) / n;

  static CalibrationReport of(List<JudgeFeedbackEntry> entries, {int bins = 10}) {
    final labels = {
      for (final e in entries) ...[e.predicted, e.userLabel],
    }.toList()..sort();
    final confusion = [for (final _ in labels) List<int>.filled(labels.length, 0)];
    final buckets = List.generate(bins, (_) => <JudgeFeedbackEntry>[]);
    var brier = 0.0;
    for (final e in entries) {
      confusion[labels.indexOf(e.userLabel)][labels.indexOf(e.predicted)]++;
      buckets[min(bins - 1, (e.probability * bins).floor())].add(e);
      brier += pow(e.probability - (e.agrees ? 1 : 0), 2);
    }
    final out = <ReliabilityBin>[];
    var ece = 0.0;
    for (var i = 0; i < bins; i++) {
      final b = buckets[i];
      if (b.isEmpty) continue;
      final conf = b.fold(0.0, (a, e) => a + e.probability) / b.length;
      final acc = b.where((e) => e.agrees).length / b.length;
      out.add(ReliabilityBin(i / bins, (i + 1) / bins, b.length, conf, acc));
      ece += b.length / entries.length * (conf - acc).abs();
    }
    return CalibrationReport(
      bins: out,
      ece: ece,
      brier: entries.isEmpty ? 0 : brier / entries.length,
      n: entries.length,
      confusion: confusion,
      labels: labels,
    );
  }
}
