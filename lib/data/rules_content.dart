/// Rules summary and glossary, written for this app from the official
/// rulebook (December 2025). They explain, they don't replace it: the
/// official rulebook and Codex are the reference for exact wording.
library;

/// Text in both app languages.
class Bilingual {
  const Bilingual(this.it, this.en);

  final String it;
  final String en;

  String of(bool english) => english ? en : it;
}

const officialCodexUrl = 'https://sorcerytcg.com/codex';
const officialChangelogUrl = 'https://sorcerytcg.com/codex/changelog';
const officialRulebookUrl = 'https://drive.google.com/file/d/1sgQo0xf0N2teIR0zlyl91g9j6LVncZnr/view';

class RulesSection {
  const RulesSection(this.title, this.points);

  final Bilingual title;
  final List<Bilingual> points;
}

const rulesSections = [
  RulesSection(Bilingual('Lo scopo', 'The goal'), [
    Bilingual(
      'Porta a 0 la vita dell\'Avatar avversario: a quel punto è sulla soglia della morte (Death\'s Door). '
          'Il primo danno che riceve dopo quel turno è il colpo mortale e vinci la partita.',
      'Bring the opposing Avatar\'s life to 0: it is then at Death\'s Door. '
          'The first damage it takes after that turn is the death blow, and you win.',
    ),
    Bilingual(
      'Nel turno in cui arriva a Death\'s Door l\'Avatar non può più subire danni, e da lì in poi non può più guadagnare vita.',
      'During the turn it reaches Death\'s Door the Avatar can\'t be damaged, and from then on it can\'t gain life.',
    ),
    Bilingual(
      'Perde anche chi deve pescare da un mazzo vuoto.',
      'A player who has to draw from an empty deck also loses.',
    ),
  ]),
  RulesSection(Bilingual('Il mazzo', 'Your deck'), [
    Bilingual(
      'Ogni giocatore ha un Avatar, che resta fuori dai mazzi e comincia in gioco.',
      'Each player has one Avatar, kept outside the decks and in play from the start.',
    ),
    Bilingual(
      'L\'Atlas è il mazzo dei siti (almeno 30), lo Spellbook quello degli incantesimi: minion, magie, aure e artefatti (almeno 60).',
      'The Atlas is the deck of sites (at least 30); the Spellbook holds the spells: minions, magics, auras and artifacts (at least 60).',
    ),
    Bilingual(
      'Copie massime per carta: 4 Ordinary, 3 Exceptional, 2 Elite, 1 Unique.',
      'Most copies of a card: 4 Ordinary, 3 Exceptional, 2 Elite, 1 Unique.',
    ),
  ]),
  RulesSection(Bilingual('Preparazione', 'Setup'), [
    Bilingual(
      'Il campo, il Realm, è una griglia di 5 × 4 caselle vuote (void) condivisa da entrambi.',
      'The board, the Realm, is a 5 × 4 grid of empty (void) squares shared by both players.',
    ),
    Bilingual(
      'Metti l\'Avatar sulla casella centrale della tua prima fila. Mescola Atlas e Spellbook.',
      'Put your Avatar on the middle square of your nearest row. Shuffle your Atlas and Spellbook.',
    ),
    Bilingual(
      'Pesca 3 carte dall\'Atlas e 3 dallo Spellbook. Una volta puoi rimetterne fino a 3 in fondo ai mazzi e ripescarne altrettante.',
      'Draw 3 cards from the Atlas and 3 from the Spellbook. Once, you may put up to 3 on the bottom of their decks and draw as many again.',
    ),
  ]),
  RulesSection(Bilingual('Il turno', 'Your turn'), [
    Bilingual(
      'Inizio: raddrizzi le tue carte, i siti ti danno il mana, poi peschi una carta dall\'Atlas o dallo Spellbook, a scelta. '
          'Chi gioca per primo non pesca al primo turno.',
      'Start: untap your cards, your sites give you mana, then draw one card from either the Atlas or the Spellbook. '
          'The first player skips this draw on their first turn.',
    ),
    Bilingual(
      'Fase principale: giochi siti, lanci incantesimi, muovi e attacchi, nell\'ordine che vuoi e finché hai risorse.',
      'Main phase: play sites, cast spells, move and attack, in any order, as long as you have the resources.',
    ),
    Bilingual(
      'Fine: i minion nel Realm guariscono da tutti i danni. L\'Avatar no: la sua vita persa resta persa.',
      'End: minions in the Realm heal all damage. The Avatar doesn\'t: lost life stays lost.',
    ),
    Bilingual(
      'Al primo turno devi usare l\'Avatar per giocare un sito sulla sua stessa casella.',
      'On your first turn you must use your Avatar to play a site on its own square.',
    ),
  ]),
  RulesSection(Bilingual('Mana e soglie', 'Mana and threshold'), [
    Bilingual(
      'Ogni sito che controlli dà 1 mana all\'inizio del tuo turno, e 1 subito quando entra in gioco. Il mana non usato si perde a fine turno.',
      'Each site you control gives 1 mana at the start of your turn, and 1 straight away when it enters. Unused mana is lost at the end of the turn.',
    ),
    Bilingual(
      'La soglia è il numero di simboli di un elemento (Aria, Terra, Fuoco, Acqua) sui tuoi siti. '
          'Per lanciare una carta devi avere almeno i simboli che chiede. La soglia non si consuma.',
      'Threshold is the number of symbols of an element (Air, Earth, Fire, Water) on your sites. '
          'To cast a card you need at least the symbols it shows. Threshold is never spent.',
    ),
  ]),
  RulesSection(Bilingual('Giocare i siti', 'Playing sites'), [
    Bilingual(
      'L\'Avatar ha l\'abilità "Tap → gioca o pesca un sito".',
      'The Avatar has the ability "Tap → play or draw a site".',
    ),
    Bilingual(
      'Un sito va su una casella vuota o di macerie (rubble), accanto a un sito che controlli. Se non ne controlli nessuno, il più vicino possibile all\'Avatar.',
      'A site goes on an empty or rubble square, next to a site you control. If you control none, as close to your Avatar as possible.',
    ),
  ]),
  RulesSection(Bilingual('Lanciare incantesimi', 'Casting spells'), [
    Bilingual(
      'Gli incantesimi li lancia uno Spellcaster che controlli, di solito l\'Avatar: paghi il mana e devi avere la soglia.',
      'Spells are cast by a Spellcaster you control, usually your Avatar: pay the mana and meet the threshold.',
    ),
    Bilingual(
      'Minion: entrano su un tuo sito. Artefatti: su un tuo sito o in mano a una tua unità. '
          'Aure: su una casella, sul bordo tra due o all\'incrocio di quattro. Magie: fanno effetto e vanno nel cimitero.',
      'Minions: enter on one of your sites. Artifacts: on one of your sites or into a unit\'s hands. '
          'Auras: on a square, on the edge between two, or where four meet. Magics: take effect and go to the cemetery.',
    ),
    Bilingual(
      'Un minion appena evocato non può essere tappato per pagare abilità in quel turno (salvo Charge), ma può difendere nel turno avversario.',
      'A minion summoned this turn can\'t be tapped to pay for abilities (unless it has Charge), but it can defend on the opponent\'s turn.',
    ),
  ]),
  RulesSection(Bilingual('Movimento e regioni', 'Movement and regions'), [
    Bilingual(
      'Con "Muovi e attacca" un\'unità si tappa, fa un passo verso una casella adiacente (non in diagonale) e poi può attaccare dove si trova.',
      'With "Move and Attack" a unit taps, takes a step to an adjacent square (not diagonally), then may attack where it ends.',
    ),
    Bilingual(
      'Le regioni sono quattro: void, superficie, sottosuolo (sotto i siti di terra) e sott\'acqua (sotto i siti d\'acqua). '
          'Senza l\'abilità giusta un minion nel void viene esiliato e uno nel sottosuolo muore.',
      'There are four regions: void, surface, underground (beneath land sites) and underwater (beneath water sites). '
          'Without the right ability a minion in the void is banished and one below the surface dies.',
    ),
    Bilingual(
      'Adiacente: la propria casella e le 4 che la toccano di lato. Vicino (nearby): la propria casella e le 8 intorno. Solo nella stessa regione.',
      'Adjacent: a unit\'s own square and the 4 that share a side with it. Nearby: its own square and the 8 around it. Same region only.',
    ),
    Bilingual(
      'L\'Avatar sta sempre in superficie e non può entrare nel void.',
      'The Avatar always stays on the surface and can never enter the void.',
    ),
  ]),
  RulesSection(Bilingual('Combattimento', 'Combat'), [
    Bilingual(
      'Attacco: dopo il movimento attacchi un\'unità nemica o un sito nemico nella stessa casella.',
      'Attack: after moving, attack an enemy unit or enemy site at your location.',
    ),
    Bilingual(
      'Difesa: nel turno avversario le tue unità non tappate a portata possono tapparsi, raggiungere l\'attacco e unirsi alla lotta.',
      'Defend: on the opponent\'s turn your untapped units in range may tap, move to the attack and join the fight.',
    ),
    Bilingual(
      'Intercettare: se un nemico finisce il movimento senza attaccare, le tue unità già lì possono tapparsi e combatterlo.',
      'Intercept: if an enemy ends its movement without attacking, your units already there may tap and fight it.',
    ),
    Bilingual(
      'Nella lotta tutti colpiscono insieme, con danno pari alla propria forza (chi ha First Strike prima). '
          'Un minion muore quando i danni raggiungono la sua forza.',
      'In a fight everyone strikes at once, dealing damage equal to their power (First Strike goes first). '
          'A minion dies when its damage reaches its power.',
    ),
    Bilingual(
      'Danneggiare un sito fa perdere altrettanta vita al suo Avatar. È perdita di vita, non danno: non può dare il colpo mortale.',
      'Damaging a site makes its Avatar lose that much life. It is life loss, not damage, so it can\'t be the death blow.',
    ),
  ]),
  RulesSection(Bilingual('Artefatti', 'Artifacts'), [
    Bilingual(
      'Una volta per turno un\'unità può raccogliere gli artefatti liberi nella sua casella, e lasciare quelli che porta se non ha agito.',
      'Once per turn a unit may pick up loose artifacts at its location, and drop those it carries if it hasn\'t acted.',
    ),
  ]),
];

enum CodexKind { keyword, term }

class CodexEntry {
  const CodexEntry(this.name, this.kind, this.text, {this.itName});

  /// The name as printed on cards (English).
  final String name;

  /// Italian name, for terms people also say in Italian.
  final String? itName;
  final CodexKind kind;
  final Bilingual text;

  String title(bool english) => english || itName == null ? name : '$name ($itName)';
}

const codex = [
  CodexEntry(
    'Airborne',
    CodexKind.keyword,
    Bilingual(
      'Vola sopra la superficie: quando fa un passo può muoversi anche in diagonale. '
          'Solo unità Airborne o Ranged possono intercettarla, e solo unità Airborne possono attaccarla.',
      'Flies over the surface: its steps may also go diagonally. '
          'Only Airborne or Ranged units can intercept it, and only Airborne units can attack it.',
    ),
  ),
  CodexEntry(
    'Burrowing',
    CodexKind.keyword,
    Bilingual(
      'Può stare nel sottosuolo dei siti di terra e passare tra superficie e sottosuolo.',
      'Can be underground beneath land sites and step between surface and underground.',
    ),
  ),
  CodexEntry(
    'Charge',
    CodexKind.keyword,
    Bilingual(
      'Può essere tappata per pagare abilità già nel turno in cui entra in gioco.',
      'Can tap, or be tapped, to pay for abilities on the turn it is summoned.',
    ),
  ),
  CodexEntry(
    'Deathrite',
    CodexKind.keyword,
    Bilingual(
      'Effetto che avviene quando l\'unità muore, prima che vada nel cimitero.',
      'An effect that happens when the unit dies, before it goes to the cemetery.',
    ),
  ),
  CodexEntry(
    'Disabled',
    CodexKind.keyword,
    Bilingual(
      'Perde tutte le abilità, non colpisce in combattimento, non lancia incantesimi e non agisce. '
          'Altri effetti possono comunque muoverla o tapparla.',
      'Loses all abilities, doesn\'t strike in fights, can\'t cast spells or take actions. '
          'Other effects can still move or tap it.',
    ),
    itName: 'disabilitato',
  ),
  CodexEntry(
    'First Strike',
    CodexKind.keyword,
    Bilingual(
      'Colpisce prima degli avversari. Se più unità ce l\'hanno colpiscono insieme, poi colpiscono le altre sopravvissute.',
      'Strikes before its opponents. Units that all have it strike together, then the surviving others strike.',
    ),
  ),
  CodexEntry(
    'Flood',
    CodexKind.keyword,
    Bilingual(
      'Un sito allagato (flooded) ha un simbolo d\'acqua in più degli altri e conta come sito d\'acqua.',
      'A flooded site has one more water symbol than any other, and counts as a water site.',
    ),
    itName: 'allagare',
  ),
  CodexEntry(
    'Genesis',
    CodexKind.keyword,
    Bilingual(
      'Effetto che avviene quando la carta entra nel Realm.',
      'An effect that happens when the card enters the Realm.',
    ),
  ),
  CodexEntry('Immobile', CodexKind.keyword, Bilingual('Non può fare passi.', 'Can\'t take steps.')),
  CodexEntry(
    'Lance',
    CodexKind.keyword,
    Bilingual(
      'Entra con una lancia. La prima volta che colpisce con la lancia fa 1 danno in più e colpisce per prima, poi la lancia si rompe.',
      'Enters with a lance. The first time it strikes carrying the lance it deals 1 extra damage and strikes first, then the lance breaks.',
    ),
  ),
  CodexEntry(
    'Landbound',
    CodexKind.keyword,
    Bilingual(
      'È disabilitata finché non si trova su un sito di terra (come Waterbound, ma per la terra).',
      'Is disabled while it isn\'t on a land site (like Waterbound, but for land).',
    ),
  ),
  CodexEntry(
    'Lethal',
    CodexKind.keyword,
    Bilingual(
      'Qualsiasi danno che infligge a un minion basta a ucciderlo.',
      'Any damage it deals to a minion is enough to kill it.',
    ),
  ),
  CodexEntry(
    'Movement',
    CodexKind.keyword,
    Bilingual(
      'Movement +X: quando si muove può fare fino a X passi in più.',
      'Movement +X: when it moves it may take up to X extra steps.',
    ),
  ),
  CodexEntry(
    'Ranged',
    CodexKind.keyword,
    Bilingual(
      'Può tapparsi per tirare un proiettile che percorre fino a X passi (1 se non indicato) e colpisce la prima unità che incontra. '
          'Può intercettare unità Airborne.',
      'Can tap to shoot a projectile that travels up to X steps (1 if not stated) and hits the first unit it meets. '
          'Can intercept Airborne units.',
    ),
  ),
  CodexEntry(
    'Spellcaster',
    CodexKind.keyword,
    Bilingual(
      'Può lanciare incantesimi. Alcuni lanciano solo incantesimi di un certo elemento.',
      'Can cast spells. Some can only cast spells of one element.',
    ),
  ),
  CodexEntry(
    'Stealth',
    CodexKind.keyword,
    Bilingual(
      'Gli avversari non possono bersagliarla, intercettarla, difendersi dai suoi attacchi o colpirla con proiettili. '
          'La perde appena interagisce col Realm. Anche gli artefatti che porta sono protetti.',
      'Opponents can\'t target it, intercept it, defend against its attacks or hit it with projectiles. '
          'It loses Stealth as soon as it interacts with the Realm. Artifacts it carries are protected too.',
    ),
    itName: 'furtività',
  ),
  CodexEntry(
    'Submerge',
    CodexKind.keyword,
    Bilingual(
      'Può stare sott\'acqua sotto i siti d\'acqua e passare tra superficie e fondale.',
      'Can be underwater beneath water sites and step between surface and underwater.',
    ),
  ),
  CodexEntry(
    'Voidwalk',
    CodexKind.keyword,
    Bilingual(
      'Può stare nel void: entrare in una casella vuota adiacente o uscirne sulla superficie di un sito vicino.',
      'Can be in the void: step into an adjacent empty square, or out onto an adjacent site\'s surface.',
    ),
  ),
  CodexEntry(
    'Ward',
    CodexKind.keyword,
    Bilingual(
      'Se un incantesimo o un\'abilità avversaria la danneggerebbe, distruggerebbe o la prenderebbe di mira, si rompe il Ward al suo posto. '
          'I minion Evil non possono avere Ward.',
      'If an opponent\'s spell or ability would damage, destroy or target it, the Ward breaks instead. '
          'Evil minions can\'t be warded.',
    ),
    itName: 'protezione',
  ),
  CodexEntry(
    'Waterbound',
    CodexKind.keyword,
    Bilingual(
      'È disabilitata finché non si trova in un luogo d\'acqua.',
      'Is disabled while it isn\'t at a water location.',
    ),
  ),
  // Game terms
  CodexEntry(
    'Atlas',
    CodexKind.term,
    Bilingual('Il mazzo dei siti, almeno 30 carte.', 'The deck of sites, at least 30 cards.'),
  ),
  CodexEntry(
    'Avatar',
    CodexKind.term,
    Bilingual(
      'La tua figura in gioco: ha la vita della partita, lancia incantesimi e gioca i siti. Sta sempre in superficie.',
      'You in the game: it has your life, casts spells and plays sites. It always stays on the surface.',
    ),
  ),
  CodexEntry(
    'Banish',
    CodexKind.term,
    Bilingual(
      'Togliere la carta dalla partita. Non va nel cimitero.',
      'Remove the card from the game. It doesn\'t go to the cemetery.',
    ),
    itName: 'esiliare',
  ),
  CodexEntry(
    'Cemetery',
    CodexKind.term,
    Bilingual(
      'La pila scoperta delle carte morte, distrutte o usate.',
      'The face-up pile of dead, destroyed or used cards.',
    ),
    itName: 'cimitero',
  ),
  CodexEntry(
    'Collection',
    CodexKind.term,
    Bilingual(
      'Fino a 10 carte tenute fuori dal mazzo, che alcuni effetti permettono di prendere durante la partita.',
      'Up to 10 cards kept outside the deck that some effects let you fetch during the game.',
    ),
  ),
  CodexEntry(
    'Death\'s Door',
    CodexKind.term,
    Bilingual(
      'Un Avatar a 0 vita. In quel turno non subisce danni; dopo, il primo danno è il colpo mortale (death blow).',
      'An Avatar at 0 life. It takes no damage that turn; after that, the first damage is the death blow.',
    ),
  ),
  CodexEntry(
    'Intercept',
    CodexKind.term,
    Bilingual(
      'Combattere un nemico che finisce il movimento senza attaccare nella casella delle tue unità.',
      'Fight an enemy that ends its movement at your units\' location without attacking.',
    ),
    itName: 'intercettare',
  ),
  CodexEntry(
    'Mana',
    CodexKind.term,
    Bilingual(
      'Si paga per lanciare incantesimi. Ogni sito ne dà 1 a turno; quello non usato si perde.',
      'Paid to cast spells. Each site gives 1 per turn; unused mana is lost.',
    ),
  ),
  CodexEntry(
    'Nearby',
    CodexKind.term,
    Bilingual(
      'La casella di un\'unità e le 8 intorno, nella stessa regione. "Adiacente" invece sono solo le 4 di lato.',
      'A unit\'s square and the 8 around it, in the same region. "Adjacent" is only the 4 sharing a side.',
    ),
    itName: 'vicino',
  ),
  CodexEntry(
    'Projectile',
    CodexKind.term,
    Bilingual(
      'Parte dalla casella di chi lo tira, va dritto in una direzione nella stessa regione e si ferma sulla prima unità che incontra.',
      'Leaves the shooter\'s square, travels straight in one direction in the same region, and stops at the first unit it meets.',
    ),
    itName: 'proiettile',
  ),
  CodexEntry(
    'Rubble',
    CodexKind.term,
    Bilingual(
      'Quello che resta di un sito distrutto: non dà mana né soglia e non è di nessuno. Ci si può giocare sopra un nuovo sito.',
      'What is left of a destroyed site: no mana, no threshold, no controller. A new site can be played on it.',
    ),
    itName: 'macerie',
  ),
  CodexEntry(
    'Spellbook',
    CodexKind.term,
    Bilingual(
      'Il mazzo degli incantesimi (minion, magie, aure, artefatti), almeno 60 carte.',
      'The deck of spells (minions, magics, auras, artifacts), at least 60 cards.',
    ),
  ),
  CodexEntry(
    'Summoning sickness',
    CodexKind.term,
    Bilingual(
      'Un minion appena evocato non può essere tappato per pagare abilità fino alla fine del turno, salvo Charge.',
      'A minion summoned this turn can\'t be tapped to pay for abilities until the end of the turn, unless it has Charge.',
    ),
  ),
  CodexEntry(
    'Tap',
    CodexKind.term,
    Bilingual(
      'Girare la carta di lato per usarla. Si raddrizza all\'inizio del tuo turno.',
      'Turn the card sideways to use it. It untaps at the start of your turn.',
    ),
    itName: 'tappare',
  ),
  CodexEntry(
    'Threshold',
    CodexKind.term,
    Bilingual(
      'I simboli di un elemento sui tuoi siti. Una carta chiede almeno quei simboli per essere lanciata; non si consumano.',
      'The symbols of an element on your sites. A card needs at least that many to be cast; they are never spent.',
    ),
    itName: 'soglia',
  ),
];

/// The glossary entry for a keyword as it appears in card data, if any.
CodexEntry? codexEntry(String name) {
  final key = name.toLowerCase();
  for (final e in codex) {
    if (e.name.toLowerCase() == key) return e;
  }
  return null;
}
