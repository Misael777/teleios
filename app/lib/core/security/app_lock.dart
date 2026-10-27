import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../preferences/app_settings.dart';
import '../theme/teleios_logo.dart';

/// Autenticación del sistema (huella, rostro, PIN del dispositivo, Windows Hello).
abstract interface class DeviceAuthenticator {
  Future<bool> isSupported();

  Future<bool> authenticate(String reason);
}

class LocalAuthAuthenticator implements DeviceAuthenticator {
  LocalAuthAuthenticator([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      // biometricOnly: false → permite el PIN/patrón del dispositivo como respaldo.
      return await _auth.authenticate(localizedReason: reason);
    } on LocalAuthException {
      return false;
    }
  }
}

final deviceAuthenticatorProvider = Provider<DeviceAuthenticator>((ref) => LocalAuthAuthenticator());

final lockSupportedProvider = FutureProvider<bool>((ref) => ref.watch(deviceAuthenticatorProvider).isSupported());

final appLockProvider = NotifierProvider<AppLockController, bool>(AppLockController.new);

/// Estado: `true` = bloqueada.
class AppLockController extends Notifier<bool> {
  static const relockAfter = Duration(minutes: 1);

  DateTime? _backgroundedAt;
  bool _authenticating = false;

  @override
  bool build() {
    final settings = ref.read(appSettingsProvider);
    // Bloqueada desde el arranque si el usuario activó el bloqueo.
    return settings.onboardingCompleted && settings.lockEnabled;
  }

  void onPaused() => _backgroundedAt ??= DateTime.now();

  void onResumed() {
    final since = _backgroundedAt;
    _backgroundedAt = null;
    if (!ref.read(appSettingsProvider).lockEnabled || since == null) return;
    if (DateTime.now().difference(since) >= relockAfter) state = true;
  }

  Future<void> unlock() async {
    if (_authenticating) return;
    _authenticating = true;
    try {
      final ok = await ref.read(deviceAuthenticatorProvider).authenticate('Desbloquea TELEIOS para ver tu diario');
      if (ok) state = false;
    } finally {
      _authenticating = false;
    }
  }
}

/// Envuelve la app: muestra la pantalla de bloqueo encima del contenido cuando corresponde.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(appLockProvider)) ref.read(appLockProvider.notifier).unlock();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        lock.onPaused();
      case AppLifecycleState.resumed:
        lock.onResumed();
        if (ref.read(appLockProvider)) lock.unlock();
      case _:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    return Stack(
      children: [
        // El contenido no se pinta mientras está bloqueada (tampoco en el selector de apps).
        Offstage(
          offstage: locked,
          child: TickerMode(enabled: !locked, child: widget.child),
        ),
        if (locked) const _LockScreen(),
      ],
    );
  }
}

class _LockScreen extends ConsumerWidget {
  const _LockScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TeleiosMark(size: 112),
              const SizedBox(height: 24),
              const TeleiosWordmark(scale: 0.8),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Tu diario está protegido',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => ref.read(appLockProvider.notifier).unlock(),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Desbloquear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
