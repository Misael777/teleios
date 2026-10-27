import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/altar/altar_screen.dart';
import '../../features/bitacora/bitacora_screen.dart';
import '../../features/ejes/ejes_screen.dart';
import '../../features/estudio/presentation/bible_reader_screen.dart';
import '../../features/estudio/presentation/devotional_detail_screen.dart';
import '../../features/estudio/presentation/devotional_editor_screen.dart';
import '../../features/estudio/presentation/devotional_list_screen.dart';
import '../../features/estudio/presentation/incubation_screen.dart';
import '../../features/estudio/presentation/timeline_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/domain/entities/passage_ref.dart';
import '../preferences/app_settings.dart';
import 'home_shell.dart';

abstract final class Routes {
  static const onboarding = '/bienvenida';
  static const settings = '/ajustes';
  static const estudio = '/estudio';
  static const nuevoDevocional = '/estudio/nuevo';
  static const biblia = '/estudio/biblia';
  static const lineaDeTiempo = '/estudio/linea-de-tiempo';
  static const incubacion = '/estudio/incubacion';
  static const bitacora = '/bitacora';
  static const altar = '/altar';
  static const ejes = '/ejes';

  static String devocional(String id) => '/estudio/devocional/$id';

  static String editarDevocional(String id) => '/estudio/devocional/$id/editar';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ValueNotifier(ref.read(appSettingsProvider).onboardingCompleted);
  ref.listen(appSettingsProvider, (_, next) => onboarded.value = next.onboardingCompleted);
  ref.onDispose(onboarded.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.estudio,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded.value && !atOnboarding) return Routes.onboarding;
      if (onboarded.value && atOnboarding) return Routes.estudio;
      return null;
    },
    routes: [
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.estudio,
                builder: (_, _) => const DevotionalListScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => DevotionalEditorScreen(initialPassage: state.extra as PassageRef?),
                  ),
                  GoRoute(path: 'biblia', builder: (_, _) => const BibleReaderScreen()),
                  GoRoute(path: 'linea-de-tiempo', builder: (_, _) => const TimelineScreen()),
                  GoRoute(path: 'incubacion', builder: (_, _) => const IncubationScreen()),
                  GoRoute(
                    path: 'devocional/:id',
                    builder: (_, state) => DevotionalDetailScreen(id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => DevotionalEditorScreen(devotionalId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.bitacora, builder: (_, _) => const BitacoraScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.altar, builder: (_, _) => const AltarScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.ejes, builder: (_, _) => const EjesScreen())],
          ),
        ],
      ),
    ],
  );
});
