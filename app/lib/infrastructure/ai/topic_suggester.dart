import 'dart:math';

import '../../core/utils/text_normalizer.dart';
import '../../shared/domain/entities/topic.dart';
import 'lexical_classifier.dart';
import 'lexicon_es.dart';

enum SuggestionSource { lexicon, myTopics, history }

class TopicSuggestion {
  const TopicSuggestion({
    required this.name,
    required this.dimensionId,
    required this.confidence,
    required this.reasons,
    required this.source,
    this.existingTopicId,
  });

  final String name;
  final String dimensionId;
  final double confidence;

  /// Explicación para el usuario: por qué se sugiere.
  final List<String> reasons;
  final SuggestionSource source;

  /// Si coincide con un tópico que el usuario ya tiene.
  final String? existingTopicId;

  String get key => '$dimensionId::${TextNormalizer.key(name)}';
}

/// Sugeridor híbrido: propone tópicos por dimensión; el usuario acepta, mueve o descarta.
///
/// Fuentes (de menor a mayor peso): historial del mismo libro, léxico general,
/// y los tópicos propios del usuario mencionados en el texto.
class TopicSuggester {
  const TopicSuggester({this.lexicon = LexiconEs.topics});

  final List<LexiconTopic> lexicon;

  static const historyConfidence = 0.35;
  static const myTopicConfidence = 0.85;

  List<TopicSuggestion> suggest({
    required String text,
    List<Topic> userTopics = const [],
    List<Topic> bookHistory = const [],
    String? bookName,
    String? historyReason,
    Set<String> exclude = const {},
    int perDimension = 3,
  }) {
    final matcher = LexicalMatcher(text);
    final usable = userTopics.where((t) => t.status != TopicStatus.refutado).toList();
    final byKey = {for (final t in usable) '${t.dimensionId}::${TextNormalizer.key(t.name)}': t};
    final results = <String, TopicSuggestion>{};

    void add(TopicSuggestion s) {
      final current = results[s.key];
      if (current == null) {
        results[s.key] = s;
        return;
      }
      // Fusiona evidencias de varias fuentes.
      results[s.key] = TopicSuggestion(
        name: current.name,
        dimensionId: s.dimensionId,
        confidence: min(0.99, max(current.confidence, s.confidence) + 0.1),
        reasons: {...current.reasons, ...s.reasons}.toList(),
        source: current.source.index > s.source.index ? current.source : s.source,
        existingTopicId: current.existingTopicId ?? s.existingTopicId,
      );
    }

    for (final topic in bookHistory) {
      if (topic.status == TopicStatus.refutado) continue;
      add(
        TopicSuggestion(
          name: topic.name,
          dimensionId: topic.dimensionId,
          confidence: historyConfidence,
          reasons: [historyReason ?? (bookName != null ? 'usado antes en $bookName' : 'usado antes en este libro')],
          source: SuggestionSource.history,
          existingTopicId: topic.id,
        ),
      );
    }

    for (final entry in lexicon) {
      final hits = matcher.matches(entry.keywords);
      if (hits.isEmpty) continue;
      final existing = byKey['${entry.dimensionId}::${TextNormalizer.key(entry.name)}'];
      add(
        TopicSuggestion(
          name: existing?.name ?? entry.name,
          dimensionId: entry.dimensionId,
          confidence: LexicalClassifier.confidenceFor(hits.length),
          reasons: hits,
          source: SuggestionSource.lexicon,
          existingTopicId: existing?.id,
        ),
      );
    }

    for (final topic in usable) {
      if (!matcher.containsAllWordsOf(topic.name)) continue;
      add(
        TopicSuggestion(
          name: topic.name,
          dimensionId: topic.dimensionId,
          confidence: myTopicConfidence,
          reasons: ['tu tópico «${topic.name}»'],
          source: SuggestionSource.myTopics,
          existingTopicId: topic.id,
        ),
      );
    }

    final sorted = results.values.where((s) => !exclude.contains(s.key)).toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final perDim = <String, int>{};
    return [
      for (final s in sorted)
        if ((perDim[s.dimensionId] = (perDim[s.dimensionId] ?? 0) + 1) <= perDimension) s,
    ];
  }
}
