import 'dart:convert';

import 'package:drift/drift.dart';

import '../../shared/data/database/app_database.dart';

/// Exporta todo el contenido del usuario en JSON legible (derecho de acceso/portabilidad).
///
/// ⚠️ El archivo resultante NO está cifrado: se avisa al usuario antes de compartirlo.
class DataExportService {
  DataExportService(this._db);

  final AppDatabase _db;

  static const formatVersion = 1;

  Future<Map<String, Object?>> exportMap({DateTime? now}) async {
    final tables = <String, Object?>{};
    for (final table in _db.allTables) {
      final rows = await _db.select(table).get();
      tables[table.actualTableName] = [for (final row in rows) (row as DataClass).toJson()];
    }
    return {
      'app': 'TELEIOS',
      'format_version': formatVersion,
      'schema_version': _db.schemaVersion,
      'exported_at': (now ?? DateTime.now()).toIso8601String(),
      'tables': tables,
    };
  }

  Future<Uint8List> exportBytes() async =>
      Uint8List.fromList(utf8.encode(const JsonEncoder.withIndent('  ').convert(await exportMap())));
}
