import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias no sensibles (nada del contenido del usuario vive aquí).
class AppSettings {
  const AppSettings({
    required this.onboardingCompleted,
    required this.lockEnabled,
    required this.themeMode,
    this.showCover = true,
  });

  final bool onboardingCompleted;

  /// Mostrar la portada (marca y lema) al abrir la app.
  final bool showCover;
  final bool lockEnabled;
  final ThemeMode themeMode;
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Se inyecta en main()'),
);

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _onboarding = 'onboarding.v1.completed';
  static const _lock = 'security.lock_enabled';
  static const _theme = 'ui.theme_mode';
  static const _cover = 'ui.show_cover';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      onboardingCompleted: prefs.getBool(_onboarding) ?? false,
      lockEnabled: prefs.getBool(_lock) ?? false,
      themeMode: ThemeMode.values.byName(prefs.getString(_theme) ?? ThemeMode.system.name),
      showCover: prefs.getBool(_cover) ?? true,
    );
  }

  Future<void> completeOnboarding({required bool enableLock}) async {
    await _prefs.setBool(_lock, enableLock);
    await _prefs.setBool(_onboarding, true);
    ref.invalidateSelf();
  }

  Future<void> setLockEnabled(bool value) async {
    await _prefs.setBool(_lock, value);
    ref.invalidateSelf();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_theme, mode.name);
    ref.invalidateSelf();
  }

  Future<void> setShowCover(bool value) async {
    await _prefs.setBool(_cover, value);
    ref.invalidateSelf();
  }

  Future<void> reset() async {
    await _prefs.clear();
    ref.invalidateSelf();
  }
}
