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

  test('accounts for glass thickness and estimates total weight', () {
    final result = calculateVolume(
      lengthCm: 100,
      widthCm: 40,
      heightCm: 45,
      glassThicknessCm: 0.6,
      substrateThicknessCm: 5,
      decorationPercent: 10,
    );

    expect(result.glassVolumeLiters, greaterThan(0));
    expect(result.glassWeightKg, greaterThan(0));
    expect(result.totalWeightKg, greaterThan(result.netLiters));
  });

  test('calculates decoration displacement from internal aquarium volume', () {
    final result = calculateVolume(
      lengthCm: 100,
      widthCm: 40,
      heightCm: 45,
      glassThicknessCm: 0.6,
      substrateThicknessCm: 5,
      decorationPercent: 10,
    );

    expect(result.decorationsLiters, closeTo(14.8737472, 0.001));
  });

  test('rejects invalid tank volume inputs', () {
    expect(
      () => calculateVolume(
        lengthCm: 0,
        widthCm: 40,
        heightCm: 45,
        substrateThicknessCm: 5,
        decorationPercent: 10,
      ),
      throwsArgumentError,
    );
  });

  test('classifies CO2 zones', () {
    expect(calculateCo2(ph: 7, kh: 5).status, Co2Status.optimal);
    expect(calculateCo2(ph: 8, kh: 1).status, Co2Status.low);
    expect(calculateCo2(ph: 6, kh: 10).status, Co2Status.high);
  });

  test('maps high CO2 values to the risk end of the scale', () {
    expect(co2ScalePosition(15), closeTo(1 / 3, 0.0001));
    expect(co2ScalePosition(30), closeTo(2 / 3, 0.0001));
    expect(co2ScalePosition(40), greaterThan(co2ScalePosition(30)));
    expect(co2ScalePosition(60), 1);
    expect(() => co2ScalePosition(double.nan), throwsArgumentError);
  });

  test('converts water-change percentages using net aquarium volume', () {
    expect(suggestedWaterChangeLiters(20), 20);
    expect(suggestedWaterChangeLiters(100), 30);
    expect(
      waterChangeVolumeLiters(
        amount: 30,
        netVolumeLiters: 240,
        isPercent: true,
      ),
      72,
    );
    expect(
      waterChangeVolumeLiters(
        amount: 30,
        netVolumeLiters: 240,
        isPercent: false,
      ),
      30,
    );
    expect(
      () => waterChangeVolumeLiters(
        amount: 101,
        netVolumeLiters: 240,
        isPercent: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => waterChangeVolumeLiters(
        amount: 30,
        netVolumeLiters: 20,
        isPercent: false,
      ),
      throwsArgumentError,
    );
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

  test('supports iron and magnesium salt recipes', () {
    expect(
      saltRecipes.map((recipe) => recipe.element),
      containsAll(['Fe', 'Mg']),
    );
    final result = calculateFertilizerDose(
      aquariumLiters: 100,
      solutionMl: 500,
      saltGrams: 50,
      targetPpm: 1,
      saltFactor: saltRecipes
          .firstWhere((recipe) => recipe.element == 'Fe')
          .factor,
    );

    expect(result.ppmPerMl, greaterThan(0));
    expect(result.weeklyMl, greaterThan(0));
  });

  test('rejects invalid fertilizer dose inputs', () {
    expect(
      () => calculateFertilizerDose(
        aquariumLiters: 0,
        solutionMl: 500,
        saltGrams: 50,
        targetPpm: 10,
        saltFactor: 0.613,
      ),
      throwsArgumentError,
    );
  });
}
