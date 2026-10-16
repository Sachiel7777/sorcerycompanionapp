import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/image_cache.dart';
import '../models/sorcery_card.dart';

class CardArt extends StatelessWidget {
  const CardArt({super.key, required this.card, this.image, this.large = false});

  final SorceryCard card;
  final CardImage? image;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final img = image ?? card.image;
    final url = img == null ? null : (large ? img.normal : img.small);
    // Sites are printed in landscape, so the image is fitted rather than cropped.
    return AspectRatio(
      aspectRatio: 488 / 680,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(large ? 14 : 8),
        child: url == null
            ? _Placeholder(card: card)
            : CachedNetworkImage(
                imageUrl: url,
                httpHeaders: imageHeaders,
                cacheManager: cardImageCache,
                fit: BoxFit.contain,
                placeholder: (_, _) => _Placeholder(card: card),
                errorWidget: (_, _, _) => _Placeholder(card: card),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.card});

  final SorceryCard card;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        card.name,
        textAlign: TextAlign.center,
        style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
      ),
    );
  }
}
