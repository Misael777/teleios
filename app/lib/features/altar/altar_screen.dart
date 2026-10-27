import 'package:flutter/material.dart';

import '../../shared/widgets/common_widgets.dart';

class AltarScreen extends StatelessWidget {
  const AltarScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScreen(
    title: 'Altar',
    icon: Icons.mic_none,
    sprint: 'Sprint 6',
    description: 'Oración por voz transcrita en el dispositivo, sin enviar audio a la nube.',
  );
}
