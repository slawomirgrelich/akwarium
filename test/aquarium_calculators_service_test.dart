import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/aquarium_calculators_service.dart';

void main() {
  test('calculates gross, substrate and net aquarium volume', () {
    final result = calculateVolume(
      lengthCm: 100,
      widthCm: 40,
      heightCm: 45,
      substrateThicknessCm: 5,
      decorationPercent: 10,
    );

    expect(result.grossLiters, 180);
    expect(result.substrateLiters, 20);
    expect(result.decorationsLiters, 16);
    expect(result.netLiters, 144);
  });

  test('classifies CO2 zones', () {
    expect(calculateCo2(ph: 7, kh: 5).status, Co2Status.optimal);
    expect(calculateCo2(ph: 8, kh: 1).status, Co2Status.low);
    expect(calculateCo2(ph: 6, kh: 10).status, Co2Status.high);
  });

  test('calculates fertilizer ppm per ml and weekly dose', () {
    final result = calculateFertilizerDose(
      aquariumLiters: 100,
      solutionMl: 500,
      saltGrams: 50,
      targetPpm: 10,
      saltFactor: 0.613,
    );

    expect(result.ppmPerMl, closeTo(0.613, 0.00001));
    expect(result.weeklyMl, closeTo(16.31, 0.01));
    expect(result.dailyMl, closeTo(2.33, 0.01));
  });
}