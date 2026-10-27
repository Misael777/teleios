import 'dart:math';

import '../../core/utils/text_normalizer.dart';
import 'ai_classification_service.dart';
import 'lexicon_es.dart';

/// Busca palabras clave en un texto comparando raíces, y frases completas.
class LexicalMatcher {
  LexicalMatcher(String text)
    : _phraseText = ' ${_flatten(text)} ',
      _stemToWord = {for (final token in TextNormalizer.tokenize(text)) TextNormalizer.stem(token): token};

  final String _phraseText;
  final Map<String, String> _stemToWord;

  static String _flatten(String s) => TextNormalizer.normalize(s).replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

  /// Palabras del texto que coinciden con [keywords] (sin repetir).
  List<String> matches(Iterable<String> keywords) {
    final found = <String>{};
    for (final keyword in keywords) {
      if (keyword.contains(' ')) {
        final phrase = _flatten(keyword);
        if (_phraseText.contains(' $phrase ')) found.add(phrase);
      } else {
        final word = _stemToWord[TextNormalizer.stem(keyword)];
        if (word != null) found.add(word);
      }
    }
    return found.toList();
  }

  /// true si todas las palabras significativas de [name] aparecen en el texto.
  bool containsAllWordsOf(String name) {
    final tokens = TextNormalizer.tokenize(name);
    return tokens.isNotEmpty && matches(tokens).length == tokens.length;
  }
}

/// Proveedor de nivel 0: sin modelos, sin red, explicable. Funciona en todas las plataformas.
class LexicalClassifier implements AiClassificationService {
  const LexicalClassifier({this.lexicon = LexiconEs.topics});

  final List<LexiconTopic> lexicon;

  /// Confianza creciente y acotada según el número de evidencias.
  static double confidenceFor(int hits) => hits <= 0 ? 0 : 1 - exp(-0.8 * hits);

  @override
  String get providerName => 'Léxico local';

  @override
  bool get isOnDevice => true;

  @override
  Future<ChoiceResult> choose({required String context, required List<String> options, String? instruction}) async {
    final matcher = LexicalMatcher(context);
    String? best;
    var bestHits = const <String>[];
    for (final option in options) {
      final key = TextNormalizer.key(option);
      final entry = lexicon.where((l) => TextNormalizer.key(l.name) == key).firstOrNull;
      final keywords = [...TextNormalizer.tokenize(option), ...?entry?.keywords];
      final hits = matcher.matches(keywords);
      if (hits.length > bestHits.length) {
        best = option;
        bestHits = hits;
      }
    }
    return ChoiceResult(option: best, confidence: confidenceFor(bestHits.length), reasons: bestHits);
  }

  /// El nivel léxico no puntúa: los puntajes los pone el usuario.
  @override
  Future<ScoreResult> score({required String context, required List<ScoreQuestion> questions}) async =>
      const ScoreResult({});

  @override
  Future<NoulResult> noul({required String context, required String yesNoQuestion}) async =>
      const NoulResult(yes: false, confidence: 0);
}
