import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../../../core/errors/failure.dart';

class RemoteBackup {
  const RemoteBackup({required this.id, required this.name, required this.createdAt, this.sizeBytes});

  final String id;
  final String name;
  final DateTime createdAt;
  final int? sizeBytes;
}

/// Backups en la carpeta oculta de la app en el Google Drive del usuario (`appDataFolder`).
///
/// - Scope mínimo `drive.appdata`: la app no ve el resto del Drive y el usuario no ve esta carpeta.
/// - Google guarda un archivo cifrado que no puede leer (la llave depende de la contraseña del usuario).
/// - Requiere configurar un proyecto OAuth propio: ver docs/GOOGLE-DRIVE-SETUP.md.
class GoogleDriveBackupDestination {
  GoogleDriveBackupDestination({this.keep = 5});

  final int keep;

  static const scopes = ['https://www.googleapis.com/auth/drive.appdata'];
  static const _serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const _iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  GoogleSignInAccount? _account;
  Future<void>? _initialized;

  /// google_sign_in solo tiene implementación en Android e iOS.
  static bool get platformSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  /// ¿Se compiló la app con las credenciales OAuth? (`--dart-define-from-file=config/ENTORNO.json`)
  static bool get isConfigured => switch (defaultTargetPlatform) {
    TargetPlatform.android => _serverClientId.isNotEmpty,
    TargetPlatform.iOS => _iosClientId.isNotEmpty,
    _ => false,
  };

  static bool get available => platformSupported && isConfigured;

  String? get email => _account?.email;

  Future<void> _init() => _initialized ??= GoogleSignIn.instance.initialize(
    clientId: _iosClientId.isEmpty ? null : _iosClientId,
    serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
  );

  /// Reanuda la sesión sin mostrar UI (para el respaldo automático).
  Future<bool> restoreSession() async {
    if (!available) return false;
    await _init();
    _account = await GoogleSignIn.instance.attemptLightweightAuthentication();
    return _account != null;
  }

  /// Inicia sesión y pide permiso para la carpeta de la app.
  Future<String> connect() async {
    if (!available) throw const BackupFailure('Google Drive no está disponible en esta versión de la app.');
    await _init();
    try {
      _account = await GoogleSignIn.instance.authenticate(scopeHint: scopes);
      await _account!.authorizationClient.authorizeScopes(scopes);
      return _account!.email;
    } on GoogleSignInException catch (e) {
      throw BackupFailure(
        e.code == GoogleSignInExceptionCode.canceled ? 'Conexión cancelada.' : 'No se pudo conectar con Google.',
      );
    }
  }

  Future<void> disconnect() async {
    await _init();
    await GoogleSignIn.instance.disconnect();
    _account = null;
  }

  Future<drive.DriveApi> _api({bool prompt = false}) async {
    final account = _account ?? (await restoreSession() ? _account : null);
    if (account == null) throw const BackupFailure('Conecta tu cuenta de Google primero.');
    final headers = await account.authorizationClient.authorizationHeaders(scopes, promptIfNecessary: prompt);
    if (headers == null) throw const BackupFailure('Falta el permiso de Google Drive.');
    return drive.DriveApi(_AuthClient(headers));
  }

  Future<void> upload(Uint8List bytes, String fileName, {bool interactive = true}) async {
    final api = await _api(prompt: interactive);
    await api.files.create(
      drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'],
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/octet-stream'),
    );
    // Rotación: conserva los [keep] más recientes.
    final all = await list(interactive: interactive);
    for (final old in all.skip(keep)) {
      await api.files.delete(old.id);
    }
  }

  Future<List<RemoteBackup>> list({bool interactive = true}) async {
    final api = await _api(prompt: interactive);
    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name contains '.teleios' and trashed = false",
      orderBy: 'createdTime desc',
      $fields: 'files(id,name,size,createdTime)',
    );
    return [
      for (final f in result.files ?? const <drive.File>[])
        RemoteBackup(
          id: f.id!,
          name: f.name ?? '',
          createdAt: f.createdTime?.toLocal() ?? DateTime(0),
          sizeBytes: int.tryParse(f.size ?? ''),
        ),
    ];
  }

  Future<Uint8List> download(String id) async {
    final api = await _api(prompt: true);
    final media = await api.files.get(id, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final builder = BytesBuilder(copy: false);
    await for (final chunk in media.stream) {
      builder.add(chunk);
    }
    return builder.toBytes();
  }
}

class _AuthClient extends http.BaseClient {
  _AuthClient(this._headers);

  final Map<String, String> _headers;
  final _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => _inner.send(request..headers.addAll(_headers));
}
