import 'package:flutter/material.dart';

import '../data/rules_content.dart';
import '../data/collection_store.dart';
import '../data/price_links.dart';
import '../models/sorcery_card.dart';
import '../widgets/card_art.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import 'codex_screen.dart';
import 'collections_screen.dart';

class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.card});

  final SorceryCard card;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  Printing? _printing;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final text = Theme.of(context).textTheme;
    final s = context.s;
    final printing = _printing;
    final store = CollectionScope.of(context);
    final collection = store.active;
    final wide = MediaQuery.sizeOf(context).width > 720;

    final art = Hero(
      tag: card.id,
      child: CardArt(card: card, image: printing?.image, large: true),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(card.name, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(
          [
            s.type(card.type),
            if (card.subtypes.isNotEmpty) card.subtypes.join(' '),
            if (card.rarity != null) card.rarity!,
          ].join(' · '),
          style: text.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _stats(context, card)),
        if (card.keywords.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in card.keywords)
                ActionChip(
                  avatar: const Icon(Icons.help_outline, size: 18),
                  label: Text(k),
                  visualDensity: VisualDensity.compact,
                  onPressed: switch (codexEntry(k)) {
                    final entry? => () => showCodexEntry(context, entry),
                    null => null,
                  },
                ),
            ],
          ),
        ],
        if (card.rules.isNotEmpty) ...[const SizedBox(height: 16), Text(card.rules, style: text.bodyLarge)],
        if (printing?.flavour != null) ...[
          const SizedBox(height: 12),
          Text(printing!.flavour!, style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 24),
        SectionTitle(s.marketPrices, padding: EdgeInsets.zero),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final link in priceLinks)
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(link.label),
                onPressed: () => link.open(card.name),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SectionTitle(s.printings(card.printings.length), padding: EdgeInsets.zero),
        const SizedBox(height: 8),
        _collectionPicker(context, store, collection),
        for (final p in card.printings)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: identical(p, printing),
            title: Text('${p.set} · ${p.product} · ${p.finish}'),
            subtitle: p.artist == null ? null : Text(s.artist(p.artist!)),
            trailing: collection == null
                ? null
                : _CopiesStepper(
                    count: collection.copies[p.id] ?? 0,
                    onChanged: (n) => store.setCopies(collection, p.id, n),
                  ),
            onTap: () => setState(() => _printing = p),
          ),
        const SizedBox(height: 16),
        Text(s.cardCredits, style: text.bodySmall),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(card.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: isLandscape(card) ? 460 : 340, child: art),
                  const SizedBox(width: 24),
                  Expanded(child: info),
                ],
              )
            : Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isLandscape(card) ? 520 : 360),
                    child: art,
                  ),
                  const SizedBox(height: 16),
                  info,
                ],
              ),
      ),
    );
  }

  /// Chooses which collection the +/− buttons next to each printing change.
  Widget _collectionPicker(BuildContext context, CollectionStore store, CardCollection? collection) {
    if (collection == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(context.s.createCollectionForCopies),
          onPressed: () async {
            final name = await askCollectionName(context);
            if (name != null) store.create(name);
          },
        ),
      );
    }
    return Row(
      children: [
        const Icon(Icons.inventory_2_outlined, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<CardCollection>(
            isExpanded: true,
            value: collection,
            underline: const SizedBox.shrink(),
            items: [for (final c in store.collections) DropdownMenuItem(value: c, child: Text(c.name))],
            onChanged: (c) => store.active = c,
          ),
        ),
      ],
    );
  }

  List<Widget> _stats(BuildContext context, SorceryCard card) {
    final s = context.s;
    Widget chip(String label, {IconData? icon, Color? color}) => Chip(
      avatar: icon == null ? null : Icon(icon, size: 18, color: color),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
    return [
      if (card.cost != null) chip(s.cost(card.cost!), icon: Icons.auto_awesome),
      for (final e in card.thresholds.entries.where((e) => e.value > 0))
        chip(
          '${s.element(_cap(e.key))} ${e.value}',
          icon: elementIcons[_cap(e.key)],
          color: elementColors[_cap(e.key)],
        ),
      if (card.attack != null) chip(s.attack(card.attack!), icon: Icons.gavel),
      if (card.defense != null) chip(s.defense(card.defense!), icon: Icons.shield_outlined),
      if (card.life != null) chip(s.lifeStat(card.life!), icon: Icons.favorite_outline),
      for (final set in card.sets) chip(set),
    ];
  }

  static String _cap(String s) => s[0].toUpperCase() + s.substring(1);
}

class _CopiesStepper extends StatelessWidget {
  const _CopiesStepper({required this.count, required this.onChanged});

  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          tooltip: s.removeCopy,
          onPressed: count == 0 ? null : () => onChanged(count - 1),
        ),
        SizedBox(width: 24, child: Text('$count', textAlign: TextAlign.center)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: s.addCopy,
          onPressed: () => onChanged(count + 1),
        ),
      ],
    );
  }
}
