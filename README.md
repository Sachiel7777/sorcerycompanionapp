# Sorcery Companion (app)

An app for Android (and later Linux, Windows and macOS) inspired by
[sorcery-companion.com](https://www.sorcery-companion.com/). It is written in Flutter, so one
codebase builds the app for every platform.

## Download

Tap the icon to download the APK of a release and install it on Android (you may have to allow
installing apps from your browser). The list is refreshed automatically on every new release.

<!-- releases:start -->
| | Release | Date | Download |
|---|---|---|---|
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.49/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 49)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.49) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.49/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.47/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 47)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.47) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.47/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.45/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 45)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.45) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.45/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.43/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 43)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.43) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.43/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.41/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 41)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.41) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.41/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.38/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 38)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.38) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.38/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.36/sorcery-companion.apk) | [**Sorcery Companion 1.0.0 (build 36)**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/v1.0.0-build.36) | 2026-10-18 | [sorcery-companion.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/v1.0.0-build.36/sorcery-companion.apk) |
| [<img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="40" alt="APK">](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/Sorcery-Companion-appv0.5/SorceryCompanionapp0.5.apk) | [**Sorcery Companion App 0.5**](https://github.com/Sachiel7777/sorcerycompanionapp/releases/tag/Sorcery-Companion-appv0.5) | 2026-10-17 | [SorceryCompanionapp0.5.apk](https://github.com/Sachiel7777/sorcerycompanionapp/releases/download/Sorcery-Companion-appv0.5/SorceryCompanionapp0.5.apk) |
<!-- releases:end -->

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
- **Collections** (button at the top of the card list): create as many as you like. On a card page
  the + and − buttons next to each printing record the copies you own, and "Add to collection" in
  a deck's menu puts all of its cards into a collection. Collections are saved on the device.
- **Market prices**: the card page links to TCGplayer and eBay. The app shows no prices of its
  own, because TCGplayer's terms don't allow reusing its price data.
- **Play**: a two-player tracker (life, mana and the four elemental thresholds), with the
  opponent's half upside down and the screen kept on.
- **Settings**: language (Italian, English or the device's), light/dark theme, starting life,
  keep screen on, "Offline use" to download every image at once, credits.
- **Backup** (in Settings): export decks, collections and settings to a JSON file and import them back, on this
  device or another one, with no account or server. A single deck can also be saved as a text file
  from its export dialog, and the deck import dialog can read a text file.
- **Rules and glossary** (from Settings): a rules summary and a glossary of keywords and game
  terms, in Italian and English, written for this app (`lib/data/rules_content.dart`), with a link
  to the official rulebook. Keywords on a card's page can be tapped to read what they mean.
- **Scan** (Android, button at the top of the card list): take a photo of a card, or pick one from
  the gallery, and the app reads its name and lists the matching cards. Text recognition
  ([Tesseract](https://github.com/tesseract-ocr/tesseract), open source) runs on the phone,
  offline. While adding cards to a deck, a scanned card goes into the deck.

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

## About this app / Informazioni sull'app

### English

- **Made with AI.** This app was created with AI (Claude Code). I have no coding experience, so
  every suggestion, tip or correction is very welcome: please open an issue or a pull request.
- **No telemetry, no data collection.** The app has no analytics, crash reporting or advertising,
  and it collects no data of any kind.
- **Permissions.** It only needs access to the internet (to download card images) and, optionally,
  the camera (only when you open the card scanner; the gallery option works without it). It does
  not need access to your storage: the card data lives inside the app's own private space.
  Downloading images contacts the image server (`api.kairosarchive.net`), which, like any web
  server, can see your IP address; the app itself sends no other data anywhere.
- **Open source.** The code is open and available here, under the license below.

### Italiano

- **Creata con l'IA.** Questa app è stata creata con l'intelligenza artificiale (Claude Code).
  Non ho esperienza di programmazione, quindi ogni suggerimento, consiglio o correzione è ben
  accetto: apri pure una issue o una pull request.
- **Nessuna telemetria, nessuna raccolta di dati.** L'app non contiene strumenti di analisi,
  segnalazione degli errori o pubblicità e non raccoglie dati di alcun tipo.
- **Permessi.** Ha bisogno solo dell'accesso a Internet (per scaricare le immagini delle carte)
  e, in modo facoltativo, della fotocamera (solo quando apri lo scanner delle carte; la scelta
  dalla galleria funziona anche senza). Non richiede l'accesso all'archiviazione: i dati delle
  carte restano nello spazio interno e privato dell'app.
  Il download delle immagini contatta il server delle immagini (`api.kairosarchive.net`), che,
  come ogni server web, può vedere il tuo indirizzo IP; l'app di per sé non invia altri dati.
- **Codice aperto.** Il codice è aperto e disponibile qui, con la licenza indicata sotto.

## License

The app's code is free software under the [GNU General Public License v3.0](LICENSE) or, at your
option, any later version. This covers the code only, not the card names, texts and images
(see above), which stay © Erik's Curiosa. The card scanner bundles Tesseract OCR and its English
model, both Apache License 2.0 (`assets/licenses/tesseract-apache-2.0.txt`).

### Copyright and takedown requests

If you believe this software infringes any copyright or violates any law, please contact the author.
Upon verification, the infringing material will be promptly removed.

## Updating the cards

A scheduled workflow (`.github/workflows/update-cards.yml`, Mondays 06:17 UTC) checks the
registry for a new release tag, rebuilds the list and opens a pull request if it changed;
if the Build workflow passes on that branch, the PR is merged and a release is published.
The release currently bundled is recorded in `tool/registry-version.txt`. To do it by hand:

```sh
TAG=$(cat tool/registry-version.txt)   # or a newer vX.Y.Z tag
curl -L -o registry.json https://raw.githubusercontent.com/sadkinglabs/sorcery-registry/$TAG/export/registry.json
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

Every change to `main` is built by GitHub Actions and published as a release; the APKs are listed
in the **Download** section at the top of this page and in the **Releases** tab. The same APK is also
attached to each **Build** run in the **Actions** tab (`sorcery-companion-apk`).
