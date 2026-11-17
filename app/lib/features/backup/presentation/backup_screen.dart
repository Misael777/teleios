import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../data/google_drive_destination.dart';
import '../domain/backup_crypto.dart';
import '../domain/backup_service.dart';
import 'backup_providers.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  String? _busy;
  List<RemoteBackup>? _remote;

  bool get _desktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  Future<T?> _run<T>(String label, Future<T> Function() task) async {
    setState(() => _busy = label);
    try {
      return await task();
    } catch (e) {
      if (mounted) showError(context, e);
      return null;
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  // ─── Configuración ──────────────────────────────────────────────────────

  Future<void> _setUp() async {
    final pass = await showDialog<String>(context: context, builder: (_) => const _NewPassphraseDialog());
    if (pass == null) return;
    final code = await _run('Generando llaves…', () => ref.read(backupServiceProvider).setUp(pass));
    ref.invalidate(backupConfiguredProvider);
    if (code != null && mounted) await _showRecoveryCode(code);
  }

  Future<void> _changePassphrase() async {
    final pass = await showDialog<String>(
      context: context,
      builder: (_) => const _NewPassphraseDialog(title: 'Nueva contraseña de respaldo'),
    );
    if (pass == null) return;
    final ok = await _run('Actualizando…', () async {
      await ref.read(backupServiceProvider).changePassphrase(pass);
      return true;
    });
    if (ok == true && mounted) showMessage(context, 'Contraseña actualizada. Aplica a los próximos respaldos.');
  }

  Future<void> _regenerateRecovery() async {
    final confirm = await _confirm(
      '¿Generar un código nuevo?',
      'El código anterior dejará de servir para los respaldos que hagas desde ahora.',
    );
    if (!confirm) return;
    final code = await _run('Generando…', () => ref.read(backupServiceProvider).regenerateRecoveryCode());
    if (code != null && mounted) await _showRecoveryCode(code);
  }

  Future<void> _showRecoveryCode(String code) => Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => RecoveryCodeScreen(code: code)));

  // ─── Respaldo ───────────────────────────────────────────────────────────

  Future<void> _backupToFile() async {
    final now = DateTime.now();
    final name = BackupService.fileNameFor(now);
    final bytes = await _run('Cifrando respaldo…', () => ref.read(backupServiceProvider).createBackup(now: now));
    if (bytes == null || !mounted) return;
    final file = XFile.fromData(bytes, mimeType: 'application/octet-stream', name: name);
    if (_desktop) {
      final location = await getSaveLocation(suggestedName: name);
      if (location == null) return;
      await file.saveTo(location.path);
    } else {
      final result = await SharePlus.instance.share(ShareParams(files: [file], fileNameOverrides: [name]));
      if (result.status == ShareResultStatus.dismissed) return;
    }
    await ref.read(backupPrefsProvider.notifier).markBackedUp(now);
    if (mounted) showMessage(context, 'Respaldo guardado.');
  }

  Future<void> _connectDrive() async {
    final email = await _run('Conectando…', () => ref.read(driveDestinationProvider).connect());
    if (email == null) return;
    await ref.read(backupPrefsProvider.notifier).setDriveEmail(email);
    await _loadRemote();
  }

  Future<void> _disconnectDrive() async {
    await _run('Desconectando…', () => ref.read(driveDestinationProvider).disconnect());
    await ref.read(backupPrefsProvider.notifier).setDriveEmail(null);
    await ref.read(backupPrefsProvider.notifier).setAutoDrive(false);
    setState(() => _remote = null);
  }

  Future<void> _backupToDrive() async {
    final now = DateTime.now();
    final ok = await _run('Subiendo a Google Drive…', () async {
      final bytes = await ref.read(backupServiceProvider).createBackup(now: now);
      await ref.read(driveDestinationProvider).upload(bytes, BackupService.fileNameFor(now));
      return true;
    });
    if (ok != true) return;
    await ref.read(backupPrefsProvider.notifier).markBackedUp(now);
    await _loadRemote();
    if (mounted) showMessage(context, 'Respaldo subido a tu Google Drive.');
  }

  Future<void> _loadRemote() async {
    final list = await _run('Consultando Drive…', () => ref.read(driveDestinationProvider).list());
    if (list != null && mounted) setState(() => _remote = list);
  }

  // ─── Restauración ───────────────────────────────────────────────────────

  Future<void> _restoreFromFile() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'Respaldo TELEIOS', extensions: [BackupService.fileExtension]),
      ],
    );
    if (file == null) return;
    await _restore(await file.readAsBytes());
  }

  Future<void> _restoreFromDrive(RemoteBackup b) async {
    final bytes = await _run('Descargando…', () => ref.read(driveDestinationProvider).download(b.id));
    if (bytes != null) await _restore(bytes);
  }

  Future<void> _restore(Uint8List bytes) async {
    BackupHeader header;
    try {
      header = BackupCrypto.readHeader(bytes);
    } catch (e) {
      if (mounted) showError(context, e);
      return;
    }
    if (!mounted) return;
    final secret = await showDialog<({String? passphrase, String? recoveryCode})>(
      context: context,
      builder: (_) => _RestoreDialog(header: header),
    );
    if (secret == null) return;
    final result = await _run(
      'Restaurando…',
      () => ref
          .read(backupServiceProvider)
          .restore(bytes, passphrase: secret.passphrase, recoveryCode: secret.recoveryCode),
    );
    ref.invalidate(backupConfiguredProvider);
    if (result != null && mounted) {
      showMessage(context, 'Restaurado: ${result.rows} registros y ${result.attachments} fotos.');
    }
  }

  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continuar')),
          ],
        ),
      ) ??
      false;

  // ─── UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configured = ref.watch(backupConfiguredProvider);
    final prefs = ref.watch(backupPrefsProvider);
    final last = prefs.lastBackupAt;
    final days = last == null ? null : DateTime.now().difference(last).inDays;

    return Scaffold(
      appBar: AppBar(title: const Text('Respaldo cifrado')),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Tu diario vive solo en este dispositivo. Un respaldo lo protege si pierdes o cambias '
                        'el teléfono. Se cifra con una contraseña que solo tú conoces: ni Google ni nadie '
                        'puede leerlo.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...configured.when(
                    loading: () => [const LinearProgressIndicator()],
                    error: (e, _) => [Text('Error: $e')],
                    data: (isConfigured) => isConfigured
                        ? _configuredSections(theme, prefs, days)
                        : [
                            SectionCard(
                              title: '1 · Crea tu contraseña de respaldo',
                              subtitle: 'Distinta del PIN del teléfono. Recibirás además un código de recuperación.',
                              child: FilledButton.icon(
                                key: const Key('setup-backup'),
                                onPressed: _busy == null ? _setUp : null,
                                icon: const Icon(Icons.key),
                                label: const Text('Configurar respaldo'),
                              ),
                            ),
                          ],
                  ),
                  SectionCard(
                    title: 'Restaurar',
                    subtitle: 'Reemplaza los datos de este dispositivo por los de un respaldo.',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _busy == null ? _restoreFromFile : null,
                          icon: const Icon(Icons.file_open_outlined),
                          label: const Text('Desde un archivo'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_busy != null)
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.scrim.withValues(alpha: 0.35),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(_busy!)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _configuredSections(ThemeData theme, BackupPrefs prefs, int? days) {
    final stale = days == null || days >= 7;
    return [
      Card(
        child: ListTile(
          leading: Icon(
            stale ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
            color: stale ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          title: Text(
            prefs.lastBackupAt == null
                ? 'Aún no tienes ningún respaldo'
                : 'Último respaldo: ${Formatters.date(prefs.lastBackupAt!)}',
          ),
          subtitle: Text(days == null ? 'Haz el primero ahora.' : (days == 0 ? 'Hoy' : 'Hace $days días')),
        ),
      ),
      SectionCard(
        title: 'Guardar en un archivo',
        subtitle: _desktop
            ? 'Elige dónde guardarlo (USB, carpeta sincronizada…).'
            : 'Compártelo a tu Drive, iCloud, correo o almacenamiento.',
        child: FilledButton.icon(
          key: const Key('backup-file'),
          onPressed: _busy == null ? _backupToFile : null,
          icon: const Icon(Icons.save_alt),
          label: const Text('Respaldar ahora'),
        ),
      ),
      _driveSection(theme, prefs),
      SectionCard(
        title: 'Seguridad del respaldo',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed: _busy == null ? _changePassphrase : null,
              child: const Text('Cambiar contraseña'),
            ),
            OutlinedButton(
              onPressed: _busy == null ? _regenerateRecovery : null,
              child: const Text('Nuevo código de recuperación'),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _driveSection(ThemeData theme, BackupPrefs prefs) {
    if (!GoogleDriveBackupDestination.platformSupported) {
      return const SectionCard(
        title: 'Google Drive',
        child: Text('Disponible en la app de Android e iOS. En escritorio, guarda el archivo en tu carpeta de Drive.'),
      );
    }
    if (!GoogleDriveBackupDestination.isConfigured) {
      return const SectionCard(
        title: 'Google Drive',
        child: Text(
          'Esta compilación no tiene credenciales de Google configuradas (ver docs/GOOGLE-DRIVE-SETUP.md). '
          'Mientras tanto, usa "Respaldar ahora" y elige Drive al compartir.',
        ),
      );
    }
    final connected = prefs.driveEmail != null;
    return SectionCard(
      title: 'Google Drive',
      subtitle: connected
          ? 'Conectado como ${prefs.driveEmail}. Se guardan los 5 respaldos más recientes en una carpeta oculta.'
          : 'Conecta tu cuenta para respaldar automáticamente cada semana.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!connected)
            FilledButton.icon(
              onPressed: _busy == null ? _connectDrive : null,
              icon: const Icon(Icons.add_to_drive),
              label: const Text('Conectar Google Drive'),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy == null ? _backupToDrive : null,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text('Respaldar en Drive'),
                ),
                OutlinedButton(onPressed: _busy == null ? _loadRemote : null, child: const Text('Ver respaldos')),
                TextButton(onPressed: _busy == null ? _disconnectDrive : null, child: const Text('Desconectar')),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: prefs.autoDrive,
              onChanged: (v) => ref.read(backupPrefsProvider.notifier).setAutoDrive(v),
              title: const Text('Respaldo automático semanal'),
              subtitle: const Text('Al abrir la app, si pasaron 7 días desde el último.'),
            ),
            if (_remote != null)
              for (final r in _remote!)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: Text(Formatters.date(r.createdAt)),
                  subtitle: Text(r.sizeBytes == null ? r.name : '${(r.sizeBytes! / 1024).toStringAsFixed(0)} KB'),
                  trailing: TextButton(
                    onPressed: _busy == null ? () => _restoreFromDrive(r) : null,
                    child: const Text('Restaurar'),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _NewPassphraseDialog extends StatefulWidget {
  const _NewPassphraseDialog({this.title = 'Contraseña de respaldo'});

  final String title;

  @override
  State<_NewPassphraseDialog> createState() => _NewPassphraseDialogState();
}

class _NewPassphraseDialogState extends State<_NewPassphraseDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  bool _show = false;
  String? _error;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      BackupCrypto.checkPassphrase(_a.text);
      if (_a.text != _b.text) throw const FormatException('Las contraseñas no coinciden.');
      Navigator.pop(context, _a.text);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst(RegExp(r'^\w+: '), ''));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Mínimo 10 caracteres. Una frase es más segura y fácil de recordar.'),
          const SizedBox(height: 12),
          TextField(
            key: const Key('pass-1'),
            controller: _a,
            obscureText: !_show,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                icon: Icon(_show ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _show = !_show),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('pass-2'),
            controller: _b,
            obscureText: !_show,
            decoration: const InputDecoration(labelText: 'Repite la contraseña'),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
      FilledButton(key: const Key('pass-ok'), onPressed: _submit, child: const Text('Guardar')),
    ],
  );
}

class _RestoreDialog extends StatefulWidget {
  const _RestoreDialog({required this.header});

  final BackupHeader header;

  @override
  State<_RestoreDialog> createState() => _RestoreDialogState();
}

class _RestoreDialogState extends State<_RestoreDialog> {
  final _secret = TextEditingController();
  bool _useRecovery = false;
  bool _understood = false;

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Restaurar respaldo'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Creado el ${Formatters.date(widget.header.createdAt)}'),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('Contraseña')),
                ButtonSegment(value: true, label: Text('Código de recuperación')),
              ],
              selected: {_useRecovery},
              onSelectionChanged: (s) => setState(() => _useRecovery = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('restore-secret'),
              controller: _secret,
              obscureText: !_useRecovery,
              autofocus: true,
              decoration: InputDecoration(labelText: _useRecovery ? 'XXXX-XXXX-…' : 'Contraseña de respaldo'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              key: const Key('restore-understood'),
              contentPadding: EdgeInsets.zero,
              value: _understood,
              onChanged: (v) => setState(() => _understood = v ?? false),
              title: Text(
                'Entiendo que se reemplazarán todos los datos de este dispositivo.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          key: const Key('restore-ok'),
          onPressed: _understood && _secret.text.trim().isNotEmpty
              ? () => Navigator.pop(context, (
                  passphrase: _useRecovery ? null : _secret.text,
                  recoveryCode: _useRecovery ? _secret.text : null,
                ))
              : null,
          child: const Text('Restaurar'),
        ),
      ],
    );
  }
}

/// Muestra el código de recuperación una sola vez.
class RecoveryCodeScreen extends StatefulWidget {
  const RecoveryCodeScreen({super.key, required this.code});

  final String code;

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = widget.code.split('-');
    return PopScope(
      canPop: _saved,
      child: Scaffold(
        appBar: AppBar(title: const Text('Código de recuperación'), automaticallyImplyLeading: false),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Icon(Icons.key, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                const Text(
                  'Si olvidas tu contraseña, este código es la ÚNICA forma de recuperar tus respaldos. '
                  'Anótalo en papel o guárdalo en un gestor de contraseñas. No se volverá a mostrar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final g in groups)
                          Text(
                            g,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFeatures: const [FontFeature.tabularFigures()],
                              letterSpacing: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: widget.code));
                    if (context.mounted) showMessage(context, 'Copiado. Pégalo en tu gestor de contraseñas.');
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar'),
                ),
                CheckboxListTile(
                  key: const Key('recovery-saved'),
                  value: _saved,
                  onChanged: (v) => setState(() => _saved = v ?? false),
                  title: const Text('Ya lo guardé en un lugar seguro'),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('recovery-done'),
                  onPressed: _saved ? () => Navigator.pop(context) : null,
                  child: const Text('Listo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
