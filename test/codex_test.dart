import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorcery_companion/data/card_repository.dart';
import 'package:sorcery_companion/data/rules_content.dart';
import 'package:sorcery_companion/l10n/strings.dart';
import 'package:sorcery_companion/screens/codex_screen.dart';
import 'package:sorcery_companion/screens/rules_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('official card page addresses follow the verified pattern', () async {
    const base = 'https://sorcerytcg.com/cards/';
    expect(officialCardUrl('Chaoswish'), '${base}chaoswish');
    expect(officialCardUrl('Apprentice Wizard'), '${base}apprentice_wizard');
    expect(officialCardUrl("Mariner's Curse"), '${base}mariners_curse');
    expect(officialCardUrl('East-West Dragon'), '${base}east_west_dragon');
    expect(officialCardUrl('Brocéliande'), '${base}broceliande');
    expect(officialCardUrl('Fire Harpoons!'), '${base}fire_harpoons');
    expect(officialCardUrl("Wills-o'-the-Wisp"), '${base}wills_o_the_wisp');
    final db = await CardDatabase.loadBundled();
    for (final c in db.cards) {
      expect(officialCardUrl(c.name), matches(RegExp('^${RegExp.escape(base)}[a-z0-9]+(_[a-z0-9]+)*\$')), reason: c.name);
    }
  });

  test('every keyword in the card data has a glossary entry', () async {
    final db = await CardDatabase.loadBundled();
    final keywords = {for (final c in db.cards) ...c.keywords};
    expect(keywords, isNotEmpty);
    for (final k in keywords) {
      expect(codexEntry(k), isNotNull, reason: k);
    }
  });

  test('rules and glossary are written in both languages', () {
    for (final section in rulesSections) {
      for (final t in [section.title, ...section.points]) {
        expect(t.it, isNotEmpty);
        expect(t.en, isNotEmpty);
        expect(t.it, isNot(t.en));
      }
    }
    final names = codex.map((e) => e.name.toLowerCase()).toList();
    expect(names.toSet(), hasLength(names.length), reason: 'no duplicate entries');
    for (final e in codex) {
      expect(e.text.it, isNot(e.text.en), reason: e.name);
    }
  });

  Widget app(Widget home, String lang) => MaterialApp(
    locale: Locale(lang),
    supportedLocales: AppStrings.supportedLocales,
    localizationsDelegates: const [
      AppStrings.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );

  testWidgets('glossary search finds an entry and opens it', (tester) async {
    final db = await tester.runAsync(CardDatabase.loadBundled);
    await tester.pumpWidget(app(CodexScreen(db: db!), 'it'));
    await tester.enterText(find.byType(TextField), 'airborne');
    await tester.pump();
    expect(find.text('Airborne'), findsOneWidget);
    expect(find.text('Ward (protezione)'), findsNothing);
    await tester.tap(find.text('Airborne'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Carte con questa parola chiave'), findsOneWidget);
  });

  testWidgets('rules screen shows sections in English', (tester) async {
    await tester.pumpWidget(app(const RulesScreen(), 'en'));
    expect(find.text('Official rulebook (PDF)'), findsOneWidget);
    expect(find.text('1. THE GOAL'), findsOneWidget);
  });
}
