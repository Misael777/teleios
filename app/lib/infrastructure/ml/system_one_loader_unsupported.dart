import '../../core/errors/failure.dart';
import '../../features/coherencia/domain/coherence_judge.dart';

const _unsupported = UnsupportedPlatformFailure('El modelo local no está disponible en esta plataforma.');

Future<SystemOneModel?> openInstalledSystemOne() async => null;

Future<String?> installedSystemOneVersion() async => null;

Future<(String, String)> installModelZip(String path) => Future.error(_unsupported);

Future<String> installSystemOneZip(String path) => Future.error(_unsupported);

Future<String> downloadSystemOne(Uri url, {void Function(double)? onProgress}) => Future.error(_unsupported);

Future<void> uninstallSystemOne() async {}

Future<DeepJudge?> openInstalledNliJudge() async => null;

Future<String> downloadNliJudge(Uri url, {void Function(double)? onProgress}) => Future.error(_unsupported);

Future<void> uninstallNliJudge() async {}
