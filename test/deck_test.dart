import 'package:flutter_test/flutter_test.dart';
import 'package:sorcery_companion/data/card_repository.dart';
import 'package:sorcery_companion/data/deck_rules.dart';
import 'package:sorcery_companion/data/deck_text.dart';
import 'package:sorcery_companion/models/deck.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CardDatabase db;
  String id(String name) => db.cards.firstWhere((c) => c.name == name).id;

  setUpAll(() async => db = await CardDatabase.loadBundled());

  const ordinarySpells = [
    'Apprentice Wizard', 'Blood Ravens', 'Cloud Spirit', 'Dead of Night Demon', 'Highland Clansmen', //
    'Men of Leng', 'Midnight Rogue', 'Palliburrie Bats', 'Plumed Pegasus', 'Roaming Monster', //
    'Snow Leopard', 'Spectral Stalker', 'Blink', 'Disenchant', 'Fade',
  ];
  const ordinarySites = [
    'Dark Tower',
    'Gothic Tower',
    'Lone Tower',
    'Humble Village',
    'Rustic Village',
    'Spire',
    'Valley',
  ];

  /// 1 Avatar, 15 x 4 Ordinary spells, 7 x 4 Ordinary sites + 2 more sites.
  Deck legalDeck() {
    final deck = Deck(id: 't', name: 'Test');
    deck.add(DeckSection.avatar, id('Sorcerer'));
    for (final n in ordinarySpells) {
      deck.add(DeckSection.spellbook, id(n), 4);
    }
    for (final n in ordinarySites) {
      deck.add(DeckSection.atlas, id(n), 4);
    }
    deck.add(DeckSection.atlas, id('Brocéliande'));
    deck.add(DeckSection.atlas, id('Simple Village'));
    return deck;
  }

  test('a deck that follows the Constructed rules has no issues', () {
    final deck = legalDeck();
    expect(deck.count(DeckSection.spellbook), 60);
    expect(deck.count(DeckSection.atlas), 30);
    expect(checkDeck(deck, db), isEmpty);
    deck.add(DeckSection.atlas, id('Spire'), -1);
    expect(checkDeck(deck, db).single, isA<TooFew>());
  });

  test('rule checks report each problem', () {
    final deck = Deck(id: 't', name: 'Test');
    deck.add(DeckSection.spellbook, id('Apprentice Wizard'), 5);
    deck.add(DeckSection.atlas, id('Brocéliande'), 2);
    deck.add(DeckSection.spellbook, id('Spire'));
    for (final n in ordinarySpells.skip(1).take(11)) {
      deck.add(DeckSection.collection, id(n));
    }
    final issues = checkDeck(deck, db);
    expect(issues.whereType<AvatarCount>().single.count, 0);
    expect(issues.whereType<TooFew>(), hasLength(2));
    expect(issues.whereType<CollectionTooBig>().single.count, 11);
    expect(
      issues.whereType<TooManyCopies>().map((i) => i.card.name),
      containsAll(['Apprentice Wizard', 'Brocéliande']),
    );
    expect(issues.whereType<WrongSection>().single.card.name, 'Spire');
  });

  test('a list survives export and import', () {
    final deck = legalDeck()..add(DeckSection.collection, id('Lightning Bolt'), 2);
    final text = deckToText(deck, db);
    expect(text, startsWith('Avatar (1)\n1 Sorcerer\n\nSpellbook (60)\n'));
    expect(text, contains('\nCollection (2)\n2 Lightning Bolt'));
    final back = deckFromText(text, db, id: 'b', name: 'Back');
    expect(back.unknown, isEmpty);
    for (final s in DeckSection.values) {
      expect(back.deck[s], deck[s], reason: s.name);
    }
  });

  test('import accepts loose lists', () {
    final r = deckFromText(
      '''
// my deck
Sorcerer
4x apprentice wizard
2 Broceliande
3 Lightning Bolt (Beta)
Sideboard:
1 Disenchant
1 Not A Real Card
''',
      db,
      id: 'x',
      name: 'X',
    );
    expect(r.deck[DeckSection.avatar], {id('Sorcerer'): 1});
    expect(r.deck[DeckSection.spellbook], {id('Apprentice Wizard'): 4, id('Lightning Bolt'): 3});
    expect(r.deck[DeckSection.atlas], {id('Brocéliande'): 2});
    expect(r.deck[DeckSection.collection], {id('Disenchant'): 1});
    expect(r.unknown, ['1 Not A Real Card']);
  });

  test('stats count the curve and thresholds', () {
    final deck = legalDeck();
    expect(manaCurve(deck, db).fold(0, (a, b) => a + b), 60);
    expect(atlasThreshold(deck, db).values.fold(0, (a, b) => a + b), greaterThan(0));
  });
}
