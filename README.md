# Sorcery Companion (app)

An app for Android (and later Linux, Windows and macOS) inspired by
[sorcery-companion.com](https://www.sorcery-companion.com/). It is written in Flutter, so one
codebase builds the app for every platform.

## What it does now

- Lists all 1100 cards of Sorcery: Contested Realm in a grid with their images.
- Search by name, rules text, subtypes and keywords.
- Filters by set, type, element and rarity; sort by name or cost.
- Card details: stats, text and every printing (tap a printing to see its image).
- Images already seen stay cached on the device.
- **Sets**: every expansion with its card count and release date; tap one to open its cards.
- **Decks**: decks saved on the device (Avatar, Spellbook, Atlas, Collection), with Constructed
  rules checks, mana curve and thresholds; import and export as a text list
  ("4 Apprentice Wizard", one card per line).
- **Play**: a two-player tracker (life, mana and the four elemental thresholds), with the
  opponent's half upside down and the screen kept on.
- **Settings**: language (Italian, English or the device's), light/dark theme, starting life,
  keep screen on, "Offline use" to download every image at once, credits.
- **Rules and glossary** (from Settings): a rules summary and a glossary of keywords and game
  terms, in Italian and English, written for this app (`lib/data/rules_content.dart`), with a link
  to the official rulebook. Keywords on a card's page can be tapped to read what they mean.

## Where the data comes from

- Cards come from the official API (`api.sorcerytcg.com`), which asks not to be used as a live
  backend but to download the data and host it yourself.
- We use the [Kairos Archive](https://github.com/sadkinglabs/sorcery-registry) export
  (`export/registry.json`), which republishes the same data with stable IDs and hosts the images
  on `api.kairosarchive.net` (hotlinking allowed, crediting Erik's Curiosa).
- `tool/build_cards.py` trims the export down to `assets/data/cards.json`, bundled in the app.

Card names, texts and images are © Erik's Curiosa. Card texts stay in English, the only language
they are published in. The title font is Cinzel (SIL Open Font License,
`assets/fonts/Cinzel-OFL.txt`).

App texts live in `lib/l10n/strings.dart`.

## Updating the cards

```sh
curl -L -o registry.json https://raw.githubusercontent.com/sadkinglabs/sorcery-registry/main/export/registry.json
python3 tool/build_cards.py registry.json
```

## Building

```sh
flutter pub get
flutter run              # on the connected device
flutter build apk        # Android
flutter build linux      # / windows / macos / web
```

## Downloading the APK

On every change to `main`, GitHub Actions builds the APK: open the **Actions** tab, pick the
latest **Build** run and download `sorcery-companion-apk` at the bottom of the page.

## Next steps

1. Update the card list automatically when a new archive version comes out.
2. Card scanner with the camera (as on the website).
