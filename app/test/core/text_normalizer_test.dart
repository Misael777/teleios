import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/utils/text_normalizer.dart';

void main() {
  group('normalize', () {
    test('quita tildes y pasa a minúsculas', () {
      expect(TextNormalizer.normalize('Él PERDONÓ a Ñuño'), 'el perdono a nuno');
    });
  });

  group('tokenize', () {
    test('separa palabras y omite stopwords', () {
      expect(TextNormalizer.tokenize('Hoy leí la carta de Pablo, ¡qué paciencia!'), [
        'lei',
        'carta',
        'pablo',
        'paciencia',
      ]);
    });
  });

  group('stem', () {
    test('une formas de la misma raíz', () {
      expect(TextNormalizer.stem('paciencia'), TextNormalizer.stem('paciente'));
      expect(TextNormalizer.stem('perdonar'), TextNormalizer.stem('perdón'));
      expect(TextNormalizer.stem('perdonado'), TextNormalizer.stem('perdonar'));
      expect(TextNormalizer.stem('hijos'), TextNormalizer.stem('hijo'));
    });

    test('no recorta palabras cortas por debajo de 4 letras', () {
      expect(TextNormalizer.stem('fe'), 'fe');
      expect(TextNormalizer.stem('paz'), 'paz');
      expect(TextNormalizer.stem('amor'), 'amor');
    });

    test('distingue esperar de esperanza', () {
      expect(TextNormalizer.stem('esperar'), isNot(TextNormalizer.stem('esperanza')));
    });
  });

  test('key compara nombres de tópicos sin importar formato', () {
    expect(TextNormalizer.key('  Dominio   Propio '), TextNormalizer.key('dominio propio'));
    expect(TextNormalizer.key('Soberanía'), TextNormalizer.key('soberania'));
  });
}
