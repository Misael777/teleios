import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/infrastructure/stt/speech_service.dart';

void main() {
  group('DictationBuffer', () {
    test('los parciales de la misma frase se reemplazan y el final se fija', () {
      final b = DictationBuffer();
      b.add('Señor', isFinal: false);
      b.add('Señor te pido', isFinal: false);
      expect(b.add('Señor te pido paciencia', isFinal: true), 'Señor te pido paciencia');
      expect(b.add('y sabiduría', isFinal: true), 'Señor te pido paciencia y sabiduría');
    });

    test('si el reconocedor reinicia la frase sin marcarla final, no se pierde la anterior', () {
      final b = DictationBuffer();
      b.add('Padre gracias por este día', isFinal: false);
      expect(b.add('perdóname', isFinal: false), 'Padre gracias por este día perdóname');
      expect(b.add('perdóname por mi enojo', isFinal: false), 'Padre gracias por este día perdóname por mi enojo');
    });

    test('continúa lo que ya estaba escrito', () {
      final b = DictationBuffer('  Texto previo. ');
      expect(b.add('Amén', isFinal: true), 'Texto previo. Amén');
    });

    test('acepta que se corrija la primera palabra sin duplicar', () {
      final b = DictationBuffer();
      b.add('no te', isFinal: false);
      expect(b.add('nos te pido', isFinal: false), 'nos te pido');
    });

    test('un parcial vacío conserva lo dictado', () {
      final b = DictationBuffer();
      b.add('hola', isFinal: false);
      expect(b.add('', isFinal: false), 'hola');
    });
  });
}
