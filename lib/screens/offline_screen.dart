import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/image_cache.dart';
import '../l10n/strings.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key, required this.db});

  final CardDatabase db;

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  OfflineImageDownload? _download;
  int _done = 0;
  int _total = 0;
  String? _message;

  Future<void> _start() async {
    final download = OfflineImageDownload(widget.db.cards);
    setState(() {
      _download = download;
      _done = 0;
      _total = download.urls.length;
      _message = null;
    });
    final failed = await download.run((done, total) {
      if (mounted) setState(() => _done = done);
    });
    if (!mounted) return;
    setState(() {
      _download = null;
      _message = failed == 0 ? context.s.offlineDone : context.s.offlineFailed(failed);
    });
  }

  Future<void> _clear() async {
    await cardImageCache.emptyCache();
    if (mounted) setState(() => _message = context.s.offlineCleared);
  }

  @override
  void dispose() {
    _download?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = _download != null;
    final text = Theme.of(context).textTheme;
    final s = context.s;
    return Scaffold(
      appBar: AppBar(title: Text(s.offline)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.offlineIntro, style: text.bodyLarge),
          const SizedBox(height: 24),
          if (running) ...[
            LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
            const SizedBox(height: 8),
            Text(s.offlineProgress(_done, _total)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _download?.cancel();
              },
              child: Text(s.stop),
            ),
          ] else ...[
            FilledButton.icon(icon: const Icon(Icons.download), label: Text(s.downloadAll), onPressed: _start),
            const SizedBox(height: 8),
            TextButton(onPressed: _clear, child: Text(s.clearImages)),
          ],
          if (_message != null) ...[const SizedBox(height: 16), Text(_message!, style: text.bodyMedium)],
        ],
      ),
    );
  }
}
