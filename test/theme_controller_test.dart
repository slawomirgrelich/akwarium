import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/services/theme_controller.dart';

void main() {
  test('persists and restores the selected theme mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController(preferences: preferences);

    await controller.setThemeMode(ThemeMode.dark);

    final restartedController = ThemeController(preferences: preferences);
    await restartedController.init();

    expect(restartedController.themeMode, ThemeMode.dark);
  });
}
