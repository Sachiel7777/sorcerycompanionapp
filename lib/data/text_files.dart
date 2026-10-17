import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Asks where to save [text] and writes it there. Returns false if the user
/// cancelled.
Future<bool> saveTextFile(String fileName, String text, {String mimeType = 'text/plain'}) async {
  final uri = await FilePicker.saveFile(fileName: fileName, bytes: utf8.encode(text), mimeType: mimeType);
  return uri != null;
}

/// Lets the user pick a file and returns its text, or null if cancelled.
Future<String?> pickTextFile() async {
  final file = await FilePicker.pickFile();
  if (file == null) return null;
  return utf8.decode(await file.readAsBytes(), allowMalformed: true);
}

/// A file name made from a deck or other name, safe on every platform.
String safeFileName(String name, String extension) {
  final base = name.trim().replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '').replaceAll(RegExp(r'\s+'), ' ');
  return '${base.isEmpty ? 'deck' : base}.$extension';
}
