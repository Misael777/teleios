import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../../../core/errors/failure.dart';
import '../../../shared/data/database/app_database.dart';
import '../../../shared/domain/repositories/attachment_store.dart';
import '../../settings/data_export_service.dart';
import 'backup_crypto.dart';

/// Guarda el material de llaves del backup en el almacén seguro del sistema.
abstract interface class BackupKeyVault {
  Future<BackupKeyMaterial?> load();

  Future<void> save(BackupKeyMaterial keys);

  Future<void> clear();
}

class MemoryBackupKeyVault implements BackupKeyVault {
  BackupKeyMaterial? keys;

  @override
  Future<BackupKeyMaterial?> load() async => keys;

  @override
  Future<void> save(BackupKeyMaterial k) async => keys = k;

  @override
  Future<void> clear() async => keys = null;
}

class RestoreResult {
  const RestoreResult({required this.createdAt, required this.rows, required this.attachments});

  final DateTime createdAt;
  final int rows;
  final int attachments;
}

/// Arma y restaura backups: datos (JSON de todas las tablas) + adjuntos, en un ZIP cifrado.
///
/// Se exportan **datos lógicos** (no el archivo SQLite): el backup es independiente de la llave
/// de la base local y del dispositivo, y se puede migrar entre versiones de esquema.
class BackupService {
  BackupService({
    required AppDatabase db,
    required AttachmentStore attachments,
    required BackupKeyVault vault,
    this.appVersion,
    KdfParams kdf = KdfParams.standard,
  }) : _db = db,
       _store = attachments,
       _vault = vault,
       _kdf = kdf;

  final AppDatabase _db;
  final AttachmentStore _store;
  final BackupKeyVault _vault;
  final KdfParams _kdf;
  final String? appVersion;

  static const fileExtension = 'teleios';

  Future<bool> get isConfigured async => await _vault.load() != null;

  /// Configura el respaldo. Devuelve el código de recuperación: se muestra UNA sola vez.
  Future<String> setUp(String passphrase) async {
    final created = await BackupCrypto.createKeys(passphrase, kdf: _kdf);
    await _vault.save(created.keys);
    return created.recoveryCode;
  }

  Future<void> changePassphrase(String newPassphrase) async {
    final keys = await _requireKeys();
    await _vault.save(await BackupCrypto.rewrapPassphrase(keys, newPassphrase, kdf: _kdf));
  }

  Future<String> regenerateRecoveryCode() async {
    final result = await BackupCrypto.regenerateRecovery(await _requireKeys());
    await _vault.save(result.keys);
    return result.recoveryCode;
  }

  Future<BackupKeyMaterial> _requireKeys() async =>
      await _vault.load() ?? (throw const BackupFailure('Primero configura tu contraseña de respaldo.'));

  Future<Uint8List> createBackup({DateTime? now}) async {
    final keys = await _requireKeys();
    final data = await DataExportService(_db).exportMap(now: now);
    final archive = Archive()..addFile(ArchiveFile.string('data.json', jsonEncode(data)));
    for (final row in await _db.select(_db.attachments).get()) {
      final bytes = await _store.read(row.fileName);
      if (bytes != null) archive.addFile(ArchiveFile.bytes('attachments/${row.fileName}', bytes));
    }
    return BackupCrypto.seal(
      payload: ZipEncoder().encodeBytes(archive),
      keys: keys,
      schemaVersion: _db.schemaVersion,
      appVersion: appVersion,
      now: now,
    );
  }

  static String fileNameFor(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'teleios-backup-${d.year}${two(d.month)}${two(d.day)}-${two(d.hour)}${two(d.minute)}.$fileExtension';
  }

  /// Reemplaza TODOS los datos locales por los del backup.
  Future<RestoreResult> restore(List<int> bytes, {String? passphrase, String? recoveryCode}) async {
    final header = BackupCrypto.readHeader(bytes);
    if (header.schemaVersion > _db.schemaVersion) {
      throw const BackupFailure('Este backup es de una versión más nueva de TELEIOS. Actualiza la app primero.');
    }
    final opened = await BackupCrypto.open(bytes, passphrase: passphrase, recoveryCode: recoveryCode);
    final archive = ZipDecoder().decodeBytes(opened.payload);
    final dataFile = archive.findFile('data.json') ?? (throw const BackupFailure('El backup no contiene datos.'));
    final data = jsonDecode(utf8.decode(dataFile.content)) as Map<String, dynamic>;
    final tables = data['tables'] as Map<String, dynamic>;

    var rows = 0;
    await _db.transaction(() async {
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final table in _db.allTables.toList().reversed) {
        await _db.delete(table).go();
      }
      for (final table in _db.allTables) {
        final list = (tables[table.actualTableName] as List<dynamic>?) ?? const [];
        final fromJson =
            _registry[table.actualTableName] ?? (throw StateError('Tabla sin importador: ${table.actualTableName}'));
        await _db.batch((b) {
          for (final json in list) {
            b.insert(table, fromJson(json as Map<String, dynamic>), mode: InsertMode.insertOrReplace);
          }
        });
        rows += list.length;
      }
    });
    // Catálogos del sistema al día aunque el backup fuera de una versión anterior.
    await _db.seedCatalogs();

    await _store.deleteAll();
    var attachments = 0;
    for (final f in archive.files.where((f) => f.isFile && f.name.startsWith('attachments/'))) {
      await _store.write(f.name.substring('attachments/'.length), f.content);
      attachments++;
    }
    // Los respaldos siguientes usan la misma contraseña y código de recuperación.
    await _vault.save(opened.keys);
    return RestoreResult(createdAt: header.createdAt, rows: rows, attachments: attachments);
  }

  /// Tabla → constructor desde JSON. Un test garantiza que cubre todas las tablas.
  static final Map<String, Insertable<DataClass> Function(Map<String, dynamic>)> _registry = {
    'dimensions': DimensionRow.fromJson,
    'emotions': EmotionRow.fromJson,
    'triggers': TriggerRow.fromJson,
    'topics': TopicRow.fromJson,
    'devotionals': DevotionalRow.fromJson,
    'devotional_topics': DevotionalTopicRow.fromJson,
    'praxis_entries': PraxisRow.fromJson,
    'praxis_emotions': PraxisEmotion.fromJson,
    'praxis_triggers': PraxisTrigger.fromJson,
    'praxis_topics': PraxisTopic.fromJson,
    'prayers': PrayerRow.fromJson,
    'prayer_topics': PrayerTopic.fromJson,
    'prayer_praxis_links': PrayerPraxisLink.fromJson,
    'attachments': AttachmentRow.fromJson,
    // v4: coherencia medida.
    'beliefs': BeliefRow.fromJson,
    'belief_topics': BeliefTopic.fromJson,
    'belief_evidence': BeliefEvidenceRow.fromJson,
    'action_beliefs': ActionBeliefRow.fromJson,
    'shared_labels': SharedLabelRow.fromJson,
    'thought_patterns': ThoughtPatternRow.fromJson,
    'judge_feedback': JudgeFeedbackRow.fromJson,
  };

  static Set<String> get importableTables => _registry.keys.toSet();
}
