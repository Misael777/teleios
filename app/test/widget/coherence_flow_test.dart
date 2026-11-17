import 'package:drift/drift.dart' show Value;
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
import 'package:teleios/features/bitacora/data/drift_praxis_repository.dart';
import 'package:teleios/features/coherencia/domain/belief.dart';
import 'package:teleios/features/coherencia/presentation/coherence_providers.dart';
import 'package:teleios/shared/data/database/app_database.dart';
import 'package:teleios/shared/domain/entities/praxis_entry.dart';
import 'package:teleios/shared/providers.dart';

import '../helpers.dart';
import 'fakes.dart';

/// Coherencia medida de punta a punta (O4, sin modelo): devocional → creencia con huella canónica →
/// vínculo desde la bitácora → pantalla de coherencia y etiquetado compartido.
void main() {
  late AppDatabase db;

  setUpAll(() => initializeDateFormatting('es'));
  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
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
          deviceAuthenticatorProvider.overrideWithValue(FakeAuthenticator()),
          // Sin System One instalado: todo manual (O4).
          systemOneProvider.overrideWith((ref) async => null),
          nliJudgeProvider.overrideWith((ref) async => null),
        ],
        child: const TeleiosApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, String location) async {
    GoRouter.of(tester.element(find.byType(Navigator).first)).go(location);
    await tester.pumpAndSettle();
  }

  testWidgets('crear una creencia desde un devocional, vincular praxis y etiquetar', (tester) async {
    final now = DateTime(2026, 10, 30, 9);
    await tester.runAsync(() async {
      await db
          .into(db.devotionals)
          .insert(
            DevotionalsCompanion.insert(
              id: 'd1',
              date: now,
              bookCode: 'GAL',
              chapter: 5,
              verseStart: const Value(22),
              verseEnd: const Value(23),
              content:
                  '## Hermenéutica · ¿Cuál es el principio atemporal?\n'
                  'El Espíritu produce en mí lo que yo no puedo producir {Juan 15:5}',
              title: const Value('El fruto que Dios produce'),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await DriftPraxisRepository(db).upsert(
        PraxisEntry(
          id: 'p1',
          date: now,
          circumstance: 'Mi hijo derramó la leche',
          emotionIds: const [],
          intensity: 6,
          filter: FilterType.biblico,
          action: 'Respiré y le ayudé a limpiar',
          peace: 8,
          coherence: 8,
        ),
      );
    });
    await pumpApp(tester);

    // Devocional → "Convertir en creencia": propone el principio atemporal y trae la evidencia canónica.
    await go(tester, Routes.devocional('d1'));
    final convert = find.byKey(const Key('devotional-to-belief'));
    await tester.scrollUntilVisible(convert, 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(convert);
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byKey(const Key('belief-proposition')));
    expect(field.controller!.text, 'El Espíritu produce en mí lo que yo no puedo producir');
    await tester.tap(find.byKey(const Key('save-belief')));
    await tester.pumpAndSettle();

    // Detalle: cita confirmada (Juan 15:5) + referencias cruzadas de Gálatas 5 (Efesios 5:9, Romanos 14:17).
    expect(find.text('Huella canónica'), findsOneWidget);
    expect(find.byKey(const Key('coherence-vector')), findsOneWidget);
    final beliefs = (await tester.runAsync(() => db.select(db.beliefs).get()))!;
    final evidence = (await tester.runAsync(() => db.select(db.beliefEvidenceTable).get()))!;
    expect(beliefs.single.origin, BeliefOrigin.devocional);
    expect(beliefs.single.basePassage, 'GAL.5.22-23');
    expect(evidence.map((e) => e.passage), containsAll(['JOH.15.5', 'EPH.5.9', 'ROM.14.17']));
    expect(evidence.firstWhere((e) => e.passage == 'JOH.15.5').source, EvidenceSource.cita);

    // Bitácora → vincular el registro a la creencia ("actué desde ella").
    await go(tester, Routes.registro('p1'));
    final linkButton = find.byKey(const Key('link-belief'));
    await tester.scrollUntilVisible(linkButton, 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(linkButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('pick-belief-${beliefs.single.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('alignment-desde')));
    await tester.pumpAndSettle();
    final links = (await tester.runAsync(() => db.select(db.actionBeliefs).get()))!;
    expect(links.single.alignment, ActionAlignment.desde);
    expect(links.single.confirmed, isTrue);

    // Coherencia: la creencia aparece y los gráficos piden más datos en lugar de inventar tendencias.
    await go(tester, Routes.coherencia);
    expect(find.byKey(Key('belief-${beliefs.single.id}')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tab-graficos')));
    await tester.pumpAndSettle();
    final chart = find.byKey(const Key('chart-alignment-peace'));
    await tester.scrollUntilVisible(chart, 300, scrollable: find.byType(Scrollable).last);
    expect(find.descendant(of: chart, matching: find.textContaining('n = 1 de 10')), findsOneWidget);

    // Etiquetar: ítems compartidos con progreso; responder guarda la etiqueta.
    await tester.tap(find.byKey(const Key('tab-etiquetar')));
    await tester.pumpAndSettle();
    expect(find.textContaining('0 de '), findsOneWidget);
    await tester.tap(find.byKey(const Key('answer-neutral')).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('1 de '), findsOneWidget);
    expect((await tester.runAsync(() => db.select(db.sharedLabels).get()))!, hasLength(1));

    // Modelo: sin System One, la transparencia lo dice.
    await tester.tap(find.byKey(const Key('tab-modelo')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sin modelo'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
