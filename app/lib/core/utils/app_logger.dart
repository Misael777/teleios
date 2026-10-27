import 'dart:developer' as developer;

/// Logger local. No envía nada fuera del dispositivo (sin telemetría por defecto).
abstract final class AppLogger {
  static void info(String message) => developer.log(message, name: 'teleios');

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      developer.log(message, name: 'teleios', level: 1000, error: error, stackTrace: stackTrace);
}
