import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/services/aquarium_diagnostic_service.dart';
import 'package:akwarium/utils/aquarium_diagnostic_localization.dart';
import 'package:flutter/widgets.dart';

void main() {
  final service = AquariumDiagnosticService();

  test('wykrywa ryzyko sinic przy braku NO3', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 7,
        no3: 2,
        po4: 1,
        co2MgPerLiter: 20,
        previousPh: 7,
        lightHours: 8,
      ),
    );

    expect(
      result.findings.any(
        (item) =>
            item.key == AquariumDiagnosticFindingKey.cyanobacteriaRisk,
      ),
      true,
    );
  });

  test('wykrywa ryzyko zielenic przy braku PO4', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 7,
        no3: 20,
        po4: 0.05,
        co2MgPerLiter: 20,
        previousPh: 7,
        lightHours: 8,
      ),
    );

    expect(
      result.findings.any(
        (item) => item.key == AquariumDiagnosticFindingKey.greenAlgaeRisk,
      ),
      true,
    );
  });

  test('łączy wysokie CO2 i wahanie pH z ostrzeżeniem', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 6.5,
        no3: 15,
        po4: 1,
        co2MgPerLiter: 35,
        previousPh: 7,
        lightHours: 10,
      ),
    );

    expect(
      result.findings.map((item) => item.key),
      containsAll([
        AquariumDiagnosticFindingKey.dangerousCo2,
        AquariumDiagnosticFindingKey.redAlgaeRisk,
      ]),
    );
    expect(result.actionPlan, isNotEmpty);
  });

  test('lokalizuje ostrzeżenia i zalecenia diagnostyczne', () async {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 7,
        no3: 2,
        po4: 1,
        co2MgPerLiter: 20,
        previousPh: 7,
        lightHours: 8,
      ),
    );
    final finding = result.findings.first;
    final english = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      diagnosticFindingTitle(english, finding.key),
      'Cyanobacteria risk',
    );
    expect(
      diagnosticFindingMessage(english, finding.key),
      'Very low NO3 with the current PO4 level may encourage cyanobacteria.',
    );
    expect(
      diagnosticAction(english, result.actionPlan.first),
      'Restore a measurable, stable NO3 level without sudden fertilization.',
    );
  });

  test('pomija diagnozę CO2, gdy pomiaru brakuje', () {
    final result = service.diagnose(
      const AquariumDiagnosticInput(
        ph: 7,
        no3: 15,
        po4: 1,
        previousPh: 7,
        lightHours: 8,
      ),
    );

    expect(
      result.findings.map((item) => item.key),
      isNot(contains(AquariumDiagnosticFindingKey.lowCo2)),
    );
    expect(
      result.findings.map((item) => item.key),
      isNot(contains(AquariumDiagnosticFindingKey.dangerousCo2)),
    );
  });
}