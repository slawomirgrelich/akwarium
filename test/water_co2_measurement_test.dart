import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/models/water_test_model.dart';
import 'package:akwarium/models/tank_firestore_models.dart' as tank_models;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy local water tests load without CO2', () {
    final test = WaterTest.fromMap({
      'id': 'legacy',
      'aquariumId': 'tank-1',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'ph': 7,
    });

    expect(test.co2, isNull);
    expect(test.toMap(), isNot(contains('co2')));
  });

  test('local water tests persist nullable CO2 values in mg/L', () {
    final test = WaterTest(
      id: 'co2-test',
      aquariumId: 'tank-1',
      date: DateTime(2026, 1, 1),
      co2: 22.5,
    );

    expect(WaterTest.fromMap(test.toMap()).co2, 22.5);
  });

  test('standalone measurement model remains backward compatible', () {
    final legacy = WaterTestModel.fromMap({
      'id': 'legacy',
      'aquariumId': 'tank-1',
      'recordedAt': DateTime(2026, 1, 1).toIso8601String(),
    });
    final measured = WaterTestModel.fromMap({...legacy.toMap(), 'co2': 22.5});

    expect(legacy.co2, isNull);
    expect(measured.co2, 22.5);
    expect(WaterTestModel.fromMap(measured.toMap()).co2, 22.5);
  });

  test('Firestore water readings preserve old maps and round-trip CO2', () {
    final legacy = WaterParametersModel.fromMap(const {'ph': 7});
    final measured = WaterParametersModel.fromMap(const {'co2': 22.5});

    expect(legacy.co2, isNull);
    expect(legacy.toMap(), isNot(contains('co2')));
    expect(WaterParametersModel.fromMap(measured.toMap()).co2, 22.5);
  });

  test('legacy tank Firestore measurements accept optional CO2', () {
    final oldMeasurement = _tankMeasurement();
    final measured = _tankMeasurement(co2: 22.5);

    expect(oldMeasurement.toFirestore(), isNot(contains('co2')));
    expect(measured.co2, 22.5);
    expect(measured.toFirestore()['co2'], 22.5);
  });
}

tank_models.WaterParameter _tankMeasurement({double? co2}) =>
    tank_models.WaterParameter(
      id: 'measurement',
      timestamp: DateTime(2026, 1, 1),
      pH: 7,
      kh: 5,
      gh: 8,
      no3: 15,
      po4: 1,
      fe: 0.2,
      k: 10,
      mg: 10,
      temp: 25,
      note: '',
      co2: co2,
    );
