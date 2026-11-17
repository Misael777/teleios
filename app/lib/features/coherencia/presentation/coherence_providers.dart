import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences/app_settings.dart';
import '../../../core/utils/ids.dart';
import '../../../infrastructure/ml/system_one_loader.dart';
import '../../../shared/providers.dart';
import '../data/drift_coherence_repository.dart';
import '../domain/coherence_data.dart';
import '../domain/coherence_judge.dart';
import '../domain/coherence_usecases.dart';
import '../domain/labeling.dart';
import '../domain/thought_prototypes.dart';

final coherenceRepositoryProvider = Provider((ref) => DriftCoherenceRepository(ref.watch(appDatabaseProvider)));

final coherenceDatasetProvider = StreamProvider<CoherenceDataset>(
  (ref) => ref.watch(coherenceRepositoryProvider).watch(),
);

final saveBeliefProvider = Provider((ref) => SaveBelief(ref.watch(coherenceRepositoryProvider)));

final importCanonicalEvidenceProvider = Provider(
  (ref) => ImportCanonicalEvidence(
    repo: ref.watch(coherenceRepositoryProvider),
    bible: ref.watch(bibleRepositoryProvider),
    devotionals: ref.watch(devotionalRepositoryProvider),
  ),
);

// ─── System One local (S13-S15) ────────────────────────────────────────────

/// Modelo instalado, o null (O4: todo manual). Se invalida al instalar o desinstalar.
final systemOneProvider = FutureProvider<SystemOneModel?>((ref) => openInstalledSystemOne());

/// Juez grande opcional (mDeBERTa, §12.5), o null. Se invalida al instalar o desinstalar.
final nliJudgeProvider = FutureProvider<DeepJudge?>((ref) => openInstalledNliJudge());

/// Cascada System One → juez grande → usuario. Null sin System One (O4: todo manual).
final cascadeJudgeProvider = FutureProvider<CascadeJudge?>((ref) async {
  final model = await ref.watch(systemOneProvider.future);
  if (model == null) return null;
  // Si el juez grande falla al abrir, la cascada sigue con el System One solo.
  final deep = await ref.watch(nliJudgeProvider.future).catchError((_) => null);
  return CascadeJudge(model, threshold: model.routeThreshold, deep: deep, deepThreshold: deep?.routeThreshold ?? 0.9);
});

final prototypeCatalogProvider = FutureProvider<PrototypeCatalog?>((ref) async {
  final model = await ref.watch(systemOneProvider.future);
  return model?.prototypeCatalog;
});

final judgeFeedbackProvider = StreamProvider<List<JudgeFeedbackEntry>>(
  (ref) => ref.watch(coherenceRepositoryProvider).watchFeedback(),
);

final patternAssignmentsProvider = StreamProvider<List<PatternAssignmentRecord>>(
  (ref) => ref.watch(coherenceRepositoryProvider).watchPatterns(),
);

// ─── Etiquetado compartido (S12) ───────────────────────────────────────────

const sharedItemsAsset = 'assets/ml/shared_items_v1.json';

final sharedItemsProvider = FutureProvider<({String version, List<SharedItem> items})>((ref) async {
  final json = jsonDecode(await rootBundle.loadString(sharedItemsAsset)) as Map<String, dynamic>;
  return (
    version: json['version'] as String,
    items: [for (final i in json['items'] as List) SharedItem.fromJson(i as Map<String, dynamic>)],
  );
});

final sharedLabelsProvider = StreamProvider<List<SharedLabel>>(
  (ref) => ref.watch(coherenceRepositoryProvider).watchSharedLabels(),
);

/// Id anónimo y local del etiquetador: permite medir su fiabilidad (Dawid-Skene) sin identificarlo.
final annotatorIdProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  const key = 'labeling.annotator_id';
  final existing = prefs.getString(key);
  if (existing != null) return existing;
  final id = 'anon-${newId().split('-').last}';
  prefs.setString(key, id);
  return id;
});
