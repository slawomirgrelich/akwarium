import 'package:flutter/material.dart';

import '../data/plant_care_profiles.dart';
import '../data/species_catalog.dart';
import '../data/species_catalog_en.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart' show CreatureCategory;
import '../models/species_models.dart';

class SpeciesAutocompleteField extends StatelessWidget {
  const SpeciesAutocompleteField({
    required this.onChanged,
    required this.onSelected,
    required this.decoration,
    this.validator,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<Species> onSelected;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Autocomplete<Species>(
      displayStringForOption: (species) =>
          localizedSpeciesDisplayName(context, species),
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<Species>.empty();
        return speciesCatalog
            .where((species) {
              final englishName = speciesNamesEn[species.id] ?? '';
              return species.namePl.toLowerCase().contains(query) ||
                  species.nameLatin.toLowerCase().contains(query) ||
                  englishName.toLowerCase().contains(query) ||
                  species.varieties.any(
                    (variety) => variety.toLowerCase().contains(query),
                  );
            })
            .take(8);
      },
      onSelected: onSelected,
      optionsViewBuilder: (context, onOptionSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final species = options.elementAt(index);
                final plantCare = plantCareProfileFor(species);
                return ListTile(
                  dense: true,
                  title: Text(localizedSpeciesDisplayName(context, species)),
                  subtitle: Text(
                    '${species.nameLatin} · '
                    '${plantCare == null ? l10n.speciesMinimumVolumeFrom(species.aquariumMinimumLiters ?? 0) : l10n.plantTargetHeightLabel(plantCare.targetHeightCm.min, plantCare.targetHeightCm.max)}'
                    '${species.varieties.isEmpty ? '' : ' · ${species.varieties.join(', ')}'}',
                  ),
                  onTap: () => onOptionSelected(species),
                );
              },
            ),
          ),
        ),
      ),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: decoration,
            validator: validator,
            onChanged: onChanged,
            onFieldSubmitted: (_) => onFieldSubmitted(),
          ),
    );
  }
}

String localizedSpeciesDisplayName(BuildContext context, Species species) {
  if (Localizations.localeOf(context).languageCode == 'en') {
    return speciesNamesEn[species.id] ?? species.nameLatin;
  }
  return species.namePl;
}

String speciesRangeLabel(SpeciesRange range) => '${range.min} - ${range.max}';

CreatureCategory creatureCategoryForSpecies(Species species) {
  switch (species.category) {
    case SpeciesCategory.fish:
      return CreatureCategory.fish;
    case SpeciesCategory.plant:
      return CreatureCategory.plant;
    case SpeciesCategory.invertebrate:
      final name = species.namePl.toLowerCase();
      if (name.contains('krewet')) return CreatureCategory.shrimp;
      if (name.contains('ślimak') || name.contains('slimak')) {
        return CreatureCategory.snail;
      }
      if (name.contains('rak ') || name.contains('krab')) {
        return CreatureCategory.crab;
      }
      return CreatureCategory.other;
  }
}
