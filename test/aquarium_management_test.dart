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

  test('preserves archive state and measures age through the end date', () {
    final profile = AquariumProfile(
      id: 'closed-tank',
      name: 'Zlikwidowane',
      volumeNetLiters: 54,
      setupDate: DateTime(2026, 1, 1),
      type: TankType.freshwater,
      isArchived: true,
      endDate: DateTime(2026, 1, 11),
    );
    final restored = AquariumProfile.fromJson(profile.toJson());

    expect(restored.isArchived, isTrue);
    expect(restored.endDate, DateTime(2026, 1, 11));
    expect(restored.ageInDays, 10);
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
    expect(provider.resolveAquariumId(), 'two');
    expect(provider.resolveAquariumId(''), 'two');
    expect(provider.inhabitants.single.id, 'shrimp');
  });

  test('archived aquariums remain selectable with their saved history', () {
    final archive = AquariumProfile(
      id: 'closed',
      name: 'Dawny zbiornik',
      volumeNetLiters: 60,
      setupDate: DateTime(2026),
      type: TankType.planted,
      isArchived: true,
      endDate: DateTime(2026, 8, 1),
    );
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'active',
          name: 'Aktywny',
          volumeNetLiters: 30,
          setupDate: DateTime(2026),
          type: TankType.freshwater,
        ),
        archive,
      ],
      activeAquariumId: 'active',
      waterTests: [
        WaterTest(
          id: 'old-test',
          aquariumId: 'closed',
          date: DateTime(2026, 7, 1),
          ph: 7,
        ),
      ],
      inhabitants: [
        Inhabitant(
          id: 'old-fish',
          aquariumId: 'closed',
          name: 'Ryba',
          latinName: 'Piscis',
          category: CreatureCategory.fish,
          count: 2,
          addedDate: DateTime(2026, 2, 1),
        ),
      ],
    );
    addTearDown(provider.dispose);

    provider.selectAquarium('closed');

    expect(provider.selectedAquarium, archive);
    expect(provider.waterTests.single.id, 'old-test');
    expect(provider.inhabitants.single.id, 'old-fish');
  });

  test('water changes update the dashboard history without a fake volume', () {
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'tank',
          name: 'Shrimp tank',
          volumeNetLiters: 20,
          setupDate: DateTime(2026),
          type: TankType.shrimp,
        ),
      ],
    );
    addTearDown(provider.dispose);
    final completedAt = DateTime(2026, 10, 5, 19);
    final change = waterChangeForReminder(
      reminderId: 'water-change-task',
      aquariumId: 'tank',
      title: 'Weekly water change',
      completedAt: completedAt,
    );

    provider.addWaterChange(change);

    expect(provider.waterChanges.single.date, completedAt);
    expect(provider.waterChanges.single.volumeLiters, isNull);
    expect(provider.journalEntries.single.id, change.id);
    expect(provider.journalEntries.single.description, 'Weekly water change');
    expect(WaterChange.fromMap(change.toMap()).volumeLiters, isNull);
  });

  test('counts only non-null readings in a water test', () {
    final test = WaterTest(
      id: 'partial',
      aquariumId: 'tank',
      date: DateTime(2026, 1, 1),
      ph: 7,
      co2: 20,
      tds: 170,
    );

    expect(test.measuredParametersCount, 3);
  });

  test('uses the first aquarium when no active id is available', () {
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'first',
          name: 'Pierwsze',
          volumeNetLiters: 60,
          setupDate: DateTime(2026),
          type: TankType.freshwater,
        ),
      ],
      activeAquariumId: '',
    );

    expect(provider.resolveAquariumId(), 'first');
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
        isArchived: true,
        endDate: DateTime(2026, 9, 1),
      ),
    ]);

    expect(provider.selectedAquariumId, 'cloud-70');
    expect(provider.activeAquarium.volumeNetLiters, 70);
    expect(provider.activeAquarium.isArchived, isTrue);
    expect(provider.activeAquarium.endDate, DateTime(2026, 9, 1));
  });

  test('retains a selected aquarium while its cloud profile is loading', () {
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'first',
          name: 'Pierwsze',
          volumeNetLiters: 60,
          setupDate: DateTime(2026),
          type: TankType.freshwater,
        ),
      ],
      activeAquariumId: 'first',
    );

    provider.selectAquarium('cloud-second');

    expect(provider.selectedAquariumId, 'cloud-second');
    expect(provider.selectedAquarium, isNull);

    provider.syncCloudAquariums([
      AquariumModel(
        id: 'cloud-second',
        name: 'Drugie',
        netVolumeLiters: 30,
        establishedAt: DateTime(2026),
        type: 'Słodkowodne',
      ),
    ]);

    expect(provider.selectedAquariumId, 'cloud-second');
    expect(provider.selectedAquarium?.name, 'Drugie');
  });
}
