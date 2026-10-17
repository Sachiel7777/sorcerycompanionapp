import 'package:flutter_test/flutter_test.dart';
import 'package:sorcery_companion/data/card_matcher.dart';
import 'package:sorcery_companion/data/card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late CardDatabase db;
  setUpAll(() async => db = await CardDatabase.loadBundled());

  String best(List<ScannedLine> lines) => matchCards(lines, db.cards).first.card.name;

  test('finds a card from its name among rules text', () {
    expect(
      best(const [
        ScannedLine('Apprentice Wizard', height: 40),
        ScannedLine('Minion - Mortal', height: 20),
        ScannedLine('Genesis -> Draw a spell.', height: 18),
      ]),
      'Apprentice Wizard',
    );
  });

  test('tolerates misread letters and accents', () {
    expect(best(const [ScannedLine('Appr3ntice Wlzard', height: 30)]), 'Apprentice Wizard');
    expect(best(const [ScannedLine('BROCELIANDE', height: 30)]), 'Brocéliande');
  });

  test('a name inside a longer line still counts', () {
    expect(best(const [ScannedLine('3 Lightning Bolt Magic', height: 30)]), 'Lightning Bolt');
  });

  test('the large title wins over a name mentioned in small text', () {
    expect(
      best(const [ScannedLine('Sorcerer', height: 12), ScannedLine('Lightning Bolt', height: 40)]),
      'Lightning Bolt',
    );
  });

  test('nothing readable gives no match', () {
    expect(matchCards(const [ScannedLine('##'), ScannedLine('qzxv qzxv qzxv qzxv')], db.cards), isEmpty);
  });
}
