import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences, saved on the device.
class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppSettings> load() async => AppSettings._(await SharedPreferences.getInstance());

  ThemeMode get themeMode => ThemeMode.values.byName(_prefs.getString('themeMode') ?? 'system');

  set themeMode(ThemeMode mode) {
    _prefs.setString('themeMode', mode.name);
    notifyListeners();
  }

  /// The app language, or null to follow the device.
  Locale? get locale {
    final code = _prefs.getString('language');
    return code == null ? null : Locale(code);
  }

  set locale(Locale? value) {
    value == null ? _prefs.remove('language') : _prefs.setString('language', value.languageCode);
    notifyListeners();
  }

  static const _backupKeys = ['themeMode', 'language', 'startingLife', 'keepScreenOn'];

  /// The preferences worth carrying to another device.
  Map<String, Object> toBackup() => {
    for (final k in _backupKeys)
      if (_prefs.get(k) case final Object v) k: v,
  };

  void restore(Map<String, Object> values) {
    for (final MapEntry(:key, :value) in values.entries) {
      if (!_backupKeys.contains(key)) continue;
      if (key == 'themeMode' && !ThemeMode.values.any((m) => m.name == value)) continue;
      switch (value) {
        case String v:
          _prefs.setString(key, v);
        case bool v:
          _prefs.setBool(key, v);
        case num v:
          _prefs.setInt(key, v.toInt());
      }
    }
    notifyListeners();
  }

  /// Life each player starts with on the Play screen.
  int get startingLife => _prefs.getInt('startingLife') ?? 20;

  set startingLife(int value) {
    _prefs.setInt('startingLife', value);
    notifyListeners();
  }

  /// Keep the screen on while the Play screen is open.
  bool get keepScreenOn => _prefs.getBool('keepScreenOn') ?? true;

  set keepScreenOn(bool value) {
    _prefs.setBool('keepScreenOn', value);
    notifyListeners();
  }
}
