import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../models/sorcery_card.dart';

/// Kairos Archive asks automated clients to name themselves; browsers send
/// their own User-Agent and refuse a custom one.
const imageHeaders = kIsWeb ? null : {'User-Agent': 'sorcery-companion-app/0.1'};

/// Card images never change at a given address, so they are kept for a year
/// and the cache is big enough to hold every card.
final cardImageCache = CacheManager(
  Config(
    'cardImages',
    stalePeriod: const Duration(days: 365),
    maxNrOfCacheObjects: 10000,
  ),
);

/// Downloads the default image of every card (grid and detail size) so the
/// card list works offline. Reports progress as (done, total).
class OfflineImageDownload {
  OfflineImageDownload(this.cards);

  final List<SorceryCard> cards;
  bool _cancelled = false;

  List<String> get urls => [
        for (final c in cards)
          if (c.image != null) ...[c.image!.small, c.image!.normal],
      ];

  void cancel() => _cancelled = true;

  /// Returns the number of images that could not be downloaded.
  Future<int> run(void Function(int done, int total) onProgress) async {
    final all = urls;
    var next = 0, done = 0, failed = 0;
    Future<void> worker() async {
      while (!_cancelled && next < all.length) {
        final url = all[next++];
        try {
          if (await cardImageCache.getFileFromCache(url) == null) {
            await cardImageCache.downloadFile(url, authHeaders: imageHeaders);
          }
        } catch (_) {
          failed++;
        }
        onProgress(++done, all.length);
      }
    }

    await Future.wait(List.generate(4, (_) => worker()));
    return failed;
  }
}
