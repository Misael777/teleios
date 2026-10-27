/// Configuración por entorno, inyectada con `--dart-define-from-file=config/<env>.json`.
abstract final class Env {
  static const String name = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static bool get isProd => name == 'prod';

  /// Bases separadas por entorno para no mezclar datos de prueba con los reales.
  static String get databaseFileName => isProd ? 'teleios.db' : 'teleios_$name.db';
}
