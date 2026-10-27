import '../../shared/domain/entities/dimension.dart';

/// Tópico candidato del léxico con las palabras que lo evocan.
///
/// Las palabras se comparan por raíz (ver `TextNormalizer.stem`), así que basta
/// con listar formas distintas cuando el stemmer no las une (humilde / humildad).
/// Las entradas con espacio se buscan como frase.
class LexiconTopic {
  const LexiconTopic(this.name, this.dimensionId, this.keywords);

  final String name;
  final String dimensionId;
  final List<String> keywords;
}

abstract final class LexiconEs {
  static const _dios = Dimension.caracterDios;
  static const _hist = Dimension.contextoHistorico;
  static const _vida = Dimension.vidaPractica;
  static const _pens = Dimension.estructuraPensamiento;

  static const topics = <LexiconTopic>[
    // ── Carácter de Dios ──
    LexiconTopic('Soberanía', _dios, [
      'soberano',
      'soberania',
      'control',
      'propósito',
      'dispone',
      'decreto',
      'reina',
      'trono',
    ]),
    LexiconTopic('Santidad', _dios, ['santo', 'santidad', 'santificación', 'pureza', 'puro']),
    LexiconTopic('Amor de Dios', _dios, ['amor de dios', 'nos amó', 'amó', 'amado', 'dios es amor']),
    LexiconTopic('Misericordia', _dios, ['misericordia', 'misericordioso', 'compasión', 'piedad', 'clemencia']),
    LexiconTopic('Gracia', _dios, ['gracia', 'favor', 'inmerecido', 'regalo', 'dádiva']),
    LexiconTopic('Justicia de Dios', _dios, ['justicia', 'justo', 'juicio', 'juez', 'recto', 'rectitud']),
    LexiconTopic('Fidelidad', _dios, ['fiel', 'fidelidad', 'pacto', 'promesa', 'cumple', 'cumplió']),
    LexiconTopic('Omnipotencia', _dios, ['poder', 'poderoso', 'todopoderoso', 'omnipotente', 'fortaleza']),
    LexiconTopic('Providencia', _dios, ['provee', 'provisión', 'proveerá', 'sustento', 'cuidado', 'cuida']),
    LexiconTopic('Paternidad de Dios', _dios, ['padre', 'abba', 'adopción', 'hijos de dios']),
    LexiconTopic('Consolación', _dios, ['consuelo', 'consolación', 'consolar', 'consuela']),

    // ── Contexto Histórico ──
    LexiconTopic('Imperio Romano', _hist, ['roma', 'romano', 'romanos', 'césar', 'imperio', 'centurión']),
    LexiconTopic('Exilio babilónico', _hist, ['babilonia', 'exilio', 'cautiverio', 'nabucodonosor', 'deportados']),
    LexiconTopic('Éxodo', _hist, ['egipto', 'faraón', 'éxodo', 'mar rojo', 'desierto']),
    LexiconTopic('Pacto abrahámico', _hist, ['abraham', 'abram', 'patriarca', 'descendencia']),
    LexiconTopic('Monarquía davídica', _hist, ['david', 'salomón', 'rey', 'reino', 'monarquía']),
    LexiconTopic('Cartas paulinas', _hist, ['pablo', 'carta', 'epístola', 'apóstol']),
    LexiconTopic('Templo y sacerdocio', _hist, ['templo', 'sacerdote', 'sacrificio', 'altar', 'tabernáculo']),
    LexiconTopic('Ley mosaica', _hist, ['moisés', 'sinaí', 'ley de moisés', 'mandamientos']),
    LexiconTopic('Profetas', _hist, ['profeta', 'profecía', 'profetizó', 'isaías', 'jeremías']),
    LexiconTopic('Mundo grecorromano', _hist, ['griego', 'griegos', 'gentiles', 'filósofos', 'atenas', 'corinto']),
    LexiconTopic('Persecución', _hist, ['persecución', 'perseguido', 'cárcel', 'prisión', 'encarcelado']),

    // ── Vida Práctica ──
    LexiconTopic('Paciencia', _vida, ['paciencia', 'paciente', 'esperar', 'calma', 'longanimidad', 'tolerancia']),
    LexiconTopic('Dominio propio', _vida, [
      'dominio propio',
      'templanza',
      'autocontrol',
      'controlarme',
      'impulso',
      'contenerme',
    ]),
    LexiconTopic('Amor al prójimo', _vida, ['prójimo', 'amor', 'amar', 'servir', 'servicio', 'amaos']),
    LexiconTopic('Perdón', _vida, ['perdón', 'perdonar', 'perdoné', 'ofensa', 'rencor', 'resentimiento']),
    LexiconTopic('Humildad', _vida, ['humilde', 'humildad', 'orgullo', 'soberbia', 'altivez']),
    LexiconTopic('Generosidad', _vida, ['generoso', 'generosidad', 'dar', 'ofrenda', 'compartir', 'dinero']),
    LexiconTopic('Confianza en Dios', _vida, ['confiar', 'confianza', 'confío', 'descansar', 'entregar']),
    LexiconTopic('Obediencia', _vida, ['obedecer', 'obediencia', 'obedecí', 'cumplir', 'mandato']),
    LexiconTopic('Gratitud', _vida, ['gracias', 'gratitud', 'agradecido', 'agradecer', 'agradezco']),
    LexiconTopic('Oración', _vida, ['orar', 'oración', 'clamar', 'ruego', 'interceder']),
    LexiconTopic('Familia', _vida, ['hijos', 'hijo', 'esposa', 'esposo', 'familia', 'hogar', 'crianza', 'padres']),
    LexiconTopic('Trabajo', _vida, ['trabajo', 'jefe', 'compañero', 'compañeros', 'oficina', 'empleo']),
    LexiconTopic('Paz interior', _vida, ['paz', 'ansiedad', 'afán', 'preocupación', 'tranquilidad']),
    LexiconTopic('Gozo', _vida, ['gozo', 'alegría', 'regocijo', 'gozaos']),
    LexiconTopic('Mansedumbre', _vida, ['manso', 'mansedumbre', 'ira', 'enojo', 'grité', 'gritar']),

    // ── Estructura del Pensamiento ──
    LexiconTopic('Fruto del Espíritu', _pens, ['fruto del espíritu', 'fruto', 'frutos']),
    LexiconTopic('Carne y Espíritu', _pens, ['carne', 'deseos de la carne', 'andad en el espíritu']),
    LexiconTopic('Fe y obras', _pens, ['fe', 'obras', 'justificación', 'justificados']),
    LexiconTopic('Ley y gracia', _pens, ['bajo la ley', 'obras de la ley', 'libertad']),
    LexiconTopic('Esperanza escatológica', _pens, [
      'esperanza',
      'venida',
      'resurrección',
      'eternidad',
      'gloria venidera',
    ]),
    LexiconTopic('Sufrimiento con propósito', _pens, [
      'sufrimiento',
      'tribulación',
      'tribulaciones',
      'prueba',
      'padecer',
      'aflicción',
    ]),
    LexiconTopic('Identidad en Cristo', _pens, ['en cristo', 'nueva criatura', 'identidad', 'hechura suya']),
    LexiconTopic('Pecado y redención', _pens, ['pecado', 'pecador', 'redención', 'rescate', 'expiación']),
    LexiconTopic('Reino de Dios', _pens, ['reino de dios', 'reino de los cielos']),
  ];
}
