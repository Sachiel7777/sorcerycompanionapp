import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../l10n/strings.dart';
import '../widgets/card_art.dart';
import 'card_list_screen.dart';

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
      appBar: AppBar(title: Text(context.s.setsTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        itemCount: sets.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _SetCard(db: db, set: sets[i]),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({required this.db, required this.set});

  final CardDatabase db;
  final CardSet set;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    final cards = db.cardsInSet(set.name);
    // A fan of three cards from the set, avatars first.
    final cover = [
      ...cards.where((c) => c.type == 'Avatar' && c.image != null),
      ...cards.where((c) => c.type == 'Minion' && c.image != null),
    ].take(3).toList();
    final subtitle = '${s.cardCount(cards.length)} · ${set.isPromo ? s.promo : s.released(set.released)}';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CardListScreen(db: db, title: set.name, initialSets: {set.name}),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primaryContainer.withValues(alpha: 0.55), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 82,
                child: Stack(
                  children: [
                    for (var i = cover.length - 1; i >= 0; i--)
                      Positioned(
                        left: i * 22.0,
                        top: 0,
                        bottom: 0,
                        child: Transform.rotate(
                          angle: (i - 1) * 0.08,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(1, 2))],
                            ),
                            child: CardArt(card: cover[i]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(set.name, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
