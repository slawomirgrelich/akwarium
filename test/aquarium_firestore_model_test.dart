import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/models/aquarium_firestore_model.dart';

void main() {
  group('WaterParametersModel NO2 compatibility', () {
    test('keeps legacy measurements without a NO2 value', () {
      final measurement = WaterParametersModel.fromMap(const {'no3': 15});

      expect(measurement.no2, isNull);
      expect(measurement.toMap(), isNot(contains('no2')));
    });

    test('round-trips an explicitly recorded NO2 value', () {
      final measurement = WaterParametersModel.fromMap(const {'no2': 0.05});

      expect(measurement.no2, 0.05);
      expect(
        WaterParametersModel.fromMap(measurement.toMap()).no2,
        0.05,
      );
    });
  });
}
