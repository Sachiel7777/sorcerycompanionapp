import 'package:flutter/material.dart';

import 'data/card_repository.dart';
import 'screens/card_list_screen.dart';

void main() => runApp(const SorceryApp());

class SorceryApp extends StatelessWidget {
  const SorceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF8C6A3F);
    return MaterialApp(
      title: 'Sorcery Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: FutureBuilder<CardDatabase>(
        future: CardDatabase.loadBundled(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Errore nel caricare le carte: ${snapshot.error}')));
          }
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return CardListScreen(db: snapshot.data!);
        },
      ),
    );
  }
}
