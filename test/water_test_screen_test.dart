import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/services/experience_mode_controller.dart';
import 'package:akwarium/water_test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('saves only entered values without enforcing target ranges', (
    tester,
  ) async {
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'tank-1',
          name: 'Test aquarium',
          volumeNetLiters: 40,
          setupDate: DateTime(2026),
          type: TankType.freshwater,
        ),
      ],
      activeAquariumId: 'tank-1',
    );
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<ExperienceModeController>.value(
        value: ExperienceModeController(),
        child: ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const WaterTestScreen(),
          ),
        ),
      ),
    );

    expect(find.text('mg/L'), findsNWidgets(3));
    expect(find.text('ppm'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '12.7');
    await tester.enterText(find.widgetWithText(TextFormField, 'NO2'), '0.05');
    await tester.enterText(find.widgetWithText(TextFormField, 'CO2'), '22.5');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ammonia (NH3/NH4)'),
      '0.2',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'TDS'), '185');
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    await tester.ensureVisible(find.text('Save measurement'));
    await tester.tap(find.text('Save measurement'));
    await tester.pumpAndSettle();

    expect(provider.waterTests, hasLength(1));
    expect(provider.waterTests.single.ph, 12.7);
    expect(provider.waterTests.single.no3, isNull);
    expect(provider.waterTests.single.no2, 0.05);
    expect(provider.waterTests.single.po4, isNull);
    expect(provider.waterTests.single.co2, 22.5);
    expect(provider.waterTests.single.nh3Nh4, 0.2);
    expect(provider.waterTests.single.tds, 185);
    expect(provider.waterTests.single.fe, isNull);
    expect(provider.waterTests.single.kh, isNull);
    expect(provider.waterTests.single.gh, isNull);
    expect(provider.waterTests.single.temp, isNull);
  });

  testWidgets('water test form scrolls on a compact viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'tank-1',
          name: 'Test aquarium',
          volumeNetLiters: 40,
          setupDate: DateTime(2026),
          type: TankType.freshwater,
        ),
      ],
      activeAquariumId: 'tank-1',
    );
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<ExperienceModeController>.value(
        value: ExperienceModeController(),
        child: ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: const WaterTestScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save measurement'));
    expect(tester.takeException(), isNull);
    expect(find.text('Save measurement'), findsOneWidget);
  });
}
