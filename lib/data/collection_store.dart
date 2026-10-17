import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';
import '../models/sorcery_card.dart';
import 'card_repository.dart';

/// A named collection: how many copies of each printing the user owns.
class CardCollection {
  CardCollection({required this.id, required this.name, Map<String, int>? copies, DateTime? updated})
      : copies = copies ?? {},
        updated = updated ?? DateTime.now();

  final String id;
  String name;

  /// Last change, used to keep the newer copy when importing a backup.
  DateTime updated;

  /// Printing id → number of copies.
  final Map<String, int> copies;

  int get totalCopies => copies.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'updated': updated.toIso8601String(), 'copies': copies};

  factory CardCollection.fromJson(Map<String, dynamic> json) => CardCollection(
        id: json['id'] as String,
        name: json['name'] as String,
        copies: Map<String, int>.from(json['copies'] as Map),
        updated: DateTime.tryParse(json['updated'] as String? ?? ''),
      );
}

/// The user's collections, saved on the device.
class CollectionStore extends ChangeNotifier {
  CollectionStore._(this._prefs, this.collections, this._activeId);

  static const _key = 'collections';
  static const _activeKey = 'activeCollection';

  final SharedPreferences _prefs;
  final List<CardCollection> collections;
  String? _activeId;

  static Future<CollectionStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final list = raw == null
        ? <CardCollection>[]
        : (jsonDecode(raw) as List)
            .map((c) => CardCollection.fromJson(c as Map<String, dynamic>))
            .toList();
    return CollectionStore._(prefs, list, prefs.getString(_activeKey));
  }

  /// The collection that the card screen adds copies to.
  CardCollection? get active {
    for (final c in collections) {
      if (c.id == _activeId) return c;
    }
    return collections.isEmpty ? null : collections.first;
  }

  set active(CardCollection? collection) {
    _activeId = collection?.id;
    _save();
  }

  CardCollection create(String name) {
    final collection = CardCollection(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name);
    collections.add(collection);
    _activeId = collection.id;
    _save();
    return collection;
  }

  void rename(CardCollection collection, String name) {
    collection
      ..name = name
      ..updated = DateTime.now();
    _save();
  }

  void delete(CardCollection collection) {
    collections.remove(collection);
    if (_activeId == collection.id) _activeId = null;
    _save();
  }

  void setCopies(CardCollection collection, String printingId, int count) {
    if (count <= 0) {
      collection.copies.remove(printingId);
    } else {
      collection.copies[printingId] = count;
    }
    collection.updated = DateTime.now();
    _save();
  }

  /// Adds every card in [deck] (all sections, with its count) to
  /// [collection], in each card's main printing. Returns the copies added.
  int addDeck(CardCollection collection, Deck deck, CardDatabase db) {
    var added = 0;
    for (final section in deck.cards.values) {
      for (final MapEntry(key: cardId, value: n) in section.entries) {
        final card = db.byId[cardId];
        if (card == null || card.printings.isEmpty || n <= 0) continue;
        final id = mainPrinting(card).id;
        collection.copies[id] = (collection.copies[id] ?? 0) + n;
        added += n;
      }
    }
    collection.updated = DateTime.now();
    _save();
    return added;
  }

  /// Adds collections from a backup. One already here (same id) is replaced
  /// by the backup's copy only if that copy is newer. Returns how many
  /// collections were added and how many replaced.
  ({int added, int updated}) merge(List<CardCollection> incoming) {
    var added = 0, updated = 0;
    for (final collection in incoming) {
      final i = collections.indexWhere((c) => c.id == collection.id);
      if (i < 0) {
        collections.add(collection);
        added++;
      } else if (collection.updated.isAfter(collections[i].updated)) {
        collections[i] = collection;
        updated++;
      }
    }
    if (added + updated > 0) _save();
    return (added: added, updated: updated);
  }

  void _save() {
    _prefs.setString(_key, jsonEncode([for (final c in collections) c.toJson()]));
    final id = _activeId;
    id == null ? _prefs.remove(_activeKey) : _prefs.setString(_activeKey, id);
    notifyListeners();
  }
}

/// The printing whose picture the card list shows.
Printing mainPrinting(SorceryCard card) => card.printings.firstWhere(
  (p) => p.image != null && p.image?.normal == card.image?.normal,
  orElse: () => card.printings.first,
);

/// Makes the collections reachable from any screen, including pushed ones.
class CollectionScope extends InheritedNotifier<CollectionStore> {
  const CollectionScope({super.key, required CollectionStore store, required super.child}) : super(notifier: store);

  static CollectionStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CollectionScope>()!.notifier!;
}
