import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:teleios/core/security/database_key_store.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/data/database/platform_storage_native.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('teleios_enc_'));
  tearDown(() async => dir.delete(recursive: true));

  test('la base queda cifrada en disco y solo abre con la llave correcta', () async {
    final file = File('${dir.path}/test.db');
    final key = DatabaseKeyStore.generateHexKey();

    final db = AppDatabase(encryptedExecutor(file, key));
    await db
        .into(db.devotionals)
        .insert(
          DevotionalsCompanion.insert(
            id: 'd1',
            date: DateTime(2026, 10, 27),
            bookCode: 'GAL',
            chapter: 5,
            content: 'TEXTO-SECRETO-DE-PRUEBA',
            createdAt: DateTime(2026, 10, 27),
            updatedAt: DateTime(2026, 10, 27),
          ),
        );
    await db.close();

    // 1. El contenido no aparece en texto plano en el archivo.
    final raw = await file.readAsBytes();
    expect(String.fromCharCodes(raw).contains('TEXTO-SECRETO-DE-PRUEBA'), isFalse);
    expect(String.fromCharCodes(raw.take(15)), isNot('SQLite format 3'));

    // 2. Con otra llave no se puede leer.
    final wrong = AppDatabase(encryptedExecutor(file, DatabaseKeyStore.generateHexKey()));
    await expectLater(wrong.customSelect('SELECT count(*) FROM sqlite_master').get(), throwsA(anything));
    await wrong.close();

    // 3. Con la llave correcta, sí.
    final again = AppDatabase(encryptedExecutor(file, key));
    final rows = await again.select(again.devotionals).get();
    expect(rows.single.content, 'TEXTO-SECRETO-DE-PRUEBA');
    await again.close();
  });

  test('la llave generada es de 256 bits en hexadecimal', () {
    expect(DatabaseKeyStore.generateHexKey(), matches(RegExp(r'^[0-9a-f]{64}$')));
  });
}
