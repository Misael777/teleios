import 'package:flutter/material.dart';

import '../../shared/widgets/common_widgets.dart';

class BitacoraScreen extends StatelessWidget {
  const BitacoraScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScreen(
    title: 'Bitácora de Praxis',
    icon: Icons.edit_note,
    sprint: 'Sprint 5',
    description:
        'Registro A-B-C: circunstancia → emoción → filtro → acción y paz. '
        'El esquema de datos ya está listo.',
  );
}
