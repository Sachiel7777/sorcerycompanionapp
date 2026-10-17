import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';

/// The user's decks, saved on the device.
class DeckStore extends ChangeNotifier {
  DeckStore._(this._prefs, this._decks);

  static const _key = 'decks';

  final SharedPreferences _prefs;
  final List<Deck> _decks;

  static Future<DeckStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final decks = raw == null
        ? <Deck>[]
        : (jsonDecode(raw) as List).map((d) => Deck.fromJson(d as Map<String, dynamic>)).toList();
    return DeckStore._(prefs, decks);
  }

  /// Most recently changed first.
  List<Deck> get decks => [..._decks]..sort((a, b) => b.updated.compareTo(a.updated));

  Deck create(String name) {
    final deck = Deck(id: DateTime.now().microsecondsSinceEpoch.toRadixString(36), name: name);
    _decks.add(deck);
    save();
    return deck;
  }

  void delete(Deck deck) {
    _decks.removeWhere((d) => d.id == deck.id);
    save();
  }

  /// Adds decks from a backup. A deck already here (same id) is replaced by
  /// the backup's copy only if that copy is newer. Returns how many decks
  /// were added and how many replaced.
  ({int added, int updated}) merge(List<Deck> incoming) {
    var added = 0, updated = 0;
    for (final deck in incoming) {
      final i = _decks.indexWhere((d) => d.id == deck.id);
      if (i < 0) {
        _decks.add(deck);
        added++;
      } else if (deck.updated.isAfter(_decks[i].updated)) {
        _decks[i] = deck;
        updated++;
      }
    }
    if (added + updated > 0) save();
    return (added: added, updated: updated);
  }

  /// Call after changing a deck in place.
  void save() {
    _prefs.setString(_key, jsonEncode([for (final d in _decks) d.toJson()]));
    notifyListeners();
  }
}
