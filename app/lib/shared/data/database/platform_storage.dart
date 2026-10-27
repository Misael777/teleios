/// Apertura de almacenamiento según plataforma.
///
/// Los módulos privados requieren `dart:io` (Android, iOS, Desktop). En Web se lanza
/// [UnsupportedPlatformFailure]: la zona privada no corre en el navegador (ver análisis I5).
library;

export 'platform_storage_unsupported.dart' if (dart.library.io) 'platform_storage_native.dart';
