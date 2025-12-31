import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DashboardWrapper({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(label: 'Home', icon: Icon(Icons.home)),
          NavigationDestination(label: 'Settings', icon: Icon(Icons.settings)),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
