import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/aquarium_management_screen.dart';
import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/services/experience_mode_controller.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('new tank dialog stays usable on a compact display', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(300, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final modeController = ExperienceModeController(preferences: preferences);

    await tester.pumpWidget(
      ChangeNotifierProvider<ExperienceModeController>.value(
        value: modeController,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const AddAquariumModal(),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(AddAquariumModal), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsNWidgets(6));
    await tester.enterText(find.byType(TextField).at(1), '60');
    await tester.enterText(find.byType(TextField).at(2), '30');
    await tester.enterText(find.byType(TextField).at(3), '36');
    await tester.pumpAndSettle();
    expect(find.textContaining('64.8'), findsOneWidget);

    await modeController.setMode(ExperienceMode.advanced);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('add species dialog wraps controls on a compact display', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(300, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const AddInhabitantModal(),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
