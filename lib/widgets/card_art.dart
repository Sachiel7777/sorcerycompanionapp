import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/image_cache.dart';
import '../models/sorcery_card.dart';

/// Sites (the cards of the Atlas) are played and shown landscape.
bool isLandscape(SorceryCard card) => card.type == 'Site';

const portraitRatio = 488 / 680;
const landscapeRatio = 680 / 488;

class CardArt extends StatelessWidget {
  const CardArt({super.key, required this.card, this.image, this.large = false});

  final SorceryCard card;
  final CardImage? image;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final img = image ?? card.image;
    final url = img == null ? null : (large ? img.normal : img.small);
    final landscape = isLandscape(card);
    return AspectRatio(
      aspectRatio: landscape ? landscapeRatio : portraitRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 14 : 8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: large ? 16 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(large ? 14 : 8),
          child: url == null
              ? _Placeholder(card: card)
              : CachedNetworkImage(
                  imageUrl: url,
                  httpHeaders: imageHeaders,
                  cacheManager: cardImageCache,
                  fit: BoxFit.contain,
                  imageBuilder: landscape ? (context, provider) => _LandscapeImage(provider: provider) : null,
                  placeholder: (_, _) => _Placeholder(card: card),
                  errorWidget: (_, _, _) => _Placeholder(card: card),
                ),
        ),
      ),
    );
  }
}

/// Shows a Site image landscape whichever way the source file is stored:
/// a portrait file is turned a quarter turn, a landscape one is left alone.
class _LandscapeImage extends StatefulWidget {
  const _LandscapeImage({required this.provider});

  final ImageProvider provider;

  @override
  State<_LandscapeImage> createState() => _LandscapeImageState();
}

class _LandscapeImageState extends State<_LandscapeImage> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  bool _rotate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(_LandscapeImage old) {
    super.didUpdateWidget(old);
    if (old.provider != widget.provider) _resolve();
  }

  void _resolve() {
    _stream?.removeListener(_listener!);
    _stream = widget.provider.resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((info, _) {
      final rotate = info.image.height > info.image.width;
      if (mounted && rotate != _rotate) setState(() => _rotate = rotate);
    });
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image(image: widget.provider, fit: BoxFit.contain);
    return _rotate ? RotatedBox(quarterTurns: 1, child: image) : image;
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
