import 'sorcery_card.dart';

/// The parts of a constructed deck.
enum DeckSection { avatar, spellbook, atlas, collection }

/// Where a card goes when it is added without saying where.
DeckSection defaultSection(SorceryCard card) => switch (card.type) {
  'Avatar' => DeckSection.avatar,
  'Site' => DeckSection.atlas,
  _ => DeckSection.spellbook,
};

/// A deck saved on the device. Cards are keyed by their stable card id
/// (the Kairos `codex_id`), so any printing fills a slot.
class Deck {
  Deck({required this.id, required this.name, Map<DeckSection, Map<String, int>>? cards, DateTime? updated})
    : cards = cards ?? {for (final s in DeckSection.values) s: {}},
      updated = updated ?? DateTime.now();

  final String id;
  String name;
  final Map<DeckSection, Map<String, int>> cards;
  DateTime updated;

  Map<String, int> operator [](DeckSection s) => cards[s]!;

  int count(DeckSection s) => this[s].values.fold(0, (a, b) => a + b);

  /// Copies of a card across every section.
  int copies(String cardId) => cards.values.fold(0, (a, m) => a + (m[cardId] ?? 0));

  void add(DeckSection s, String cardId, [int n = 1]) {
    final next = (this[s][cardId] ?? 0) + n;
    if (next <= 0) {
      this[s].remove(cardId);
    } else {
      this[s][cardId] = next;
    }
    updated = DateTime.now();
  }

  void move(String cardId, DeckSection from, DeckSection to) {
    final n = this[from].remove(cardId) ?? 0;
    if (n > 0) add(to, cardId, n);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updated': updated.toIso8601String(),
    for (final s in DeckSection.values) s.name: this[s],
  };

  factory Deck.fromJson(Map<String, dynamic> json) => Deck(
    id: json['id'] as String,
    name: json['name'] as String,
    updated: DateTime.tryParse(json['updated'] as String? ?? ''),
    cards: {for (final s in DeckSection.values) s: Map<String, int>.from((json[s.name] as Map?) ?? const {})},
  );
}
