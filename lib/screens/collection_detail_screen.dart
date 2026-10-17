import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/collection_store.dart';
import '../l10n/strings.dart';
import '../models/sorcery_card.dart';
import '../widgets/card_art.dart';
import 'card_detail_screen.dart';
import 'collections_screen.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.db, required this.collection});

  final CardDatabase db;
  final CardCollection collection;

  @override
  Widget build(BuildContext context) {
    final store = CollectionScope.of(context);
    final s = context.s;
    // Each owned printing, with its card, sorted by card name then set.
    final entries = [
      for (final e in collection.copies.entries)
        if (db.cardByPrinting[e.key] case final card?)
          (card, card.printings.firstWhere((p) => p.id == e.key), e.value),
    ]..sort((a, b) {
        final byName = a.$1.name.compareTo(b.$1.name);
        return byName != 0 ? byName : a.$2.set.compareTo(b.$2.set);
      });
    final cardCount = entries.map((e) => e.$1.id).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: s.rename,
            onPressed: () async {
              final name = await askCollectionName(context, initial: collection.name);
              if (name != null) store.rename(collection, name);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: s.delete,
            onPressed: () => _confirmDelete(context, store),
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.emptyCollection, textAlign: TextAlign.center),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      [s.cardCount(cardCount), s.printingCount(entries.length), s.copyCount(collection.totalCopies)]
                          .join(' · '),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, i) {
                      final (card, printing, count) = entries[i];
                      return _Entry(
                        card: card,
                        printing: printing,
                        count: count,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CardDetailScreen(card: card),
                        )),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CollectionStore store) async {
    final s = context.s;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteCollectionQuestion),
        content: Text(s.deleteCollectionText(collection.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(s.cancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pop();
      store.delete(collection);
    }
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.card, required this.printing, required this.count, required this.onTap});

  final SorceryCard card;
  final Printing printing;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Badge(
                label: Text('×$count'),
                largeSize: 22,
                child: CardArt(card: card, image: printing.image),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(card.name, style: text.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            '${printing.set} · ${printing.finish}',
            style: text.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
