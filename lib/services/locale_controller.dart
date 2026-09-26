import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({this.preferences});

  static const localeKey = 'app_locale';

  final SharedPreferences? preferences;
  SharedPreferences? _loadedPreferences;
  Locale? _locale = const Locale('pl');

  Locale? get locale => _locale;

  Future<void> init() async {
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    final languageCode = stored.getString(localeKey);
    _locale = languageCode == null ? const Locale('pl') : Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    if (locale == null) {
      await stored.remove(localeKey);
    } else {
      await stored.setString(localeKey, locale.languageCode);
    }
  }
}
