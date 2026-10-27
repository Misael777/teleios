import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleios/app.dart';
import 'package:teleios/core/preferences/app_settings.dart';
import 'package:teleios/core/security/app_lock.dart';
import 'package:teleios/features/estudio/presentation/devotional_detail_screen.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/domain/entities/topic.dart';
import 'package:teleios/shared/providers.dart';

import '../helpers.dart';
import 'fakes.dart';

/// Flujo completo del Sprint 3-4: crear un devocional con pasaje, reflexión,
/// sugerencia aceptada y tópico propio; verlo en el detalle y en la lista.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('es'));
  setUp(() => db = memoryDatabase());
  // Fuera de la zona de reloj simulado de testWidgets, donde close() no avanza.
  tearDown(() => db.close());

  testWidgets('crear un devocional de punta a punta', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({'onboarding.v1.completed': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWithValue(db),
          bibleRepositoryProvider.overrideWithValue(FakeBible()),
          deviceAuthenticatorProvider.overrideWithValue(FakeAuthenticator()),
        ],
        child: const TeleiosApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Lista vacía → nuevo devocional.
    expect(find.text('Tu primer devocional'), findsOneWidget);
    await tester.tap(find.byKey(const Key('new-devotional')));
    await tester.pumpAndSettle();

    // Elegir pasaje escribiendo la cita.
    await tester.tap(find.byKey(const Key('pick-passage')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'gá 5:22-23');
    await tester.pump();
    await tester.tap(find.text('Usar Gálatas 5:22-23'));
    await tester.pumpAndSettle();
    expect(find.text('Gálatas 5:22-23'), findsOneWidget);

    // Reflexión → aparecen sugerencias tras el debounce.
    await tester.enterText(
      find.byKey(const Key('devotional-content')),
      'El fruto del Espíritu incluye paciencia. Necesito dominio propio con mis hijos.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.widgetWithIcon(InputChip, Icons.auto_awesome), findsWidgets);

    // Aceptar la sugerencia "Paciencia".
    final suggestion = find.widgetWithText(InputChip, 'Paciencia');
    await tester.ensureVisible(suggestion);
    await tester.pumpAndSettle();
    await tester.tap(suggestion);
    await tester.pumpAndSettle();

    // Guardar.
    await tester.tap(find.byKey(const Key('save-devotional')));
    await tester.pumpAndSettle();

    // Detalle: pasaje, texto de la Biblia y tópico.
    expect(find.text('Gálatas 5:22-23'), findsWidgets);
    expect(find.textContaining('Mansedumbre, templanza', findRichText: true), findsOneWidget);
    expect(
      find.descendant(of: find.byType(DevotionalDetailScreen), matching: find.text('Paciencia', skipOffstage: false)),
      findsOneWidget,
    );
    // Y en la lista de fondo, la tarjeta del nuevo devocional.
    expect(find.text('Tu primer devocional', skipOffstage: false), findsNothing);

    // Lecturas directas a SQLite fuera del reloj simulado de testWidgets.
    final (topics, devotionals) = (await tester.runAsync(
      () async => (await db.select(db.topics).get(), await db.select(db.devotionals).get()),
    ))!;

    // Persistido como tópico sugerido y validado.
    final paciencia = topics.singleWhere((t) => t.name == 'Paciencia');
    expect(paciencia.status, TopicStatus.validado);
    expect(paciencia.origin, TopicOrigin.sugerido);

    // El contexto histórico se pre-llenó desde el libro.
    final devotional = devotionals.single;
    expect(devotional.author, 'Pablo');
    expect(devotional.periodId, 'iglesia_primitiva');

    // Desmontar para cancelar los streams antes de que tearDown cierre la base.
    await tester.pumpWidget(const SizedBox.shrink());
    // Drift cierra los streams cancelados con un Timer de duración cero.
    await tester.pump(const Duration(seconds: 1));
  });
}
