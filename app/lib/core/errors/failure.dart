/// Errores de dominio. Las capas superiores muestran [message] al usuario.
sealed class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message, [this.cause]);

  final Object? cause;
}

final class UnsupportedPlatformFailure extends Failure {
  const UnsupportedPlatformFailure(super.message);
}

/// Errores del respaldo cifrado (contraseña incorrecta, archivo dañado, versión no soportada).
final class BackupFailure extends Failure {
  const BackupFailure(super.message);
}
