import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleios/app.dart';
import 'package:teleios/core/preferences/app_settings.dart';
import 'package:teleios/core/security/app_lock.dart';
import 'package:teleios/features/backup/domain/backup_crypto.dart';
import 'package:teleios/features/backup/domain/backup_service.dart';
import 'package:teleios/features/backup/presentation/backup_providers.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/domain/repositories/attachment_store.dart';
import 'package:teleios/shared/providers.dart';

import '../helpers.dart';
import 'fakes.dart';

void main() {
  late AppDatabase db;
  setUpAll(() => initializeDateFormatting('es'));
  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  testWidgets('configurar el respaldo exige guardar el código de recuperación', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarding.v1.completed': true, 'ui.show_cover': false});
    final prefs = await SharedPreferences.getInstance();
    final vault = MemoryBackupKeyVault();
    final store = MemoryAttachmentStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
          bibleRepositoryProvider.overrideWithValue(FakeBible()),
          attachmentStoreProvider.overrideWithValue(store),
          deviceAuthenticatorProvider.overrideWithValue(FakeAuthenticator()),
          backupVaultProvider.overrideWithValue(vault),
          backupServiceProvider.overrideWithValue(
            BackupService(db: db, attachments: store, vault: vault, kdf: KdfParams.testing),
          ),
        ],
        child: const TeleiosApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open-backup')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setup-backup')));
    await tester.pumpAndSettle();

    // Contraseñas que no coinciden → error y el diálogo sigue abierto.
    await tester.enterText(find.byKey(const Key('pass-1')), 'frase de prueba larga');
    await tester.enterText(find.byKey(const Key('pass-2')), 'otra frase distinta');
    await tester.tap(find.byKey(const Key('pass-ok')));
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('pass-2')), 'frase de prueba larga');
    await tester.tap(find.byKey(const Key('pass-ok')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 500)));
    await tester.pumpAndSettle();

    // Código de recuperación: "Listo" deshabilitado hasta confirmar.
    expect(find.text('Código de recuperación'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('recovery-done'))).onPressed, isNull);
    await tester.tap(find.byKey(const Key('recovery-saved')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('recovery-done')));
    await tester.pumpAndSettle();

    expect(await tester.runAsync(vault.load), isNotNull);
    expect(find.text('Aún no tienes ningún respaldo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
