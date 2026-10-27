import 'package:flutter/material.dart';

import '../../shared/widgets/common_widgets.dart';

class EjesScreen extends StatelessWidget {
  const EjesScreen({super.key});

  @override
  Widget build(BuildContext context) => const ComingSoonScreen(
    title: 'Ejes',
    icon: Icons.hub_outlined,
    sprint: 'Sprint 7',
    description: 'Dashboards de correlación estudio ↔ praxis y grafo de personalidad (Sprint 8).',
  );
}
