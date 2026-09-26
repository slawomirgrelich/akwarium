import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/services/pro_access_service.dart';

void main() {
  test('clears PRO activation when no account is signed in', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final service = ProAccessService(preferences: preferences);

    await service.activateFreeTrial();

    expect(preferences.getBool(ProAccessService.proStatusKey), isTrue);

    final restartedService = ProAccessService(preferences: preferences);
    await restartedService.init();

    expect(restartedService.isProUser, isFalse);
  });
}
