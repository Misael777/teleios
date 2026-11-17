import 'package:flutter/material.dart';

import '../../../shared/domain/entities/praxis_entry.dart';

/// Insignia del filtro cognitivo (Bíblico / Cosmovisión / Impulso).
class FilterBadge extends StatelessWidget {
  const FilterBadge(this.filter, {super.key});

  final FilterType filter;

  static Color colorOf(BuildContext context, FilterType f) {
    final scheme = Theme.of(context).colorScheme;
    return switch (f) {
      FilterType.biblico => scheme.primary,
      FilterType.cosmovision => scheme.secondary,
      FilterType.impulso => scheme.error,
    };
  }

  static IconData iconOf(FilterType f) => switch (f) {
    FilterType.biblico => Icons.menu_book,
    FilterType.cosmovision => Icons.hourglass_top,
    FilterType.impulso => Icons.bolt,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(context, filter);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconOf(filter), size: 14, color: color),
          const SizedBox(width: 4),
          Text(filter.shortLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Barra compacta 1-10 (paz, coherencia, intensidad).
class ScoreBar extends StatelessWidget {
  const ScoreBar({super.key, required this.label, required this.value, this.invert = false});

  final String label;
  final int? value;

  /// true cuando un valor alto es "malo" (intensidad).
  final bool invert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = value;
    final good = v == null ? 0.5 : (invert ? 1 - (v - 1) / 9 : (v - 1) / 9);
    final color = Color.lerp(theme.colorScheme.error, const Color(0xFF6DBB8A), good)!;
    return Row(
      children: [
        SizedBox(width: 92, child: Text(label, style: theme.textTheme.labelMedium)),
        Expanded(
          child: LinearProgressIndicator(
            value: v == null ? 0 : v / 10,
            minHeight: 8,
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(v == null ? '—' : '$v/10', textAlign: TextAlign.end, style: theme.textTheme.labelMedium),
        ),
      ],
    );
  }
}
