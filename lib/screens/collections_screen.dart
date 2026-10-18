import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/collection_store.dart';
import '../l10n/strings.dart';
import 'collection_detail_screen.dart';

/// Asks for a collection name; returns null if the dialog is cancelled.
Future<String?> askCollectionName(BuildContext context, {String initial = ''}) {
  final controller = TextEditingController(text: initial);
  final s = context.s;
  return showDialog<String>(
    context: context,
    builder: (context) {
      void submit() {
        final name = controller.text.trim();
        if (name.isNotEmpty) Navigator.of(context).pop(name);
      }

      return AlertDialog(
        title: Text(initial.isEmpty ? s.newCollection : s.renameCollection),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: s.collectionName),
          onSubmitted: (_) => submit(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.cancel)),
          FilledButton(onPressed: submit, child: Text(s.save)),
        ],
      );
    },
  );
}

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key, required this.db});

  final CardDatabase db;

  @override
  Widget build(BuildContext context) {
    final store = CollectionScope.of(context);
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.collectionsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'newCollection',
        icon: const Icon(Icons.add),
        label: Text(s.newCollection),
        onPressed: () async {
          final name = await askCollectionName(context);
          if (name != null) store.create(name);
        },
      ),
      body: store.collections.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(s.noCollections, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final c in store.collections)
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(c.name),
                    subtitle: Text('${s.printingCount(c.copies.length)} · ${s.copyCount(c.totalCopies)}'),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CollectionDetailScreen(db: db, collection: c),
                    )),
                  ),
              ],
            ),
    );
  }
}
