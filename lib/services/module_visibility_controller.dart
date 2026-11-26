import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppModule {
  waterTests,
  partners,
  community,
  templates,
  calculators,
  speciesAtlas,
  aiScanner,
  algaeAssistant,
}

class ModuleVisibilityController extends ChangeNotifier {
  ModuleVisibilityController({this.preferences});

  static const keyPrefix = 'module_visible_';
  static const List<AppModule> optionalModules = AppModule.values;

  final SharedPreferences? preferences;
  SharedPreferences? _loadedPreferences;
  final Map<AppModule, bool> _visibility = {
    for (final module in AppModule.values) module: true,
  };

  bool isVisible(AppModule module) => _visibility[module] ?? true;

  Future<void> init() async {
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    for (final module in AppModule.values) {
      _visibility[module] =
          stored.getBool('$keyPrefix${module.name}') ?? true;
    }
    notifyListeners();
  }

  Future<void> setVisible(AppModule module, bool visible) async {
    if (_visibility[module] == visible) return;
    _visibility[module] = visible;
    notifyListeners();
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    await stored.setBool('$keyPrefix${module.name}', visible);
  }

  Future<void> showAll() async {
    final changed = AppModule.values
        .where((module) => _visibility[module] != true)
        .toList(growable: false);
    if (changed.isEmpty) return;
    for (final module in AppModule.values) {
      _visibility[module] = true;
    }
    notifyListeners();
    final stored = _loadedPreferences ??=
        preferences ?? await SharedPreferences.getInstance();
    for (final module in AppModule.values) {
      await stored.setBool('$keyPrefix${module.name}', true);
    }
  }
}
