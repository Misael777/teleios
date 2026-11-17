import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences/app_settings.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/providers.dart';
import '../data/google_drive_destination.dart';
import '../data/secure_backup_vault.dart';
import '../domain/backup_service.dart';

final backupVaultProvider = Provider<BackupKeyVault>((ref) => SecureBackupKeyVault());

final backupServiceProvider = Provider(
  (ref) => BackupService(
    db: ref.watch(appDatabaseProvider),
    attachments: ref.watch(attachmentStoreProvider),
    vault: ref.watch(backupVaultProvider),
    appVersion: const String.fromEnvironment('APP_VERSION', defaultValue: '0.1'),
  ),
);

final backupConfiguredProvider = FutureProvider<bool>((ref) => ref.watch(backupServiceProvider).isConfigured);

final driveDestinationProvider = Provider((ref) => GoogleDriveBackupDestination());

/// Preferencias del respaldo (no sensibles).
class BackupPrefs {
  const BackupPrefs({this.lastBackupAt, this.autoDrive = false, this.driveEmail});

  final DateTime? lastBackupAt;
  final bool autoDrive;
  final String? driveEmail;

  static const autoInterval = Duration(days: 7);

  bool isDue(DateTime now) => lastBackupAt == null || now.difference(lastBackupAt!) >= autoInterval;
}

final backupPrefsProvider = NotifierProvider<BackupPrefsNotifier, BackupPrefs>(BackupPrefsNotifier.new);

class BackupPrefsNotifier extends Notifier<BackupPrefs> {
  static const _last = 'backup.last_at';
  static const _auto = 'backup.auto_drive';
  static const _email = 'backup.drive_email';

  @override
  BackupPrefs build() {
    final p = ref.watch(sharedPreferencesProvider);
    final last = p.getString(_last);
    return BackupPrefs(
      lastBackupAt: last == null ? null : DateTime.tryParse(last),
      autoDrive: p.getBool(_auto) ?? false,
      driveEmail: p.getString(_email),
    );
  }

  Future<void> markBackedUp(DateTime at) async {
    await ref.read(sharedPreferencesProvider).setString(_last, at.toIso8601String());
    ref.invalidateSelf();
  }

  Future<void> setAutoDrive(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(_auto, value);
    ref.invalidateSelf();
  }

  Future<void> setDriveEmail(String? email) async {
    final p = ref.read(sharedPreferencesProvider);
    email == null ? await p.remove(_email) : await p.setString(_email, email);
    ref.invalidateSelf();
  }
}

/// Respaldo automático semanal en Drive: se intenta al abrir la app y al volver a ella.
/// Silencioso: si algo falla (sin red, sin sesión), se reintenta la próxima vez.
final autoBackupProvider = Provider(AutoBackup.new);

class AutoBackup {
  AutoBackup(this._ref);

  final Ref _ref;
  bool _running = false;

  Future<void> runIfDue() async {
    final prefs = _ref.read(backupPrefsProvider);
    final now = DateTime.now();
    if (_running || !prefs.autoDrive || !prefs.isDue(now) || !GoogleDriveBackupDestination.available) return;
    _running = true;
    try {
      final service = _ref.read(backupServiceProvider);
      if (!await service.isConfigured) return;
      final drive = _ref.read(driveDestinationProvider);
      if (!await drive.restoreSession()) return;
      final bytes = await service.createBackup(now: now);
      await drive.upload(bytes, BackupService.fileNameFor(now), interactive: false);
      await _ref.read(backupPrefsProvider.notifier).markBackedUp(now);
      AppLogger.info('Respaldo automático completado');
    } catch (e, st) {
      AppLogger.error('Respaldo automático falló', e, st);
    } finally {
      _running = false;
    }
  }
}
