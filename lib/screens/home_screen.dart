import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/settings.dart';
import '../l10n/strings.dart';
import 'card_list_screen.dart';
import 'play_screen.dart';
import 'sets_screen.dart';
import 'settings_screen.dart';

/// The main sections of the app, switched from the bar at the bottom.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.db, required this.settings});

  final CardDatabase db;
  final AppSettings settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CardListScreen(db: widget.db),
          SetsScreen(db: widget.db),
          PlayScreen(settings: widget.settings, visible: _index == 2),
          SettingsScreen(db: widget.db, settings: widget.settings),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.style_outlined),
            selectedIcon: const Icon(Icons.style),
            label: s.navCards,
          ),
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark_outlined),
            selectedIcon: const Icon(Icons.collections_bookmark),
            label: s.navSets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite),
            label: s.navPlay,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: s.navSettings,
          ),
        ],
      ),
    );
  }
}
