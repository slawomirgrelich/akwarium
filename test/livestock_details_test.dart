import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/utils/localized_labels.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('localizes coral as a first-class livestock category', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));

    expect(creatureCategoryLabel(l10n, CreatureCategory.coral), 'Corals');
    expect(speciesCategoryLabel(l10n, 'coral'), 'Corals');
  });
}
