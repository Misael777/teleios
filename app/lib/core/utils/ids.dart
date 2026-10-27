import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// UUID v7: ordenable por tiempo y sin colisiones entre dispositivos (útil para backup/sync).
String newId() => _uuid.v7();
