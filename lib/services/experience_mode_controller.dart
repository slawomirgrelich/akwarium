import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ExperienceMode { beginner, advanced }

class ExperienceModeController extends ChangeNotifier {
  ExperienceModeController({this.preferences});

  static const experienceModeKey = 'experience_mode';
  static const beginnerGuideCompletedKey = 'beginner_guide_completed';

  final SharedPreferences? preferences;
  SharedPreferences? _loadedPreferences;
  ExperienceMode _mode = ExperienceMode.beginner;
  bool _beginnerGuideCompleted = false;
  bool _initialized = false;

  ExperienceMode get mode => _mode;
  bool get isBeginner => _mode == ExperienceMode.beginner;
  bool get beginnerGuideCompleted => _beginnerGuideCompleted;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    _mode = switch (stored.getString(experienceModeKey)) {
      'advanced' => ExperienceMode.advanced,
      _ => ExperienceMode.beginner,
    };
    _beginnerGuideCompleted =
        stored.getBool(beginnerGuideCompletedKey) ?? false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setMode(ExperienceMode mode) async {
    _mode = mode;
    notifyListeners();
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    await stored.setString(experienceModeKey, mode.name);
  }

  Future<void> completeBeginnerGuide() async {
    if (_beginnerGuideCompleted) return;
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    await stored.setBool(beginnerGuideCompletedKey, true);
    _beginnerGuideCompleted = true;
    _initialized = true;
    notifyListeners();
  }
}
