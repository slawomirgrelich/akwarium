import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/aquarium_management_screen.dart';
import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/services/experience_mode_controller.dart';
import 'package:akwarium/widgets/experience_mode_banner.dart';

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

    expect(find.byType(TextField), findsNWidgets(7));
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

  testWidgets('new tank help text stays separated at large text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider<ExperienceModeController>.value(
        value: ExperienceModeController(preferences: preferences),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
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
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final dialogContext = tester.element(find.byType(AddAquariumModal));
    final l10n = AppLocalizations.of(dialogContext)!;
    final dimensionHelp = find.text(l10n.beginnerDimensionHint);
    final firstDimensionField = find.byType(TextField).at(1);
    final netHelp = find.text(l10n.beginnerNetVolumeHint);
    final typeField = find.byType(DropdownButtonFormField<TankType>);

    expect(
      tester.getBottomRight(dimensionHelp).dy,
      lessThanOrEqualTo(tester.getTopLeft(firstDimensionField).dy),
    );
    expect(
      tester.getBottomRight(netHelp).dy,
      lessThanOrEqualTo(tester.getTopLeft(typeField).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mode onboarding remains usable at large text scale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider<ExperienceModeController>.value(
        value: ExperienceModeController(preferences: preferences),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: ExperienceModeOnboardingCard(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final cardContext = tester.element(
      find.byType(ExperienceModeOnboardingCard),
    );
    final l10n = AppLocalizations.of(cardContext)!;
    expect(find.byType(ExperienceModeOnboardingCard), findsOneWidget);
    expect(find.text(l10n.advancedMode), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
