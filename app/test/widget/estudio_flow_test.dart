import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teleios/app.dart';
import 'package:teleios/core/preferences/app_settings.dart';
import 'package:teleios/core/router/app_router.dart';
import 'package:teleios/core/security/app_lock.dart';
import 'package:teleios/features/estudio/presentation/devotional_detail_screen.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/domain/entities/topic.dart';
import 'package:teleios/shared/providers.dart';

import '../helpers.dart';
import 'fakes.dart';

/// Flujo completo del estudio: crear un devocional con portada, reflexión guiada por secciones,
/// versículos vinculados con llaves, sugerencia aceptada; verlo en el detalle y en la lista.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('es'));
  setUp(() => db = memoryDatabase());
  // Fuera de la zona de reloj simulado de testWidgets, donde close() no avanza.
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester, {bool showCover = false}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'onboarding.v1.completed': true, 'ui.show_cover': showCover});
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
  }

  Future<void> unmount(WidgetTester tester) async {
    // Desmontar para cancelar los streams antes de que tearDown cierre la base.
    await tester.pumpWidget(const SizedBox.shrink());
    // Drift cierra los streams cancelados con un Timer de duración cero.
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> choosePassage(WidgetTester tester, String query, String button) async {
    await tester.enterText(find.byType(TextField).first, query);
    await tester.pump();
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
  }

  Future<void> reveal(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 250, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
  }

  Future<void> answer(WidgetTester tester, String questionId, String text) async {
    final field = find.byKey(Key('reflection-$questionId'));
    await reveal(tester, field);
    await tester.enterText(field, text);
  }

  testWidgets('la portada muestra la marca y el lema, y entra a la app', (tester) async {
    await pumpApp(tester, showCover: true);
    expect(find.text('ΤΕΛΕΙΟΣ'), findsOneWidget);
    expect(find.textContaining('MATEO 5:48'), findsWidgets);
    await tester.tap(find.byKey(const Key('enter-app')));
    await tester.pumpAndSettle();
    expect(find.text('Tu primer devocional'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('crear un devocional de punta a punta', (tester) async {
    await pumpApp(tester);

    // Lista vacía → nuevo devocional.
    expect(find.text('Tu primer devocional'), findsOneWidget);
    await tester.tap(find.byKey(const Key('new-devotional')));
    await tester.pumpAndSettle();

    // Elegir pasaje escribiendo la cita.
    await tester.tap(find.byKey(const Key('pick-passage')));
    await tester.pumpAndSettle();
    await choosePassage(tester, 'gá 5:22-23', 'Usar Gálatas 5:22-23');
    expect(find.text('Gálatas 5:22-23'), findsOneWidget);

    // Portada: título y versículo lema.
    await tester.enterText(find.byKey(const Key('devotional-title')), 'El fruto que Dios produce');
    await reveal(tester, find.byKey(const Key('pick-key-verse')));
    await tester.tap(find.byKey(const Key('pick-key-verse')));
    await tester.pumpAndSettle();
    // Abre en los versículos del pasaje estudiado; se vuelve al buscador con "atrás".
    expect(find.text('Gálatas 5:22-23'), findsWidgets);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
    }
    await choosePassage(tester, 'gá 5:22', 'Usar Gálatas 5:22');
    expect(find.text('Lema: Gálatas 5:22'), findsOneWidget);

    // Exégesis, escribiendo "{" para vincular un versículo.
    await answer(tester, 'exegesis.resumen', 'Pablo enumera el fruto del Espíritu ');
    await tester.enterText(
      find.byKey(const Key('reflection-exegesis.resumen')),
      'Pablo enumera el fruto del Espíritu {',
    );
    await tester.pumpAndSettle();
    await choosePassage(tester, 'jn 15:5', 'Usar Juan 15:5');
    final resumen = tester.widget<TextField>(find.byKey(const Key('reflection-exegesis.resumen')));
    expect(resumen.controller!.text, 'Pablo enumera el fruto del Espíritu {Juan 15:5} ');

    // Sin las preguntas clave obligatorias no se puede guardar.
    await tester.tap(find.byKey(const Key('save-devotional')));
    await tester.pump();
    expect(find.textContaining('Hermenéutica, Teología, Aplicación'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));

    // La batería de preguntas se despliega con "Profundizar".
    await reveal(tester, find.byKey(const Key('deepen-hermeneutica')));
    await tester.tap(find.byKey(const Key('deepen-hermeneutica')));
    await tester.pumpAndSettle();
    await answer(tester, 'hermeneutica.original', 'Los gálatas volvían a la ley.');
    await answer(tester, 'hermeneutica.principio', 'El Espíritu produce lo que la ley exige.');
    await answer(tester, 'teologia.dios', 'Dios produce el fruto, no yo.');
    // Las sugerencias aparecen tras el debounce.
    await answer(
      tester,
      'aplicacion.cambio',
      'El fruto del Espíritu incluye paciencia. Necesito dominio propio con mis hijos.',
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Tópicos por dimensión'));
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

    // Detalle: portada, pasaje, reflexión por sección y versículo vinculado.
    expect(find.byKey(const Key('devotional-cover')), findsOneWidget);
    expect(find.text('El fruto que Dios produce'), findsOneWidget);
    expect(find.text('— Gálatas 5:22'), findsOneWidget);
    expect(find.textContaining('Mansedumbre, templanza', findRichText: true), findsOneWidget);
    final detailScroll = find
        .descendant(of: find.byType(DevotionalDetailScreen), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(find.text('Hermenéutica'), 300, scrollable: detailScroll);
    expect(find.text('¿Cuál es el principio atemporal?'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pasajes vinculados'), 300, scrollable: detailScroll);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ActionChip, 'Juan 15:5'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Tópicos'), 300, scrollable: detailScroll);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(DevotionalDetailScreen), matching: find.text('Paciencia', skipOffstage: false)),
      findsOneWidget,
    );
    // Y en la lista de fondo, la tarjeta del nuevo devocional.
    expect(find.text('Tu primer devocional', skipOffstage: false), findsNothing);

    // Línea de tiempo: el vínculo aparece como hilo de la sección Exégesis.
    expect(find.text('Ver la red en la línea de tiempo', skipOffstage: false), findsOneWidget);
    GoRouter.of(tester.element(find.byType(DevotionalDetailScreen))).go(Routes.lineaDeTiempo);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('section-filter-exegesis')), findsOneWidget);
    expect(find.text('Exégesis · 1'), findsOneWidget);
    final network = find.byKey(const Key('network-JOH.15.5'));
    await tester.scrollUntilVisible(network, 300, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(network);
    await tester.pumpAndSettle();
    final selection = find.byKey(const Key('timeline-selection'));
    expect(selection, findsOneWidget);
    expect(find.descendant(of: selection, matching: find.text('Juan 15:5')), findsOneWidget);
    expect(find.descendant(of: selection, matching: find.text('Exégesis')), findsOneWidget);
    expect(find.descendant(of: selection, matching: find.text('desde El fruto que Dios produce')), findsOneWidget);

    // Lecturas directas a SQLite fuera del reloj simulado de testWidgets.
    final (topics, devotionals) = (await tester.runAsync(
      () async => (await db.select(db.topics).get(), await db.select(db.devotionals).get()),
    ))!;

    // Persistido como tópico sugerido y validado.
    final paciencia = topics.singleWhere((t) => t.name == 'Paciencia');
    expect(paciencia.status, TopicStatus.validado);
    expect(paciencia.origin, TopicOrigin.sugerido);

    final devotional = devotionals.single;
    expect(devotional.title, 'El fruto que Dios produce');
    expect(devotional.keyVerse, 'GAL.5.22');
    expect(devotional.content, contains('## Aplicación · ¿Qué vas a hacer distinto?'));
    expect(devotional.content, contains('{Juan 15:5}'));
    // El contexto histórico se pre-llenó desde el libro.
    expect(devotional.author, 'Pablo');
    expect(devotional.periodId, 'iglesia_primitiva');

    await unmount(tester);
  });
}
