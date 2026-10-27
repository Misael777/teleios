import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/env.dart';

/// Llave de 256 bits de la base local, guardada en Keychain (iOS/macOS),
/// Keystore (Android) o DPAPI (Windows). Nunca sale del dispositivo.
///
/// Importante: el backup (Sprint 9) NO usa esta llave, sino una derivada de la
/// passphrase del usuario, para poder restaurar en otro dispositivo (ADR-004).
class DatabaseKeyStore {
  DatabaseKeyStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String get _keyName => 'teleios.${Env.name}.db_key.v1';

  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;
    final key = generateHexKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  Future<void> delete() => _storage.delete(key: _keyName);

  static String generateHexKey([Random? random]) {
    final rng = random ?? Random.secure();
    return List.generate(32, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}
