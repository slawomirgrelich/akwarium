import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/models/aquarium_firestore_model.dart';
import 'package:akwarium/models/aquarium_model.dart' as local_models;

void main() {
  group('Aquarium setup details compatibility', () {
    test('loads older Firestore tanks without optional setup details', () {
      final aquarium = AquariumModel.fromMap(const {
        'id': 'legacy',
        'name': 'Legacy tank',
        'type': 'freshwater',
      });

      expect(aquarium.lengthCm, isNull);
      expect(aquarium.widthCm, isNull);
      expect(aquarium.heightCm, isNull);
      expect(aquarium.equipment, isNull);
    });

    test('round-trips tank dimensions and lighting hours to Firestore', () {
      final aquarium = AquariumModel(
        id: 'tank-1',
        name: 'Test tank',
        type: 'freshwater',
        lengthCm: 60,
        widthCm: 30,
        heightCm: 36,
        equipment: const AquariumEquipment(lightingHoursPerDay: 7),
      );

      final restored = AquariumModel.fromMap(aquarium.toMap());

      expect(restored.lengthCm, 60);
      expect(restored.widthCm, 30);
      expect(restored.heightCm, 36);
      expect(restored.equipment?.lightingHoursPerDay, 7);
    });

    test('round-trips beginner setup details in the local profile', () {
      final aquarium = local_models.AquariumProfile(
        id: 'tank-1',
        name: 'Test tank',
        volumeNetLiters: 54,
        setupDate: DateTime(2026),
        type: local_models.TankType.freshwater,
        lengthCm: 60,
        widthCm: 30,
        heightCm: 36,
        lighting: '7',
      );

      final restored = local_models.AquariumProfile.fromJson(aquarium.toJson());

      expect(restored.lengthCm, 60);
      expect(restored.widthCm, 30);
      expect(restored.heightCm, 36);
      expect(restored.lighting, '7');
    });
  });

  group('WaterParametersModel NO2 compatibility', () {
    test('keeps legacy measurements without a NO2 value', () {
      final measurement = WaterParametersModel.fromMap(const {'no3': 15});

      expect(measurement.no2, isNull);
      expect(measurement.toMap(), isNot(contains('no2')));
    });

    test('round-trips an explicitly recorded NO2 value', () {
      final measurement = WaterParametersModel.fromMap(const {'no2': 0.05});

      expect(measurement.no2, 0.05);
      expect(WaterParametersModel.fromMap(measurement.toMap()).no2, 0.05);
    });
  });

  group('WaterParametersModel CO2 compatibility', () {
    test('keeps legacy measurements without a CO2 value', () {
      final measurement = WaterParametersModel.fromMap(const {'no3': 15});

      expect(measurement.co2, isNull);
      expect(measurement.toMap(), isNot(contains('co2')));
    });

    test('round-trips an explicitly recorded CO2 value in mg/L', () {
      final measurement = WaterParametersModel.fromMap(const {'co2': 22.5});

      expect(measurement.co2, 22.5);
      expect(WaterParametersModel.fromMap(measurement.toMap()).co2, 22.5);
    });
  });
}
