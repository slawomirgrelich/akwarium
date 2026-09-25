enum KnowledgeCategory { fish, plants, algae }

class FishSpeciesModel {
  const FishSpeciesModel({
    required this.polishName,
    required this.latinName,
    required this.phMin,
    required this.phMax,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.ghMin,
    required this.ghMax,
    required this.minimumLiters,
    required this.difficulty,
    required this.temperament,
  });

  final String polishName;
  final String latinName;
  final double phMin;
  final double phMax;
  final double temperatureMin;
  final double temperatureMax;
  final double ghMin;
  final double ghMax;
  final int minimumLiters;
  final String difficulty;
  final String temperament;
}

class PlantSpeciesModel {
  const PlantSpeciesModel({
    required this.name,
    required this.lightRequirements,
    required this.co2Requirements,
    required this.growthRate,
    required this.position,
  });

  final String name;
  final String lightRequirements;
  final String co2Requirements;
  final String growthRate;
  final String position;
}

class AlgaeModel {
  const AlgaeModel({
    required this.name,
    required this.causes,
    required this.symptoms,
    required this.controlSteps,
  });

  final String name;
  final List<String> causes;
  final List<String> symptoms;
  final List<String> controlSteps;
}

const fishSpecies = <FishSpeciesModel>[
  FishSpeciesModel(
    polishName: 'Neon Innesa',
    latinName: 'Paracheirodon innesi',
    phMin: 5.0,
    phMax: 7.0,
    temperatureMin: 20,
    temperatureMax: 26,
    ghMin: 1,
    ghMax: 10,
    minimumLiters: 60,
    difficulty: 'Łatwa',
    temperament: 'Łagodny, stadny',
  ),
  FishSpeciesModel(
    polishName: 'Razbora klinowa',
    latinName: 'Trigonostigma heteromorpha',
    phMin: 5.0,
    phMax: 7.5,
    temperatureMin: 22,
    temperatureMax: 28,
    ghMin: 2,
    ghMax: 12,
    minimumLiters: 60,
    difficulty: 'Łatwa',
    temperament: 'Łagodna, stadna',
  ),
  FishSpeciesModel(
    polishName: 'Gupik pawie oczko',
    latinName: 'Poecilia reticulata',
    phMin: 7.0,
    phMax: 8.2,
    temperatureMin: 22,
    temperatureMax: 28,
    ghMin: 8,
    ghMax: 20,
    minimumLiters: 54,
    difficulty: 'Łatwa',
    temperament: 'Łagodny, aktywny',
  ),
  FishSpeciesModel(
    polishName: 'Pielęgniczka ramireza',
    latinName: 'Mikrogeophagus ramirezi',
    phMin: 5.0,
    phMax: 7.0,
    temperatureMin: 26,
    temperatureMax: 30,
    ghMin: 1,
    ghMax: 8,
    minimumLiters: 80,
    difficulty: 'Zaawansowana',
    temperament: 'Spokojna, terytorialna',
  ),
  FishSpeciesModel(
    polishName: 'Bojownik syjamski',
    latinName: 'Betta splendens',
    phMin: 6.0,
    phMax: 7.5,
    temperatureMin: 24,
    temperatureMax: 30,
    ghMin: 5,
    ghMax: 20,
    minimumLiters: 25,
    difficulty: 'Średnia',
    temperament: 'Samiec terytorialny',
  ),
];

const plantSpecies = <PlantSpeciesModel>[
  PlantSpeciesModel(
    name: 'Anubias barteri',
    lightRequirements: 'Niskie',
    co2Requirements: 'Niewymagane',
    growthRate: 'Wolne',
    position: 'Środek / korzeń',
  ),
  PlantSpeciesModel(
    name: 'Microsorum pteropus',
    lightRequirements: 'Niskie do średniego',
    co2Requirements: 'Niewymagane',
    growthRate: 'Wolne',
    position: 'Środek / tył',
  ),
  PlantSpeciesModel(
    name: 'Cryptocoryne wendtii',
    lightRequirements: 'Niskie do średniego',
    co2Requirements: 'Opcjonalne',
    growthRate: 'Średnie',
    position: 'Środek',
  ),
  PlantSpeciesModel(
    name: 'Hygrophila polysperma',
    lightRequirements: 'Średnie',
    co2Requirements: 'Opcjonalne',
    growthRate: 'Szybkie',
    position: 'Tył',
  ),
  PlantSpeciesModel(
    name: 'Eleocharis acicularis',
    lightRequirements: 'Średnie do wysokiego',
    co2Requirements: 'Zalecane',
    growthRate: 'Średnie',
    position: 'Przód',
  ),
];

const algaeSpecies = <AlgaeModel>[
  AlgaeModel(
    name: 'Krasnorosty',
    causes: ['Wahania CO2', 'Słaba cyrkulacja', 'Niestabilne nawożenie'],
    symptoms: ['Czarne lub czerwone kępki na liściach i dekoracjach'],
    controlSteps: [
      'Ustabilizuj podawanie CO2 i popraw cyrkulację.',
      'Usuń mechanicznie porażone liście i dekoracje.',
      'Ogranicz światło do 6–8 godzin i obserwuj zbiornik przez tydzień.',
    ],
  ),
  AlgaeModel(
    name: 'Zielenice',
    causes: ['Nadmiar światła', 'Niedobór PO4', 'Niestabilne CO2'],
    symptoms: ['Zielony nalot na szybach lub punktowe plamy na liściach'],
    controlSteps: [
      'Skróć świecenie i regularnie czyść szyby.',
      'Sprawdź PO4 i uzupełniaj je stopniowo.',
      'Zwiększ masę szybko rosnących roślin.',
    ],
  ),
  AlgaeModel(
    name: 'Sinice',
    causes: ['Brak NO3', 'Zastoiny wody', 'Nadmiar materii organicznej'],
    symptoms: ['Śluzowata niebieskozielona warstwa o charakterystycznym zapachu'],
    controlSteps: [
      'Usuń matę mechanicznie i wykonaj większą podmianę wody.',
      'Przywróć mierzalny poziom NO3 i popraw przepływ.',
      'Ogranicz światło oraz karmienie do czasu ustabilizowania zbiornika.',
    ],
  ),
  AlgaeModel(
    name: 'Okrzemki',
    causes: ['Nowy zbiornik', 'Krzemiany w wodzie', 'Niedojrzały filtr'],
    symptoms: ['Brązowy pył na szybach, podłożu i dekoracjach'],
    controlSteps: [
      'Usuwaj nalot przy podmianach i utrzymuj regularność prac.',
      'Daj biologii czas na dojrzewanie i nie myj całego wkładu naraz.',
      'Sprawdź krzemiany w wodzie kranowej, jeśli problem trwa długo.',
    ],
  ),
];