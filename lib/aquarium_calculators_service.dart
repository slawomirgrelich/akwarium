import 'dart:math' as math;

class AquariumVolumeResult {
  const AquariumVolumeResult({
    required this.grossLiters,
    required this.substrateLiters,
    required this.decorationsLiters,
    required this.netLiters,
    required this.glassVolumeLiters,
    required this.glassWeightKg,
    required this.totalWeightKg,
  });

  final double grossLiters;
  final double substrateLiters;
  final double decorationsLiters;
  final double netLiters;
  final double glassVolumeLiters;
  final double glassWeightKg;
  final double totalWeightKg;
}

class Co2Result {
  const Co2Result({required this.mgPerLiter, required this.status});

  final double mgPerLiter;
  final Co2Status status;
}

enum Co2Status { low, optimal, high }

class FertilizerDoseResult {
  const FertilizerDoseResult({
    required this.ppmPerMl,
    required this.dailyMl,
    required this.weeklyMl,
  });

  final double ppmPerMl;
  final double dailyMl;
  final double weeklyMl;
}

class SaltRecipe {
  const SaltRecipe({required this.name, required this.element, required this.factor});

  final String name;
  final String element;
  final double factor;
}

const saltRecipes = <SaltRecipe>[
  SaltRecipe(name: 'KNO3', element: 'NO3', factor: 0.613),
  SaltRecipe(name: 'KH2PO4', element: 'PO4', factor: 0.698),
  SaltRecipe(name: 'K2SO4', element: 'K', factor: 0.448),
  SaltRecipe(name: 'MgSO4 x 7H2O', element: 'Mg', factor: 0.0986),
];

AquariumVolumeResult calculateVolume({
  required double lengthCm,
  required double widthCm,
  required double heightCm,
  required double substrateThicknessCm,
  required double decorationPercent,
  double glassThicknessCm = 0,
}) {
  final gross = lengthCm * widthCm * heightCm / 1000;
  final innerLength = math.max(0.0, lengthCm - 2 * glassThicknessCm);
  final innerWidth = math.max(0.0, widthCm - 2 * glassThicknessCm);
  final innerHeight = math.max(0.0, heightCm - 2 * glassThicknessCm);
  final innerGross = innerLength * innerWidth * innerHeight / 1000;
  final substrate = innerLength * innerWidth * substrateThicknessCm / 1000;
  final decorations = math.max(0.0, gross - substrate) * decorationPercent / 100;
  final net = math.max(0.0, innerGross - substrate - decorations).toDouble();
  final glassVolume = math.max(0.0, gross - innerGross).toDouble();
  final glassWeight = glassVolume * 2.5;
  final substrateWeight = substrate * 1.5;
  final decorationsWeight = decorations * 2.0;
  final totalWeight = net + glassWeight + substrateWeight + decorationsWeight;
  return AquariumVolumeResult(
    grossLiters: gross,
    substrateLiters: substrate,
    decorationsLiters: decorations,
    netLiters: net,
    glassVolumeLiters: glassVolume,
    glassWeightKg: glassWeight,
    totalWeightKg: totalWeight,
  );
}

Co2Result calculateCo2({required double ph, required double kh}) {
  final co2 = 3.0 * kh * math.pow(10, 7.0 - ph).toDouble();
  final status = co2 < 15
      ? Co2Status.low
      : co2 <= 30
      ? Co2Status.optimal
      : Co2Status.high;
  return Co2Result(mgPerLiter: co2, status: status);
}

FertilizerDoseResult calculateFertilizerDose({
  required double aquariumLiters,
  required double solutionMl,
  required double saltGrams,
  required double targetPpm,
  required double saltFactor,
}) {
  if (aquariumLiters <= 0 || solutionMl <= 0 || saltGrams < 0) {
    return const FertilizerDoseResult(ppmPerMl: 0, dailyMl: 0, weeklyMl: 0);
  }
  final ppmPerMl = saltGrams * 1000 * saltFactor / solutionMl / aquariumLiters;
  final weeklyMl = ppmPerMl <= 0 ? 0.0 : targetPpm / ppmPerMl;
  return FertilizerDoseResult(
    ppmPerMl: ppmPerMl,
    dailyMl: weeklyMl / 7,
    weeklyMl: weeklyMl,
  );
}