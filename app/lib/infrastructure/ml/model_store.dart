import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/errors/failure.dart';

/// Instala un paquete de modelo (zip del laboratorio) en la carpeta de la app: el System One
/// (ml/scripts/s14_export.py) o el juez grande (ml/scripts/nli_export.py, kind "nli-judge"). Nada se
/// descarga sin que el usuario lo pida: los modelos son opcionales (+~100 y +~140 MB).
class ModelStore {
  ModelStore({Future<Directory> Function()? baseDir, this.folder = systemOneFolder, this.kind = systemOneKind})
    : _baseDir = baseDir ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _baseDir;

  static const systemOneFolder = 'models/system-one';
  static const nliJudgeFolder = 'models/nli-judge';
  static const systemOneKind = 'system-one';
  static const nliJudgeKind = 'nli-judge';

  final String folder;

  /// Valor de `kind` que debe traer el manifest (los paquetes del System One no lo declaran).
  final String kind;

  /// `kind` del manifest dentro de un zip, sin descomprimir el resto (null si no hay manifest).
  static Future<String?> peekKind(File zip) => Isolate.run(() {
    final archive = ZipDecoder().decodeStream(InputFileStream(zip.path));
    for (final file in archive) {
      if (file.isFile && p.basename(file.name) == 'manifest.json') {
        final json = jsonDecode(utf8.decode(file.content)) as Map<String, dynamic>;
        return json['kind'] as String? ?? systemOneKind;
      }
    }
    return null;
  });

  Future<Directory> get dir async => Directory(p.join((await _baseDir()).path, folder));

  Future<bool> get isInstalled async => File(p.join((await dir).path, 'manifest.json')).exists();

  /// Versión instalada (del manifest), o null.
  Future<String?> installedVersion() async {
    final f = File(p.join((await dir).path, 'manifest.json'));
    if (!await f.exists()) return null;
    return (jsonDecode(await f.readAsString()) as Map<String, dynamic>)['version'] as String?;
  }

  /// Descomprime y valida: manifest con versión y todos los archivos que declara.
  Future<String> installZip(File zip) async {
    final target = await dir;
    final staging = Directory('${target.path}.staging');
    if (await staging.exists()) await staging.delete(recursive: true);
    await staging.create(recursive: true);
    await Isolate.run(() {
      final archive = ZipDecoder().decodeStream(InputFileStream(zip.path));
      for (final file in archive) {
        final name = p.basename(file.name);
        if (!file.isFile || name.startsWith('.')) continue;
        final out = OutputFileStream(p.join(staging.path, name));
        file.writeContent(out);
        out.closeSync();
      }
    });
    final manifest = File(p.join(staging.path, 'manifest.json'));
    if (!await manifest.exists()) {
      await staging.delete(recursive: true);
      throw const ValidationFailure('El archivo no es un paquete del System One (falta manifest.json).');
    }
    final json = jsonDecode(await manifest.readAsString()) as Map<String, dynamic>;
    if ((json['kind'] as String? ?? systemOneKind) != kind) {
      await staging.delete(recursive: true);
      throw ValidationFailure('El paquete es de tipo "${json['kind']}", no "$kind".');
    }
    for (final name in (json['files'] as Map).values) {
      if (!await File(p.join(staging.path, name as String)).exists()) {
        await staging.delete(recursive: true);
        throw ValidationFailure('El paquete está incompleto: falta $name.');
      }
    }
    if (await target.exists()) await target.delete(recursive: true);
    await staging.rename(target.path);
    return json['version'] as String;
  }

  /// Descarga el zip desde [url] (configurable con MODEL_BUNDLE_URL) e instala.
  Future<String> download(Uri url, {void Function(double progress)? onProgress}) async {
    final tmp = File(p.join((await _baseDir()).path, '$kind-download.zip'));
    final client = http.Client();
    try {
      final response = await client.send(http.Request('GET', url));
      if (response.statusCode != 200) throw StorageFailure('Descarga fallida (HTTP ${response.statusCode}).');
      final total = response.contentLength ?? 0;
      var received = 0;
      final sink = tmp.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
      await sink.close();
      return await installZip(tmp);
    } finally {
      client.close();
      if (await tmp.exists()) await tmp.delete();
    }
  }

  Future<void> uninstall() async {
    final d = await dir;
    if (await d.exists()) await d.delete(recursive: true);
  }
}
