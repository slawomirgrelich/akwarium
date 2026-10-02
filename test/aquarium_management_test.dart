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

  test('loads legacy aquarium profiles without a setup date', () {
    final profile = AquariumProfile.fromJson({
      'id': 'tank-legacy',
      'name': 'Stare akwarium',
      'volumeNetLiters': 30,
      'type': 'freshwater',
    });

    final today = DateTime.now();
    expect(profile.setupDate.year, today.year);
    expect(profile.setupDate.month, today.month);
    expect(profile.setupDate.day, today.day);
    expect(profile.ageInDays, 0);
  });

  test('calculates aquarium age by calendar day without going negative', () {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final yesterday = todayStart.subtract(const Duration(days: 1));

    AquariumProfile profileFor(DateTime setupDate) => AquariumProfile(
      id: 'tank-1',
      name: 'Kostka',
      volumeNetLiters: 30,
      setupDate: setupDate,
      type: TankType.shrimp,
    );

    expect(
      profileFor(DateTime(today.year, today.month, today.day, 23, 59))
          .ageInDays,
      0,
    );
    expect(
      profileFor(
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59),
      ).ageInDays,
      1,
    );
    expect(profileFor(todayStart.add(const Duration(days: 1))).ageInDays, 0);
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

  test('selects the first aquarium and syncs the cloud selection', () {
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'first',
          name: 'Pierwsze',
          volumeNetLiters: 60,
          setupDate: DateTime(2026),
          type: TankType.freshwater,
        ),
        AquariumProfile(
          id: 'second',
          name: 'Drugie',
          volumeNetLiters: 30,
          setupDate: DateTime(2026),
          type: TankType.shrimp,
        ),
      ],
    );

    expect(provider.selectedAquariumId, 'first');

    provider.syncCloudAquariums([
      AquariumModel(
        id: 'cloud-70',
        name: 'Moje 70 l',
        netVolumeLiters: 70,
        establishedAt: DateTime(2026),
        type: 'Słodkowodne',
      ),
    ]);

    expect(provider.selectedAquariumId, 'cloud-70');
    expect(provider.activeAquarium.volumeNetLiters, 70);
  });
}
