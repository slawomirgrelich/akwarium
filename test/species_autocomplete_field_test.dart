import 'package:akwarium/data/species_catalog.dart';
import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/models/species_models.dart';
import 'package:akwarium/widgets/species_autocomplete_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('suggests atlas species and returns the selected entry', (
    tester,
  ) async {
    Species? selectedSpecies;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pl'),
        home: Scaffold(
          body: SpeciesAutocompleteField(
            onChanged: (_) {},
            onSelected: (species) => selectedSpecies = species,
            decoration: const InputDecoration(labelText: 'Gatunek'),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Paracheirodon');
    await tester.pumpAndSettle();

    expect(find.text('Neon Innesa'), findsOneWidget);
    await tester.tap(find.text('Neon Innesa'));
    await tester.pumpAndSettle();

    expect(selectedSpecies?.nameLatin, 'Paracheirodon innesi');
    expect(creatureCategoryForSpecies(selectedSpecies!), CreatureCategory.fish);
  });

  test('maps atlas invertebrates to their stocking categories', () {
    final shrimp = speciesCatalog.firstWhere(
      (species) => species.id == 'cherry-shrimp',
    );
    final snail = speciesCatalog.firstWhere(
      (species) => species.id == 'diadem-nerite',
    );

    expect(creatureCategoryForSpecies(shrimp), CreatureCategory.shrimp);
    expect(creatureCategoryForSpecies(snail), CreatureCategory.snail);
  });
}
