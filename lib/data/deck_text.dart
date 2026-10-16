import '../models/deck.dart';
import 'card_repository.dart';

/// Decks as plain text, one "count name" line per card under a heading per
/// section, the shape deck sites such as Curiosa.io use for lists:
///
///     Avatar (1)
///     1 Sorcerer
///
///     Spellbook (60)
///     4 Apprentice Wizard
///     ...
String deckToText(Deck deck, CardDatabase db) {
  const headings = {
    DeckSection.avatar: 'Avatar',
    DeckSection.spellbook: 'Spellbook',
    DeckSection.atlas: 'Atlas',
    DeckSection.collection: 'Collection',
  };
  final out = StringBuffer();
  for (final s in DeckSection.values) {
    final entries = deck[s].entries.where((e) => db.byId.containsKey(e.key)).toList()
      ..sort((a, b) => db.byId[a.key]!.name.compareTo(db.byId[b.key]!.name));
    if (entries.isEmpty) continue;
    if (out.isNotEmpty) out.writeln();
    out.writeln('${headings[s]} (${deck.count(s)})');
    for (final e in entries) {
      out.writeln('${e.value} ${db.byId[e.key]!.name}');
    }
  }
  return out.toString().trimRight();
}

class DeckImport {
  DeckImport(this.deck, this.unknown);

  final Deck deck;

  /// Lines that named no known card.
  final List<String> unknown;
}

final _countLine = RegExp(r'^(\d+)\s*[xX×]?\s+(.+)$');
final _heading = RegExp(
  r'^(avatar|spellbook|atlas|collection|sideboard|maybeboard|sites?|spells?)\b',
  caseSensitive: false,
);

/// Reads a deck list. Lines may be "4 Name", "4x Name" or just "Name";
/// headings (Avatar, Spellbook, Atlas, Collection or Sideboard, with or
/// without a count) pick the section, and cards under no heading go where
/// their type belongs. Names match ignoring case, accents and punctuation.
DeckImport deckFromText(String text, CardDatabase db, {required String id, required String name}) {
  final byName = {for (final c in db.cards) _key(c.name): c};
  final deck = Deck(id: id, name: name);
  final unknown = <String>[];
  DeckSection? section;

  for (final raw in text.split(RegExp(r'\r?\n'))) {
    var line = raw.trim();
    if (line.isEmpty || line.startsWith('#') || line.startsWith('//')) continue;
    final heading = _heading.firstMatch(line);
    if (heading != null && !_countLine.hasMatch(line) && byName[_key(line)] == null) {
      section = switch (heading.group(1)!.toLowerCase()) {
        'avatar' => DeckSection.avatar,
        'atlas' || 'site' || 'sites' => DeckSection.atlas,
        'collection' || 'sideboard' || 'maybeboard' => DeckSection.collection,
        _ => DeckSection.spellbook,
      };
      continue;
    }
    var count = 1;
    final m = _countLine.firstMatch(line);
    if (m != null) {
      count = int.parse(m.group(1)!);
      line = m.group(2)!;
    }
    // Drop set or printing notes some sites add, e.g. "Name (Beta)" or "Name [Foil]".
    final card = byName[_key(line)] ?? byName[_key(line.replaceAll(RegExp(r'\s*[\(\[].*$'), ''))];
    if (card == null) {
      unknown.add(raw.trim());
      continue;
    }
    // A heading only overrides the card's own place for the Collection.
    final target = section == DeckSection.collection ? DeckSection.collection : defaultSection(card);
    deck.add(target, card.id, count);
  }
  return DeckImport(deck, unknown);
}

String _key(String name) => _fold(name.toLowerCase()).replaceAll(RegExp(r'[^a-z0-9]'), '');

String _fold(String s) {
  const from = 'àáâäãåèéêëìíîïòóôöõùúûüñç’‘';
  const to = 'aaaaaaeeeeiiiiooooouuuunc\'\'';
  final b = StringBuffer();
  for (final ch in s.split('')) {
    final i = from.indexOf(ch);
    b.write(i < 0 ? ch : to[i]);
  }
  return b.toString();
}
