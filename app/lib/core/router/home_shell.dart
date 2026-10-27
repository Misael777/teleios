import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/teleios_logo.dart';

/// Navegación principal: barra inferior en móvil, riel lateral en pantallas anchas.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    (icon: Icons.menu_book_outlined, selected: Icons.menu_book, label: 'Estudio'),
    (icon: Icons.edit_note_outlined, selected: Icons.edit_note, label: 'Bitácora'),
    (icon: Icons.mic_none_outlined, selected: Icons.mic, label: 'Altar'),
    (icon: Icons.hub_outlined, selected: Icons.hub, label: 'Ejes'),
  ];

  void _go(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              labelType: NavigationRailLabelType.all,
              leading: const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: TeleiosMark(size: 44)),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: Text(d.label)),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _go,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selected), label: d.label),
        ],
      ),
    );
  }
}
