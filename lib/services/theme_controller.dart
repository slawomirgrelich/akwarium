import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({this.preferences});

  static const themeModeKey = 'theme_mode';

  final SharedPreferences? preferences;
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _loadedPreferences;

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final preferences = _loadedPreferences ??=
        this.preferences ?? await SharedPreferences.getInstance();
    final savedMode = preferences.getString(themeModeKey);
    _themeMode = switch (savedMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final preferences = _loadedPreferences ??=
        this.preferences ?? await SharedPreferences.getInstance();
    await preferences.setString(themeModeKey, mode.name);
  }
}
