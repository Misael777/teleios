import 'package:flutter/material.dart';

import '../../domain/guided_reflection.dart';

/// Color e ícono de cada sección de la reflexión: identifica de qué sección salió un versículo
/// vinculado, igual en el detalle del devocional y en los hilos de la línea de tiempo.
abstract final class SectionStyle {
  static const _light = {
    'exegesis': Color(0xFF1F7A8C),
    'hermeneutica': Color(0xFF7B4FB0),
    'teologia': Color(0xFFA87B1F),
    'homiletica': Color(0xFFC0504D),
    'aplicacion': Color(0xFF3C8D4F),
  };

  static const _dark = {
    'exegesis': Color(0xFF5BC0D0),
    'hermeneutica': Color(0xFFB693E8),
    'teologia': Color(0xFFE0BF6E),
    'homiletica': Color(0xFFEB8C84),
    'aplicacion': Color(0xFF7FCB8E),
  };

  static const _icons = {
    'exegesis': Icons.search,
    'hermeneutica': Icons.translate,
    'teologia': Icons.auto_awesome_outlined,
    'homiletica': Icons.campaign_outlined,
    'aplicacion': Icons.directions_walk,
  };

  /// `sectionId == null`: notas libres.
  static Color color(BuildContext context, String? sectionId) {
    final theme = Theme.of(context);
    final palette = theme.brightness == Brightness.dark ? _dark : _light;
    return palette[sectionId] ?? theme.colorScheme.outline;
  }

  static IconData icon(String? sectionId) => _icons[sectionId] ?? Icons.notes;

  static String name(String? sectionId) =>
      GuidedReflection.sections.where((s) => s.id == sectionId).firstOrNull?.name ?? 'Notas';

  /// Secciones (más "Notas") en el orden de la guía.
  static const ids = <String?>['exegesis', 'hermeneutica', 'teologia', 'homiletica', 'aplicacion', null];
}
