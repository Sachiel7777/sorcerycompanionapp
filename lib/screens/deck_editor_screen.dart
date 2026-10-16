import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/card_repository.dart';
import '../data/deck_rules.dart';
import '../data/deck_store.dart';
import '../data/deck_text.dart';
import '../l10n/strings.dart';
import '../models/deck.dart';
import '../models/sorcery_card.dart';
import '../theme.dart';
import '../widgets/card_art.dart';
import 'card_detail_screen.dart';
import 'card_list_screen.dart';
import 'decks_screen.dart';

class DeckEditorScreen extends StatelessWidget {
  const DeckEditorScreen({super.key, required this.db, required this.store, required this.deck});

  final CardDatabase db;
  final DeckStore store;
  final Deck deck;

  void _change(void Function() update) {
    update();
    store.save();
  }

  void _addCards(BuildContext context) {
    final s = context.s;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CardListScreen(
            db: db,
            title: s.addCards,
            onPick: (card) => _change(() => deck.add(defaultSection(card), card.id)),
            countOf: (card) => deck.copies(card.id),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(s.addCardsHint, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final s = context.s;
    final name = await askDeckName(context, title: s.rename, action: s.save, initial: deck.name);
    if (name != null && name.isNotEmpty) _change(() => deck.name = name);
  }

  Future<void> _delete(BuildContext context) async {
    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteDeckQuestion(deck.name)),
        content: Text(s.deleteDeckText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      store.delete(deck);
      Navigator.of(context).pop();
    }
  }

  Future<void> _export(BuildContext context) async {
    final s = context.s;
    final text = deckToText(deck, db);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.exportDeck),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace')),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(s.close)),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: Text(s.copy),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.copied)));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(deck.name),
          actions: [
            IconButton(icon: const Icon(Icons.ios_share), tooltip: s.exportDeck, onPressed: () => _export(context)),
            PopupMenuButton<String>(
              onSelected: (v) => v == 'rename' ? _rename(context) : _delete(context),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'rename', child: Text(s.rename)),
                PopupMenuItem(value: 'delete', child: Text(s.delete)),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'addCards',
          icon: const Icon(Icons.add),
          label: Text(s.addCards),
          onPressed: () => _addCards(context),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
          children: [
            _Legality(issues: checkDeck(deck, db)),
            const SizedBox(height: 10),
            _Stats(deck: deck, db: db),
            for (final section in DeckSection.values) ..._section(context, section),
          ],
        ),
      ),
    );
  }

  List<Widget> _section(BuildContext context, DeckSection section) {
    final s = context.s;
    final entries = deck[section].entries.where((e) => db.byId.containsKey(e.key)).toList()
      ..sort((a, b) {
        final ca = db.byId[a.key]!, cb = db.byId[b.key]!;
        final byCost = (ca.cost ?? -1).compareTo(cb.cost ?? -1);
        return byCost != 0 ? byCost : ca.name.compareTo(cb.name);
      });
    return [
      SectionTitle('${s.section(section)} · ${deck.count(section)}', padding: const EdgeInsets.fromLTRB(4, 20, 4, 8)),
      if (entries.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(s.emptySection, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        )
      else
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final e in entries)
                _CardRow(
                  card: db.byId[e.key]!,
                  count: e.value,
                  section: section,
                  onAdd: () => _change(() => deck.add(section, e.key)),
                  onRemove: () => _change(() => deck.add(section, e.key, -1)),
                  onMove: () => _change(
                    () => section == DeckSection.collection
                        ? deck.move(e.key, section, defaultSection(db.byId[e.key]!))
                        : deck.move(e.key, section, DeckSection.collection),
                  ),
                  onRemoveAll: () => _change(() => deck[section].remove(e.key)),
                ),
            ],
          ),
        ),
    ];
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.card,
    required this.count,
    required this.section,
    required this.onAdd,
    required this.onRemove,
    required this.onMove,
    required this.onRemoveAll,
  });

  final SorceryCard card;
  final int count;
  final DeckSection section;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onMove;
  final VoidCallback onRemoveAll;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final elements = card.elements;
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 12, right: 0),
      leading: SizedBox(
        width: isLandscape(card) ? 52 : 36,
        child: CardArt(card: card),
      ),
      title: Text(card.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          if (card.cost != null) ...[
            Icon(Icons.auto_awesome, size: 14, color: theme.colorScheme.primary),
            Text(' ${card.cost}  '),
          ],
          for (final e in elements) Icon(elementIcons[e], size: 14, color: elementColors[e]),
          if (elements.isNotEmpty) const Text('  '),
          Flexible(child: Text(s.type(card.type), overflow: TextOverflow.ellipsis)),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardDetailScreen(card: card))),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 20,
            child: Text('$count', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (f) => f(),
            itemBuilder: (_) => [
              if (section != DeckSection.avatar)
                PopupMenuItem(
                  value: onMove,
                  child: Text(section == DeckSection.collection ? s.moveToDeck : s.moveToCollection),
                ),
              PopupMenuItem(value: onRemoveAll, child: Text(s.removeAll)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legality extends StatelessWidget {
  const _Legality({required this.issues});

  final List<DeckIssue> issues;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final ok = issues.isEmpty;
    final color = ok ? scheme.primary : scheme.error;
    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(ok ? Icons.verified_outlined : Icons.error_outline, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: ok
                  ? Text(s.legalDeck)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [for (final i in issues) Text('• ${s.issue(i)}')],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.deck, required this.db});

  final Deck deck;
  final CardDatabase db;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final curve = manaCurve(deck, db);
    final peak = curve.fold(1, (a, b) => b > a ? b : a);
    final atlas = atlasThreshold(deck, db);
    final elements = spellbookElements(deck, db);

    Widget elementRow(Map<String, int> values) => Wrap(
      spacing: 14,
      children: [
        for (final e in CardDatabase.elements)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(elementIcons[e], size: 18, color: elementColors[e]),
              const SizedBox(width: 4),
              Text('${values[e]}', style: theme.textTheme.titleSmall),
            ],
          ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(s.manaCurve, padding: const EdgeInsets.only(top: 12, bottom: 8)),
            SizedBox(
              height: 84,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < curve.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(curve[i] == 0 ? '' : '${curve[i]}', style: theme.textTheme.labelSmall),
                            const SizedBox(height: 2),
                            Container(
                              height: 48 * curve[i] / peak + 2,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: curve[i] == 0 ? 0.15 : 0.8),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(i == 7 ? '7+' : '$i', style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SectionTitle(s.atlasThreshold, padding: const EdgeInsets.only(top: 16, bottom: 8)),
            elementRow(atlas),
            SectionTitle(s.spellbookElements, padding: const EdgeInsets.only(top: 16, bottom: 8)),
            elementRow(elements),
          ],
        ),
      ),
    );
  }
}
