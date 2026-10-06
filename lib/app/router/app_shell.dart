import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_NavDestination>[
    _NavDestination(
      label: 'Accueil',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _NavDestination(
      label: 'Explorer',
      icon: Icons.travel_explore_outlined,
      selectedIcon: Icons.travel_explore,
    ),
    _NavDestination(
      label: 'Portefeuille',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    _NavDestination(
      label: 'Simulateur',
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: outline)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            for (final destination in _destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
