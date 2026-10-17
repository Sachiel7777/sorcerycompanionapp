import 'dart:convert';

import '../models/deck.dart';
import 'collection_store.dart';

/// A backup file holds everything the app keeps on the device, so it can be
/// moved to another phone or computer without an account or a server.
class Backup {
  Backup({required this.decks, this.collections = const [], this.settings = const {}, DateTime? created})
    : created = created ?? DateTime.now();

  static const _app = 'sorcery-companion';
  static const _version = 1;

  final List<Deck> decks;
  final List<CardCollection> collections;

  /// Preference keys and values, as saved by [AppSettings].
  final Map<String, Object> settings;
  final DateTime created;

  String toJson() => const JsonEncoder.withIndent('  ').convert({
    'app': _app,
    'version': _version,
    'created': created.toIso8601String(),
    'decks': [for (final d in decks) d.toJson()],
    'collections': [for (final c in collections) c.toJson()],
    'settings': settings,
  });

  /// Reads a backup. Throws [FormatException] if the text is not one.
  factory Backup.fromJson(String text) {
    final Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      throw const FormatException('not JSON');
    }
    if (json is! Map<String, dynamic> || json['app'] != _app) {
      throw const FormatException('not a Sorcery Companion backup');
    }
    if ((json['version'] as num? ?? 0) > _version) {
      throw const FormatException('made by a newer version of the app');
    }
    return Backup(
      decks: [for (final d in json['decks'] as List? ?? const []) Deck.fromJson(d as Map<String, dynamic>)],
      collections: [
        for (final c in json['collections'] as List? ?? const []) CardCollection.fromJson(c as Map<String, dynamic>),
      ],
      settings: {
        for (final e in (json['settings'] as Map<String, dynamic>? ?? const {}).entries)
          if (e.value is String || e.value is num || e.value is bool) e.key: e.value as Object,
      },
      created: DateTime.tryParse(json['created'] as String? ?? ''),
    );
  }

  /// A file name with today's date, e.g. sorcery-companion-2026-10-17.json.
  String get fileName {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'sorcery-companion-${created.year}-${two(created.month)}-${two(created.day)}.json';
  }
}
