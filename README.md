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
- **Backup** (in Settings): export decks and settings to a JSON file and import them back, on this
  device or another one, with no account or server. A single deck can also be saved as a text file
  from its export dialog, and the deck import dialog can read a text file.
- **Rules and glossary** (from Settings): a rules summary and a glossary of keywords and game
  terms, in Italian and English, written for this app (`lib/data/rules_content.dart`), with a link
  to the official rulebook. Keywords on a card's page can be tapped to read what they mean.
- **Scan** (Android, button at the top of the card list): take a photo of a card, or pick one from
  the gallery, and the app reads its name and lists the matching cards. Text recognition (Google ML
  Kit) runs on the phone, offline. While adding cards to a deck, a scanned card goes into the deck.

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
