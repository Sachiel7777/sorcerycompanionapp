import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sorcery_companion/data/backup.dart';
import 'package:sorcery_companion/data/deck_store.dart';
import 'package:sorcery_companion/data/settings.dart';
import 'package:sorcery_companion/data/text_files.dart';
import 'package:sorcery_companion/models/deck.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a backup survives the trip through a file', () {
    final deck = Deck(id: 'a', name: 'Fuoco', updated: DateTime(2026, 10, 1))
      ..add(DeckSection.avatar, 'C000001')
      ..add(DeckSection.spellbook, 'C000002', 3);
    final text = Backup(
      decks: [deck],
      settings: {'themeMode': 'dark', 'startingLife': 25},
      created: DateTime(2026, 10, 17),
    ).toJson();
    final back = Backup.fromJson(text);
    expect(back.decks.single.name, 'Fuoco');
    expect(back.decks.single[DeckSection.spellbook], {'C000002': 3});
    expect(back.settings, {'themeMode': 'dark', 'startingLife': 25});
    expect(back.fileName, 'sorcery-companion-2026-10-17.json');
  });

  test('other files are refused', () {
    expect(() => Backup.fromJson('hello'), throwsFormatException);
    expect(() => Backup.fromJson('{"decks": []}'), throwsFormatException);
    expect(() => Backup.fromJson('{"app": "sorcery-companion", "version": 99}'), throwsFormatException);
  });

  test('importing adds new decks and keeps the newer copy of the same deck', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await DeckStore.load();
    final mine = store.create('Mio');
    final older = Deck(id: mine.id, name: 'Vecchio', updated: mine.updated.subtract(const Duration(days: 1)));
    final newer = Deck(id: 'other', name: 'Nuovo');
    expect(store.merge([older, newer]), (added: 1, updated: 0));
    expect(store.decks.map((d) => d.name), containsAll(['Mio', 'Nuovo']));
    final edited = Deck(id: mine.id, name: 'Modificato', updated: mine.updated.add(const Duration(days: 1)));
    expect(store.merge([edited]), (added: 0, updated: 1));
    expect(store.decks.any((d) => d.name == 'Modificato'), isTrue);
  });

  test('settings are saved and restored, ignoring bad values', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark', 'startingLife': 30});
    final settings = await AppSettings.load();
    expect(settings.toBackup(), {'themeMode': 'dark', 'startingLife': 30});
    settings.restore({'themeMode': 'purple', 'startingLife': 40, 'secret': 'x'});
    expect(settings.toBackup(), {'themeMode': 'dark', 'startingLife': 40});
  });

  test('file names are safe', () {
    expect(safeFileName('Fuoco: v2/finale?', 'txt'), 'Fuoco v2finale.txt');
    expect(safeFileName('  ', 'txt'), 'deck.txt');
  });
}
