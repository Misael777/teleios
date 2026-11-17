import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers.dart';
import '../../bitacora/presentation/bitacora_providers.dart';
import '../../coherencia/domain/belief.dart';
import '../../coherencia/domain/coherence_judge.dart';
import '../../coherencia/presentation/coherence_providers.dart';
import '../domain/mind_map.dart';

/// Embeddings ya calculados (por versión del modelo y texto): al cambiar un devocional o una praxis solo se
/// recalcula lo nuevo. Vive mientras la app está abierta; no se guarda en disco.
final _embeddingCacheProvider = Provider((ref) => <String, Float32List>{});

final _devotionalsProvider = StreamProvider((ref) => ref.watch(devotionalRepositoryProvider).watch());

final _praxisProvider = StreamProvider((ref) => ref.watch(praxisRepositoryProvider).watch());

/// Índice de las dos mentes en el espacio del System One. Null sin modelo instalado.
final mindIndexProvider = FutureProvider<MindIndex?>((ref) async {
  final model = await ref.watch(systemOneProvider.future);
  if (model == null) return null;
  final beliefs = (await ref.watch(coherenceDatasetProvider.future)).beliefs;
  final devotionals = await ref.watch(_devotionalsProvider.future);
  final praxis = await ref.watch(_praxisProvider.future);

  final items = <MindItem>[
    for (final b in beliefs)
      if (b.status != BeliefStatus.refutada)
        MindItem(
          id: 'creencia:${b.id}',
          side: MindSide.cristo,
          source: MindSource.creencia,
          text: b.proposition,
          refId: b.id,
          date: b.createdAt,
        ),
    for (final d in devotionals)
      for (final (i, s) in MindMap.sentences(d.content).indexed)
        MindItem(
          id: 'devocional:${d.id}:$i',
          side: MindSide.cristo,
          source: MindSource.devocional,
          text: s,
          refId: d.id,
          date: d.date,
        ),
    for (final r in praxis)
      if ('${r.entry.circumstance} ${r.entry.action}'.trim().isNotEmpty)
        MindItem(
          id: 'bitacora:${r.entry.id}',
          side: MindSide.mia,
          source: MindSource.bitacora,
          text: [r.entry.circumstance.trim(), r.entry.action.trim()].where((s) => s.isNotEmpty).join('. '),
          refId: r.entry.id,
          date: r.entry.date,
          filter: r.entry.filter,
          peace: r.entry.peace,
        ),
  ];

  final cache = ref.read(_embeddingCacheProvider);
  String key(String text) => '${model.version}\u0000$text';
  final missing = {for (final i in items) i.text}.where((t) => !cache.containsKey(key(t))).toList();
  if (missing.isNotEmpty) {
    final structures = await model.analyze(missing);
    for (final (i, t) in missing.indexed) {
      cache[key(t)] = structures[i].embedding;
    }
  }
  return MindIndex(items, [for (final i in items) cache[key(i.text)]!]);
});

/// Comparación de las dos mentes en una temática escrita por el usuario. Null sin System One o sin temática.
///
/// Sin juez grande solo se muestra lo cercano en el embedding, sin juzgar: el System One se equivoca con
/// confianza en estas preguntas (§13) y no se usa para ellas.
final themeComparisonProvider = FutureProvider.family<ThemeComparison?, String>((ref, theme) async {
  final query = theme.trim();
  if (query.isEmpty) return null;
  final index = await ref.watch(mindIndexProvider.future);
  final model = await ref.watch(systemOneProvider.future);
  if (index == null || model == null) return null;
  final deep = await ref.watch(nliJudgeProvider.future).catchError((_) => null);
  final vector = (await model.analyze([query])).single.embedding;
  if (deep == null) {
    final hits = MindMap.search(index, vector);
    return ThemeComparison.unjudged(query, hits, MindMap.project([...hits.christ, ...hits.mine]));
  }
  final hits = await MindMap.rerank(query, MindMap.search(index, vector, k: MindMap.candidates), deep);
  return MindMap.compare(query, hits, CascadeJudge(deep, threshold: deep.routeThreshold));
});
