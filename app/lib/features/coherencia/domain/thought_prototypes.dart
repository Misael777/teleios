import 'dart:typed_data';

import 'coherence_judge.dart';

/// Prototipo de pensamiento: un grupo de "misma cadena de razonamiento" del clusterizador de grafo
/// con signo (§11.2), con nombre propuesto por un LLM y confirmado por una persona.
class ThoughtPrototype {
  const ThoughtPrototype({
    required this.id,
    required this.name,
    required this.definition,
    required this.centroid,
    required this.examples,
    this.antagonistId,
    this.stability,
    this.structure = const {},
    this.confirmed = false,
  });

  factory ThoughtPrototype.fromJson(Map<String, dynamic> j) => ThoughtPrototype(
    id: j['id'] as String,
    name: j['name'] as String,
    definition: j['definition'] as String? ?? '',
    centroid: Float32List.fromList([for (final x in j['centroid'] as List) (x as num).toDouble()]),
    examples: [for (final e in j['examples'] as List? ?? const []) e as String],
    antagonistId: j['antagonist'] as String?,
    stability: (j['stability'] as num?)?.toDouble(),
    structure: {for (final e in (j['structure'] as Map? ?? const {}).entries) e.key as String: e.value as String},
    confirmed: j['confirmed'] as bool? ?? false,
  );

  final String id;
  final String name;
  final String definition;

  /// Centroide normalizado en el espacio del System One.
  final Float32List centroid;

  /// Ejemplos sintéticos o compartidos (nunca texto de diarios).
  final List<String> examples;

  /// Patrón antagónico (la cadena opuesta), si existe.
  final String? antagonistId;

  /// Estabilidad bootstrap (ARI medio) del grupo en el laboratorio.
  final double? stability;

  /// Estructura dominante: cabeza → etiqueta (p. ej. agente: yo, distorsion: catastrofizacion).
  final Map<String, String> structure;

  /// Nombre confirmado por una persona; si no, es la propuesta del LLM (§11.2 paso 6).
  final bool confirmed;

  String get displayName => confirmed ? name : '$name (nombre propuesto)';
}

class PrototypeAssignment {
  const PrototypeAssignment(this.prototype, this.similarity, this.margin);

  final ThoughtPrototype prototype;
  final double similarity;

  /// Diferencia con el segundo más cercano: con margen chico se escala al usuario.
  final double margin;
}

/// Catálogo exportado por el laboratorio. En el teléfono no se clusteriza: solo se asigna.
class PrototypeCatalog {
  PrototypeCatalog(this.version, this.prototypes, {required this.threshold, this.minMargin = 0.03});

  factory PrototypeCatalog.fromJson(Map<String, dynamic> j, {required double threshold}) => PrototypeCatalog(
    j['version'] as String? ?? 'sin-version',
    [for (final p in j['prototypes'] as List) ThoughtPrototype.fromJson(p as Map<String, dynamic>)],
    threshold: threshold,
  );

  final String version;
  final List<ThoughtPrototype> prototypes;
  final double threshold;
  final double minMargin;

  late final Map<String, ThoughtPrototype> byId = {for (final p in prototypes) p.id: p};

  ThoughtPrototype? antagonistOf(ThoughtPrototype p) => p.antagonistId == null ? null : byId[p.antagonistId];

  /// Prototipo más cercano si la similitud supera el umbral calibrado y el margen es suficiente.
  PrototypeAssignment? assign(Float32List embedding) {
    if (prototypes.isEmpty) return null;
    final scored = [for (final p in prototypes) (p, cosine(embedding, p.centroid))]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    final (best, sim) = scored.first;
    final margin = scored.length > 1 ? sim - scored[1].$2 : 1.0;
    if (sim < threshold || margin < minMargin) return null;
    return PrototypeAssignment(best, sim, margin);
  }
}
