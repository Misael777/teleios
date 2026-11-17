import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/domain/entities/praxis_entry.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/private_image.dart';
import '../../domain/save_praxis.dart';

/// Fotos privadas del registro: existentes (cifradas) + nuevas (pendientes).
class AttachmentsField extends StatefulWidget {
  const AttachmentsField({
    super.key,
    required this.existing,
    required this.pending,
    required this.removedIds,
    required this.onChanged,
  });

  final List<Attachment> existing;
  final List<PendingImage> pending;
  final Set<String> removedIds;
  final void Function(List<PendingImage> pending, Set<String> removedIds) onChanged;

  @override
  State<AttachmentsField> createState() => _AttachmentsFieldState();
}

class _AttachmentsFieldState extends State<AttachmentsField> {
  bool _busy = false;

  int get _count => widget.existing.where((a) => !widget.removedIds.contains(a.id)).length + widget.pending.length;

  bool get _cameraAvailable =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _pick(ImageSource source) async {
    if (_count >= SavePraxis.maxImages) {
      showMessage(context, 'Máximo ${SavePraxis.maxImages} imágenes por registro.');
      return;
    }
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(source: source);
      if (file == null) return;
      final prepared = await prepareImage(await file.readAsBytes());
      if (prepared == null) {
        if (mounted) showMessage(context, 'No se pudo leer la imagen.');
        return;
      }
      widget.onChanged([...widget.pending, prepared], widget.removedIds);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = widget.existing.where((a) => !widget.removedIds.contains(a.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in visible)
              _Thumb(
                onTap: () => showPrivateImage(context, a.fileName),
                onRemove: () => widget.onChanged(widget.pending, {...widget.removedIds, a.id}),
                child: PrivateImage(fileName: a.fileName),
              ),
            for (final (i, p) in widget.pending.indexed)
              _Thumb(
                onRemove: () => widget.onChanged([...widget.pending]..removeAt(i), widget.removedIds),
                child: Image.memory(p.bytes, fit: BoxFit.cover),
              ),
          ],
        ),
        if (visible.isNotEmpty || widget.pending.isNotEmpty) const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _busy ? null : () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galería'),
            ),
            if (_cameraAvailable)
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _pick(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Cámara'),
              ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Se guardan cifradas en este dispositivo, sin ubicación ni datos de la cámara.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.child, required this.onRemove, this.onTap});

  final Widget child;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 84,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GestureDetector(onTap: onTap, child: child),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: IconButton.filledTonal(
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            tooltip: 'Quitar imagen',
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    ),
  );
}
