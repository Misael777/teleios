import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleios/app.dart';
import 'package:teleios/core/preferences/app_settings.dart';
import 'package:teleios/core/security/app_lock.dart';
import 'package:teleios/features/altar/presentation/altar_providers.dart';
import 'package:teleios/infrastructure/stt/speech_service.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/domain/entities/prayer_entry.dart';
import 'package:teleios/shared/domain/repositories/attachment_store.dart';
import 'package:teleios/shared/providers.dart';

import '../helpers.dart';
import 'fakes.dart';

/// Simula el reconocedor de Android: cada sesión emite su guion de resultados `(texto, final)` y termina.
/// Cuando se acaba el guion, las sesiones terminan sin texto (silencio).
class FakeSpeech implements SpeechService {
  FakeSpeech(this.sessions, {this.availability = SpeechAvailability.available});

  final List<List<(String, bool)>> sessions;
  final SpeechAvailability availability;
  int started = 0;
  bool _listening = false;

  @override
  bool get isListening => _listening;

  @override
  Future<SpeechAvailability> initialize() async => availability;

  @override
  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    required void Function(double level) onLevel,
    required void Function(SpeechAvailability? problem) onDone,
  }) async {
    _listening = true;
    for (final l in [1.0, 5.0, 3.0, 8.0]) {
      onLevel(l);
    }
    final script = started < sessions.length ? sessions[started] : const <(String, bool)>[];
    started++;
    for (final (text, isFinal) in script) {
      onResult(text, isFinal);
    }
    _listening = false;
    onDone(null);
  }

  @override
  Future<void> stop() async => _listening = false;
}

void main() {
  late AppDatabase db;
  setUpAll(() => initializeDateFormatting('es'));
  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester, {SpeechService? speech}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarding.v1.completed': true, 'ui.show_cover': false});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
          bibleRepositoryProvider.overrideWithValue(FakeBible()),
          attachmentStoreProvider.overrideWithValue(MemoryAttachmentStore()),
          deviceAuthenticatorProvider.overrideWithValue(FakeAuthenticator()),
          if (speech != null) speechServiceProvider.overrideWithValue(speech),
        ],
        child: const TeleiosApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('registro rápido de praxis en pocos toques', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Bitácora'));
    await tester.pumpAndSettle();
    expect(find.text('Tu primera praxis'), findsOneWidget);

    await tester.tap(find.byKey(const Key('quick-praxis')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('praxis-circumstance')), 'Me cerraron el paso en el tráfico');
    await tester.tap(find.widgetWithText(FilterChip, 'Ira'));
    await tester.tap(find.text('Impulso'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('save-praxis')));
    await tester.pumpAndSettle();

    expect(find.text('Registro rápido'), findsOneWidget, reason: 'el detalle invita a completarlo');
    final rows = (await tester.runAsync(() => db.select(db.praxisEntries).get()))!;
    expect(rows.single.coherence, isNull);
    expect(rows.single.circumstance, 'Me cerraron el paso en el tráfico');
    await unmount(tester);
  });

  testWidgets('agregar una emoción propia con el teclado abierto no rompe el editor', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Bitácora'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quick-praxis')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Otra'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('new-emotion-name')), 'Nostalgia');
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(FilterChip, 'Nostalgia'), findsOneWidget);
    expect(find.text('Sentí: nostalgia'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('dictar una oración: transcribe, sugiere intención y guarda', (tester) async {
    final speech = FakeSpeech([
      [
        ('Padre te doy', false),
        ('Padre te doy gracias', false),
        // Tras una pausa, el reconocedor reinicia la frase sin marcar la anterior como final.
        ('por tu fidelidad', false),
        ('por tu fidelidad y te alabo', true),
      ],
      // Android cortó la escucha por silencio: la app reanuda y el texto continúa.
      [('en el nombre de Jesús', true)],
    ]);
    await pumpApp(tester, speech: speech);
    await tester.tap(find.text('Altar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-prayer')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('mic-button')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pumpAndSettle();
    expect(find.text('Padre te doy gracias por tu fidelidad y te alabo en el nombre de Jesús'), findsOneWidget);
    expect(speech.started, 5, reason: '2 sesiones con texto + 3 de silencio antes de detenerse');
    expect(find.text('Toca para dictar · el audio no se guarda'), findsOneWidget);
    expect(find.textContaining('Sugerida: Agradecimiento'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save-prayer')));
    await tester.pumpAndSettle();
    final rows = (await tester.runAsync(() => db.select(db.prayers).get()))!;
    expect(rows.single.intent, PrayerIntent.agradecimiento);
    await unmount(tester);
  });

  testWidgets('sin dictado offline, el micrófono se desactiva y se explica por qué', (tester) async {
    await pumpApp(tester, speech: FakeSpeech(const [], availability: SpeechAvailability.onDeviceUnavailable));
    await tester.tap(find.text('Altar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-prayer')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('mic-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('dictado sin conexión'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('mic-button'))).onPressed, isNull);
    await unmount(tester);
  });
}
