import 'dart:typed_data';

import '../../../core/errors/failure.dart';
import '../../../features/estudio/domain/repositories.dart';
import 'app_database.dart';

const _message = 'Los módulos privados (Estudio, Bitácora, Altar) solo funcionan en la app móvil o de escritorio.';

Future<AppDatabase> openAppDatabase({required String hexKey, required String fileName}) =>
    throw const UnsupportedPlatformFailure(_message);

Future<void> deleteAppDatabaseFile(String fileName) async {}

Future<BibleRepository> openBibleRepository(Future<ByteData> Function() loadAsset) =>
    throw const UnsupportedPlatformFailure(_message);
