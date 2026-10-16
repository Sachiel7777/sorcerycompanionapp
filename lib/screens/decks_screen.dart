import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/card_repository.dart';
import '../data/deck_rules.dart';
import '../data/deck_store.dart';
import '../data/deck_text.dart';
import '../l10n/strings.dart';
import '../models/deck.dart';
import '../widgets/card_art.dart';
import 'deck_editor_screen.dart';

/// The decks saved on this device.
class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key, required this.db, required this.store});

  final CardDatabase db;
  final DeckStore store;

  void _open(BuildContext context, Deck deck) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DeckEditorScreen(db: db, store: store, deck: deck),
    ),
  );

  Future<void> _create(BuildContext context) async {
    final s = context.s;
    final name = await askDeckName(context, title: s.newDeck, action: s.create);
    if (name == null || !context.mounted) return;
    _open(context, store.create(name.isEmpty ? s.untitledDeck : name));
  }

  Future<void> _import(BuildContext context) async {
    final s = context.s;
    final controller = TextEditingController();
    final nameController = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.importDeck),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.importHint),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: s.deckName, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  minLines: 8,
                  maxLines: 14,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Avatar\n1 Sorcerer\n\nSpellbook\n4 Apprentice Wizard\n…',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste),
                      tooltip: s.paste,
                      onPressed: () async {
                        final data = await Clipboard.getData(Clipboard.kTextPlain);
                        if (data?.text != null) controller.text = data!.text!;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(s.importAction)),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !context.mounted) return;

    final name = nameController.text.trim().isEmpty ? s.untitledDeck : nameController.text.trim();
    final result = deckFromText(text, db, id: '', name: name);
    if (DeckSection.values.every((sec) => result.deck[sec].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.nothingImported)));
      return;
    }
    final deck = store.create(name);
    for (final sec in DeckSection.values) {
      deck[sec].addAll(result.deck[sec]);
    }
    store.save();
    if (result.unknown.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(s.importUnknown(result.unknown.length)),
          content: SingleChildScrollView(child: Text(result.unknown.join('\n'))),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(s.close))],
        ),
      );
    }
    if (context.mounted) _open(context, deck);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.decksTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: s.importDeck,
            onPressed: () => _import(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'newDeck',
        icon: const Icon(Icons.add),
        label: Text(s.newDeck),
        onPressed: () => _create(context),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final decks = store.decks;
          if (decks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.style_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(s.noDecks, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.file_download_outlined),
                      label: Text(s.importDeck),
                      onPressed: () => _import(context),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
            itemCount: decks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _DeckCard(db: db, deck: decks[i], onTap: () => _open(context, decks[i])),
          );
        },
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.db, required this.deck, required this.onTap});

  final CardDatabase db;
  final Deck deck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final avatarId = deck[DeckSection.avatar].keys.firstOrNull;
    final avatar = avatarId == null ? null : db.byId[avatarId];
    final legal = checkDeck(deck, db).isEmpty;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: avatar == null
                    ? AspectRatio(
                        aspectRatio: portraitRatio,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.person_outline, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      )
                    : CardArt(card: avatar),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deck.name, style: theme.textTheme.titleLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (avatar != null) avatar.name,
                        s.deckSummary(deck.count(DeckSection.spellbook), deck.count(DeckSection.atlas)),
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                legal ? Icons.verified_outlined : Icons.construction_outlined,
                color: legal ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for a deck name; returns null if cancelled.
Future<String?> askDeckName(
  BuildContext context, {
  required String title,
  required String action,
  String initial = '',
}) {
  final s = context.s;
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: s.deckName, border: const OutlineInputBorder()),
        onSubmitted: (v) => Navigator.pop(context, v.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(action)),
      ],
    ),
  );
}
