import 'package:flutter/material.dart';
import 'package:snappdf/presentation/screens/history/history_screen.dart';
import 'package:snappdf/presentation/screens/home/home_screen.dart';
import 'package:snappdf/presentation/screens/settings/settings_screen.dart';
import 'package:theme/theme.dart';

/// Root screen with the Home / History / Settings bottom tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _historyTab = 1;

  int _tab = 0;

  static const _items = [
    UiNavItem(Icons.home_outlined, 'Home', selectedIcon: Icons.home),
    UiNavItem(Icons.history, 'History', selectedIcon: Icons.history),
    UiNavItem(Icons.settings_outlined, 'Settings', selectedIcon: Icons.settings),
  ];

  void _select(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) {
    return UiShell(
      items: _items,
      index: _tab,
      onChanged: _select,
      pages: [
        HomeScreen(onSeeAll: () => _select(_historyTab)),
        const HistoryScreen(),
        const SettingsScreen(),
      ],
    );
  }
}
