import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/models/water_standards.dart';
import 'package:akwarium/utils/water_assessment_localization.dart';

void main() {
  WaterTest makeTest({double no3 = 16, double po4 = 1}) {
    return WaterTest(
      id: 'test',
      date: DateTime(2026, 1, 1),
      ph: 7,
      no3: no3,
      po4: po4,
      fe: 0.2,
      kh: 5,
      gh: 8,
      temp: 25,
    );
  }

  test('oznacza NO3 powyżej 50 jako krytyczne', () {
    expect(
      assessWaterValue(WaterParameter.no3, 51).status,
      WaterStatus.critical,
    );
  });

  test('oznacza niski PO4 jako ostrzeżenie', () {
    expect(
      assessWaterValue(WaterParameter.po4, 0.1).status,
      WaterStatus.warning,
    );
  });

  test('assesses recorded CO2 against the 15-30 mg/L plant range', () {
    expect(assessWaterValue(WaterParameter.co2, 22).status, WaterStatus.good);
    expect(
      assessWaterValue(WaterParameter.co2, 31).status,
      WaterStatus.warning,
    );
  });

  test('oblicza stosunek Redfielda NO3 do PO4', () {
    expect(redfieldRatio(makeTest()), 16);
  });

  test('zgłasza alert dla stosunku poza zakresem', () {
    expect(
      latestWaterAlert(makeTest(no3: 16, po4: 0.5))?.messageKey,
      WaterAssessmentMessageKey.redfieldRatio,
    );
  });

  test('lokalizuje alert NO3:PO4 i jego etykietę w obu językach', () async {
    final alert = latestWaterAlert(makeTest(no3: 16, po4: 0.5))!;
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final polish = await AppLocalizations.delegate.load(const Locale('pl'));

    expect(waterAssessmentLabel(english, alert), 'Warning');
    expect(
      waterAssessmentMessage(english, alert),
      'NO3:PO4 ratio is outside the suggested range of 10:1-16:1.',
    );
    expect(waterAssessmentLabel(polish, alert), 'Uwaga');
    expect(
      waterAssessmentMessage(polish, alert),
      'Stosunek NO3:PO4 poza sugerowanym zakresem 10:1-16:1.',
    );
  });

  test('lokalizuje treść oceny parametru w tooltipie', () async {
    final assessment = assessWaterValue(WaterParameter.no3, 51);
    final english = await AppLocalizations.delegate.load(const Locale('en'));

    expect(
      waterAssessmentMessage(english, assessment),
      'Critical NO3 level. A 30% water change is recommended.',
    );
  });
}
