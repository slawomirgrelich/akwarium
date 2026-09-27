import '../models/species_models.dart';

/// Wynik walidacji kompatybilności gatunku z parametrami akwarium.
class CompatibilityResult {
  const CompatibilityResult({required this.isCompatible, required this.warnings});

  final bool isCompatible;
  final List<String> warnings;
}

/// Porównuje wymagania gatunku z Atlasu z parametrami obecnego akwarium.
///
/// [volumeLiters] - pojemność akwarium w litrach.
/// [ph] - aktualne pH wody (opcjonalne, brak pomiaru pomija sprawdzenie).
/// [temperature] - aktualna temperatura wody w °C (opcjonalna).
CompatibilityResult checkCompatibility({
  required Species species,
  required double volumeLiters,
  double? ph,
  double? temperature,
}) {
  final warnings = <String>[];

  if (volumeLiters < species.minTankVolumeLiters) {
    warnings.add(
      'Za mała pojemność akwarium: ${volumeLiters.round()} l, wymagane minimum '
      '${species.minTankVolumeLiters} l.',
    );
  }

  if (ph != null && !species.phRange.contains(ph)) {
    warnings.add(
      'pH akwarium ($ph) poza zalecanym zakresem '
      '${species.phRange.min}–${species.phRange.max}.',
    );
  }

  if (temperature != null && !species.tempRange.contains(temperature)) {
    warnings.add(
      'Temperatura akwarium ($temperature°C) poza zalecanym zakresem '
      '${species.tempRange.min}–${species.tempRange.max}°C.',
    );
  }

  return CompatibilityResult(isCompatible: warnings.isEmpty, warnings: warnings);
}
