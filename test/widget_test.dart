import 'package:flutter_test/flutter_test.dart';
import 'package:sorcery_companion/data/card_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled card list loads', () async {
    final db = await CardDatabase.loadBundled();
    expect(db.cards.length, greaterThan(1000));
    expect(db.sets, contains('Gothic'));
    expect(db.cards.where((c) => c.name == 'Apprentice Wizard'), hasLength(1));
  });
}
