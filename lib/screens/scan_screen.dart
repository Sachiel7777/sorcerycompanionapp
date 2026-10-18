import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/card_matcher.dart';
import '../data/card_repository.dart';
import '../data/ocr.dart';
import '../l10n/strings.dart';
import '../models/sorcery_card.dart';
import '../theme.dart';
import '../widgets/card_art.dart';
import 'card_detail_screen.dart';

/// Text recognition (Tesseract) runs on the phone through Android code, so
/// scanning is only offered on Android.
bool get scannerAvailable => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Takes a photo of a card, reads its text and lists the cards whose name
/// matches best. Works offline: nothing leaves the device.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.db, this.onPick});

  final CardDatabase db;

  /// When set, tapping a match picks it (e.g. adds it to a deck).
  final void Function(SorceryCard card)? onPick;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  String? _photo;
  bool _reading = false;
  List<CardMatch>? _matches;
  String? _error;
  bool _cameraDenied = false;
  bool _cameraBlocked = false;

  @override
  void initState() {
    super.initState();
    // Open the camera straight away: that is why the screen was opened.
    WidgetsBinding.instance.addPostFrameCallback((_) => _scan(ImageSource.camera));
  }

  /// Asks for the camera only now that the user wants it. Returns false if
  /// refused; the gallery stays available either way.
  Future<bool> _ensureCamera() async {
    if (!scannerAvailable) return true;
    var status = await Permission.camera.status;
    if (!status.isGranted && !status.isPermanentlyDenied) status = await Permission.camera.request();
    if (!mounted) return false;
    setState(() {
      _cameraDenied = !status.isGranted;
      _cameraBlocked = status.isPermanentlyDenied;
    });
    return status.isGranted;
  }

  Future<void> _scan(ImageSource source) async {
    if (source == ImageSource.camera && !await _ensureCamera()) return;
    final XFile? file;
    try {
      file = await _picker.pickImage(source: source, maxWidth: 2000, maxHeight: 2000);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
      return;
    }
    if (file == null || !mounted) return;
    setState(() {
      _photo = file!.path;
      _reading = true;
      _matches = null;
      _error = null;
    });
    try {
      final lines = await readTextLines(file.path);
      final matches = await compute(_match, (lines: lines, cards: widget.db.cards));
      if (mounted) setState(() => _matches = matches);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  static List<CardMatch> _match(({List<ScannedLine> lines, List<SorceryCard> cards}) input) =>
      matchCards(input.lines, input.cards);

  void _open(SorceryCard card) {
    final pick = widget.onPick;
    if (pick != null) {
      pick(card);
      Navigator.pop(context);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardDetailScreen(card: card)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final text = Theme.of(context).textTheme;
    final matches = _matches;
    return Scaffold(
      appBar: AppBar(title: Text(s.scanTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(s.scanHint, style: text.bodyMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text(_photo == null ? s.takePhoto : s.takeAnother),
                  onPressed: _reading ? null : () => _scan(ImageSource.camera),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(s.fromGallery),
                  onPressed: _reading ? null : () => _scan(ImageSource.gallery),
                ),
              ],
            ),
          ),
          if (_cameraDenied)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(child: Text(s.cameraDenied, style: text.bodyMedium)),
                  if (_cameraBlocked) TextButton(onPressed: openAppSettings, child: Text(s.openSettings)),
                ],
              ),
            ),
          if (_photo != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_photo!), height: 220, fit: BoxFit.contain),
                ),
              ),
            ),
          if (_reading)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(s.readingCard)],
              ),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.scanFailed, style: text.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            ),
          if (matches != null && matches.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(s.noScanMatch, style: text.bodyLarge),
            ),
          if (matches != null && matches.isNotEmpty) ...[
            SectionTitle(s.scanMatches),
            for (final (i, m) in matches.indexed)
              ListTile(
                leading: SizedBox(width: 44, child: CardArt(card: m.card)),
                title: Text(m.card.name, style: i == 0 ? text.titleMedium : null),
                subtitle: Text(s.type(m.card.type)),
                trailing: widget.onPick != null
                    ? const Icon(Icons.add_circle_outline)
                    : const Icon(Icons.chevron_right),
                onTap: () => _open(m.card),
              ),
          ],
        ],
      ),
    );
  }
}
