import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/main.dart' show WaterParametersCard;
import 'package:akwarium/models/aquarium_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('warning parameters are highlighted and open details', (
    tester,
  ) async {
    final test = WaterTest(
      id: 'test',
      aquariumId: 'tank',
      date: DateTime(2026, 1, 2),
      ph: 7,
      no3: 55,
      no2: 0.1,
      po4: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        theme: ThemeData(useMaterial3: true),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: WaterParametersCard(test: test)),
      ),
    );
    await tester.pump();

    final no3 = find.textContaining('55.0 mg/l');
    expect(no3, findsOneWidget);
    final no3Chip = find.ancestor(of: no3, matching: find.byType(InkWell));
    expect(no3Chip, findsOneWidget);
    expect(
      find.descendant(of: no3Chip, matching: find.byIcon(Icons.error_outline)),
      findsOneWidget,
    );

    await tester.tap(no3Chip);
    await tester.pumpAndSettle();
    expect(find.text('NO3'), findsWidgets);
    expect(find.text('Zalecany zakres'), findsOneWidget);
    expect(find.text('Jak skorygować'), findsOneWidget);
  });
}
