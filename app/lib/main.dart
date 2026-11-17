import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/errors/failure.dart';
import 'core/preferences/app_settings.dart';
import 'core/security/database_key_store.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'shared/data/database/platform_storage.dart';
import 'shared/domain/repositories/attachment_store.dart';
import 'shared/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  try {
    final prefs = await SharedPreferences.getInstance();
    final key = await DatabaseKeyStore().readOrCreate();
    final db = await openAppDatabase(hexKey: key, fileName: Env.databaseFileName);
    final bible = await openBibleRepository(() => rootBundle.load('assets/bible/rv1909.sqlite.gz'));
    final attachments = EncryptedAttachmentStore(
      await openRawAttachmentStore(),
      await EncryptedAttachmentStore.deriveKey(hex.decode(key)),
    );
    AppLogger.info('TELEIOS iniciado (${Env.name})');

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
          bibleRepositoryProvider.overrideWithValue(bible),
          attachmentStoreProvider.overrideWithValue(attachments),
        ],
        child: const TeleiosApp(),
      ),
    );
  } catch (error, stack) {
    AppLogger.error('Fallo al iniciar', error, stack);
    runApp(BootErrorApp(error: error));
  }
}

/// Pantalla de último recurso si la base cifrada no abre (p. ej. llave perdida).
class BootErrorApp extends StatefulWidget {
  const BootErrorApp({super.key, required this.error});

  final Object error;

  @override
  State<BootErrorApp> createState() => _BootErrorAppState();
}

class _BootErrorAppState extends State<BootErrorApp> {
  bool _resetDone = false;

  bool get _canReset => widget.error is StorageFailure;

  Future<void> _reset() async {
    await deleteAppDatabaseFile(Env.databaseFileName);
    await DatabaseKeyStore().delete();
    setState(() => _resetDone = true);
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.error is Failure ? (widget.error as Failure).message : 'No se pudo iniciar la aplicación.';
    return MaterialApp(
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56),
                  const SizedBox(height: 16),
                  Text(message, textAlign: TextAlign.center),
                  if (_canReset && !_resetDone) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Si la llave de cifrado se perdió (p. ej. tras restaurar el sistema), '
                      'los datos locales no se pueden recuperar. Puedes empezar de cero '
                      'y luego restaurar un backup (disponible desde el Sprint 9).',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: _reset, child: const Text('Borrar datos locales y empezar de cero')),
                  ],
                  if (_resetDone) ...[
                    const SizedBox(height: 16),
                    const Text('Listo. Cierra y vuelve a abrir TELEIOS.'),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
