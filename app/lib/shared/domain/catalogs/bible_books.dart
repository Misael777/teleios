import '../../../core/utils/text_normalizer.dart';

enum Testament { antiguo, nuevo }

enum BookGenre {
  ley('Ley (Pentateuco)'),
  historia('Historia'),
  poesia('Poesía y Sabiduría'),
  profetasMayores('Profetas mayores'),
  profetasMenores('Profetas menores'),
  evangelio('Evangelio'),
  epistolaPaulina('Epístola paulina'),
  epistolaGeneral('Epístola general'),
  apocaliptico('Apocalíptico');

  const BookGenre(this.label);
  final String label;
}

/// Metadatos de un libro. [author] y [periodId] son la atribución tradicional,
/// usados solo para pre-llenar el formulario cronológico (el usuario puede cambiarlos).
class BibleBook {
  const BibleBook(this.code, this.name, this.abbreviations, this.testament, this.genre, this.author, this.periodId);

  /// Código de 3 letras de la fuente (eBible VPL).
  final String code;
  final String name;
  final List<String> abbreviations;
  final Testament testament;
  final BookGenre genre;
  final String author;
  final String periodId;

  String get shortName => abbreviations.first;
}

abstract final class BibleBooks {
  static const _at = Testament.antiguo;
  static const _nt = Testament.nuevo;

  static const all = <BibleBook>[
    BibleBook('GEN', 'Génesis', ['Gn', 'Gen'], _at, BookGenre.ley, 'Moisés', 'patriarcal'),
    BibleBook('EXO', 'Éxodo', ['Ex', 'Exo'], _at, BookGenre.ley, 'Moisés', 'egipto_exodo'),
    BibleBook('LEV', 'Levítico', ['Lv', 'Lev'], _at, BookGenre.ley, 'Moisés', 'egipto_exodo'),
    BibleBook('NUM', 'Números', ['Nm', 'Num'], _at, BookGenre.ley, 'Moisés', 'egipto_exodo'),
    BibleBook('DEU', 'Deuteronomio', ['Dt', 'Deut'], _at, BookGenre.ley, 'Moisés', 'egipto_exodo'),
    BibleBook('JOS', 'Josué', ['Jos'], _at, BookGenre.historia, 'Josué', 'conquista_jueces'),
    BibleBook('JDG', 'Jueces', ['Jue', 'Jc'], _at, BookGenre.historia, 'Samuel (trad.)', 'conquista_jueces'),
    BibleBook('RUT', 'Rut', ['Rt', 'Rut'], _at, BookGenre.historia, 'Anónimo', 'conquista_jueces'),
    BibleBook('1SA', '1 Samuel', ['1 S', '1 Sam'], _at, BookGenre.historia, 'Samuel / profetas', 'reino_unido'),
    BibleBook('2SA', '2 Samuel', ['2 S', '2 Sam'], _at, BookGenre.historia, 'Profetas (Natán, Gad)', 'reino_unido'),
    BibleBook('1KI', '1 Reyes', ['1 R', '1 Re'], _at, BookGenre.historia, 'Jeremías (trad.)', 'reino_dividido'),
    BibleBook('2KI', '2 Reyes', ['2 R', '2 Re'], _at, BookGenre.historia, 'Jeremías (trad.)', 'reino_dividido'),
    BibleBook('1CH', '1 Crónicas', ['1 Cr', '1 Cro'], _at, BookGenre.historia, 'Esdras (trad.)', 'post_exilio'),
    BibleBook('2CH', '2 Crónicas', ['2 Cr', '2 Cro'], _at, BookGenre.historia, 'Esdras (trad.)', 'post_exilio'),
    BibleBook('EZR', 'Esdras', ['Esd'], _at, BookGenre.historia, 'Esdras', 'post_exilio'),
    BibleBook('NEH', 'Nehemías', ['Neh'], _at, BookGenre.historia, 'Nehemías', 'post_exilio'),
    BibleBook('EST', 'Ester', ['Est'], _at, BookGenre.historia, 'Anónimo', 'post_exilio'),
    BibleBook('JOB', 'Job', ['Job'], _at, BookGenre.poesia, 'Anónimo', 'patriarcal'),
    BibleBook('PSA', 'Salmos', ['Sal', 'Slm'], _at, BookGenre.poesia, 'David y otros', 'reino_unido'),
    BibleBook('PRO', 'Proverbios', ['Pr', 'Prov'], _at, BookGenre.poesia, 'Salomón y otros', 'reino_unido'),
    BibleBook('ECC', 'Eclesiastés', ['Ec', 'Ecl'], _at, BookGenre.poesia, 'Salomón (trad.)', 'reino_unido'),
    BibleBook('SOL', 'Cantares', ['Cnt', 'Cant'], _at, BookGenre.poesia, 'Salomón', 'reino_unido'),
    BibleBook('ISA', 'Isaías', ['Is', 'Isa'], _at, BookGenre.profetasMayores, 'Isaías', 'reino_dividido'),
    BibleBook('JER', 'Jeremías', ['Jr', 'Jer'], _at, BookGenre.profetasMayores, 'Jeremías', 'reino_dividido'),
    BibleBook('LAM', 'Lamentaciones', ['Lm', 'Lam'], _at, BookGenre.profetasMayores, 'Jeremías', 'exilio'),
    BibleBook('EZE', 'Ezequiel', ['Ez', 'Eze'], _at, BookGenre.profetasMayores, 'Ezequiel', 'exilio'),
    BibleBook('DAN', 'Daniel', ['Dn', 'Dan'], _at, BookGenre.profetasMayores, 'Daniel', 'exilio'),
    BibleBook('HOS', 'Oseas', ['Os'], _at, BookGenre.profetasMenores, 'Oseas', 'reino_dividido'),
    BibleBook('JOE', 'Joel', ['Jl'], _at, BookGenre.profetasMenores, 'Joel', 'reino_dividido'),
    BibleBook('AMO', 'Amós', ['Am'], _at, BookGenre.profetasMenores, 'Amós', 'reino_dividido'),
    BibleBook('OBA', 'Abdías', ['Abd'], _at, BookGenre.profetasMenores, 'Abdías', 'exilio'),
    BibleBook('JON', 'Jonás', ['Jon'], _at, BookGenre.profetasMenores, 'Jonás', 'reino_dividido'),
    BibleBook('MIC', 'Miqueas', ['Mi', 'Miq'], _at, BookGenre.profetasMenores, 'Miqueas', 'reino_dividido'),
    BibleBook('NAH', 'Nahúm', ['Nah'], _at, BookGenre.profetasMenores, 'Nahúm', 'reino_dividido'),
    BibleBook('HAB', 'Habacuc', ['Hab'], _at, BookGenre.profetasMenores, 'Habacuc', 'reino_dividido'),
    BibleBook('ZEP', 'Sofonías', ['Sof'], _at, BookGenre.profetasMenores, 'Sofonías', 'reino_dividido'),
    BibleBook('HAG', 'Hageo', ['Hag', 'Ag'], _at, BookGenre.profetasMenores, 'Hageo', 'post_exilio'),
    BibleBook('ZEC', 'Zacarías', ['Zac'], _at, BookGenre.profetasMenores, 'Zacarías', 'post_exilio'),
    BibleBook('MAL', 'Malaquías', ['Mal'], _at, BookGenre.profetasMenores, 'Malaquías', 'post_exilio'),
    BibleBook('MAT', 'Mateo', ['Mt', 'Mat'], _nt, BookGenre.evangelio, 'Mateo', 'vida_jesus'),
    BibleBook('MAR', 'Marcos', ['Mc', 'Mr', 'Mar'], _nt, BookGenre.evangelio, 'Marcos', 'vida_jesus'),
    BibleBook('LUK', 'Lucas', ['Lc', 'Luc'], _nt, BookGenre.evangelio, 'Lucas', 'vida_jesus'),
    BibleBook('JOH', 'Juan', ['Jn', 'Jua'], _nt, BookGenre.evangelio, 'Juan', 'vida_jesus'),
    BibleBook('ACT', 'Hechos', ['Hch', 'Hech'], _nt, BookGenre.historia, 'Lucas', 'iglesia_primitiva'),
    BibleBook('ROM', 'Romanos', ['Ro', 'Rom'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('1CO', '1 Corintios', ['1 Co', '1 Cor'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('2CO', '2 Corintios', ['2 Co', '2 Cor'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('GAL', 'Gálatas', ['Gá', 'Gal'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('EPH', 'Efesios', ['Ef', 'Efe'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('PHI', 'Filipenses', ['Fil', 'Flp'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('COL', 'Colosenses', ['Col'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook(
      '1TH',
      '1 Tesalonicenses',
      ['1 Ts', '1 Tes'],
      _nt,
      BookGenre.epistolaPaulina,
      'Pablo',
      'iglesia_primitiva',
    ),
    BibleBook(
      '2TH',
      '2 Tesalonicenses',
      ['2 Ts', '2 Tes'],
      _nt,
      BookGenre.epistolaPaulina,
      'Pablo',
      'iglesia_primitiva',
    ),
    BibleBook('1TI', '1 Timoteo', ['1 Ti', '1 Tim'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('2TI', '2 Timoteo', ['2 Ti', '2 Tim'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('TIT', 'Tito', ['Tit'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('PHM', 'Filemón', ['Flm'], _nt, BookGenre.epistolaPaulina, 'Pablo', 'iglesia_primitiva'),
    BibleBook('HEB', 'Hebreos', ['He', 'Heb'], _nt, BookGenre.epistolaGeneral, 'Anónimo', 'iglesia_primitiva'),
    BibleBook('JAM', 'Santiago', ['Stg', 'Sant'], _nt, BookGenre.epistolaGeneral, 'Santiago', 'iglesia_primitiva'),
    BibleBook('1PE', '1 Pedro', ['1 P', '1 Pe'], _nt, BookGenre.epistolaGeneral, 'Pedro', 'iglesia_primitiva'),
    BibleBook('2PE', '2 Pedro', ['2 P', '2 Pe'], _nt, BookGenre.epistolaGeneral, 'Pedro', 'iglesia_primitiva'),
    BibleBook('1JO', '1 Juan', ['1 Jn'], _nt, BookGenre.epistolaGeneral, 'Juan', 'iglesia_primitiva'),
    BibleBook('2JO', '2 Juan', ['2 Jn'], _nt, BookGenre.epistolaGeneral, 'Juan', 'iglesia_primitiva'),
    BibleBook('3JO', '3 Juan', ['3 Jn'], _nt, BookGenre.epistolaGeneral, 'Juan', 'iglesia_primitiva'),
    BibleBook('JUD', 'Judas', ['Jud'], _nt, BookGenre.epistolaGeneral, 'Judas', 'iglesia_primitiva'),
    BibleBook('REV', 'Apocalipsis', ['Ap', 'Apoc'], _nt, BookGenre.apocaliptico, 'Juan', 'iglesia_primitiva'),
  ];

  static final Map<String, BibleBook> _byCode = {for (final b in all) b.code: b};

  static final Map<String, BibleBook> _byKey = {
    for (final b in all) ...{_key(b.name): b, for (final a in b.abbreviations) _key(a): b},
  };

  static String _key(String s) => TextNormalizer.normalize(s).replaceAll(RegExp(r'[\s.]'), '');

  static BibleBook byCode(String code) =>
      _byCode[code] ?? (throw ArgumentError.value(code, 'code', 'Libro desconocido'));

  static int indexOf(String code) => all.indexWhere((b) => b.code == code);

  /// Busca por nombre completo, abreviatura o prefijo único ("gal", "1co", "filip").
  static BibleBook? find(String input) {
    final key = _key(input);
    if (key.isEmpty) return null;
    final exact = _byKey[key];
    if (exact != null) return exact;
    final matches = all.where((b) => _key(b.name).startsWith(key)).toList();
    return matches.length == 1 ? matches.single : null;
  }
}
