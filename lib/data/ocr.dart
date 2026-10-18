import 'package:flutter/services.dart';

import 'card_matcher.dart';

const _channel = MethodChannel('sorcery_companion/ocr');

/// Reads the text lines of the photo at [path] with Tesseract, an open
/// source engine that runs on the phone (see `MainActivity.kt`).
Future<List<ScannedLine>> readTextLines(String path) async {
  final raw = await _channel.invokeListMethod<Map<Object?, Object?>>('recognize', {'path': path});
  return [
    for (final line in raw ?? const <Map<Object?, Object?>>[])
      ScannedLine(line['text'] as String, height: (line['height'] as num).toDouble()),
  ];
}
