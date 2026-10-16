import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../widgets/card_art.dart';
import 'card_list_screen.dart';

const _months = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

String _monthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

/// Every expansion, newest first; tapping one opens its cards.
class SetsScreen extends StatelessWidget {
  const SetsScreen({super.key, required this.db});

  final CardDatabase db;

  @override
  Widget build(BuildContext context) {
    // Promo cards come out over time, so they go last rather than by date.
    final sets = [...db.setInfo]
      ..sort((a, b) {
        if (a.isPromo != b.isPromo) return a.isPromo ? 1 : -1;
        return b.released.compareTo(a.released);
      });
    return Scaffold(
      appBar: AppBar(title: const Text('Set')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sets.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 88),
        itemBuilder: (context, i) => _SetTile(db: db, set: sets[i]),
      ),
    );
  }
}

class _SetTile extends StatelessWidget {
  const _SetTile({required this.db, required this.set});

  final CardDatabase db;
  final CardSet set;

  @override
  Widget build(BuildContext context) {
    final cards = db.cardsInSet(set.name);
    final avatar =
        cards.where((c) => c.type == 'Avatar' && c.image != null).firstOrNull ??
        cards.where((c) => !isLandscape(c) && c.image != null).firstOrNull;
    final subtitle = set.isPromo
        ? '${cards.length} carte · promozionali'
        : '${cards.length} carte · uscito a ${_monthYear(set.released)}';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: SizedBox(width: 56, child: avatar == null ? null : CardArt(card: avatar)),
      title: Text(set.name),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CardListScreen(db: db, title: set.name, initialSets: {set.name}),
        ),
      ),
    );
  }
}
