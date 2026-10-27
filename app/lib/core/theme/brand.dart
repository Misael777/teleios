import 'package:flutter/material.dart';

/// Tokens de marca de TELEIOS, derivados del logo (assets/brand/teleios-logo-vertical.svg).
abstract final class Brand {
  // Dorado del logo (degradado claro → medio → profundo).
  static const goldLight = Color(0xFFF0D48A);
  static const gold = Color(0xFFC9A961);
  static const goldDeep = Color(0xFF8C6B2E);

  /// Dorado legible sobre pergamino (contraste AA para texto).
  static const goldInk = Color(0xFF7A5C22);

  // Fondo nocturno ("los cielos") y superficies elevadas.
  static const midnight = Color(0xFF0E1320);
  static const midnightLowest = Color(0xFF0A0E18);
  static const midnightLow = Color(0xFF121827);
  static const midnightRaised = Color(0xFF161C2C);
  static const midnightHigh = Color(0xFF1C2335);
  static const midnightHighest = Color(0xFF232B3F);

  // Texto crema del logo y pergamino para el modo claro.
  static const cream = Color(0xFFF5EFE0);
  static const parchment = Color(0xFFFAF6EC);
  static const ink = Color(0xFF1B1A17);

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
  );

  // Familias tipográficas (empaquetadas en assets/fonts).
  static const fontUi = 'Inter';
  static const fontScripture = 'CrimsonPro';
  static const fontGreek = 'GFSDidot';

  static const mottoGreek = 'Ἔσεσθε οὖν ὑμεῖς τέλειοι\nὡς ὁ πατὴρ ὑμῶν ὁ οὐράνιος τέλειός ἐστιν';
  static const mottoSpanish = '«Sed, pues, vosotros perfectos, como vuestro Padre que está en los cielos es perfecto»';
  static const mottoReference = 'ΚΑΤΑ ΜΑΤΘΑΙΟΝ 5:48  ·  MATEO 5:48';
}
