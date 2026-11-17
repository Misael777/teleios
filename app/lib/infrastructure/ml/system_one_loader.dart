/// Carga del System One según plataforma: en Web no hay ONNX Runtime ni dart:io (el modelo es opcional).
library;

export 'system_one_loader_unsupported.dart' if (dart.library.io) 'system_one_loader_native.dart';
