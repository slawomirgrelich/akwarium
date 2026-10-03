import '../models/species_models.dart';

enum CompatibilityWarningType {
  insufficientVolume,
  temperatureOutsideRange,
  phOutsideRange,
  incompatibleTemperatureRanges,
}

class CompatibilityWarning {
  const CompatibilityWarning({
    required this.type,
    required this.speciesLatinName,
    this.otherSpeciesLatinName,
    this.actualValue,
    this.minimumValue,
    this.maximumValue,
    this.isCritical = false,
  });

  final CompatibilityWarningType type;
  final String speciesLatinName;
  final String? otherSpeciesLatinName;
  final double? actualValue;
  final double? minimumValue;
  final double? maximumValue;
  final bool isCritical;
}

class CompatibilityReport {
  const CompatibilityReport(this.warnings);
  final List<CompatibilityWarning> warnings;
  bool get isCompatible => warnings.isEmpty;
  int get score => (100 - warnings.length * 20).clamp(0, 100);
}

class StockingCompatibilityService {
  CompatibilityReport validate({
    required double volumeLiters,
    required double? temperature,
    required double? pH,
    required List<Species> species,
  }) {
    final warnings = <CompatibilityWarning>[];
    for (final item in species) {
      if (volumeLiters < item.minTankVolumeLiters) {
        warnings.add(
          CompatibilityWarning(
            type: CompatibilityWarningType.insufficientVolume,
            speciesLatinName: item.nameLatin,
            actualValue: volumeLiters,
            minimumValue: item.minTankVolumeLiters.toDouble(),
            isCritical: true,
          ),
        );
      }
      if (temperature != null && !item.tempRange.contains(temperature)) {
        warnings.add(
          CompatibilityWarning(
            type: CompatibilityWarningType.temperatureOutsideRange,
            speciesLatinName: item.nameLatin,
            actualValue: temperature,
            minimumValue: item.tempRange.min,
            maximumValue: item.tempRange.max,
          ),
        );
      }
      if (pH != null && !item.phRange.contains(pH)) {
        warnings.add(
          CompatibilityWarning(
            type: CompatibilityWarningType.phOutsideRange,
            speciesLatinName: item.nameLatin,
            actualValue: pH,
            minimumValue: item.phRange.min,
            maximumValue: item.phRange.max,
          ),
        );
      }
    }
    for (var index = 0; index < species.length; index++) {
      for (var other = index + 1; other < species.length; other++) {
        if (!species[index].tempRange.overlaps(species[other].tempRange)) {
          warnings.add(
            CompatibilityWarning(
              type: CompatibilityWarningType.incompatibleTemperatureRanges,
              speciesLatinName: species[index].nameLatin,
              otherSpeciesLatinName: species[other].nameLatin,
              isCritical: true,
            ),
          );
        }
      }
    }
    return CompatibilityReport(warnings);
  }
}
