import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/services/experience_mode_controller.dart';

void main() {
  test('defaults to beginner mode and persists the selected mode', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final controller = ExperienceModeController(preferences: preferences);

    await controller.init();
    expect(controller.mode, ExperienceMode.beginner);
    expect(controller.isBeginner, isTrue);
    expect(controller.modeOnboardingCompleted, isFalse);

    await controller.setMode(ExperienceMode.advanced);
    final restartedController = ExperienceModeController(
      preferences: preferences,
    );
    await restartedController.init();

    expect(restartedController.mode, ExperienceMode.advanced);
    expect(restartedController.isBeginner, isFalse);
  });

  test('persists beginner guide completion across app restarts', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final controller = ExperienceModeController(preferences: preferences);

    await controller.init();
    expect(controller.isInitialized, isTrue);
    expect(controller.beginnerGuideCompleted, isFalse);

    await controller.completeBeginnerGuide();

    final restartedController = ExperienceModeController(
      preferences: preferences,
    );
    await restartedController.init();

    expect(restartedController.beginnerGuideCompleted, isTrue);
    expect(restartedController.modeOnboardingCompleted, isTrue);
  });

  test('persists mode onboarding independently from beginner guide', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final controller = ExperienceModeController(preferences: preferences);
    await controller.init();

    await controller.setMode(ExperienceMode.advanced);
    await controller.completeModeOnboarding();

    final restartedController = ExperienceModeController(
      preferences: preferences,
    );
    await restartedController.init();
    expect(restartedController.mode, ExperienceMode.advanced);
    expect(restartedController.modeOnboardingCompleted, isTrue);
    expect(restartedController.beginnerGuideCompleted, isFalse);
  });
}
