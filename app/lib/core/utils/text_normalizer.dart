/// Normalización y stemming ligero para español.
///
/// Se usa en el clasificador léxico y para comparar nombres de tópicos
/// ("Paciencia" == "paciencia" == "PACIENCIA").
abstract final class TextNormalizer {
  static const _diacritics = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ñ': 'n',
    'ç': 'c',
  };

  // Ordenados de más largo a más corto: se elimina el primero que coincida.
  static const _suffixes = [
    'amientos',
    'imientos',
    'amiento',
    'imiento',
    'aciones',
    'uciones',
    'ancias',
    'encias',
    'idades',
    'mente',
    'acion',
    'ucion',
    'ancia',
    'encia',
    'idad',
    'entes',
    'ente',
    'antes',
    'ante',
    'ando',
    'iendo',
    'ados',
    'adas',
    'idos',
    'idas',
    'ado',
    'ada',
    'ido',
    'ida',
    'ar',
    'er',
    'ir',
    'os',
    'as',
    'es',
    'o',
    'a',
    'e',
    's',
  ];

  static const _stopwords = {
    'a',
    'al',
    'ante',
    'con',
    'de',
    'del',
    'el',
    'en',
    'es',
    'esa',
    'ese',
    'eso',
    'esta',
    'este',
    'esto',
    'la',
    'las',
    'le',
    'les',
    'lo',
    'los',
    'me',
    'mi',
    'mis',
    'no',
    'nos',
    'o',
    'para',
    'pero',
    'por',
    'que',
    'se',
    'si',
    'sin',
    'su',
    'sus',
    'te',
    'tu',
    'un',
    'una',
    'uno',
    'y',
    'ya',
    'yo',
    'fue',
    'era',
    'muy',
    'mas',
    'como',
    'cuando',
    'hoy',
    'sobre',
    'entre',
    'porque',
  };

  /// Minúsculas y sin tildes.
  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacritics[char] ?? char);
    }
    return buffer.toString();
  }

  /// Palabras normalizadas (sin signos ni stopwords).
  static List<String> tokenize(String input) =>
      normalize(input).split(RegExp(r'[^a-z0-9]+')).where((t) => t.length > 1 && !_stopwords.contains(t)).toList();

  /// Raíz aproximada: quita el sufijo más largo dejando al menos 4 letras.
  static String stem(String token) {
    final word = normalize(token);
    for (final suffix in _suffixes) {
      if (word.endsWith(suffix) && word.length - suffix.length >= 4) {
        return word.substring(0, word.length - suffix.length);
      }
    }
    return word;
  }

  /// Clave canónica para comparar nombres de tópicos.
  static String key(String name) => normalize(name).trim().replaceAll(RegExp(r'\s+'), ' ');
}
