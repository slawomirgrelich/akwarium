import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/models/water_test_model.dart';
import 'package:akwarium/models/tank_firestore_models.dart' as tank_models;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy local water tests load without new optional readings', () {
    final test = WaterTest.fromMap({
      'id': 'legacy',
      'aquariumId': 'tank-1',
      'date': DateTime(2026, 1, 1).toIso8601String(),
      'ph': 7,
    });

    expect(test.co2, isNull);
    expect(test.no2, isNull);
    expect(test.nh3Nh4, isNull);
    expect(test.tds, isNull);
    expect(test.toMap(), isNot(contains('co2')));
    expect(test.toMap(), isNot(contains('no2')));
    expect(test.toMap(), isNot(contains('nh3Nh4')));
    expect(test.toMap(), isNot(contains('tds')));
  });

  test('local water tests persist NO2, CO2, ammonia and TDS', () {
    final test = WaterTest(
      id: 'co2-test',
      aquariumId: 'tank-1',
      date: DateTime(2026, 1, 1),
      no2: 0.1,
      co2: 22.5,
      nh3Nh4: 0.2,
      tds: 185,
    );

    final restored = WaterTest.fromMap(test.toMap());
    expect(restored.no2, 0.1);
    expect(restored.co2, 22.5);
    expect(restored.nh3Nh4, 0.2);
    expect(restored.tds, 185);
    expect(waterTestSummary(restored), contains('NH3/NH4 0.2 mg/L'));
    expect(waterTestSummary(restored), contains('TDS 185.0 ppm'));
  });

  test('standalone measurement model preserves optional readings', () {
    final legacy = WaterTestModel.fromMap({
      'id': 'legacy',
      'aquariumId': 'tank-1',
      'recordedAt': DateTime(2026, 1, 1).toIso8601String(),
    });
    final measured = WaterTestModel.fromMap({
      ...legacy.toMap(),
      'no2': 0.1,
      'co2': 22.5,
    });

    expect(legacy.co2, isNull);
    expect(legacy.no2, isNull);
    expect(legacy.nh3Nh4, isNull);
    expect(legacy.tds, isNull);
    expect(measured.co2, 22.5);
    expect(measured.no2, 0.1);
    final readings = WaterTestModel.fromMap({
      ...legacy.toMap(),
      'nh3Nh4': 0.2,
      'tds': 185,
    });
    expect(readings.nh3Nh4, 0.2);
    expect(readings.tds, 185);
    expect(WaterTestModel.fromMap(measured.toMap()).co2, 22.5);
    expect(WaterTestModel.fromMap(measured.toMap()).no2, 0.1);
    expect(WaterTestModel.fromMap(readings.toMap()).nh3Nh4, 0.2);
    expect(WaterTestModel.fromMap(readings.toMap()).tds, 185);
  });

  test(
    'Firestore water readings preserve old maps and round-trip all fields',
    () {
      final legacy = WaterParametersModel.fromMap(const {'ph': 7});
      final measured = WaterParametersModel.fromMap(const {
        'co2': 22.5,
        'no2': 0.1,
        'nh3Nh4': 0.2,
        'tds': 185,
      });

      expect(legacy.co2, isNull);
      expect(legacy.no2, isNull);
      expect(legacy.nh3Nh4, isNull);
      expect(legacy.tds, isNull);
      expect(legacy.toMap(), isNot(contains('co2')));
      expect(legacy.toMap(), isNot(contains('no2')));
      expect(legacy.toMap(), isNot(contains('nh3Nh4')));
      expect(legacy.toMap(), isNot(contains('tds')));
      final restored = WaterParametersModel.fromMap(measured.toMap());
      expect(restored.co2, 22.5);
      expect(restored.no2, 0.1);
      expect(restored.nh3Nh4, 0.2);
      expect(restored.tds, 185);
      expect(measured.copyWith().nh3Nh4, 0.2);
      expect(measured.copyWith().tds, 185);
    },
  );

  test('legacy tank Firestore measurements accept optional readings', () {
    final oldMeasurement = _tankMeasurement();
    final measured = _tankMeasurement(
      no2: 0.05,
      co2: 22.5,
      nh3Nh4: 0.2,
      tds: 185,
    );

    expect(oldMeasurement.toFirestore(), isNot(contains('no2')));
    expect(oldMeasurement.toFirestore(), isNot(contains('co2')));
    expect(oldMeasurement.toFirestore(), isNot(contains('nh3Nh4')));
    expect(oldMeasurement.toFirestore(), isNot(contains('tds')));
    expect(measured.no2, 0.05);
    expect(measured.co2, 22.5);
    expect(measured.nh3Nh4, 0.2);
    expect(measured.tds, 185);
    expect(measured.toFirestore()['no2'], 0.05);
    expect(measured.toFirestore()['co2'], 22.5);
    expect(measured.toFirestore()['nh3Nh4'], 0.2);
    expect(measured.toFirestore()['tds'], 185);
  });
}

tank_models.WaterParameter _tankMeasurement({
  double? no2,
  double? co2,
  double? nh3Nh4,
  double? tds,
}) => tank_models.WaterParameter(
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
  no2: no2,
  co2: co2,
  nh3Nh4: nh3Nh4,
  tds: tds,
);
