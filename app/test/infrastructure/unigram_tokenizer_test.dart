import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/infrastructure/ml/unigram_tokenizer.dart';

void main() {
  // Vocabulario mínimo con los especiales de XLM-R en sus ids.
  final tok = UnigramTokenizer.fromTsv([
    '<s>\t0',
    '<pad>\t0',
    '</s>\t0',
    '<unk>\t0',
    '▁Dios\t-2',
    '▁pro\t-4',
    'vee\t-4',
    '▁provee\t-3',
    '▁no\t-2',
    'p\t-6',
    'r\t-6',
    'o\t-6',
  ]);

  test('Viterbi elige la segmentación de mayor puntaje', () {
    expect(tok.encodePieces('Dios provee'), [4, 7]); // "▁provee" (−3) gana a "▁pro"+"vee" (−8)
    expect(tok.encodePieces('  Dios   no '), [4, 8]);
  });

  test('desconocidos se funden y se arman pares como XLM-R', () {
    expect(tok.encodePieces('Dios xyz'), [4, UnigramTokenizer.unk]);
    expect(tok.encode('Dios', b: 'no'), [0, 4, 2, 2, 8, 2]);
    expect(tok.encode('Dios provee no', maxLength: 4), [0, 4, 7, 2]);
  });

  test('formato DeBERTa: [CLS] A [SEP] B [SEP] con sus ids', () {
    final deb = UnigramTokenizer.fromTsv([
      '[PAD]	0',
      '[CLS]	0',
      '[SEP]	0',
      '[UNK]	0',
      '▁Dios	-2',
      '▁no	-2',
    ], format: TokenizerFormat.deberta);
    expect(deb.encode('Dios', b: 'no'), [1, 4, 2, 5, 2]);
    expect(deb.encode('Dios xyz'), [1, 4, UnigramTokenizer.unk, 2]);
    expect(deb.encode('Dios no', b: 'Dios no', maxLength: 5), [1, 4, 2, 4, 2]);
  });

  // Paridad con `tokenizers` de Hugging Face: corre solo si hay un modelo exportado por el laboratorio.
  final dir = Platform.environment['TELEIOS_MODEL_DIR'];
  test(
    'paridad con el tokenizador del laboratorio',
    () {
      final real = UnigramTokenizer.fromTsv(File('$dir/sentencepiece.tsv').readAsLinesSync());
      for (final line in File('$dir/tokenizer_cases.tsv').readAsLinesSync()) {
        final [text, ids] = line.split('\t');
        expect(real.encode(text, maxLength: 512).join(' '), ids, reason: text);
      }
    },
    skip: dir == null ? 'TELEIOS_MODEL_DIR no definido' : false,
  );

  // Juez grande (ml/scripts/nli_export.py): casos "a<TAB>b<TAB>ids", b vacío = texto suelto.
  final nliDir = Platform.environment['TELEIOS_NLI_DIR'];
  test(
    'paridad del tokenizador del juez grande (DeBERTa)',
    () {
      final real = UnigramTokenizer.fromTsv(
        File('$nliDir/sentencepiece.tsv').readAsLinesSync(),
        format: TokenizerFormat.deberta,
      );
      for (final line in File('$nliDir/tokenizer_cases.tsv').readAsLinesSync()) {
        final [a, b, ids] = line.split('	');
        expect(real.encode(a, b: b.isEmpty ? null : b, maxLength: 512).join(' '), ids, reason: '$a | $b');
      }
    },
    skip: nliDir == null ? 'TELEIOS_NLI_DIR no definido' : false,
  );
}
