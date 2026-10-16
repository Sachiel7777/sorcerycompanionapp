import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/sorcery_card.dart';

/// An expansion (or the promo cards), as listed on the Sets page.
class CardSet {
  const CardSet({required this.name, required this.released, required this.isPromo});

  final String name;
  final DateTime released;
  final bool isPromo;

  factory CardSet.fromJson(Map<String, dynamic> json) => CardSet(
    name: json['name'] as String,
    released: DateTime.parse(json['released'] as String),
    isPromo: json['kind'] == 'promo',
  );
}

class CardDatabase {
  const CardDatabase({required this.setInfo, required this.cards});

  final List<CardSet> setInfo;
  final List<SorceryCard> cards;

  List<String> get sets => [for (final s in setInfo) s.name];

  List<SorceryCard> cardsInSet(String set) => cards.where((c) => c.sets.contains(set)).toList();

  List<String> get types => _distinct(cards.map((c) => c.type));
  List<String> get rarities => _distinct(cards.map((c) => c.rarity).whereType<String>());

  static const elements = ['Air', 'Earth', 'Fire', 'Water'];

  static List<String> _distinct(Iterable<String> values) => values.toSet().toList()..sort();

  /// Loads the card list bundled with the app (assets/data/cards.json).
  static Future<CardDatabase> loadBundled() async {
    final raw = await rootBundle.loadString('assets/data/cards.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final cards = (json['cards'] as List).map((c) => SorceryCard.fromJson(c as Map<String, dynamic>)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final sets = (json['sets'] as List).map((s) => CardSet.fromJson(s as Map<String, dynamic>)).toList();
    return CardDatabase(setInfo: sets, cards: cards);
  }
}
