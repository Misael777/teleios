import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../../core/errors/failure.dart';
import '../../../features/estudio/data/sqlite_bible_repository.dart';
import '../../../features/estudio/domain/repositories.dart';
import 'app_database.dart';

/// Debe cambiar si se regenera el asset con otro esquema (ver tool/build_bible_db.py).
const _bibleFileName = 'rv1909_v1.sqlite';

Future<AppDatabase> openAppDatabase({required String hexKey, required String fileName}) async {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey)) {
    throw const StorageFailure('Llave de cifrado con formato inválido.');
  }
  final dir = await getApplicationSupportDirectory();
  final db = AppDatabase(encryptedExecutor(File(p.join(dir.path, fileName)), hexKey));
  try {
    // Fuerza la apertura: si la llave no corresponde, falla aquí y no en la primera pantalla.
    await db.customSelect('SELECT count(*) FROM sqlite_master').get();
  } catch (e) {
    await db.close();
    throw StorageFailure('No se pudo abrir la base cifrada.', e);
  }
  return db;
}

/// Executor de Drift sobre un archivo cifrado con SQLite3MultipleCiphers.
QueryExecutor encryptedExecutor(File file, String hexKey) => NativeDatabase.createInBackground(
  file,
  setup: (raw) {
    // Sin SQLite3MultipleCiphers el PRAGMA key se ignora en silencio y la base
    // quedaría en texto plano: preferimos fallar.
    if (raw.select('PRAGMA cipher;').isEmpty) {
      throw StateError('SQLite3MultipleCiphers no está activo (revisar hooks en pubspec.yaml).');
    }
    raw.execute("PRAGMA hexkey = '$hexKey';");
  },
);

Future<void> deleteAppDatabaseFile(String fileName) async {
  final dir = await getApplicationSupportDirectory();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File(p.join(dir.path, '$fileName$suffix'));
    if (await file.exists()) await file.delete();
  }
}

/// Descomprime el asset la primera vez y abre la Biblia en modo solo lectura.
Future<BibleRepository> openBibleRepository(Future<ByteData> Function() loadAsset) async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, 'bible', _bibleFileName));
  if (!await file.exists()) {
    await file.parent.create(recursive: true);
    final data = await loadAsset();
    final compressed = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final bytes = await Isolate.run(() => gzip.decode(compressed));
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(file.path);
  }
  return SqliteBibleRepository(sqlite3.open(file.path, mode: OpenMode.readOnly));
}
