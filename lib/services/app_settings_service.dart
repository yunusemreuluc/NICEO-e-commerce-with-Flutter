import 'package:flutter/material.dart';

class AppSettingsService extends ChangeNotifier {
  // THEME
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  // LOCALE
  Locale _locale = const Locale('tr');
  Locale get locale => _locale;
  void setLocale(Locale l) {
    if (_locale == l) return;
    _locale = l;
    notifyListeners();
  }

  // CURRENCY
  String _currency = 'TRY';
  String get currency => _currency;
  void setCurrency(String c) {
    if (_currency == c) return;
    _currency = c;
    notifyListeners();
  }

  // APP BEHAVIOR TOGGLES
  bool _haptics = true;
  bool get haptics => _haptics;
  void setHaptics(bool v) {
    if (_haptics == v) return;
    _haptics = v;
    notifyListeners();
  }

  bool _sfx = true;
  bool get sfx => _sfx;
  void setSfx(bool v) {
    if (_sfx == v) return;
    _sfx = v;
    notifyListeners();
  }

  bool _autoUpdate = true;
  bool get autoUpdate => _autoUpdate;
  void setAutoUpdate(bool v) {
    if (_autoUpdate == v) return;
    _autoUpdate = v;
    notifyListeners();
  }
}
