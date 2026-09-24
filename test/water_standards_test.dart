import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/models/water_standards.dart';

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
    expect(assessWaterValue(WaterParameter.no3, 51).status,
        WaterStatus.critical);
  });

  test('oznacza niski PO4 jako ostrzeżenie', () {
    expect(assessWaterValue(WaterParameter.po4, 0.1).status,
        WaterStatus.warning);
  });

  test('oblicza stosunek Redfielda NO3 do PO4', () {
    expect(redfieldRatio(makeTest()), 16);
  });

  test('zgłasza alert dla stosunku poza zakresem', () {
    expect(latestWaterAlert(makeTest(no3: 16, po4: 0.5))?.message,
        contains('10:1-16:1'));
  });
}