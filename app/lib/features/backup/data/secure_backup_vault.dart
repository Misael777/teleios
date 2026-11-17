import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/env.dart';
import '../domain/backup_crypto.dart';
import '../domain/backup_service.dart';

/// Material de llaves del respaldo en Keychain / Keystore / DPAPI (nunca en la base ni en prefs).
class SecureBackupKeyVault implements BackupKeyVault {
  SecureBackupKeyVault([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String get _key => 'teleios.${Env.name}.backup_keys.v1';

  @override
  Future<BackupKeyMaterial?> load() async {
    final raw = await _storage.read(key: _key);
    return raw == null ? null : BackupKeyMaterial.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(BackupKeyMaterial keys) => _storage.write(key: _key, value: jsonEncode(keys.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
