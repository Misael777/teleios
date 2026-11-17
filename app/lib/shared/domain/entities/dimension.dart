/// Las 4 dimensiones fijas de análisis. Sembradas en el primer arranque; no editables.
class Dimension {
  const Dimension({
    required this.id,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.sortOrder,
    required this.shortName,
  });

  final String id;
  final String name;
  final String description;
  final String colorHex;
  final int sortOrder;

  /// Nombre corto para gráficos estrechos.
  final String shortName;

  static const caracterDios = 'caracter_dios';
  static const contextoHistorico = 'contexto_historico';
  static const vidaPractica = 'vida_practica';
  static const estructuraPensamiento = 'estructura_pensamiento';

  static const all = <Dimension>[
    Dimension(
      id: caracterDios,
      name: 'Carácter de Dios',
      shortName: 'Carácter de Dios',
      description: 'Atributos de Dios revelados en el texto.',
      colorHex: '#5B45A8',
      sortOrder: 0,
    ),
    Dimension(
      id: contextoHistorico,
      name: 'Contexto Histórico',
      shortName: 'Contexto',
      description: 'Época, cultura, imperio y circunstancias del texto.',
      colorHex: '#9A5636',
      sortOrder: 1,
    ),
    Dimension(
      id: vidaPractica,
      name: 'Vida Práctica',
      shortName: 'Vida Práctica',
      description: 'Aplicación concreta a mis acciones y relaciones.',
      colorHex: '#2F7D4E',
      sortOrder: 2,
    ),
    Dimension(
      id: estructuraPensamiento,
      name: 'Estructura del Pensamiento',
      shortName: 'Pensamiento',
      description: 'Argumento del texto, conceptos teológicos y conexiones.',
      colorHex: '#2B64B5',
      sortOrder: 3,
    ),
  ];

  static Dimension byId(String id) => all.firstWhere((d) => d.id == id);
}
