import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/altar/altar_screen.dart';
import '../../features/altar/presentation/prayer_composer_screen.dart';
import '../../features/altar/presentation/prayer_detail_screen.dart';
import '../../features/backup/presentation/auto_backup_hook.dart';
import '../../features/backup/presentation/backup_screen.dart';
import '../../features/bitacora/bitacora_screen.dart';
import '../../features/bitacora/presentation/praxis_detail_screen.dart';
import '../../features/bitacora/presentation/praxis_editor_screen.dart';
import '../../features/coherencia/presentation/belief_detail_screen.dart';
import '../../features/coherencia/presentation/coherence_screen.dart';
import '../../features/cover/cover_screen.dart';
import '../../features/ejes/ejes_screen.dart';
import '../../features/ejes/presentation/graph_screen.dart';
import '../../features/ejes/presentation/mind_map_screen.dart';
import '../../features/ejes/presentation/sankey_screen.dart';
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
  static const portada = '/portada';
  static const settings = '/ajustes';
  static const backup = '/ajustes/respaldo';
  static const estudio = '/estudio';
  static const nuevoDevocional = '/estudio/nuevo';
  static const biblia = '/estudio/biblia';
  static const lineaDeTiempo = '/estudio/linea-de-tiempo';
  static const incubacion = '/estudio/incubacion';
  static const bitacora = '/bitacora';
  static const nuevoRegistro = '/bitacora/nuevo';
  static const registroRapido = '/bitacora/rapido';

  static String registro(String id) => '/bitacora/registro/$id';

  static String editarRegistro(String id) => '/bitacora/registro/$id/editar';
  static const altar = '/altar';
  static const orar = '/altar/orar';

  static String oracion(String id) => '/altar/oracion/$id';

  static String editarOracion(String id) => '/altar/oracion/$id/editar';
  static const ejes = '/ejes';
  static const grafo = '/ejes/grafo';
  static const aluvion = '/ejes/aluvion';
  static const coherencia = '/ejes/coherencia';
  static const mente = '/ejes/mente';

  static String creencia(String id) => '/ejes/coherencia/creencia/$id';

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
    initialLocation: ref.read(appSettingsProvider).showCover ? Routes.portada : Routes.estudio,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded.value && !atOnboarding) return Routes.onboarding;
      if (onboarded.value && atOnboarding) return Routes.estudio;
      return null;
    },
    routes: [
      GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: Routes.portada, builder: (_, _) => const CoverScreen()),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsScreen(),
        routes: [GoRoute(path: 'respaldo', builder: (_, _) => const BackupScreen())],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AutoBackupHook(child: HomeShell(shell: shell)),
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
            routes: [
              GoRoute(
                path: Routes.bitacora,
                builder: (_, _) => const BitacoraScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const PraxisEditorScreen(),
                  ),
                  GoRoute(
                    path: 'rapido',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const PraxisEditorScreen(quick: true),
                  ),
                  GoRoute(
                    path: 'registro/:id',
                    builder: (_, state) => PraxisDetailScreen(id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => PraxisEditorScreen(praxisId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.altar,
                builder: (_, _) => const AltarScreen(),
                routes: [
                  GoRoute(
                    path: 'orar',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const PrayerComposerScreen(),
                  ),
                  GoRoute(
                    path: 'oracion/:id',
                    builder: (_, state) => PrayerDetailScreen(id: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => PrayerComposerScreen(prayerId: state.pathParameters['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.ejes,
                builder: (_, _) => const EjesScreen(),
                routes: [
                  GoRoute(path: 'grafo', builder: (_, _) => const GraphScreen()),
                  GoRoute(path: 'aluvion', builder: (_, _) => const SankeyScreen()),
                  GoRoute(path: 'mente', builder: (_, _) => const MindMapScreen()),
                  GoRoute(
                    path: 'coherencia',
                    builder: (_, _) => const CoherenceScreen(),
                    routes: [
                      GoRoute(
                        path: 'creencia/:id',
                        builder: (_, state) => BeliefDetailScreen(id: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
