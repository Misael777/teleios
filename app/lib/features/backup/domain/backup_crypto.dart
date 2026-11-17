import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../../../core/errors/failure.dart';

/// Formato de backup cifrado de TELEIOS (ADR-004).
///
/// Archivo:  "TELEIOSBK" (9) | versión (1) | largo de cabecera uint32 BE (4) | cabecera JSON | cuerpo
/// Cuerpo:   AES-256-GCM(nonce 12 | ciphertext | mac 16) con la **llave de datos**; AAD = bytes de la cabecera.
///
/// La llave de datos (aleatoria, 256 bits) va en la cabecera envuelta dos veces:
///  - con una llave derivada de la contraseña (Argon2id), y
///  - con una llave derivada del código de recuperación (HKDF; el código ya tiene 256 bits de entropía).
/// Así se puede restaurar con cualquiera de los dos, y cambiar la contraseña sin re-cifrar los datos.

class KdfParams {
  const KdfParams({required this.memoryKiB, required this.iterations, required this.parallelism});

  /// Recomendación OWASP para Argon2id (m = 19 MiB, t = 2, p = 1).
  static const standard = KdfParams(memoryKiB: 19456, iterations: 2, parallelism: 1);

  /// Solo para tests: rápido e inseguro.
  static const testing = KdfParams(memoryKiB: 64, iterations: 1, parallelism: 1);

  final int memoryKiB;
  final int iterations;
  final int parallelism;

  Map<String, Object> toJson() => {'alg': 'argon2id', 'm': memoryKiB, 't': iterations, 'p': parallelism};

  static KdfParams fromJson(Map<String, dynamic> j) {
    if (j['alg'] != 'argon2id') throw const BackupFailure('Algoritmo de derivación no soportado.');
    return KdfParams(memoryKiB: j['m'] as int, iterations: j['t'] as int, parallelism: j['p'] as int);
  }
}

class WrappedKey {
  const WrappedKey(this.nonce, this.cipherText, this.mac);

  final List<int> nonce;
  final List<int> cipherText;
  final List<int> mac;

  Map<String, String> toJson() => {
    'nonce': base64Encode(nonce),
    'ct': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  static WrappedKey fromJson(Map<String, dynamic> j) =>
      WrappedKey(base64Decode(j['nonce'] as String), base64Decode(j['ct'] as String), base64Decode(j['mac'] as String));
}

/// Material de llaves que el dispositivo conserva para hacer backups sin pedir la contraseña cada vez.
class BackupKeyMaterial {
  const BackupKeyMaterial({
    required this.dataKey,
    required this.kdf,
    required this.salt,
    required this.byPassphrase,
    required this.byRecovery,
  });

  final List<int> dataKey;
  final KdfParams kdf;
  final List<int> salt;
  final WrappedKey byPassphrase;
  final WrappedKey byRecovery;

  Map<String, Object> toJson() => {
    'dataKey': base64Encode(dataKey),
    'kdf': kdf.toJson(),
    'salt': base64Encode(salt),
    'byPassphrase': byPassphrase.toJson(),
    'byRecovery': byRecovery.toJson(),
  };

  static BackupKeyMaterial fromJson(Map<String, dynamic> j) => BackupKeyMaterial(
    dataKey: base64Decode(j['dataKey'] as String),
    kdf: KdfParams.fromJson(j['kdf'] as Map<String, dynamic>),
    salt: base64Decode(j['salt'] as String),
    byPassphrase: WrappedKey.fromJson(j['byPassphrase'] as Map<String, dynamic>),
    byRecovery: WrappedKey.fromJson(j['byRecovery'] as Map<String, dynamic>),
  );
}

class BackupHeader {
  const BackupHeader({
    required this.createdAt,
    required this.schemaVersion,
    required this.kdf,
    required this.salt,
    required this.byPassphrase,
    required this.byRecovery,
    this.appVersion,
  });

  static const formatVersion = 1;

  final DateTime createdAt;
  final int schemaVersion;
  final String? appVersion;
  final KdfParams kdf;
  final List<int> salt;
  final WrappedKey byPassphrase;
  final WrappedKey byRecovery;

  Map<String, Object?> toJson() => {
    'format': formatVersion,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'kdf': kdf.toJson(),
    'salt': base64Encode(salt),
    'byPassphrase': byPassphrase.toJson(),
    'byRecovery': byRecovery.toJson(),
  };

  static BackupHeader fromJson(Map<String, dynamic> j) {
    if (j['format'] != formatVersion) throw const BackupFailure('Versión de backup no soportada.');
    return BackupHeader(
      createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      schemaVersion: j['schemaVersion'] as int,
      appVersion: j['appVersion'] as String?,
      kdf: KdfParams.fromJson(j['kdf'] as Map<String, dynamic>),
      salt: base64Decode(j['salt'] as String),
      byPassphrase: WrappedKey.fromJson(j['byPassphrase'] as Map<String, dynamic>),
      byRecovery: WrappedKey.fromJson(j['byRecovery'] as Map<String, dynamic>),
    );
  }
}

/// Código de recuperación: 256 bits en Base32, en grupos de 4 ("ABCD-EFGH-…").
abstract final class RecoveryCode {
  static const _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static String generate([Random? random]) {
    final rng = random ?? Random.secure();
    return format(List.generate(32, (_) => rng.nextInt(256)));
  }

  static String format(List<int> bytes) {
    final buffer = StringBuffer();
    var bits = 0, value = 0;
    for (final b in bytes) {
      value = (value << 8) | b;
      bits += 8;
      while (bits >= 5) {
        buffer.write(_alphabet[(value >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }
    if (bits > 0) buffer.write(_alphabet[(value << (5 - bits)) & 31]);
    final s = buffer.toString();
    return [for (var i = 0; i < s.length; i += 4) s.substring(i, min(i + 4, s.length))].join('-');
  }

  /// Tolera minúsculas, espacios, guiones y confusiones típicas (0→O, 1→I, 8→B).
  static List<int> parse(String code) {
    final clean = code
        .toUpperCase()
        .replaceAll(RegExp(r'[\s\-_.]'), '')
        .replaceAll('0', 'O')
        .replaceAll('1', 'I')
        .replaceAll('8', 'B');
    if (clean.length != 52) throw const BackupFailure('El código de recuperación no tiene el largo correcto.');
    final out = <int>[];
    var bits = 0, value = 0;
    for (final ch in clean.split('')) {
      final v = _alphabet.indexOf(ch);
      if (v < 0) throw BackupFailure('Carácter inválido en el código: $ch');
      value = (value << 5) | v;
      bits += 5;
      if (bits >= 8) {
        out.add((value >> (bits - 8)) & 0xff);
        bits -= 8;
      }
    }
    return out.sublist(0, 32);
  }
}

abstract final class BackupCrypto {
  static final _aes = AesGcm.with256bits();
  static const _magic = 'TELEIOSBK';
  static const _version = 1;
  static const minPassphraseLength = 10;

  static List<int> randomBytes(int n) {
    final rng = Random.secure();
    return List.generate(n, (_) => rng.nextInt(256));
  }

  static void checkPassphrase(String passphrase) {
    if (passphrase.length < minPassphraseLength) {
      throw const BackupFailure('La contraseña debe tener al menos 10 caracteres.');
    }
    if (passphrase.split('').toSet().length < 4) {
      throw const BackupFailure('La contraseña es demasiado simple.');
    }
  }

  /// Argon2id es costoso a propósito (~0,3 s en escritorio, 1-2 s en móvil): se calcula en otro
  /// isolate para no congelar la interfaz.
  static Future<SecretKey> passphraseKey(String passphrase, List<int> salt, KdfParams kdf) async {
    final bytes = await Isolate.run(
      () async => (await Argon2id(
        parallelism: kdf.parallelism,
        memory: kdf.memoryKiB,
        iterations: kdf.iterations,
        hashLength: 32,
      ).deriveKeyFromPassword(password: passphrase, nonce: salt)).extractBytes(),
    );
    return SecretKey(bytes);
  }

  static Future<SecretKey> recoveryKey(String code) => Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
    secretKey: SecretKey(RecoveryCode.parse(code)),
    info: utf8.encode('teleios-backup-recovery-v1'),
    nonce: const [],
  );

  static Future<WrappedKey> wrap(List<int> dataKey, SecretKey wrappingKey) async {
    final box = await _aes.encrypt(dataKey, secretKey: wrappingKey);
    return WrappedKey(box.nonce, box.cipherText, box.mac.bytes);
  }

  static Future<List<int>> unwrap(WrappedKey w, SecretKey wrappingKey) => _aes.decrypt(
    SecretBox(w.cipherText, nonce: w.nonce, mac: Mac(w.mac)),
    secretKey: wrappingKey,
  );

  /// Crea el material de llaves: llave de datos nueva + código de recuperación (mostrar UNA vez).
  static Future<({BackupKeyMaterial keys, String recoveryCode})> createKeys(
    String passphrase, {
    KdfParams kdf = KdfParams.standard,
  }) async {
    checkPassphrase(passphrase);
    final dataKey = randomBytes(32);
    final salt = randomBytes(16);
    final code = RecoveryCode.generate();
    final keys = BackupKeyMaterial(
      dataKey: dataKey,
      kdf: kdf,
      salt: salt,
      byPassphrase: await wrap(dataKey, await passphraseKey(passphrase, salt, kdf)),
      byRecovery: await wrap(dataKey, await recoveryKey(code)),
    );
    return (keys: keys, recoveryCode: code);
  }

  /// Cambia la contraseña conservando la llave de datos y el código de recuperación.
  static Future<BackupKeyMaterial> rewrapPassphrase(
    BackupKeyMaterial keys,
    String newPassphrase, {
    KdfParams? kdf,
  }) async {
    checkPassphrase(newPassphrase);
    final params = kdf ?? keys.kdf;
    final salt = randomBytes(16);
    return BackupKeyMaterial(
      dataKey: keys.dataKey,
      kdf: params,
      salt: salt,
      byPassphrase: await wrap(keys.dataKey, await passphraseKey(newPassphrase, salt, params)),
      byRecovery: keys.byRecovery,
    );
  }

  /// Genera un código de recuperación nuevo (el anterior deja de servir para backups futuros).
  static Future<({BackupKeyMaterial keys, String recoveryCode})> regenerateRecovery(BackupKeyMaterial keys) async {
    final code = RecoveryCode.generate();
    return (
      keys: BackupKeyMaterial(
        dataKey: keys.dataKey,
        kdf: keys.kdf,
        salt: keys.salt,
        byPassphrase: keys.byPassphrase,
        byRecovery: await wrap(keys.dataKey, await recoveryKey(code)),
      ),
      recoveryCode: code,
    );
  }

  static Future<Uint8List> seal({
    required List<int> payload,
    required BackupKeyMaterial keys,
    required int schemaVersion,
    String? appVersion,
    DateTime? now,
  }) async {
    final header = BackupHeader(
      createdAt: now ?? DateTime.now(),
      schemaVersion: schemaVersion,
      appVersion: appVersion,
      kdf: keys.kdf,
      salt: keys.salt,
      byPassphrase: keys.byPassphrase,
      byRecovery: keys.byRecovery,
    );
    final headerBytes = utf8.encode(jsonEncode(header.toJson()));
    final box = await _aes.encrypt(payload, secretKey: SecretKey(keys.dataKey), aad: headerBytes);
    final out = BytesBuilder(copy: false)
      ..add(ascii.encode(_magic))
      ..addByte(_version)
      ..add((ByteData(4)..setUint32(0, headerBytes.length)).buffer.asUint8List())
      ..add(headerBytes)
      ..add(box.concatenation());
    return out.toBytes();
  }

  static ({BackupHeader header, List<int> headerBytes, List<int> body}) _split(List<int> bytes) {
    if (bytes.length < 14 || ascii.decode(bytes.sublist(0, 9), allowInvalid: true) != _magic) {
      throw const BackupFailure('El archivo no es un backup de TELEIOS.');
    }
    if (bytes[9] != _version) throw const BackupFailure('Versión de backup no soportada.');
    final len = ByteData.sublistView(Uint8List.fromList(bytes.sublist(10, 14))).getUint32(0);
    if (14 + len > bytes.length) throw const BackupFailure('El backup está incompleto o dañado.');
    final headerBytes = bytes.sublist(14, 14 + len);
    try {
      final header = BackupHeader.fromJson(jsonDecode(utf8.decode(headerBytes)) as Map<String, dynamic>);
      return (header: header, headerBytes: headerBytes, body: bytes.sublist(14 + len));
    } on BackupFailure {
      rethrow;
    } catch (_) {
      throw const BackupFailure('La cabecera del backup está dañada.');
    }
  }

  static BackupHeader readHeader(List<int> bytes) => _split(bytes).header;

  /// Descifra con la contraseña o con el código de recuperación.
  /// Devuelve también el material de llaves para seguir haciendo backups compatibles.
  static Future<({List<int> payload, BackupKeyMaterial keys})> open(
    List<int> bytes, {
    String? passphrase,
    String? recoveryCode,
  }) async {
    final parts = _split(bytes);
    final h = parts.header;
    List<int> dataKey;
    try {
      dataKey = passphrase != null
          ? await unwrap(h.byPassphrase, await passphraseKey(passphrase, h.salt, h.kdf))
          : await unwrap(h.byRecovery, await recoveryKey(recoveryCode ?? ''));
    } on BackupFailure {
      rethrow;
    } catch (_) {
      throw BackupFailure(passphrase != null ? 'Contraseña incorrecta.' : 'Código de recuperación incorrecto.');
    }
    try {
      final box = SecretBox.fromConcatenation(parts.body, nonceLength: 12, macLength: 16);
      final payload = await _aes.decrypt(box, secretKey: SecretKey(dataKey), aad: parts.headerBytes);
      return (
        payload: payload,
        keys: BackupKeyMaterial(
          dataKey: dataKey,
          kdf: h.kdf,
          salt: h.salt,
          byPassphrase: h.byPassphrase,
          byRecovery: h.byRecovery,
        ),
      );
    } catch (_) {
      throw const BackupFailure('El backup fue modificado o está dañado.');
    }
  }
}
