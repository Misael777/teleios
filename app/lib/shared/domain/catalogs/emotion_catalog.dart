/// Semillas de emociones y detonantes. Se copian a la base en el primer arranque;
/// desde el Sprint 5 el usuario podrá agregar las suyas.
library;

class EmotionSeed {
  const EmotionSeed(this.id, this.name, [this.parentId]);

  final String id;
  final String name;

  /// null = emoción primaria.
  final String? parentId;
}

abstract final class EmotionCatalog {
  static const emotions = <EmotionSeed>[
    EmotionSeed('alegria', 'Alegría'),
    EmotionSeed('gozo', 'Gozo', 'alegria'),
    EmotionSeed('gratitud', 'Gratitud', 'alegria'),
    EmotionSeed('esperanza', 'Esperanza', 'alegria'),
    EmotionSeed('paz', 'Paz', 'alegria'),
    EmotionSeed('tristeza', 'Tristeza'),
    EmotionSeed('soledad', 'Soledad', 'tristeza'),
    EmotionSeed('desanimo', 'Desánimo', 'tristeza'),
    EmotionSeed('decepcion', 'Decepción', 'tristeza'),
    EmotionSeed('duelo', 'Duelo', 'tristeza'),
    EmotionSeed('ira', 'Ira'),
    EmotionSeed('frustracion', 'Frustración', 'ira'),
    EmotionSeed('impaciencia', 'Impaciencia', 'ira'),
    EmotionSeed('resentimiento', 'Resentimiento', 'ira'),
    EmotionSeed('celos', 'Celos / Envidia', 'ira'),
    EmotionSeed('miedo', 'Miedo'),
    EmotionSeed('ansiedad', 'Ansiedad', 'miedo'),
    EmotionSeed('inseguridad', 'Inseguridad', 'miedo'),
    EmotionSeed('preocupacion', 'Preocupación', 'miedo'),
    EmotionSeed('verguenza', 'Vergüenza'),
    EmotionSeed('culpa', 'Culpa', 'verguenza'),
    EmotionSeed('humillacion', 'Humillación', 'verguenza'),
    EmotionSeed('sorpresa', 'Sorpresa'),
    EmotionSeed('asombro', 'Asombro', 'sorpresa'),
    EmotionSeed('confusion', 'Confusión', 'sorpresa'),
  ];

  static const triggers = <EmotionSeed>[
    EmotionSeed('t_ira', 'Ira'),
    EmotionSeed('t_orgullo', 'Orgullo'),
    EmotionSeed('t_miedo', 'Miedo'),
    EmotionSeed('t_cansancio', 'Cansancio'),
    EmotionSeed('t_impaciencia', 'Impaciencia'),
    EmotionSeed('t_envidia', 'Envidia / comparación'),
    EmotionSeed('t_rechazo', 'Sentirme rechazado'),
    EmotionSeed('t_deseo', 'Deseo desordenado'),
    EmotionSeed('t_estres', 'Estrés / presión'),
  ];
}
