import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleios/core/preferences/app_settings.dart';
import 'package:teleios/core/security/app_lock.dart';
import 'package:teleios/features/onboarding/onboarding_screen.dart';

import 'fakes.dart';

void main() {
  testWidgets('no se puede comenzar sin los dos consentimientos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceAuthenticatorProvider.overrideWithValue(FakeAuthenticator(supported: true)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    FilledButton finish() => tester.widget<FilledButton>(find.byKey(const Key('onboarding-finish')));
    expect(finish().onPressed, isNull);

    await tester.tap(find.byKey(const Key('consent-data')));
    await tester.pump();
    expect(finish().onPressed, isNull, reason: 'falta el segundo consentimiento');

    await tester.tap(find.byKey(const Key('consent-not-clinical')));
    await tester.pump();
    expect(finish().onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('onboarding-finish')));
    await tester.pumpAndSettle();

    final settings = container.read(appSettingsProvider);
    expect(settings.onboardingCompleted, isTrue);
    expect(settings.lockEnabled, isTrue, reason: 'el bloqueo viene activado por defecto si el dispositivo lo soporta');
  });

  testWidgets('sin método de bloqueo en el dispositivo no se activa el bloqueo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceAuthenticatorProvider.overrideWithValue(FakeAuthenticator(supported: false)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('consent-data')));
    await tester.tap(find.byKey(const Key('consent-not-clinical')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('onboarding-finish')));
    await tester.pumpAndSettle();

    expect(container.read(appSettingsProvider).lockEnabled, isFalse);
  });
}
