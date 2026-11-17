import 'dart:math';

/// Formato de especiales y de pares según el modelo. Los dos comparten unk = 3, así que la segmentación
/// es la misma; cambia cómo se arma la secuencia.
enum TokenizerFormat {
  /// XLM-R / System One: `<s> A </s></s> B </s>`; `<s>` 0, `<pad>` 1, `</s>` 2.
  xlmr(cls: 0, pad: 1, sep: 2, pairSeps: 2),

  /// DeBERTa-v3 / juez grande: `[CLS] A [SEP] B [SEP]`; [PAD] 0, [CLS] 1, [SEP] 2.
  deberta(cls: 1, pad: 0, sep: 2, pairSeps: 1);

  const TokenizerFormat({required this.cls, required this.pad, required this.sep, required this.pairSeps});

  final int cls;
  final int pad;
  final int sep;

  /// Separadores entre A y B.
  final int pairSeps;

  static TokenizerFormat parse(String? name) => name == 'deberta' ? deberta : xlmr;
}

/// Tokenizador SentencePiece Unigram (el de XLM-R / multilingual-e5 y el de mDeBERTa) en Dart puro.
///
/// El laboratorio exporta el vocabulario como `sentencepiece.tsv` (una pieza y su log-probabilidad
/// por línea; el número de línea es el id). La segmentación es Viterbi: la de mayor puntaje total.
/// Paridad verificada contra `tokenizers` de Hugging Face en test/infrastructure/ml/ (si hay modelo).
class UnigramTokenizer {
  UnigramTokenizer._(this._pieces, this._maxLen, this._unkScore, this.format);

  /// [lines]: "pieza\tpuntaje", en orden de id.
  factory UnigramTokenizer.fromTsv(Iterable<String> lines, {TokenizerFormat format = TokenizerFormat.xlmr}) {
    final pieces = <String, (int, double)>{};
    var maxLen = 1;
    var minScore = 0.0;
    var id = 0;
    for (final line in lines) {
      final tab = line.lastIndexOf('\t');
      if (tab <= 0) {
        id++;
        continue;
      }
      final piece = line.substring(0, tab);
      final score = double.parse(line.substring(tab + 1));
      pieces.putIfAbsent(piece, () => (id, score));
      maxLen = max(maxLen, piece.length);
      minScore = min(minScore, score);
      id++;
    }
    return UnigramTokenizer._(pieces, maxLen, minScore - 10, format);
  }

  final TokenizerFormat format;

  final Map<String, (int, double)> _pieces;
  final int _maxLen;
  final double _unkScore;

  // Especiales de XLM-R (el formato por defecto); unk es el mismo en ambos formatos.
  static const bos = 0;
  static const pad = 1;
  static const eos = 2;
  static const unk = 3;

  static const _space = '▁';

  /// Normalización mínima (XLM-R usa NMT-NFKC): espacios colapsados, prefijo "▁".
  static String normalize(String text) => _space + text.trim().replaceAll(RegExp(r'\s+'), ' ').replaceAll(' ', _space);

  List<int> encodePieces(String text) {
    final s = normalize(text);
    final n = s.length;
    final best = List<double>.filled(n + 1, double.negativeInfinity);
    final back = List<int>.filled(n + 1, -1);
    final ids = List<int>.filled(n + 1, unk);
    best[0] = 0;
    for (var end = 1; end <= n; end++) {
      for (var len = 1; len <= min(_maxLen, end); len++) {
        final start = end - len;
        if (best[start] == double.negativeInfinity) continue;
        final hit = _pieces[s.substring(start, end)];
        final (id, score) = hit ?? (len == 1 ? (unk, _unkScore) : (-1, 0.0));
        if (id < 0) continue;
        final total = best[start] + score;
        if (total > best[end]) {
          best[end] = total;
          back[end] = start;
          ids[end] = id;
        }
      }
    }
    final out = <int>[];
    for (var end = n; end > 0; end = back[end]) {
      out.add(ids[end]);
    }
    // Desconocidos consecutivos se funden en uno (como sentencepiece).
    final merged = <int>[];
    for (final id in out.reversed) {
      if (id == unk && merged.isNotEmpty && merged.last == unk) continue;
      merged.add(id);
    }
    return merged;
  }

  /// `CLS A SEP` o, para pares, `CLS A SEP (SEP) B SEP` según [format], truncado a [maxLength] quitando
  /// del final del más largo (longest_first, como Hugging Face).
  List<int> encode(String a, {String? b, int maxLength = 128}) {
    final f = format;
    var pa = encodePieces(a);
    var pb = b == null ? const <int>[] : encodePieces(b);
    final budget = maxLength - (b == null ? 2 : 2 + f.pairSeps);
    while (pa.length + pb.length > budget) {
      if (pa.length >= pb.length) {
        pa = pa.sublist(0, pa.length - 1);
      } else {
        pb = pb.sublist(0, pb.length - 1);
      }
    }
    return [
      f.cls,
      ...pa,
      f.sep,
      if (b != null) ...[for (var i = 1; i < f.pairSeps; i++) f.sep, ...pb, f.sep],
    ];
  }
}
