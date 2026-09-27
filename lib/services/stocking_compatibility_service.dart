import '../models/species_models.dart';

class CompatibilityWarning {
  const CompatibilityWarning(this.message, {this.isCritical = false});
  final String message;
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
        warnings.add(CompatibilityWarning(
          '${item.namePl}: wymagane minimum ${item.minTankVolumeLiters} l.',
          isCritical: true,
        ));
      }
      if (temperature != null && !item.tempRange.contains(temperature)) {
        warnings.add(CompatibilityWarning('${item.namePl}: temperatura poza zakresem.'));
      }
      if (pH != null && !item.phRange.contains(pH)) {
        warnings.add(CompatibilityWarning('${item.namePl}: pH poza zakresem.'));
      }
    }
    for (var index = 0; index < species.length; index++) {
      for (var other = index + 1; other < species.length; other++) {
        if (!species[index].tempRange.overlaps(species[other].tempRange)) {
          warnings.add(CompatibilityWarning(
            '${species[index].namePl} i ${species[other].namePl} nie mają wspólnego zakresu temperatur.',
            isCritical: true,
          ));
        }
      }
    }
    return CompatibilityReport(warnings);
  }
}