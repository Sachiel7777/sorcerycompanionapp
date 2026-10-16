import 'package:flutter/material.dart';

import '../data/card_repository.dart';
import '../data/image_cache.dart';

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
      _message = failed == 0
          ? 'Fatto: tutte le immagini sono sul dispositivo.'
          : 'Completato, ma $failed immagini non sono state scaricate. Riprova più tardi.';
    });
  }

  Future<void> _clear() async {
    await cardImageCache.emptyCache();
    if (mounted) setState(() => _message = 'Immagini cancellate dal dispositivo.');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Uso offline')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'L\'elenco delle carte è già nell\'app. Scarica anche le immagini per '
            'sfogliarle senza connessione (circa 2200 file, conviene usare il Wi-Fi).',
            style: text.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (running) ...[
            LinearProgressIndicator(value: _total == 0 ? null : _done / _total),
            const SizedBox(height: 8),
            Text('$_done di $_total immagini'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _download?.cancel();
              },
              child: const Text('Interrompi'),
            ),
          ] else ...[
            FilledButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Scarica tutte le immagini'),
              onPressed: _start,
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _clear, child: const Text('Cancella immagini scaricate')),
          ],
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: text.bodyMedium),
          ],
        ],
      ),
    );
  }
}
