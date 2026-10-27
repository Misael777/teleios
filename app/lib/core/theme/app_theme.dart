import 'package:flutter/material.dart';

import '../../shared/domain/entities/dimension.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF4B3F8F);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [DimensionColors.forBrightness(brightness)],
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      chipTheme: const ChipThemeData(showCheckmark: false),
    );
  }
}

/// Tokens de color de las 4 dimensiones, ajustados por tema.
@immutable
class DimensionColors extends ThemeExtension<DimensionColors> {
  const DimensionColors(this.colors);

  final Map<String, Color> colors;

  factory DimensionColors.forBrightness(Brightness brightness) {
    final base = {for (final d in Dimension.all) d.id: Color(int.parse('FF${d.colorHex.substring(1)}', radix: 16))};
    if (brightness == Brightness.light) return DimensionColors(base);
    return DimensionColors({for (final e in base.entries) e.key: Color.lerp(e.value, Colors.white, 0.3)!});
  }

  Color of(String dimensionId) => colors[dimensionId] ?? Colors.grey;

  @override
  DimensionColors copyWith({Map<String, Color>? colors}) => DimensionColors(colors ?? this.colors);

  @override
  DimensionColors lerp(DimensionColors? other, double t) {
    if (other == null) return this;
    return DimensionColors({for (final key in colors.keys) key: Color.lerp(colors[key], other.colors[key], t)!});
  }
}

extension DimensionColorsX on BuildContext {
  Color dimensionColor(String dimensionId) => Theme.of(this).extension<DimensionColors>()!.of(dimensionId);
}
