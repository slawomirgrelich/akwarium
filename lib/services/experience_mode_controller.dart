import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ExperienceMode { beginner, advanced }

class ExperienceModeController extends ChangeNotifier {
  ExperienceModeController({this.preferences});

  static const experienceModeKey = 'experience_mode';

  final SharedPreferences? preferences;
  SharedPreferences? _loadedPreferences;
  ExperienceMode _mode = ExperienceMode.beginner;

  ExperienceMode get mode => _mode;
  bool get isBeginner => _mode == ExperienceMode.beginner;

  Future<void> init() async {
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    _mode = switch (stored.getString(experienceModeKey)) {
      'advanced' => ExperienceMode.advanced,
      _ => ExperienceMode.beginner,
    };
    notifyListeners();
  }

  Future<void> setMode(ExperienceMode mode) async {
    _mode = mode;
    notifyListeners();
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    await stored.setString(experienceModeKey, mode.name);
  }
}
