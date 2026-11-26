import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/main.dart';
import 'package:akwarium/services/admin_service.dart';
import 'package:akwarium/services/experience_mode_controller.dart';
import 'package:akwarium/services/module_visibility_controller.dart';
import 'package:akwarium/services/pro_access_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('admin user sorting', () {
    final oldest = _user(
      id: 'oldest',
      name: 'Zofia',
      createdAt: DateTime(2024, 1, 1),
      lastActiveAt: DateTime(2026, 1, 1),
    );
    final newest = _user(
      id: 'newest',
      name: 'Adam',
      createdAt: DateTime(2026, 1, 1),
      lastActiveAt: DateTime(2026, 2, 1),
    );
    final legacy = _user(
      id: 'legacy',
      name: 'Legacy',
      createdAt: null,
      lastActiveAt: null,
    );

    test('last active is descending and null dates stay last', () {
      expect(
        sortAdminUsers([
          oldest,
          legacy,
          newest,
        ], AdminUserSort.lastActive).map((user) => user.id),
        ['newest', 'oldest', 'legacy'],
      );
    });

    test('new registrations are descending and null dates stay last', () {
      expect(
        sortAdminUsers([
          oldest,
          legacy,
          newest,
        ], AdminUserSort.newest).map((user) => user.id),
        ['newest', 'oldest', 'legacy'],
      );
    });

    test('alphabetical sorting falls back to email when name is missing', () {
      final emailOnly = _user(
        id: 'email',
        name: '',
        email: 'barbara@example.com',
      );
      expect(
        sortAdminUsers([
          oldest,
          emailOnly,
          newest,
        ], AdminUserSort.alphabetical).map((user) => user.id),
        ['newest', 'email', 'oldest'],
      );
    });
  });

  test('module visibility defaults to true and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final controller = ModuleVisibilityController(preferences: preferences);
    await controller.init();

    expect(controller.isVisible(AppModule.partners), isTrue);
    await controller.setVisible(AppModule.partners, false);
    expect(controller.isVisible(AppModule.partners), isFalse);
    expect(
      preferences.getBool(
        '${ModuleVisibilityController.keyPrefix}${AppModule.partners.name}',
      ),
      isFalse,
    );

    final reloaded = ModuleVisibilityController(preferences: preferences);
    await reloaded.init();
    expect(reloaded.isVisible(AppModule.partners), isFalse);
    await reloaded.showAll();
    expect(AppModule.values.every(reloaded.isVisible), isTrue);
  });

  testWidgets('hidden optional cards disappear immediately from tools', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final visibility = ModuleVisibilityController(preferences: preferences);
    final experience = ExperienceModeController(preferences: preferences);
    await visibility.init();
    await experience.init();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: visibility),
          ChangeNotifierProvider.value(value: experience),
          ChangeNotifierProvider(create: (_) => ProAccessService()),
        ],
        child: MaterialApp(
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ToolsPage(),
        ),
      ),
    );

    expect(find.text('Partnerzy i Twórcy'), findsOneWidget);
    expect(find.text('Testy wody'), findsOneWidget);

    await visibility.setVisible(AppModule.partners, false);
    await visibility.setVisible(AppModule.waterTests, false);
    await tester.pump();

    expect(find.text('Partnerzy i Twórcy'), findsNothing);
    expect(find.text('Testy wody'), findsNothing);
    expect(find.text('Akwaria i obsada'), findsOneWidget);
  });
}

AdminUserRecord _user({
  required String id,
  required String name,
  String email = 'user@example.com',
  DateTime? createdAt,
  DateTime? lastActiveAt,
}) {
  return AdminUserRecord(
    id: id,
    email: email,
    displayName: name,
    isPro: false,
    subscriptionPlan: '',
    proExpiryDate: null,
    successfulReferralsCount: 0,
    adminGrantedPro: false,
    createdAt: createdAt,
    lastActiveAt: lastActiveAt,
    authProviders: const [],
  );
}
