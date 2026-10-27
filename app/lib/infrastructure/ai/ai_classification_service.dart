/// Contrato de clasificación tipada estilo *System One* (ADR-002).
///
/// La IA de TELEIOS no genera texto: elige, puntúa o decide. Cada proveedor
/// (léxico, embeddings ONNX, Ollama, Jev opt-in) implementa esta interfaz.
library;

class ChoiceResult {
  const ChoiceResult({required this.option, required this.confidence, this.reasons = const []});

  /// null si ninguna opción supera el umbral.
  final String? option;
  final double confidence;

  /// Evidencia legible para el usuario ("escribiste *esperar*, *calma*").
  final List<String> reasons;
}

class ScoreQuestion {
  const ScoreQuestion(this.key, this.question);

  final String key;
  final String question;
}

class ScoreResult {
  const ScoreResult(this.scores);

  /// key → valor en [1, 10]. Vacío si el proveedor no puede opinar.
  final Map<String, double> scores;
}

class NoulResult {
  const NoulResult({required this.yes, required this.confidence});

  final bool yes;
  final double confidence;
}

abstract interface class AiClassificationService {
  /// Nombre visible del proveedor ("Léxico local", "Ollama", ...).
  String get providerName;

  /// true si el texto nunca sale del dispositivo.
  bool get isOnDevice;

  Future<ChoiceResult> choose({required String context, required List<String> options, String? instruction});

  Future<ScoreResult> score({required String context, required List<ScoreQuestion> questions});

  Future<NoulResult> noul({required String context, required String yesNoQuestion});
}
