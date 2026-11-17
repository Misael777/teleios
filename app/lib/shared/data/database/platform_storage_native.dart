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
import '../../domain/repositories/attachment_store.dart';
import 'app_database.dart';

/// Debe cambiar si se regenera el asset con otro esquema (ver tool/build_bible_db.py).
const _bibleFileName = 'rv1909_v2.sqlite';

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

/// Carpeta privada de adjuntos (los archivos se escriben ya cifrados, ver EncryptedAttachmentStore).
Future<AttachmentStore> openRawAttachmentStore() async {
  final dir = Directory(p.join((await getApplicationSupportDirectory()).path, 'attachments'));
  await dir.create(recursive: true);
  return FileAttachmentStore(dir);
}

class FileAttachmentStore implements AttachmentStore {
  FileAttachmentStore(this.dir);

  final Directory dir;

  File _file(String fileName) {
    // Defensa contra rutas: solo nombres simples.
    if (fileName.contains('/') || fileName.contains(r'\') || fileName.contains('..')) {
      throw ArgumentError.value(fileName, 'fileName');
    }
    return File(p.join(dir.path, fileName));
  }

  @override
  Future<void> write(String fileName, Uint8List bytes) async {
    final tmp = File('${_file(fileName).path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(_file(fileName).path);
  }

  @override
  Future<Uint8List?> read(String fileName) async {
    final f = _file(fileName);
    return await f.exists() ? f.readAsBytes() : null;
  }

  @override
  Future<void> delete(String fileName) async {
    final f = _file(fileName);
    if (await f.exists()) await f.delete();
  }

  @override
  Future<List<String>> listFileNames() async => [
    await for (final e in dir.list())
      if (e is File && !e.path.endsWith('.tmp')) p.basename(e.path),
  ];

  @override
  Future<void> deleteAll() async {
    for (final name in await listFileNames()) {
      await delete(name);
    }
  }
}
