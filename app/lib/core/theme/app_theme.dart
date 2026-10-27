import 'package:flutter/material.dart';

import '../../shared/domain/entities/dimension.dart';
import 'brand.dart';

/// Tema de TELEIOS: dorado sobre medianoche (oscuro) y tinta dorada sobre pergamino (claro).
abstract final class AppTheme {
  static ThemeData light() => _build(_lightScheme);

  static ThemeData dark() => _build(_darkScheme);

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Brand.gold,
    onPrimary: Color(0xFF1A1407),
    primaryContainer: Color(0xFF3A2F17),
    onPrimaryContainer: Brand.goldLight,
    secondary: Color(0xFFA9B6D3),
    onSecondary: Color(0xFF10141F),
    secondaryContainer: Color(0xFF26304A),
    onSecondaryContainer: Color(0xFFDCE3F5),
    tertiary: Brand.goldLight,
    onTertiary: Color(0xFF231A06),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    surface: Brand.midnight,
    onSurface: Brand.cream,
    onSurfaceVariant: Color(0xFFBDB6A6),
    surfaceContainerLowest: Brand.midnightLowest,
    surfaceContainerLow: Brand.midnightLow,
    surfaceContainer: Brand.midnightRaised,
    surfaceContainerHigh: Brand.midnightHigh,
    surfaceContainerHighest: Brand.midnightHighest,
    outline: Color(0xFF5A6378),
    outlineVariant: Color(0xFF2A3247),
    inverseSurface: Brand.cream,
    onInverseSurface: Brand.ink,
    inversePrimary: Brand.goldDeep,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Brand.goldInk,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFF3E3B8),
    onPrimaryContainer: Color(0xFF2A1F06),
    secondary: Color(0xFF3E4A66),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDCE3F5),
    onSecondaryContainer: Color(0xFF121A2E),
    tertiary: Brand.goldDeep,
    onTertiary: Colors.white,
    error: Color(0xFFB3261E),
    onError: Colors.white,
    surface: Brand.parchment,
    onSurface: Brand.ink,
    onSurfaceVariant: Color(0xFF5A5446),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: Color(0xFFF5F0E3),
    surfaceContainer: Color(0xFFEFE9DA),
    surfaceContainerHigh: Color(0xFFE9E2D1),
    surfaceContainerHighest: Color(0xFFE3DBC8),
    outline: Color(0xFF8F8775),
    outlineVariant: Color(0xFFDCD3C0),
    inverseSurface: Color(0xFF2B2A26),
    onInverseSurface: Brand.cream,
    inversePrimary: Brand.goldLight,
    shadow: Colors.black,
    scrim: Colors.black,
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: Brand.fontUi);
    final text = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
    final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [DimensionColors.forBrightness(scheme.brightness), ScriptureStyles.of(scheme, text)],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: rounded,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: rounded,
          side: BorderSide(color: scheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 1,
        focusElevation: 2,
        hoverElevation: 2,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}

/// Tokens de color de las 4 dimensiones: tonos joya que conviven con el dorado.
@immutable
class DimensionColors extends ThemeExtension<DimensionColors> {
  const DimensionColors(this.colors);

  final Map<String, Color> colors;

  static const _light = {
    Dimension.caracterDios: Color(0xFF5B45A8),
    Dimension.contextoHistorico: Color(0xFF9A5636),
    Dimension.vidaPractica: Color(0xFF2F7D4E),
    Dimension.estructuraPensamiento: Color(0xFF2B64B5),
  };

  static const _dark = {
    Dimension.caracterDios: Color(0xFF9D89E0),
    Dimension.contextoHistorico: Color(0xFFD9946B),
    Dimension.vidaPractica: Color(0xFF72C192),
    Dimension.estructuraPensamiento: Color(0xFF79AAEB),
  };

  factory DimensionColors.forBrightness(Brightness brightness) =>
      DimensionColors(brightness == Brightness.dark ? _dark : _light);

  Color of(String dimensionId) => colors[dimensionId] ?? Colors.grey;

  @override
  DimensionColors copyWith({Map<String, Color>? colors}) => DimensionColors(colors ?? this.colors);

  @override
  DimensionColors lerp(DimensionColors? other, double t) {
    if (other == null) return this;
    return DimensionColors({for (final key in colors.keys) key: Color.lerp(colors[key], other.colors[key], t)!});
  }
}

/// Estilos de lectura: Escritura en serif (Crimson Pro) y griego en GFS Didot.
@immutable
class ScriptureStyles extends ThemeExtension<ScriptureStyles> {
  const ScriptureStyles({required this.body, required this.verseNumber, required this.greek});

  final TextStyle body;
  final TextStyle verseNumber;
  final TextStyle greek;

  factory ScriptureStyles.of(ColorScheme scheme, TextTheme text) => ScriptureStyles(
    body: TextStyle(fontFamily: Brand.fontScripture, fontSize: 19, height: 1.55, color: scheme.onSurface),
    verseNumber: TextStyle(
      fontFamily: Brand.fontUi,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: scheme.primary,
      fontFeatures: const [FontFeature.superscripts()],
    ),
    greek: TextStyle(fontFamily: Brand.fontGreek, fontSize: 17, height: 1.5, color: scheme.primary),
  );

  @override
  ScriptureStyles copyWith({TextStyle? body, TextStyle? verseNumber, TextStyle? greek}) => ScriptureStyles(
    body: body ?? this.body,
    verseNumber: verseNumber ?? this.verseNumber,
    greek: greek ?? this.greek,
  );

  @override
  ScriptureStyles lerp(ScriptureStyles? other, double t) {
    if (other == null) return this;
    return ScriptureStyles(
      body: TextStyle.lerp(body, other.body, t)!,
      verseNumber: TextStyle.lerp(verseNumber, other.verseNumber, t)!,
      greek: TextStyle.lerp(greek, other.greek, t)!,
    );
  }
}

/// Acceso a los tokens; si el tema no es el de TELEIOS (p. ej. en un test o diálogo
/// aislado) se derivan del tema actual en lugar de fallar.
extension ThemeTokensX on BuildContext {
  Color dimensionColor(String dimensionId) {
    final theme = Theme.of(this);
    return (theme.extension<DimensionColors>() ?? DimensionColors.forBrightness(theme.brightness)).of(dimensionId);
  }

  ScriptureStyles get scripture {
    final theme = Theme.of(this);
    return theme.extension<ScriptureStyles>() ?? ScriptureStyles.of(theme.colorScheme, theme.textTheme);
  }
}
