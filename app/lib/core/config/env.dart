/// Configuración por entorno, inyectada con `--dart-define-from-file=config/<env>.json`.
abstract final class Env {
  static const String name = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

  static bool get isProd => name == 'prod';

  /// URL del zip del System One (ml/scripts/s14_export.py). Vacía: solo se puede importar desde archivo.
  static const String modelBundleUrl = String.fromEnvironment('MODEL_BUNDLE_URL');

  /// URL del zip del juez grande (ml/scripts/nli_export.py). Vacía: solo se puede importar desde archivo.
  static const String nliBundleUrl = String.fromEnvironment('NLI_BUNDLE_URL');

  /// Bases separadas por entorno para no mezclar datos de prueba con los reales.
  static String get databaseFileName => isProd ? 'teleios.db' : 'teleios_$name.db';
}
