import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/settings.dart';
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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: 'Carte'),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            selectedIcon: Icon(Icons.collections_bookmark),
            label: 'Set',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Partita',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
