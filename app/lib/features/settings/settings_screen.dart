import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/env.dart';
import '../../core/preferences/app_settings.dart';
import '../../core/security/app_lock.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/common_widgets.dart';
import 'data_export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final lockSupported = ref.watch(lockSupportedProvider).value ?? false;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          const _Header('Apariencia'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (s) => ref.read(appSettingsProvider.notifier).setThemeMode(s.first),
            ),
          ),
          const _Header('Seguridad'),
          SwitchListTile(
            value: settings.lockEnabled,
            onChanged: lockSupported
                ? (v) async {
                    // Confirmar identidad antes de desactivar o activar.
                    final ok = await ref
                        .read(deviceAuthenticatorProvider)
                        .authenticate('Confirma para cambiar el bloqueo');
                    if (ok) await ref.read(appSettingsProvider.notifier).setLockEnabled(v);
                  }
                : null,
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Bloqueo con huella, rostro o PIN'),
            subtitle: Text(
              lockSupported ? 'Al abrir y tras 1 minuto en segundo plano' : 'No disponible en este dispositivo',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.enhanced_encryption_outlined),
            title: Text('Base de datos cifrada'),
            subtitle: Text('AES-256 (SQLite3MultipleCiphers). La llave vive en el almacén seguro del sistema.'),
          ),
          const _Header('Mis datos'),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Exportar mis datos (JSON)'),
            subtitle: const Text('Copia legible de todo tu diario. El archivo no va cifrado.'),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text('Borrar todos mis datos', style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Elimina devocionales, tópicos y registros de este dispositivo.'),
            onTap: () => _wipe(context, ref),
          ),
          const _Header('Acerca de'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('TELEIOS'),
            subtitle: Text('Entorno: ${Env.name}'),
          ),
          const ListTile(
            leading: Icon(Icons.menu_book_outlined),
            title: Text('Texto bíblico: Reina-Valera 1909'),
            subtitle: Text('Dominio público · Fuente: eBible.org'),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar sin cifrar'),
        content: const Text(
          'El archivo contendrá tus reflexiones en texto legible. '
          'Guárdalo solo en un lugar de confianza.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exportar')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final bytes = await DataExportService(ref.read(appDatabaseProvider)).exportBytes();
      final name = 'teleios_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'application/json', name: name)],
          fileNameOverrides: [name],
          subject: 'Exportación de TELEIOS',
        ),
      );
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _wipe(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('¿Borrar todo?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Esta acción no se puede deshacer. Escribe BORRAR para confirmar.'),
              const SizedBox(height: 12),
              TextField(controller: controller, autofocus: true, onChanged: (_) => setState(() {})),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: controller.text.trim() == 'BORRAR' ? () => Navigator.pop(context, true) : null,
              child: const Text('Borrar'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (confirmed != true) return;
    await ref.read(appDatabaseProvider).wipeUserData();
    // Vuelve al onboarding.
    await ref.read(appSettingsProvider.notifier).reset();
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}
