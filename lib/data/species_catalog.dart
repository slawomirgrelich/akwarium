import '../models/species_models.dart';

const speciesCatalog = <Species>[
  Species(
    id: 'neon-tetra', namePl: 'Neon Innesa', nameLatin: 'Paracheirodon innesi',
    category: SpeciesCategory.fish, minTankVolumeLiters: 54,
    tempRange: SpeciesRange(22, 26), phRange: SpeciesRange(6, 7.5), ghRange: SpeciesRange(2, 10),
    difficulty: SpeciesDifficulty.easy, swimmingZone: SwimmingZone.middle,
    description: 'Spokojna ryba ławicowa. Najlepiej czuje się w grupie co najmniej sześciu sztuk.', imageUrl: '',
  ),
  Species(
    id: 'corydoras', namePl: 'Kirys pstry', nameLatin: 'Corydoras paleatus',
    category: SpeciesCategory.fish, minTankVolumeLiters: 60,
    tempRange: SpeciesRange(22, 26), phRange: SpeciesRange(6, 7.5), ghRange: SpeciesRange(2, 15),
    difficulty: SpeciesDifficulty.easy, swimmingZone: SwimmingZone.bottom,
    description: 'Towarzyska ryba denna, która wymaga miękkiego, niekaleczącego podłoża.', imageUrl: '',
  ),
  Species(
    id: 'cherry-shrimp', namePl: 'Krewetka Neocaridina', nameLatin: 'Neocaridina davidi',
    category: SpeciesCategory.invertebrate, minTankVolumeLiters: 20,
    tempRange: SpeciesRange(20, 28), phRange: SpeciesRange(6.5, 8), ghRange: SpeciesRange(4, 15),
    difficulty: SpeciesDifficulty.easy, swimmingZone: SwimmingZone.bottom,
    description: 'Odporna krewetka słodkowodna, ceniona za aktywność i kolory.', imageUrl: '',
  ),
  Species(
    id: 'anubias', namePl: 'Anubias barteri', nameLatin: 'Anubias barteri',
    category: SpeciesCategory.plant, minTankVolumeLiters: 20,
    tempRange: SpeciesRange(20, 30), phRange: SpeciesRange(6, 8), ghRange: SpeciesRange(1, 20),
    difficulty: SpeciesDifficulty.easy, swimmingZone: SwimmingZone.all,
    description: 'Powoli rosnąca roślina epifityczna tolerująca słabsze światło.', imageUrl: '',
  ),
  Species(
    id: 'java-moss', namePl: 'Mech jawajski', nameLatin: 'Taxiphyllum barbieri',
    category: SpeciesCategory.plant, minTankVolumeLiters: 10,
    tempRange: SpeciesRange(18, 30), phRange: SpeciesRange(5.5, 8), ghRange: SpeciesRange(1, 20),
    difficulty: SpeciesDifficulty.easy, swimmingZone: SwimmingZone.all,
    description: 'Wszechstronny mech zapewniający schronienie młodym rybom i krewetkom.', imageUrl: '',
  ),
  Species(
    id: 'angelfish', namePl: 'Skalar', nameLatin: 'Pterophyllum scalare',
    category: SpeciesCategory.fish, minTankVolumeLiters: 200,
    tempRange: SpeciesRange(24, 30), phRange: SpeciesRange(6, 7.5), ghRange: SpeciesRange(3, 12),
    difficulty: SpeciesDifficulty.medium, swimmingZone: SwimmingZone.middle,
    description: 'Duża pielęgnica wymagająca wysokiego akwarium i przemyślanej obsady.', imageUrl: '',
  ),
];