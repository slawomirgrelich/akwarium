import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/models/aquarium_model.dart';

void main() {
  test('serializes aquarium profiles and inhabitants', () {
    final profile = AquariumProfile(
      id: 'tank-1',
      name: 'Kostka',
      volumeNetLiters: 30,
      setupDate: DateTime(2026, 1, 1),
      type: TankType.shrimp,
    );
    final inhabitant = Inhabitant(
      id: 'shrimp-1',
      aquariumId: profile.id,
      name: 'Neocaridina',
      latinName: 'Neocaridina davidi',
      category: CreatureCategory.shrimp,
      count: 12,
      addedDate: DateTime(2026, 2, 1),
    );

    expect(AquariumProfile.fromJson(profile.toJson()).name, 'Kostka');
    expect(Inhabitant.fromJson(inhabitant.toJson()).count, 12);
    expect(Inhabitant.fromJson(inhabitant.toJson()).aquariumId, 'tank-1');
  });

  test('provider scopes inhabitants to active aquarium', () {
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'one',
          name: 'One',
          volumeNetLiters: 60,
          setupDate: DateTime(2026),
          type: TankType.planted,
        ),
        AquariumProfile(
          id: 'two',
          name: 'Two',
          volumeNetLiters: 30,
          setupDate: DateTime(2026),
          type: TankType.shrimp,
        ),
      ],
      activeAquariumId: 'one',
    );
    provider.addInhabitant(
      Inhabitant(
        id: 'fish',
        aquariumId: 'one',
        name: 'Ryba',
        latinName: 'Fishus testus',
        category: CreatureCategory.fish,
        count: 1,
        addedDate: DateTime(2026),
      ),
    );
    provider.addInhabitant(
      Inhabitant(
        id: 'shrimp',
        aquariumId: 'two',
        name: 'Krewetka',
        latinName: 'Shrimpus testus',
        category: CreatureCategory.shrimp,
        count: 5,
        addedDate: DateTime(2026),
      ),
    );

    expect(provider.inhabitants.single.id, 'fish');
    provider.selectAquarium('two');
    expect(provider.inhabitants.single.id, 'shrimp');
  });
}