import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/rules_content.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'card_list_screen.dart';

/// Shows one glossary entry in a bottom sheet. With [db], keywords get a
/// button listing the cards that have them.
Future<void> showCodexEntry(BuildContext context, CodexEntry entry, {CardDatabase? db}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final s = sheetContext.s;
      final text = Theme.of(sheetContext).textTheme;
      final count = db == null || entry.kind != CodexKind.keyword
          ? 0
          : db.cards.where((c) => c.keywords.contains(entry.name)).length;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.title(s.english), style: text.headlineSmall),
              const SizedBox(height: 4),
              Text(
                entry.kind == CodexKind.keyword ? s.keywordLabel : s.termLabel,
                style: text.labelMedium?.copyWith(color: Theme.of(sheetContext).colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(entry.text.of(s.english), style: text.bodyLarge),
              if (count > 0) ...[
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.style_outlined),
                  label: Text('${s.cardsWithKeyword} (${s.cardCount(count)})'),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CardListScreen(db: db!, title: entry.name, keyword: entry.name),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key, required this.db});

  final CardDatabase db;

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final en = s.english;
    final q = _query.trim().toLowerCase();
    final entries = codex.where((e) {
      if (q.isEmpty) return true;
      return e.title(en).toLowerCase().contains(q) || e.text.of(en).toLowerCase().contains(q);
    }).toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final rows = <Widget>[];
    for (final kind in CodexKind.values) {
      final group = entries.where((e) => e.kind == kind).toList();
      if (group.isEmpty) continue;
      rows.add(SectionTitle(kind == CodexKind.keyword ? s.keywordsSection : s.termsSection));
      String? letter;
      for (final e in group) {
        final first = e.name[0].toUpperCase();
        rows.add(
          ListTile(
            leading: SizedBox(
              width: 28,
              child: Text(
                first == letter ? '' : first,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            title: Text(e.title(en)),
            subtitle: Text(e.text.of(en), maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => showCodexEntry(context, e, db: widget.db),
          ),
        );
        letter = first;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.codexTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: SearchBar(
              hintText: s.searchCodex,
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? Center(child: Text(s.noCodexResults))
                : ListView(padding: const EdgeInsets.only(bottom: 24), children: rows),
          ),
        ],
      ),
    );
  }
}
