import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Every text the app shows, in Italian and English.
/// Card names and rules text stay as published (English only).
class AppStrings {
  const AppStrings._(this.english);

  final bool english;

  static const supportedLocales = [Locale('it'), Locale('en')];
  static const delegate = _AppStringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings) ?? const AppStrings._(false);

  String _t(String it, String en) => english ? en : it;

  // Navigation
  String get navCards => _t('Carte', 'Cards');
  String get navSets => _t('Set', 'Sets');
  String get navPlay => _t('Partita', 'Play');
  String get navSettings => _t('Impostazioni', 'Settings');

  // Card list
  String get sort => _t('Ordina', 'Sort');
  String get sortName => _t('Nome', 'Name');
  String get sortCostAsc => _t('Costo crescente', 'Cost, low to high');
  String get sortCostDesc => _t('Costo decrescente', 'Cost, high to low');
  String get searchHint => _t('Cerca per nome o testo', 'Search by name or text');
  String get filters => _t('Filtri', 'Filters');
  String cardCount(int n) => english ? (n == 1 ? '1 card' : '$n cards') : (n == 1 ? '1 carta' : '$n carte');
  String get noCards => _t('Nessuna carta trovata', 'No cards found');
  String get atlas => _t('Atlas (Siti)', 'Atlas (Sites)');
  String get filterSet => _t('Espansione', 'Set');
  String get filterType => _t('Tipo', 'Type');
  String get filterElement => _t('Elemento', 'Element');
  String get filterRarity => _t('Rarità', 'Rarity');
  String get clearFilters => _t('Azzera filtri', 'Clear filters');
  String loadError(Object e) => _t('Errore nel caricare le carte: $e', 'Could not load the cards: $e');

  String type(String t) => english ? t : const {'Magic': 'Magia', 'Artifact': 'Artefatto', 'Site': 'Sito'}[t] ?? t;

  /// [e] is an element name as in the card data: Air, Earth, Fire, Water.
  String element(String e) =>
      english ? e : const {'Air': 'Aria', 'Earth': 'Terra', 'Fire': 'Fuoco', 'Water': 'Acqua'}[e] ?? e;

  // Card detail
  String cost(int n) => _t('Costo $n', 'Cost $n');
  String attack(int n) => _t('Attacco $n', 'Attack $n');
  String defense(int n) => _t('Difesa $n', 'Defence $n');
  String lifeStat(int n) => _t('Vita $n', 'Life $n');
  String printings(int n) => _t('Stampe ($n)', 'Printings ($n)');
  String artist(String a) => _t('Illustrazione: $a', 'Art: $a');
  String get cardCredits => _t(
    'Dati e immagini © Erik\'s Curiosa, tramite Kairos Archive (kairosarchive.net).',
    'Data and images © Erik\'s Curiosa, via Kairos Archive (kairosarchive.net).',
  );

  // Sets
  String get setsTitle => _t('Set', 'Sets');
  String get promo => _t('promozionali', 'promotional');
  String released(DateTime d) =>
      english ? 'released ${_monthsEn[d.month - 1]} ${d.year}' : 'uscito a ${_monthsIt[d.month - 1]} ${d.year}';

  // Play
  String get newGameQuestion => _t('Nuova partita?', 'New game?');
  String newGameText(int life) => _t(
    'Vita a $life, mana e soglie a zero per entrambi.',
    'Life back to $life, mana and threshold to zero for both players.',
  );
  String get cancel => _t('Annulla', 'Cancel');
  String get restart => _t('Ricomincia', 'Restart');
  String get newGame => _t('Nuova partita', 'New game');
  String player(int n) => _t('Giocatore $n', 'Player $n');
  String get life => _t('Vita', 'Life');
  String get deathsDoor => "Death's Door";
  String get loseLife => _t('Togli vita', 'Lose life');
  String get gainLife => _t('Aggiungi vita', 'Gain life');
  String get mana => 'Mana';
  String threshold(String element) => _t('Soglia $element', '$element threshold');

  // Settings
  String get settingsTitle => _t('Impostazioni', 'Settings');
  String get language => _t('Lingua', 'Language');
  String get languageAuto => _t('Automatica', 'Automatic');
  String get appearance => _t('Aspetto', 'Appearance');
  String get themeAuto => 'Auto';
  String get themeLight => _t('Chiaro', 'Light');
  String get themeDark => _t('Scuro', 'Dark');
  String get game => _t('Partita', 'Game');
  String get startingLife => _t('Vita iniziale', 'Starting life');
  String get startingLifeHint => _t('Vale dalla prossima partita', 'Applies from the next game');
  String get lessLife => _t('Meno vita', 'Less life');
  String get moreLife => _t('Più vita', 'More life');
  String get keepScreenOn => _t('Schermo sempre acceso', 'Keep screen on');
  String get keepScreenOnHint => _t('Durante la partita lo schermo non si spegne', 'The screen stays on during a game');
  String get images => _t('Immagini', 'Images');
  String get offline => _t('Uso offline', 'Offline use');
  String get offlineHint => _t('Scarica tutte le immagini delle carte', 'Download every card image');
  String get about => _t('Informazioni', 'About');
  String get cardArchive => _t('Archivio carte', 'Card archive');
  String archiveSummary(int cards, int sets) => _t('$cards carte in $sets set', '$cards cards in $sets sets');
  String get credits => _t('Crediti', 'Credits');
  String get creditsText => _t(
    'Nomi, testi e immagini delle carte sono © Erik\'s Curiosa. '
        'Dati e immagini da Kairos Archive (kairosarchive.net). '
        'App non ufficiale, ispirata a sorcery-companion.com.',
    'Card names, text and images are © Erik\'s Curiosa. '
        'Data and images from Kairos Archive (kairosarchive.net). '
        'Unofficial app, inspired by sorcery-companion.com.',
  );
  String get licenses => _t('Licenze del software', 'Software licences');

  // Offline images
  String get offlineIntro => _t(
    'L\'elenco delle carte è già nell\'app. Scarica anche le immagini per '
        'sfogliarle senza connessione (circa 2200 file, conviene usare il Wi-Fi).',
    'The card list is already in the app. Download the images too to browse '
        'without a connection (about 2200 files, Wi-Fi recommended).',
  );
  String get offlineDone =>
      _t('Fatto: tutte le immagini sono sul dispositivo.', 'Done: every image is on this device.');
  String offlineFailed(int n) => _t(
    'Completato, ma $n immagini non sono state scaricate. Riprova più tardi.',
    'Finished, but $n images could not be downloaded. Try again later.',
  );
  String get offlineCleared => _t('Immagini cancellate dal dispositivo.', 'Images removed from this device.');
  String offlineProgress(int done, int total) => _t('$done di $total immagini', '$done of $total images');
  String get stop => _t('Interrompi', 'Stop');
  String get downloadAll => _t('Scarica tutte le immagini', 'Download all images');
  String get clearImages => _t('Cancella immagini scaricate', 'Delete downloaded images');

  static const _monthsIt = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];
  static const _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppStrings> load(Locale locale) => SynchronousFuture(AppStrings._(locale.languageCode != 'it'));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}

extension AppStringsContext on BuildContext {
  AppStrings get s => AppStrings.of(this);
}
