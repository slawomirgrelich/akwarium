import 'package:akwarium/models/aquarium_firestore_model.dart';
import 'package:akwarium/utils/water_measurement_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 2, 12);
  final measurements = [
    _measurement(now.subtract(const Duration(days: 8))),
    _measurement(now.subtract(const Duration(days: 7))),
    _measurement(now.subtract(const Duration(days: 2))),
    _measurement(now),
    _measurement(now.add(const Duration(minutes: 1))),
  ];

  test('7-day range includes its cutoff and excludes future measurements', () {
    final filtered = filterWaterMeasurementsByRange(
      measurements,
      WaterMeasurementRange.days7,
      now: now,
    );

    expect(filtered, [measurements[1], measurements[2], measurements[3]]);
  });

  test('all history excludes future measurements', () {
    final filtered = filterWaterMeasurementsByRange(
      measurements,
      WaterMeasurementRange.all,
      now: now,
    );

    expect(filtered, measurements.take(4));
  });
}

WaterParametersModel _measurement(DateTime timestamp) => WaterParametersModel(
  id: timestamp.toIso8601String(),
  aquariumId: 'tank-1',
  timestamp: timestamp,
  ph: 7,
  kh: 5,
  gh: 8,
  no3: 15,
  po4: 1,
  fe: 0.1,
  temp: 25,
  notes: '',
);
