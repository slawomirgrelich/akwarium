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
            _measurement(
              'newer',
              DateTime(2026, 1, 2),
              25,
              no2: 0.1,
              nh3Nh4: 0.3,
              tds: 185,
            ),
            _measurement(
              'older',
              DateTime(2026, 1, 1),
              20,
              no2: 0.05,
              nh3Nh4: 0.2,
              tds: 175,
            ),
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

    await tester.tap(find.widgetWithText(ChoiceChip, 'NO2'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .lineBarsData
          .single
          .spots
          .map((spot) => spot.y),
      [0.05, 0.1],
    );
    expect(find.text('Target: undetectable (0 mg/L)'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'NH4 (NH3/NH4)'));
    await tester.pumpAndSettle();
    expect(find.text('Target: undetectable (0 mg/L)'), findsOneWidget);
    expect(
      tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .lineBarsData
          .single
          .spots
          .map((spot) => spot.y),
      [0.2, 0.3],
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'TDS'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'TDS has no universal target; compare it with your livestock and source water.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .lineBarsData
          .single
          .spots
          .map((spot) => spot.y),
      [175, 185],
    );
  });

  testWidgets('missing NO2 values show no data instead of throwing', (
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

    await tester.tap(find.widgetWithText(ChoiceChip, 'NO2'));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Firestore measurement form saves combined ammonia and TDS', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(560, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final service = _TestFirestoreService();
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
            service: service,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'NO2'), '0.05');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ammonia (NH3/NH4)'),
      '0.2',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'TDS'), '185');
    await tester.tap(find.text('Save measurement'));
    await tester.pumpAndSettle();

    expect(service.savedMeasurement?.nh3Nh4, 0.2);
    expect(service.savedMeasurement?.no2, 0.05);
    expect(service.savedMeasurement?.tds, 185);
    expect(tester.takeException(), isNull);
  });
}

WaterParametersModel _measurement(
  String id,
  DateTime timestamp,
  double co2, {
  double? no2,
  double? nh3Nh4,
  double? tds,
}) => WaterParametersModel(
  id: id,
  aquariumId: 'tank-1',
  timestamp: timestamp,
  co2: co2,
  no2: no2,
  nh3Nh4: nh3Nh4,
  tds: tds,
  notes: '',
);

class _TestFirestoreService extends Fake implements FirestoreService {
  _TestFirestoreService([this.measurements = const []]);

  final List<WaterParametersModel> measurements;
  WaterParametersModel? savedMeasurement;

  @override
  Stream<List<WaterParametersModel>> getWaterParameters(String aquariumId) =>
      Stream.value(measurements);

  @override
  Future<void> addWaterParameters(WaterParametersModel params) async {
    savedMeasurement = params;
  }
}
