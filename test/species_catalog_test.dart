import 'package:akwarium/data/species_catalog.dart';
import 'package:akwarium/data/species_catalog_en.dart';
import 'package:akwarium/models/species_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('species catalog has unique IDs and complete care parameters', () {
    final ids = speciesCatalog.map((species) => species.id).toSet();
    final plants = speciesCatalog.where(
      (species) => species.category == SpeciesCategory.plant,
    );
    final invertebrates = speciesCatalog.where(
      (species) => species.category == SpeciesCategory.invertebrate,
    );

    expect(ids, hasLength(speciesCatalog.length));
    expect(plants.length, greaterThanOrEqualTo(50));
    expect(invertebrates.length, greaterThanOrEqualTo(38));

    for (final species in speciesCatalog) {
      expect(species.minTankVolumeLiters, greaterThan(0), reason: species.id);
      expect(species.tempRange.min, lessThanOrEqualTo(species.tempRange.max));
      expect(species.phRange.min, lessThanOrEqualTo(species.phRange.max));
      expect(species.ghRange.min, lessThanOrEqualTo(species.ghRange.max));
    }
  });

  test('new atlas entries have English names and descriptions', () {
    const newSpeciesIds = {
      'hygrophila-polysperma',
      'bacopa-monnieri',
      'sagittaria-subulata',
      'hydrocotyle-tripartita',
      'echinodorus-grisebachii',
      'cryptocoryne-parva',
      'hygrophila-pinnatifida',
      'alternanthera-reineckii',
      'micranthemum-micranthemoides',
      'pogostemon-erectus',
      'ludwigia-palustris',
      'vallisneria-nana',
      'aponogeton-crispus',
      'myriophyllum-mattogrossense',
      'limnophila-aromatica',
      'sulawesi-cardinal-shrimp',
      'babaulti-shrimp',
      'orange-eye-blue-tiger-shrimp',
      'white-pearl-shrimp',
      'pagoda-snail',
      'colombian-ramshorn-snail',
      'least-dwarf-crayfish',
      'australian-redclaw-crayfish',
      'pom-pom-crab',
      'red-nose-shrimp',
      'cajun-dwarf-crayfish',
      'diadem-nerite',
    };
    final ids = speciesCatalog.map((species) => species.id).toSet();

    expect(ids, containsAll(newSpeciesIds));
    expect(speciesNamesEn.keys, containsAll(newSpeciesIds));
    expect(speciesDescriptionsEn.keys, containsAll(newSpeciesIds));
  });

  test('new entries use reusable photos with attribution where required', () {
    final newEntries = speciesCatalog.where(
      (species) =>
          species.id == 'hygrophila-polysperma' ||
          species.id == 'bacopa-monnieri' ||
          species.id == 'sagittaria-subulata' ||
          species.id == 'hydrocotyle-tripartita' ||
          species.id == 'echinodorus-grisebachii' ||
          species.id == 'hygrophila-pinnatifida' ||
          species.id == 'ludwigia-palustris' ||
          species.id == 'vallisneria-nana' ||
          species.id == 'aponogeton-crispus' ||
          species.id == 'myriophyllum-mattogrossense' ||
          species.id == 'sulawesi-cardinal-shrimp' ||
          species.id == 'orange-eye-blue-tiger-shrimp' ||
          species.id == 'colombian-ramshorn-snail' ||
          species.id == 'australian-redclaw-crayfish' ||
          species.id == 'cajun-dwarf-crayfish',
    );

    expect(newEntries, hasLength(15));
    expect(
      newEntries.every((species) => species.imageUrl.startsWith('https://')),
      isTrue,
    );
    expect(
      newEntries
          .where(
            (species) => !species.imageAttribution.contains('Public domain'),
          )
          .every((species) => species.imageAttribution.isNotEmpty),
      isTrue,
    );
  });
}
