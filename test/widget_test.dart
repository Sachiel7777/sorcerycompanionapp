import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorcery_companion/data/card_repository.dart';
import 'package:sorcery_companion/data/collection_store.dart';
import 'package:sorcery_companion/models/deck.dart';
import 'package:sorcery_companion/l10n/strings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled card list loads', () async {
    final db = await CardDatabase.loadBundled();
    expect(db.cards.length, greaterThan(1000));
    expect(db.sets, contains('Gothic'));
    expect(db.cards.where((c) => c.name == 'Apprentice Wizard'), hasLength(1));
  });

  test('sets carry release dates and card counts', () async {
    final db = await CardDatabase.loadBundled();
    final alpha = db.setInfo.firstWhere((s) => s.name == 'Alpha');
    expect(alpha.released.year, 2023);
    expect(alpha.isPromo, isFalse);
    expect(db.setInfo.firstWhere((s) => s.name == 'Promo').isPromo, isTrue);
    expect(db.cardsInSet('Alpha').length, greaterThan(400));
  });

  test('texts come in Italian and English', () async {
    final it = await AppStrings.delegate.load(const Locale('it'));
    final en = await AppStrings.delegate.load(const Locale('en'));
    expect(it.navCards, 'Carte');
    expect(en.navCards, 'Cards');
    expect(it.element('Fire'), 'Fuoco');
    expect(en.element('Fire'), 'Fire');
    expect(en.cardCount(1), '1 card');
    expect(it.released(DateTime(2023, 6, 22)), 'uscito a giugno 2023');
  });

  test('collections are saved and loaded back', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await CollectionStore.load();
    expect(store.active, isNull);
    final c = store.create('Fire deck');
    store.setCopies(c, 'P000001', 3);
    store.setCopies(c, 'P000002', 1);
    store.setCopies(c, 'P000002', 0);

    final reloaded = await CollectionStore.load();
    expect(reloaded.collections, hasLength(1));
    expect(reloaded.active?.name, 'Fire deck');
    expect(reloaded.active?.copies, {'P000001': 3});
  });

  test('a deck goes into a collection in its main printings', () async {
    SharedPreferences.setMockInitialValues({});
    final db = await CardDatabase.loadBundled();
    final store = await CollectionStore.load();
    final c = store.create('Everything');
    final wizard = db.cards.firstWhere((card) => card.name == 'Apprentice Wizard');
    final main = mainPrinting(wizard);
    store.setCopies(c, main.id, 1);

    final deck = Deck(id: 'd', name: 'Test')
      ..add(DeckSection.spellbook, wizard.id, 3)
      ..add(DeckSection.collection, wizard.id);
    expect(store.addDeck(c, deck, db), 4);
    expect(c.copies[main.id], 5);
    expect(db.cardByPrinting[main.id], same(wizard));
  });
}
