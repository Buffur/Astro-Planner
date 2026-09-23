import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/feature_scope.dart';

/// The bottom-navigation shell of ADR-015 (TASK 12.2): Tonight · Sessions ·
/// Library · Settings, one navigator per tab.
///
/// Back (ADR-015 §3): pops within the current tab first (go_router); at a
/// tab's root it returns to Tonight; at Tonight's root it leaves the app.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static List<NavigationDestination> get destinations => [
    const NavigationDestination(
      icon: Icon(Icons.nights_stay_outlined),
      selectedIcon: Icon(Icons.nights_stay),
      label: 'Tonight',
    ),
    if (FeatureScope.logbook)
      const NavigationDestination(
        icon: Icon(Icons.book_outlined),
        selectedIcon: Icon(Icons.book),
        label: 'Sessions',
      ),
    const NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Library',
    ),
    const NavigationDestination(
      icon: Icon(Icons.tune_outlined),
      selectedIcon: Icon(Icons.tune),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final onTonight = navigationShell.currentIndex == 0;
    return PopScope(
      canPop: onTonight,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(0);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: destinations,
          // Tapping the current tab again returns to its root.
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
        ),
      ),
    );
  }
}
