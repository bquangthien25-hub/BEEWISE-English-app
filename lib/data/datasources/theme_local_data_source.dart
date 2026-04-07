import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalDataSource {
  ThemeLocalDataSource(this._prefs);

  static const _key = 'beewise_theme_mode';

  final SharedPreferences _prefs;

  ThemeMode load() {
    final v = _prefs.getString(_key);
    if (v == 'dark') return ThemeMode.dark;
    if (v == 'light') return ThemeMode.light;
    return ThemeMode.dark;
  }

  Future<void> save(ThemeMode mode) async {
    final s = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    await _prefs.setString(_key, s);
  }
}
