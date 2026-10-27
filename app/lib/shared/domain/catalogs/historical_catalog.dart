/// Catálogos fijos del formulario cronológico y la línea de tiempo.
///
/// Fechas aproximadas según la cronología conservadora tradicional (p. ej. datación
/// temprana del Éxodo). Son orientativas; el usuario puede registrar su propio año.
library;

class CatalogItem {
  const CatalogItem(this.id, this.name);

  final String id;
  final String name;
}

class HistoricalPeriod extends CatalogItem {
  const HistoricalPeriod(super.id, super.name, this.startYear, this.endYear);

  /// Años negativos = a.C.
  final int startYear;
  final int endYear;

  int get midYear => (startYear + endYear) ~/ 2;
}

class Milestone {
  const Milestone(this.title, this.year, this.periodId, [this.reference]);

  final String title;
  final int year;
  final String periodId;

  /// Referencia codificada (`PassageRef.encode`) cuando aplica.
  final String? reference;
}

abstract final class HistoricalCatalog {
  static const periods = <HistoricalPeriod>[
    HistoricalPeriod('patriarcal', 'Patriarcas', -2100, -1800),
    HistoricalPeriod('egipto_exodo', 'Egipto y Éxodo', -1800, -1406),
    HistoricalPeriod('conquista_jueces', 'Conquista y Jueces', -1406, -1050),
    HistoricalPeriod('reino_unido', 'Reino unido', -1050, -931),
    HistoricalPeriod('reino_dividido', 'Reino dividido', -931, -586),
    HistoricalPeriod('exilio', 'Exilio babilónico', -586, -538),
    HistoricalPeriod('post_exilio', 'Restauración (persa)', -538, -400),
    HistoricalPeriod('intertestamentario', 'Período intertestamentario', -400, -5),
    HistoricalPeriod('vida_jesus', 'Vida de Jesús', -5, 30),
    HistoricalPeriod('iglesia_primitiva', 'Iglesia primitiva', 30, 100),
  ];

  static const empires = <CatalogItem>[
    CatalogItem('egipto', 'Egipto'),
    CatalogItem('hitita', 'Hitita'),
    CatalogItem('filisteo', 'Filisteos'),
    CatalogItem('asiria', 'Asiria'),
    CatalogItem('babilonia', 'Babilonia'),
    CatalogItem('persia', 'Medo-Persa'),
    CatalogItem('grecia', 'Grecia (Alejandro)'),
    CatalogItem('ptolomeo', 'Ptolemaico'),
    CatalogItem('seleucida', 'Seléucida'),
    CatalogItem('asmoneo', 'Asmoneo'),
    CatalogItem('roma', 'Roma'),
    CatalogItem('ninguno', 'Israel independiente'),
  ];

  static const regions = <CatalogItem>[
    CatalogItem('mesopotamia', 'Mesopotamia'),
    CatalogItem('canaan', 'Canaán / Israel'),
    CatalogItem('egipto', 'Egipto'),
    CatalogItem('sinai', 'Sinaí / desierto'),
    CatalogItem('juda', 'Judá / Judea'),
    CatalogItem('samaria', 'Samaria'),
    CatalogItem('galilea', 'Galilea'),
    CatalogItem('babilonia', 'Babilonia'),
    CatalogItem('persia', 'Persia'),
    CatalogItem('siria', 'Siria / Antioquía'),
    CatalogItem('asia_menor', 'Asia Menor'),
    CatalogItem('grecia', 'Macedonia / Acaya'),
    CatalogItem('roma', 'Roma / Italia'),
    CatalogItem('islas', 'Chipre / Creta / Patmos'),
  ];

  static const milestones = <Milestone>[
    Milestone('Llamado de Abraham', -2091, 'patriarcal', 'GEN.12'),
    Milestone('José en Egipto', -1898, 'patriarcal', 'GEN.37'),
    Milestone('Éxodo', -1446, 'egipto_exodo', 'EXO.12'),
    Milestone('Ley en el Sinaí', -1445, 'egipto_exodo', 'EXO.20'),
    Milestone('Entrada a Canaán', -1406, 'conquista_jueces', 'JOS.3'),
    Milestone('Saúl rey', -1050, 'reino_unido', '1SA.10'),
    Milestone('David rey', -1010, 'reino_unido', '2SA.5'),
    Milestone('Templo de Salomón', -966, 'reino_unido', '1KI.6'),
    Milestone('División del reino', -931, 'reino_dividido', '1KI.12'),
    Milestone('Elías', -860, 'reino_dividido', '1KI.17'),
    Milestone('Caída de Samaria', -722, 'reino_dividido', '2KI.17'),
    Milestone('Reforma de Josías', -622, 'reino_dividido', '2KI.22'),
    Milestone('Caída de Jerusalén', -586, 'exilio', '2KI.25'),
    Milestone('Decreto de Ciro', -538, 'post_exilio', 'EZR.1'),
    Milestone('Segundo templo', -516, 'post_exilio', 'EZR.6'),
    Milestone('Muros de Nehemías', -445, 'post_exilio', 'NEH.6'),
    Milestone('Alejandro Magno', -332, 'intertestamentario'),
    Milestone('Revuelta macabea', -167, 'intertestamentario'),
    Milestone('Pompeyo toma Jerusalén', -63, 'intertestamentario'),
    Milestone('Nacimiento de Jesús', -5, 'vida_jesus', 'LUK.2'),
    Milestone('Crucifixión y resurrección', 30, 'vida_jesus', 'JOH.19'),
    Milestone('Pentecostés', 30, 'iglesia_primitiva', 'ACT.2'),
    Milestone('Conversión de Pablo', 34, 'iglesia_primitiva', 'ACT.9'),
    Milestone('Concilio de Jerusalén', 49, 'iglesia_primitiva', 'ACT.15'),
    Milestone('Destrucción del templo', 70, 'iglesia_primitiva'),
    Milestone('Apocalipsis', 95, 'iglesia_primitiva', 'REV.1'),
  ];

  static HistoricalPeriod? period(String? id) => id == null ? null : periods.where((p) => p.id == id).firstOrNull;

  static CatalogItem? empire(String? id) => id == null ? null : empires.where((e) => e.id == id).firstOrNull;

  static CatalogItem? region(String? id) => id == null ? null : regions.where((r) => r.id == id).firstOrNull;
}
