import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechAvailability {
  available,

  /// El reconocedor existe pero no ofrece modo sin conexión: no se usa (el audio saldría del dispositivo).
  onDeviceUnavailable,
  permissionDenied,
  unsupported,
}

/// Dictado de voz **en el dispositivo**. El audio nunca se guarda ni se envía a servidores.
abstract interface class SpeechService {
  Future<SpeechAvailability> initialize();

  bool get isListening;

  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    required void Function(double level) onLevel,
    required void Function(SpeechAvailability? problem) onDone,
  });

  Future<void> stop();
}

/// Acumula el texto de una sesión de dictado sobre lo que ya estaba escrito.
///
/// Muchos reconocedores de Android, tras una pausa, **reinician la hipótesis sin marcarla como final**:
/// el siguiente parcial trae solo la frase nueva. Si un parcial no continúa al anterior, el anterior
/// se conserva en vez de sobrescribirse.
class DictationBuffer {
  DictationBuffer([String initial = '']) : _committed = initial.trim();

  String _committed;
  String _partial = '';

  String get text => _join(_committed, _partial);

  String add(String words, {required bool isFinal}) {
    final next = words.trim();
    if (_partial.isNotEmpty && !_continues(_partial, next)) _committed = _join(_committed, _partial);
    _partial = next;
    if (isFinal) {
      _committed = _join(_committed, _partial);
      _partial = '';
    }
    return text;
  }

  static String _join(String a, String b) => a.isEmpty ? b : (b.isEmpty ? a : '$a $b');

  /// Una revisión de la misma frase empieza igual; una frase nueva, no.
  static bool _continues(String previous, String next) {
    if (next.isEmpty) return false;
    final a = previous.toLowerCase().split(' ').first;
    final b = next.toLowerCase().split(' ').first;
    if (a == b) return true;
    // El reconocedor a veces corrige la primera palabra ("no" → "nos"): se acepta si el texto no se acorta.
    final prefix = a.length < 2 ? a.length : 2;
    return next.length >= previous.length && b.startsWith(a.substring(0, prefix));
  }
}

class DeviceSpeechService implements SpeechService {
  final _stt = SpeechToText();
  String? _localeId;
  void Function(SpeechAvailability? problem)? _onDone;

  /// En Web el navegador envía el audio a la nube: deshabilitado por diseño (ADR / análisis C5).
  static bool get platformAllowed => !kIsWeb;

  @override
  bool get isListening => _stt.isListening;

  @override
  Future<SpeechAvailability> initialize() async {
    if (!platformAllowed) return SpeechAvailability.unsupported;
    try {
      final ok = await _stt.initialize(
        onError: _handleError,
        onStatus: (status) {
          if (status == SpeechToText.doneStatus) _finish(null);
        },
      );
      if (!ok) return (await _stt.hasPermission) ? SpeechAvailability.unsupported : SpeechAvailability.permissionDenied;
      final locales = await _stt.locales();
      final system = await _stt.systemLocale();
      final spanish = locales.where((l) => l.localeId.toLowerCase().startsWith('es')).toList();
      _localeId = system != null && system.localeId.toLowerCase().startsWith('es')
          ? system.localeId
          : (spanish.isNotEmpty ? spanish.first.localeId : null);
      return SpeechAvailability.available;
    } catch (_) {
      return SpeechAvailability.unsupported;
    }
  }

  void _handleError(SpeechRecognitionError error) {
    final msg = error.errorMsg.toLowerCase();
    // Android: el reconocedor offline no tiene el idioma o no soporta onDevice.
    final offlineProblem = msg.contains('language') || msg.contains('server') || msg.contains('network');
    if (error.permanent || offlineProblem) _finish(offlineProblem ? SpeechAvailability.onDeviceUnavailable : null);
  }

  void _finish(SpeechAvailability? problem) {
    final cb = _onDone;
    _onDone = null;
    cb?.call(problem);
  }

  @override
  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    required void Function(double level) onLevel,
    required void Function(SpeechAvailability? problem) onDone,
  }) async {
    _onDone = onDone;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords, r.finalResult),
      onSoundLevelChange: onLevel,
      listenOptions: SpeechListenOptions(
        onDevice: true,
        partialResults: true,
        listenMode: ListenMode.dictation,
        cancelOnError: true,
        localeId: _localeId,
        listenFor: const Duration(minutes: 10),
        pauseFor: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Future<void> stop() => _stt.stop();
}
