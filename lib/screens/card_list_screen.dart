import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../models/sorcery_card.dart';
import '../widgets/card_art.dart';
import 'card_detail_screen.dart';

const typeLabels = {
  'Avatar': 'Avatar',
  'Minion': 'Minion',
  'Magic': 'Magia',
  'Artifact': 'Artefatto',
  'Aura': 'Aura',
  'Site': 'Sito',
};

const elementLabels = {'Air': 'Aria', 'Earth': 'Terra', 'Fire': 'Fuoco', 'Water': 'Acqua'};

enum SortOrder { name, costAsc, costDesc }

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key, required this.db, this.title, this.initialSets = const {}});

  final CardDatabase db;

  /// Shown in the app bar instead of the app name (used when opened from a set).
  final String? title;

  /// Expansions selected in the filters when the screen opens.
  final Set<String> initialSets;

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  String _query = '';
  late final Set<String> _sets = {...widget.initialSets};
  final Set<String> _types = {};
  final Set<String> _elements = {};
  final Set<String> _rarities = {};
  SortOrder _sort = SortOrder.name;

  int get _activeFilters => _sets.length + _types.length + _elements.length + _rarities.length;

  List<SorceryCard> get _visible {
    final q = _query.trim().toLowerCase();
    final result = widget.db.cards.where((c) {
      if (q.isNotEmpty && !c.searchText.contains(q)) return false;
      if (_sets.isNotEmpty && !c.sets.any(_sets.contains)) return false;
      if (_types.isNotEmpty && !_types.contains(c.type)) return false;
      if (_elements.isNotEmpty && !c.elements.any(_elements.contains)) return false;
      if (_rarities.isNotEmpty && !_rarities.contains(c.rarity)) return false;
      return true;
    }).toList();
    int cost(SorceryCard c) => c.cost ?? -1;
    switch (_sort) {
      case SortOrder.name:
        break; // already sorted by name
      case SortOrder.costAsc:
        result.sort((a, b) => cost(a).compareTo(cost(b)));
      case SortOrder.costDesc:
        result.sort((a, b) => cost(b).compareTo(cost(a)));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cards = _visible;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Sorcery Companion'),
        actions: [
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordina',
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => const [
              PopupMenuItem(value: SortOrder.name, child: Text('Nome')),
              PopupMenuItem(value: SortOrder.costAsc, child: Text('Costo crescente')),
              PopupMenuItem(value: SortOrder.costDesc, child: Text('Costo decrescente')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    hintText: 'Cerca per nome o testo',
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: _activeFilters > 0,
                  label: Text('$_activeFilters'),
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filtri',
                    onPressed: _openFilters,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${cards.length} carte', style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
          Expanded(
            child: cards.isEmpty
                ? const Center(child: Text('Nessuna carta trovata'))
                : CustomScrollView(
                    slivers: [
                      ..._section(null, cards.where((c) => !isLandscape(c)).toList(), portraitRatio, 180),
                      ..._section('Atlas (Siti)', cards.where(isLandscape).toList(), landscapeRatio, 260),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// One block of the list: an optional title and a grid of cards sharing
  /// the same orientation (Sites are landscape, everything else portrait).
  List<Widget> _section(String? title, List<SorceryCard> cards, double ratio, double maxWidth) {
    if (cards.isEmpty) return const [];
    return [
      if (title != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text('$title · ${cards.length}', style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxWidth,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemCount: cards.length,
          itemBuilder: (context, i) {
            final card = cards[i];
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardDetailScreen(card: card))),
              child: Hero(
                tag: card.id,
                child: CardArt(card: card),
              ),
            );
          },
        ),
      ),
    ];
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          void toggle(Set<String> set, String value) {
            setState(() => set.contains(value) ? set.remove(value) : set.add(value));
            setSheet(() {});
          }

          Widget section(
            String title,
            List<String> values,
            Set<String> selected, [
            Map<String, String> labels = const {},
          ]) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final v in values)
                        FilterChip(
                          label: Text(labels[v] ?? v),
                          selected: selected.contains(v),
                          onSelected: (_) => toggle(selected, v),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  section('Espansione', widget.db.sets, _sets),
                  section('Tipo', widget.db.types, _types, typeLabels),
                  section('Elemento', CardDatabase.elements, _elements, elementLabels),
                  section('Rarità', widget.db.rarities, _rarities),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _activeFilters == 0
                          ? null
                          : () {
                              setState(() {
                                _sets.clear();
                                _types.clear();
                                _elements.clear();
                                _rarities.clear();
                              });
                              setSheet(() {});
                            },
                      child: const Text('Azzera filtri'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
