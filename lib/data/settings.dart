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
