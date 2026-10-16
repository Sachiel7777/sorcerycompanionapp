import '../models/deck.dart';
import '../models/sorcery_card.dart';
import 'card_repository.dart';

/// Constructed format (sorcerytcg.com/constructed): one Avatar, a Spellbook
/// of at least 60 cards, an Atlas of at least 30 Sites, copies limited by
/// rarity. The Collection (sideboard) holds up to 10 cards.
const minSpellbook = 60;
const minAtlas = 30;
const maxCollection = 10;

const copyLimits = {'Ordinary': 4, 'Exceptional': 3, 'Elite': 2, 'Unique': 1};

/// One thing that keeps a deck from being legal. The UI turns it into words.
sealed class DeckIssue {
  const DeckIssue();
}

class AvatarCount extends DeckIssue {
  const AvatarCount(this.count);
  final int count;
}

class TooFew extends DeckIssue {
  const TooFew(this.section, this.count, this.min);
  final DeckSection section;
  final int count;
  final int min;
}

class CollectionTooBig extends DeckIssue {
  const CollectionTooBig(this.count);
  final int count;
}

class TooManyCopies extends DeckIssue {
  const TooManyCopies(this.card, this.count, this.limit);
  final SorceryCard card;
  final int count;
  final int limit;
}

class WrongSection extends DeckIssue {
  const WrongSection(this.card, this.section);
  final SorceryCard card;
  final DeckSection section;
}

List<DeckIssue> checkDeck(Deck deck, CardDatabase db) {
  final issues = <DeckIssue>[];
  final avatars = deck.count(DeckSection.avatar);
  if (avatars != 1) issues.add(AvatarCount(avatars));
  final spells = deck.count(DeckSection.spellbook);
  if (spells < minSpellbook) issues.add(TooFew(DeckSection.spellbook, spells, minSpellbook));
  final sites = deck.count(DeckSection.atlas);
  if (sites < minAtlas) issues.add(TooFew(DeckSection.atlas, sites, minAtlas));
  final extra = deck.count(DeckSection.collection);
  if (extra > maxCollection) issues.add(CollectionTooBig(extra));

  for (final s in [DeckSection.avatar, DeckSection.spellbook, DeckSection.atlas]) {
    for (final id in deck[s].keys) {
      final card = db.byId[id];
      if (card != null && defaultSection(card) != s) issues.add(WrongSection(card, s));
    }
  }

  final ids = {for (final m in deck.cards.values) ...m.keys};
  for (final id in ids) {
    final card = db.byId[id];
    final limit = copyLimits[card?.rarity];
    if (card == null || limit == null) continue;
    final n = deck.copies(id);
    if (n > limit) issues.add(TooManyCopies(card, n, limit));
  }
  return issues;
}

/// Cards per mana cost in the Spellbook; the last bucket is 7 or more.
List<int> manaCurve(Deck deck, CardDatabase db) {
  final curve = List.filled(8, 0);
  deck[DeckSection.spellbook].forEach((id, n) {
    final cost = db.byId[id]?.cost;
    if (cost != null) curve[cost.clamp(0, 7)] += n;
  });
  return curve;
}

/// Threshold the Atlas provides, per element (Air, Earth, Fire, Water).
Map<String, int> atlasThreshold(Deck deck, CardDatabase db) {
  final total = {for (final e in CardDatabase.elements) e: 0};
  deck[DeckSection.atlas].forEach((id, n) {
    final card = db.byId[id];
    if (card == null) return;
    for (final e in CardDatabase.elements) {
      total[e] = total[e]! + (card.thresholds[e.toLowerCase()] ?? 0) * n;
    }
  });
  return total;
}

/// Spellbook cards that need each element.
Map<String, int> spellbookElements(Deck deck, CardDatabase db) {
  final total = {for (final e in CardDatabase.elements) e: 0};
  deck[DeckSection.spellbook].forEach((id, n) {
    for (final e in db.byId[id]?.elements ?? const <String>[]) {
      if (total.containsKey(e)) total[e] = total[e]! + n;
    }
  });
  return total;
}
