import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/water_parameters_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders historical measurements as a line chart', (
    tester,
  ) async {
    final provider = AquariumProvider(
      activeAquariumId: 'tank-1',
      waterTests: [
        _test(
          id: 'older',
          date: DateTime(2026, 1, 1),
          ph: 6.8,
          no2: 0.05,
          co2: 22,
          nh3Nh4: 0.2,
          tds: 175,
        ),
        _test(
          id: 'newer',
          date: DateTime(2026, 1, 2),
          ph: 7.1,
          no2: 0.1,
          co2: 25,
          nh3Nh4: 0.3,
          tds: 185,
        ),
      ],
    );
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: SingleChildScrollView(child: WaterParametersChart()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Water parameter history'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('NO3'), findsOneWidget);
    expect(find.text('NO2'), findsOneWidget);
    expect(find.text('PO4'), findsOneWidget);
    expect(find.text('CO2'), findsOneWidget);
    expect(find.text('NH3/NH4'), findsOneWidget);
    expect(find.text('TDS'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'CO2'));
    await tester.pumpAndSettle();

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.lineBarsData.single.spots.map((spot) => spot.y), [
      25,
      22,
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
      [0.1, 0.05],
    );
    expect(find.text('Target: undetectable (0 mg/L)'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'NH3/NH4'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .lineBarsData
          .single
          .spots
          .map((spot) => spot.y),
      [0.3, 0.2],
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'TDS'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<LineChart>(find.byType(LineChart))
          .data
          .lineBarsData
          .single
          .spots
          .map((spot) => spot.y),
      [185, 175],
    );
    expect(
      find.text(
        'TDS has no universal target; compare it with your livestock and source water.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('uses a compact empty state before two tests are available', (
    tester,
  ) async {
    final provider = AquariumProvider(
      activeAquariumId: 'tank-1',
      waterTests: [_test(id: 'only', date: DateTime(2026, 1, 1), ph: 6.8)],
    );
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: SingleChildScrollView(child: WaterParametersChart()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsNothing);
    expect(
      find.text('Add at least two measurements to see the chart.'),
      findsOneWidget,
    );
    expect(tester.getSize(find.byType(Card)).height, lessThan(180));
  });
}

WaterTest _test({
  required String id,
  required DateTime date,
  required double ph,
  double? no2,
  double? co2,
  double? nh3Nh4,
  double? tds,
}) {
  return WaterTest(
    id: id,
    date: date,
    ph: ph,
    no3: 15,
    no2: no2,
    po4: 1,
    fe: 0.2,
    kh: 5,
    gh: 8,
    temp: 25,
    co2: co2,
    nh3Nh4: nh3Nh4,
    tds: tds,
    aquariumId: 'tank-1',
  );
}
