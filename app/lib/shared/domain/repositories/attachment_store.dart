import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Archivos privados (imágenes de la bitácora) en la carpeta de la app.
///
/// Se guardan por nombre de archivo, nunca por ruta absoluta: la carpeta cambia
/// entre dispositivos y al restaurar un backup.
abstract interface class AttachmentStore {
  Future<void> write(String fileName, Uint8List bytes);

  Future<Uint8List?> read(String fileName);

  Future<void> delete(String fileName);

  Future<List<String>> listFileNames();

  Future<void> deleteAll();
}

/// Implementación en memoria (tests y Web).
class MemoryAttachmentStore implements AttachmentStore {
  final files = <String, Uint8List>{};

  @override
  Future<void> write(String fileName, Uint8List bytes) async => files[fileName] = bytes;

  @override
  Future<Uint8List?> read(String fileName) async => files[fileName];

  @override
  Future<void> delete(String fileName) async => files.remove(fileName);

  @override
  Future<List<String>> listFileNames() async => files.keys.toList();

  @override
  Future<void> deleteAll() async => files.clear();
}

/// Cifra cada archivo con AES-256-GCM antes de delegar en [inner].
///
/// La base ya está cifrada; sin esto las fotos quedarían legibles en la carpeta de la app.
/// Formato en disco: nonce(12) | ciphertext | mac(16).
class EncryptedAttachmentStore implements AttachmentStore {
  EncryptedAttachmentStore(this.inner, this._key);

  final AttachmentStore inner;
  final SecretKey _key;
  static final _aes = AesGcm.with256bits();

  /// Deriva la llave de adjuntos a partir de la llave de la base (HKDF-SHA256).
  static Future<SecretKey> deriveKey(List<int> databaseKey) => Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  ).deriveKey(secretKey: SecretKey(databaseKey), info: 'teleios-attachments-v1'.codeUnits, nonce: const []);

  @override
  Future<void> write(String fileName, Uint8List bytes) async {
    final box = await _aes.encrypt(bytes, secretKey: _key, aad: fileName.codeUnits);
    await inner.write(fileName, box.concatenation());
  }

  @override
  Future<Uint8List?> read(String fileName) async {
    final data = await inner.read(fileName);
    if (data == null) return null;
    final box = SecretBox.fromConcatenation(data, nonceLength: 12, macLength: 16);
    return Uint8List.fromList(await _aes.decrypt(box, secretKey: _key, aad: fileName.codeUnits));
  }

  @override
  Future<void> delete(String fileName) => inner.delete(fileName);

  @override
  Future<List<String>> listFileNames() => inner.listFileNames();

  @override
  Future<void> deleteAll() => inner.deleteAll();
}
