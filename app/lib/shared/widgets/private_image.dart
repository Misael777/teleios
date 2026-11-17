import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../domain/entities/praxis_entry.dart';
import '../providers.dart';

/// Reduce una foto a máx. 1600 px, corrige la orientación y **elimina los metadatos EXIF**
/// (ubicación GPS, modelo de teléfono…). Se ejecuta en otro isolate.
Future<PendingImage?> prepareImage(Uint8List original, {int maxSide = 1600, int quality = 82}) => Isolate.run(() {
  final decoded = img.decodeImage(original);
  if (decoded == null) return null;
  var image = img.bakeOrientation(decoded);
  if (image.width > maxSide || image.height > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide, interpolation: img.Interpolation.average)
        : img.copyResize(image, height: maxSide, interpolation: img.Interpolation.average);
  }
  image.exif = img.ExifData();
  final bytes = img.encodeJpg(image, quality: quality);
  return PendingImage(bytes: bytes, width: image.width, height: image.height);
});

final _privateImageProvider = FutureProvider.family<Uint8List?, String>(
  (ref, fileName) => ref.watch(attachmentStoreProvider).read(fileName),
);

/// Muestra una imagen privada descifrándola desde el almacén.
class PrivateImage extends ConsumerWidget {
  const PrivateImage({super.key, required this.fileName, this.fit = BoxFit.cover});

  final String fileName;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(_privateImageProvider(fileName));
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, _) => const Center(child: Icon(Icons.broken_image_outlined)),
      data: (bytes) => bytes == null
          ? const Center(child: Icon(Icons.broken_image_outlined))
          : Image.memory(bytes, fit: fit, gaplessPlayback: true),
    );
  }
}

/// Visor a pantalla completa con zoom.
void showPrivateImage(BuildContext context, String fileName) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: PrivateImage(fileName: fileName, fit: BoxFit.contain),
        ),
      ),
    ),
  ),
);
