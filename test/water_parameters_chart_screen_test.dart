import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_firestore_model.dart';
import 'package:akwarium/screens/water_parameters_chart_screen.dart';
import 'package:akwarium/services/experience_mode_controller.dart';
import 'package:akwarium/services/firestore_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Firestore history chart plots recorded CO2 values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: WaterParametersChartScreen(
          aquarium: AquariumModel(
            id: 'tank-1',
            name: 'Test aquarium',
            type: 'freshwater',
          ),
          service: _TestFirestoreService([
            _measurement('newer', DateTime(2026, 1, 2), 25),
            _measurement('older', DateTime(2026, 1, 1), 20),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'CO2'));
    await tester.pumpAndSettle();

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData.single.spots.map((spot) => spot.y), [
      20,
      25,
    ]);
  });

  testWidgets(
    'Firestore measurement form keeps CO2 reachable while scrolling',
    (tester) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<ExperienceModeController>.value(
          value: ExperienceModeController(),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: FirestoreWaterParametersFormScreen(
              aquarium: AquariumModel(
                id: 'tank-1',
                name: 'Test aquarium',
                type: 'freshwater',
              ),
              service: _TestFirestoreService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('CO2'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('CO2'), findsOneWidget);
      expect(find.text('mg/L'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

WaterParametersModel _measurement(String id, DateTime timestamp, double co2) =>
    WaterParametersModel(
      id: id,
      aquariumId: 'tank-1',
      timestamp: timestamp,
      co2: co2,
      notes: '',
    );

class _TestFirestoreService extends Fake implements FirestoreService {
  _TestFirestoreService([this.measurements = const []]);

  final List<WaterParametersModel> measurements;

  @override
  Stream<List<WaterParametersModel>> getWaterParameters(String aquariumId) =>
      Stream.value(measurements);
}
