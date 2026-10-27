import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/preferences/app_settings.dart';
import '../../core/security/app_lock.dart';
import '../../core/theme/teleios_logo.dart';

/// Propósito → privacidad → consentimiento explícito de datos sensibles.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  bool _consentData = false;
  bool _consentNotClinical = false;
  bool _enableLock = true;

  static const _pageCount = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() => _pages.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  Future<void> _finish() async {
    final lockSupported = ref.read(lockSupportedProvider).value ?? false;
    await ref.read(appSettingsProvider.notifier).completeOnboarding(enableLock: _enableLock && lockSupported);
  }

  @override
  Widget build(BuildContext context) {
    final canFinish = _consentData && _consentNotClinical;
    final lockSupported = ref.watch(lockSupportedProvider).value ?? false;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pages,
                    onPageChanged: (p) => setState(() => _page = p),
                    children: [
                      const _BrandPage(),
                      const _InfoPage(
                        icon: Icons.shield_outlined,
                        title: 'Tu diario es tuyo',
                        body:
                            '• Todo se guarda en este dispositivo, cifrado.\n'
                            '• No hay cuenta ni servidor para usar el diario.\n'
                            '• Las sugerencias de tópicos se calculan aquí mismo, sin internet.\n'
                            '• Más adelante podrás respaldar en tu Google Drive con una '
                            'contraseña que solo tú conoces.',
                      ),
                      _ConsentPage(
                        consentData: _consentData,
                        consentNotClinical: _consentNotClinical,
                        enableLock: _enableLock,
                        lockSupported: lockSupported,
                        onConsentData: (v) => setState(() => _consentData = v),
                        onConsentNotClinical: (v) => setState(() => _consentNotClinical = v),
                        onEnableLock: (v) => setState(() => _enableLock = v),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      for (var i = 0; i < _pageCount; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      const Spacer(),
                      if (_page < _pageCount - 1)
                        FilledButton(onPressed: _next, child: const Text('Siguiente'))
                      else
                        FilledButton(
                          key: const Key('onboarding-finish'),
                          onPressed: canFinish ? _finish : null,
                          child: const Text('Comenzar'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Primera impresión: el logo completo con el lema de Mateo 5:48.
class _BrandPage extends StatelessWidget {
  const _BrandPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
      children: [
        const TeleiosLogo(markSize: 128, showMotto: true),
        const SizedBox(height: 32),
        Text(
          'Un diario para estudiar la Escritura con rigor y observar, con honestidad, '
          'cómo lo que aprendes se refleja en tu vida.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 32),
        Icon(icon, size: 72, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _ConsentPage extends StatelessWidget {
  const _ConsentPage({
    required this.consentData,
    required this.consentNotClinical,
    required this.enableLock,
    required this.lockSupported,
    required this.onConsentData,
    required this.onConsentNotClinical,
    required this.onEnableLock,
  });

  final bool consentData;
  final bool consentNotClinical;
  final bool enableLock;
  final bool lockSupported;
  final ValueChanged<bool> onConsentData;
  final ValueChanged<bool> onConsentNotClinical;
  final ValueChanged<bool> onEnableLock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Antes de empezar', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        CheckboxListTile(
          key: const Key('consent-data'),
          value: consentData,
          onChanged: (v) => onConsentData(v ?? false),
          title: const Text('Consiento registrar datos sensibles'),
          subtitle: const Text(
            'Registrarás creencias religiosas y estados emocionales. Se guardan cifrados '
            'en este dispositivo y puedes exportarlos o borrarlos cuando quieras.',
          ),
        ),
        CheckboxListTile(
          key: const Key('consent-not-clinical'),
          value: consentNotClinical,
          onChanged: (v) => onConsentNotClinical(v ?? false),
          title: const Text('Entiendo que TELEIOS no es una herramienta de salud mental'),
          subtitle: const Text(
            'Las métricas son autoevaluaciones y muestran correlaciones, no diagnósticos. '
            'Si atraviesas una crisis, busca ayuda profesional y pastoral.',
          ),
        ),
        const Divider(height: 32),
        SwitchListTile(
          value: enableLock && lockSupported,
          onChanged: lockSupported ? onEnableLock : null,
          title: const Text('Bloquear con huella, rostro o PIN'),
          subtitle: Text(
            lockSupported
                ? 'Se pedirá al abrir la app y al volver tras 1 minuto.'
                : 'Este dispositivo no tiene un método de bloqueo configurado.',
          ),
        ),
      ],
    );
  }
}
