import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../data/deck_rules.dart';
import '../models/deck.dart';

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
  String get navDecks => _t('Mazzi', 'Decks');

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

  // Decks
  String get decksTitle => _t('Mazzi', 'Decks');
  String get noDecks =>
      _t('Ancora nessun mazzo. Creane uno o importa una lista.', 'No decks yet. Create one or import a list.');
  String get newDeck => _t('Nuovo mazzo', 'New deck');
  String get importDeck => _t('Importa lista', 'Import list');
  String get deckName => _t('Nome del mazzo', 'Deck name');
  String get untitledDeck => _t('Mazzo senza nome', 'Untitled deck');
  String get create => _t('Crea', 'Create');
  String get save => _t('Salva', 'Save');
  String get rename => _t('Rinomina', 'Rename');
  String get delete => _t('Elimina', 'Delete');
  String deleteDeckQuestion(String name) => _t('Eliminare "$name"?', 'Delete "$name"?');
  String get deleteDeckText =>
      _t('Il mazzo verrà cancellato dal dispositivo.', 'The deck will be removed from this device.');
  String get exportDeck => _t('Esporta come testo', 'Export as text');
  String get copy => _t('Copia', 'Copy');
  String get close => _t('Chiudi', 'Close');
  String get copied => _t('Lista copiata negli appunti', 'List copied to the clipboard');
  String get importHint => _t(
    'Incolla la lista del mazzo, una carta per riga (per esempio "4 Apprentice Wizard"). '
        'Le intestazioni Avatar, Spellbook, Atlas e Collection sono facoltative.',
    'Paste the deck list, one card per line (for example "4 Apprentice Wizard"). '
        'Avatar, Spellbook, Atlas and Collection headings are optional.',
  );
  String get paste => _t('Incolla', 'Paste');
  String get importAction => _t('Importa', 'Import');
  String importUnknown(int n) => _t(
    n == 1 ? 'Una riga non corrisponde a nessuna carta:' : '$n righe non corrispondono a nessuna carta:',
    n == 1 ? 'One line matched no card:' : '$n lines matched no card:',
  );
  String get nothingImported => _t('Nessuna carta riconosciuta nella lista.', 'No cards recognised in the list.');
  String get addCards => _t('Aggiungi carte', 'Add cards');
  String get addCardsHint => _t(
    'Tocca una carta per aggiungerla, tienila premuta per vederla.',
    'Tap a card to add it, long press to see it.',
  );
  String section(DeckSection s) => switch (s) {
    DeckSection.avatar => 'Avatar',
    DeckSection.spellbook => 'Spellbook',
    DeckSection.atlas => 'Atlas',
    DeckSection.collection => 'Collection',
  };
  String get legalDeck => _t('Mazzo valido per il formato Constructed', 'Legal for the Constructed format');
  String issue(DeckIssue i) => switch (i) {
    AvatarCount(count: 0) => _t('Manca l\'Avatar', 'No Avatar yet'),
    AvatarCount(:final count) => _t(
      'Serve un solo Avatar (ne hai $count)',
      'Only one Avatar allowed (you have $count)',
    ),
    TooFew(:final section, :final count, :final min) => _t(
      '${this.section(section)}: $count di almeno $min',
      '${this.section(section)}: $count of at least $min',
    ),
    CollectionTooBig(:final count) => _t(
      'Collection: $count carte, al massimo $maxCollection',
      'Collection: $count cards, at most $maxCollection',
    ),
    TooManyCopies(:final card, :final count, :final limit) => _t(
      '${card.name}: $count copie, al massimo $limit (${card.rarity})',
      '${card.name}: $count copies, at most $limit (${card.rarity})',
    ),
    WrongSection(:final card, :final section) => _t(
      '${card.name} non può stare nello ${this.section(section)}',
      '${card.name} can\'t go in the ${this.section(section)}',
    ),
  };
  String get manaCurve => _t('Curva di mana', 'Mana curve');
  String get atlasThreshold => _t('Soglie date dall\'Atlas', 'Threshold from the Atlas');
  String get spellbookElements => _t('Elementi dello Spellbook', 'Spellbook elements');
  String get moveToCollection => _t('Sposta nella Collection', 'Move to Collection');
  String get moveToDeck => _t('Rimetti nel mazzo', 'Move back to the deck');
  String get removeAll => _t('Togli tutte le copie', 'Remove all copies');
  String deckSummary(int spells, int sites) => _t('$spells carte · $sites siti', '$spells spells · $sites sites');
  String get emptySection => _t('Nessuna carta', 'No cards');

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
