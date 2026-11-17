import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/errors/failure.dart';
import 'package:teleios/features/altar/data/drift_prayer_repository.dart';
import 'package:teleios/features/altar/domain/prayer.dart';
import 'package:teleios/features/backup/domain/backup_crypto.dart';
import 'package:teleios/features/backup/domain/backup_service.dart';
import 'package:teleios/features/bitacora/data/drift_praxis_repository.dart';
import 'package:teleios/features/bitacora/domain/praxis.dart';
import 'package:teleios/features/bitacora/domain/save_praxis.dart';
import 'package:teleios/features/estudio/data/drift_devotional_repository.dart';
import 'package:teleios/features/estudio/domain/devotional.dart';
import 'package:teleios/features/estudio/domain/save_devotional.dart';
import 'package:teleios/features/settings/data_export_service.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/repositories/drift_topic_repository.dart';
import 'package:teleios/shared/domain/entities/dimension.dart';
import 'package:teleios/shared/domain/entities/passage_ref.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';
import 'package:teleios/shared/domain/entities/prayer_entry.dart';
import 'package:teleios/shared/domain/repositories/attachment_store.dart';

import '../../helpers.dart';

const pass = 'mi contraseña segura 123';

void main() {
  group('RecoveryCode', () {
    test('formato: 13 grupos de 4 en Base32', () {
      final code = RecoveryCode.generate();
      expect(code, matches(RegExp(r'^([A-Z2-7]{4}-){12}[A-Z2-7]{4}$')));
    });

    test('ida y vuelta y tolerancia a errores de tipeo', () {
      final bytes = List.generate(32, (i) => i * 7 % 256);
      final code = RecoveryCode.format(bytes);
      expect(RecoveryCode.parse(code), bytes);
      expect(RecoveryCode.parse(code.toLowerCase().replaceAll('-', ' ')), bytes);
      expect(RecoveryCode.parse(code.replaceAll('O', '0').replaceAll('I', '1')), bytes);
    });

    test('rechaza códigos incompletos', () {
      expect(() => RecoveryCode.parse('ABCD-EFGH'), throwsA(isA<BackupFailure>()));
    });
  });

  group('BackupCrypto', () {
    late BackupKeyMaterial keys;
    late String code;
    final payload = utf8.encode('datos privados de prueba');

    setUpAll(() async {
      final c = await BackupCrypto.createKeys(pass, kdf: KdfParams.testing);
      keys = c.keys;
      code = c.recoveryCode;
    });

    Future<Uint8List> sealed() => BackupCrypto.seal(payload: payload, keys: keys, schemaVersion: 2);

    test('el archivo no contiene el texto en claro', () async {
      final bytes = await sealed();
      expect(utf8.decode(bytes, allowMalformed: true).contains('datos privados'), isFalse);
      expect(ascii.decode(bytes.sublist(0, 9)), 'TELEIOSBK');
    });

    test('abre con la contraseña y con el código de recuperación', () async {
      final bytes = await sealed();
      expect((await BackupCrypto.open(bytes, passphrase: pass)).payload, payload);
      expect((await BackupCrypto.open(bytes, recoveryCode: code)).payload, payload);
    });

    test('contraseña o código incorrectos fallan con un mensaje claro', () async {
      final bytes = await sealed();
      await expectLater(
        BackupCrypto.open(bytes, passphrase: 'otra contraseña 999'),
        throwsA(isA<BackupFailure>().having((f) => f.message, 'message', 'Contraseña incorrecta.')),
      );
      await expectLater(
        BackupCrypto.open(bytes, recoveryCode: RecoveryCode.generate()),
        throwsA(isA<BackupFailure>().having((f) => f.message, 'message', 'Código de recuperación incorrecto.')),
      );
    });

    test('modificar la cabecera o el cuerpo se detecta', () async {
      final bytes = await sealed();
      final tamperedBody = Uint8List.fromList(bytes)..[bytes.length - 20] ^= 1;
      await expectLater(BackupCrypto.open(tamperedBody, passphrase: pass), throwsA(isA<BackupFailure>()));

      // Cambiar la fecha en la cabecera (autenticada como AAD).
      final text = latin1.decode(bytes);
      final year = DateTime.now().year.toString();
      final tamperedHeader = Uint8List.fromList(
        latin1.encode(text.replaceFirst('"createdAt":"$year', '"createdAt":"1999')),
      );
      await expectLater(BackupCrypto.open(tamperedHeader, passphrase: pass), throwsA(isA<BackupFailure>()));
    });

    test('archivos ajenos se rechazan', () {
      expect(() => BackupCrypto.readHeader(utf8.encode('hola mundo, no soy un backup')), throwsA(isA<BackupFailure>()));
    });

    test('cambiar la contraseña conserva el código de recuperación', () async {
      final rewrapped = await BackupCrypto.rewrapPassphrase(keys, 'nueva contraseña 456', kdf: KdfParams.testing);
      final bytes = await BackupCrypto.seal(payload: payload, keys: rewrapped, schemaVersion: 2);
      expect((await BackupCrypto.open(bytes, passphrase: 'nueva contraseña 456')).payload, payload);
      expect((await BackupCrypto.open(bytes, recoveryCode: code)).payload, payload);
      await expectLater(BackupCrypto.open(bytes, passphrase: pass), throwsA(isA<BackupFailure>()));
    });

    test('contraseñas débiles se rechazan', () {
      expect(() => BackupCrypto.checkPassphrase('corta'), throwsA(isA<BackupFailure>()));
      expect(() => BackupCrypto.checkPassphrase('aaaaaaaaaaaa'), throwsA(isA<BackupFailure>()));
    });
  });

  group('BackupService', () {
    late AppDatabase db;
    late MemoryAttachmentStore store;
    late MemoryBackupKeyVault vault;
    late BackupService service;

    setUp(() async {
      db = memoryDatabase();
      store = MemoryAttachmentStore();
      vault = MemoryBackupKeyVault();
      service = BackupService(db: db, attachments: store, vault: vault, kdf: KdfParams.testing, appVersion: '0.1.1');
      final topics = DriftTopicRepository(db);
      await SaveDevotional(devotionals: DriftDevotionalRepository(db), topics: topics, transaction: db)(
        DevotionalDraft(
          date: DateTime(2026, 10, 20),
          passage: const PassageRef(bookCode: 'GAL', chapter: 5, verseStart: 22),
          content: 'Reflexión íntima',
          topics: const [TopicDraft(name: 'Paciencia', dimensionId: Dimension.vidaPractica)],
        ),
      );
      final praxisId =
          await SavePraxis(
            praxis: DriftPraxisRepository(db),
            topics: topics,
            attachments: DriftAttachmentRepository(db),
            store: store,
            transaction: db,
          )(
            PraxisDraft(
              date: DateTime(2026, 10, 21),
              circumstance: 'Algo difícil',
              emotionIds: const ['ansiedad'],
              intensity: 8,
              filter: FilterType.cosmovision,
              worldview: 'Cuidar lo mío',
              peace: 4,
              newImages: [
                PendingImage(bytes: Uint8List.fromList(List.generate(500, (i) => i % 256)), width: 1, height: 1),
              ],
            ),
          );
      await SavePrayer(prayers: DriftPrayerRepository(db), topics: topics, transaction: db)(
        PrayerDraft(
          date: DateTime(2026, 10, 22),
          transcript: 'Señor…',
          intent: PrayerIntent.lamentacion,
          praxisIds: [praxisId],
        ),
      );
      await DriftPraxisCatalogRepository(db).addEmotion('Nostalgia');
    });
    tearDown(() => db.close());

    test('el registro de importación cubre todas las tablas', () {
      expect(BackupService.importableTables, db.allTables.map((t) => t.actualTableName).toSet());
    });

    test('sin configurar no se puede respaldar', () {
      expect(service.createBackup(), throwsA(isA<BackupFailure>()));
    });

    test('respaldo → borrar todo → restaurar deja los datos idénticos', () async {
      final code = await service.setUp(pass);
      expect(code, isNotEmpty);
      final before = await DataExportService(db).exportMap(now: DateTime(2026));
      final filesBefore = Map.of(store.files);
      final bytes = await service.createBackup();

      await db.wipeUserData();
      await store.deleteAll();
      await vault.clear();
      expect(await db.select(db.devotionals).get(), isEmpty);

      final result = await service.restore(bytes, passphrase: pass);
      final after = await DataExportService(db).exportMap(now: DateTime(2026));
      expect(jsonEncode(after['tables']), jsonEncode(before['tables']));
      expect(result.attachments, 1);
      expect(store.files.keys, filesBefore.keys);
      expect(store.files.values.single, filesBefore.values.single);
      expect(await vault.load(), isNotNull, reason: 'los siguientes respaldos usan la misma contraseña');
    });

    test('se puede restaurar en "otro dispositivo" solo con el código de recuperación', () async {
      final code = await service.setUp(pass);
      final bytes = await service.createBackup();
      final otherDb = memoryDatabase();
      final other = BackupService(
        db: otherDb,
        attachments: MemoryAttachmentStore(),
        vault: MemoryBackupKeyVault(),
        kdf: KdfParams.testing,
      );
      await other.restore(bytes, recoveryCode: code);
      expect((await otherDb.select(otherDb.devotionals).get()).single.content, 'Reflexión íntima');
      await otherDb.close();
    });

    test('un backup de una versión de esquema más nueva se rechaza sin tocar los datos', () async {
      await service.setUp(pass);
      final keys = (await vault.load())!;
      final future = await BackupCrypto.seal(payload: [1, 2, 3], keys: keys, schemaVersion: 99);
      await expectLater(service.restore(future, passphrase: pass), throwsA(isA<BackupFailure>()));
      expect(await db.select(db.devotionals).get(), hasLength(1));
    });

    test('contraseña incorrecta no borra nada', () async {
      await service.setUp(pass);
      final bytes = await service.createBackup();
      await expectLater(service.restore(bytes, passphrase: 'equivocada 123456'), throwsA(isA<Failure>()));
      expect(await db.select(db.devotionals).get(), hasLength(1));
      expect(store.files, hasLength(1));
    });

    test('nombre de archivo ordenable por fecha', () {
      expect(BackupService.fileNameFor(DateTime(2026, 3, 7, 9, 5)), 'teleios-backup-20260307-0905.teleios');
    });
  });
}
