import 'package:flutter/material.dart';

import 'data/card_repository.dart';
import 'data/settings.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  runApp(SorceryApp(settings: settings));
}

class SorceryApp extends StatelessWidget {
  const SorceryApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF8C6A3F);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'Sorcery Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: seed),
        darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
        themeMode: settings.themeMode,
        home: FutureBuilder<CardDatabase>(
          future: _cards,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(body: Center(child: Text('Errore nel caricare le carte: ${snapshot.error}')));
            }
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return HomeScreen(db: snapshot.data!, settings: settings);
          },
        ),
      ),
    );
  }
}

final Future<CardDatabase> _cards = CardDatabase.loadBundled();
