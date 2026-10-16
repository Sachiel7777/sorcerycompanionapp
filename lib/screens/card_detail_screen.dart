import 'package:flutter/material.dart';

import '../models/sorcery_card.dart';
import '../widgets/card_art.dart';
import 'card_list_screen.dart';

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
    final printing = _printing;
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
            typeLabels[card.type] ?? card.type,
            if (card.subtypes.isNotEmpty) card.subtypes.join(' '),
            if (card.rarity != null) card.rarity!,
          ].join(' · '),
          style: text.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _stats(card)),
        if (card.rules.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(card.rules, style: text.bodyLarge),
        ],
        if (printing?.flavour != null) ...[
          const SizedBox(height: 12),
          Text(printing!.flavour!, style: text.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: 24),
        Text('Stampe (${card.printings.length})', style: text.titleMedium),
        const SizedBox(height: 8),
        for (final p in card.printings)
          ListTile(
            contentPadding: EdgeInsets.zero,
            selected: identical(p, printing),
            title: Text('${p.set} · ${p.product} · ${p.finish}'),
            subtitle: p.artist == null ? null : Text('Illustrazione: ${p.artist}'),
            onTap: () => setState(() => _printing = p),
          ),
        const SizedBox(height: 16),
        Text(
          'Dati e immagini © Erik\'s Curiosa, tramite Kairos Archive (kairosarchive.net).',
          style: text.bodySmall,
        ),
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
                  ConstrainedBox(constraints: BoxConstraints(maxWidth: isLandscape(card) ? 520 : 360), child: art),
                  const SizedBox(height: 16),
                  info,
                ],
              ),
      ),
    );
  }

  List<Widget> _stats(SorceryCard card) {
    Widget chip(String label) => Chip(label: Text(label), visualDensity: VisualDensity.compact);
    final thresholds = card.thresholds.entries
        .where((e) => e.value > 0)
        .map((e) => '${elementLabels[_cap(e.key)]} ${e.value}');
    return [
      if (card.cost != null) chip('Costo ${card.cost}'),
      for (final t in thresholds) chip(t),
      if (card.attack != null) chip('Attacco ${card.attack}'),
      if (card.defense != null) chip('Difesa ${card.defense}'),
      if (card.life != null) chip('Vita ${card.life}'),
      for (final s in card.sets) chip(s),
    ];
  }

  static String _cap(String s) => s[0].toUpperCase() + s.substring(1);
}
