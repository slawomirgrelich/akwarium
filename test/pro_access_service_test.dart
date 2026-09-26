import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/services/pro_access_service.dart';

void main() {
  test('clears PRO activation when no account is signed in', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(ProAccessService.proStatusKey, true);

    final restartedService = ProAccessService(preferences: preferences);
    await restartedService.init();

    expect(restartedService.isProUser, isFalse);
  });
}
