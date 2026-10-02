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
        _test(id: 'older', date: DateTime(2026, 1, 1), ph: 6.8),
        _test(id: 'newer', date: DateTime(2026, 1, 2), ph: 7.1),
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
          home: const Scaffold(body: WaterParametersChart()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Water parameter history'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('NO3'), findsOneWidget);
    expect(find.text('PO4'), findsOneWidget);
  });
}

WaterTest _test({
  required String id,
  required DateTime date,
  required double ph,
}) {
  return WaterTest(
    id: id,
    date: date,
    ph: ph,
    no3: 15,
    po4: 1,
    fe: 0.2,
    kh: 5,
    gh: 8,
    temp: 25,
    aquariumId: 'tank-1',
  );
}
