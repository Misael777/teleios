import 'dart:io';

import '../../core/errors/failure.dart';
import '../../features/coherencia/domain/coherence_judge.dart';
import 'model_store.dart';
import 'nli_judge_bundle.dart';
import 'system_one_bundle.dart';

final _store = ModelStore();
final _nliStore = ModelStore(folder: ModelStore.nliJudgeFolder, kind: ModelStore.nliJudgeKind);

Future<SystemOneModel?> openInstalledSystemOne() async =>
    await _store.isInstalled ? OnnxSystemOne.open(await _store.dir) : null;

Future<String?> installedSystemOneVersion() => _store.installedVersion();

/// Instala un paquete del laboratorio según su manifest: System One o juez grande.
/// Devuelve (kind, versión) para que la interfaz invalide el proveedor correcto.
Future<(String, String)> installModelZip(String path) async {
  final file = File(path);
  final kind = await ModelStore.peekKind(file);
  final store = switch (kind) {
    ModelStore.systemOneKind => _store,
    ModelStore.nliJudgeKind => _nliStore,
    null => throw const ValidationFailure('El archivo no es un paquete de modelo (falta manifest.json).'),
    _ => throw ValidationFailure('Tipo de paquete desconocido: $kind.'),
  };
  return (kind!, await store.installZip(file));
}

Future<String> installSystemOneZip(String path) => _store.installZip(File(path));

Future<String> downloadSystemOne(Uri url, {void Function(double)? onProgress}) =>
    _store.download(url, onProgress: onProgress);

Future<void> uninstallSystemOne() => _store.uninstall();

// ─── Juez grande (opcional, §12.5) ─────────────────────────────────────────

Future<DeepJudge?> openInstalledNliJudge() async =>
    await _nliStore.isInstalled ? OnnxNliJudge.open(await _nliStore.dir) : null;

Future<String> downloadNliJudge(Uri url, {void Function(double)? onProgress}) =>
    _nliStore.download(url, onProgress: onProgress);

Future<void> uninstallNliJudge() => _nliStore.uninstall();
