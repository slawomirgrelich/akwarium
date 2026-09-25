import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/services/aquarium_diagnostic_service.dart';

void main() {
  final service = AquariumDiagnosticService();

  test('wykrywa ryzyko sinic przy braku NO3', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 7,
        no3: 2,
        po4: 1,
        co2Ppm: 20,
        previousPh: 7,
        lightHours: 8,
      ),
    );

    expect(result.findings.any((item) => item.title == 'Ryzyko sinic'), true);
  });

  test('wykrywa ryzyko zielenic przy braku PO4', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 7,
        no3: 20,
        po4: 0.05,
        co2Ppm: 20,
        previousPh: 7,
        lightHours: 8,
      ),
    );

    expect(result.findings.any((item) => item.title == 'Ryzyko zielenic'), true);
  });

  test('łączy wysokie CO2 i wahanie pH z ostrzeżeniem', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 6.5,
        no3: 15,
        po4: 1,
        co2Ppm: 35,
        previousPh: 7,
        lightHours: 10,
      ),
    );

    expect(
      result.findings.map((item) => item.title),
      containsAll(['Niebezpieczny poziom CO2', 'Ryzyko krasnorostów']),
    );
    expect(result.actionPlan, isNotEmpty);
  });
}