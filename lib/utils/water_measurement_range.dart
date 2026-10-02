import '../models/aquarium_firestore_model.dart';

enum WaterMeasurementRange { days7, days30, days90, all }

List<WaterParametersModel> filterWaterMeasurementsByRange(
  List<WaterParametersModel> measurements,
  WaterMeasurementRange range, {
  DateTime? now,
}) {
  final end = now ?? DateTime.now();
  final days = switch (range) {
    WaterMeasurementRange.days7 => 7,
    WaterMeasurementRange.days30 => 30,
    WaterMeasurementRange.days90 => 90,
    WaterMeasurementRange.all => null,
  };
  final start = days == null ? null : end.subtract(Duration(days: days));
  return measurements
      .where(
        (measurement) =>
            !measurement.timestamp.isAfter(end) &&
            (start == null || !measurement.timestamp.isBefore(start)),
      )
      .toList(growable: false);
}
