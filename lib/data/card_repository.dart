import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sorcery_card.dart';

class CardDatabase {
  const CardDatabase({required this.sets, required this.cards});

  final List<String> sets;
  final List<SorceryCard> cards;

  List<String> get types => _distinct(cards.map((c) => c.type));
  List<String> get rarities => _distinct(cards.map((c) => c.rarity).whereType<String>());

  static const elements = ['Air', 'Earth', 'Fire', 'Water'];

  static List<String> _distinct(Iterable<String> values) => values.toSet().toList()..sort();

  /// Loads the card list bundled with the app (assets/data/cards.json).
  static Future<CardDatabase> loadBundled() async {
    final raw = await rootBundle.loadString('assets/data/cards.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final cards = (json['cards'] as List)
        .map((c) => SorceryCard.fromJson(c as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return CardDatabase(sets: List<String>.from(json['sets'] as List), cards: cards);
  }
}
