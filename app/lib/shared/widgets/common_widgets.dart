import 'package:flutter/material.dart';

import '../../core/errors/failure.dart';
import '../../core/theme/app_theme.dart';
import '../domain/entities/dimension.dart';
import '../domain/entities/topic.dart';

/// Chip de tópico coloreado por su dimensión, con estilo según su estado.
class DimensionChip extends StatelessWidget {
  const DimensionChip({
    super.key,
    required this.label,
    required this.dimensionId,
    this.status = TopicStatus.validado,
    this.onDeleted,
    this.onPressed,
    this.dense = false,
  });

  final String label;
  final String dimensionId;
  final TopicStatus status;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = context.dimensionColor(dimensionId);
    final dashed = status == TopicStatus.incubacion;
    final side = BorderSide(color: color, width: dashed ? 1 : 1.5, style: BorderStyle.solid);
    final avatar = dashed ? Icon(Icons.hourglass_top, size: 16, color: color) : null;
    final background = color.withValues(alpha: dashed ? 0.04 : 0.12);
    final labelStyle = TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500);
    final tooltip = '${Dimension.byId(dimensionId).name} · ${status.label}';

    // Sin acciones se usa Chip: un InputChip sin callbacks se pinta como deshabilitado.
    if (onDeleted == null && onPressed == null) {
      return Tooltip(
        message: tooltip,
        child: Chip(
          label: Text(label),
          labelStyle: labelStyle,
          avatar: avatar,
          visualDensity: dense ? VisualDensity.compact : null,
          materialTapTargetSize: dense ? MaterialTapTargetSize.shrinkWrap : null,
          backgroundColor: background,
          side: side,
        ),
      );
    }
    return InputChip(
      label: Text(label),
      labelStyle: labelStyle,
      avatar: avatar,
      visualDensity: dense ? VisualDensity.compact : null,
      materialTapTargetSize: dense ? MaterialTapTargetSize.shrinkWrap : null,
      backgroundColor: background,
      side: side,
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: 'Quitar',
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, this.subtitle, this.trailing, required this.child});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Slider 1-10 para intensidad, coherencia y paz (Sprint 5).
class ScoreSlider extends StatelessWidget {
  const ScoreSlider({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label: $value / 10', style: Theme.of(context).textTheme.labelLarge),
      Slider(
        value: value.toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        label: '$value',
        onChanged: (v) => onChanged(v.round()),
      ),
    ],
  );
}

/// Muestra un error de dominio o inesperado como SnackBar.
void showError(BuildContext context, Object error) {
  final message = error is Failure ? error.message : 'Ocurrió un error inesperado.';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Placeholder para módulos de sprints futuros.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.sprint,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String sprint;
  final String description;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: EmptyState(icon: icon, title: 'Llega en el $sprint', message: description),
  );
}
