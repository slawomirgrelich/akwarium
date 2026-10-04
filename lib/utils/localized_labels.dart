import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';

String tankTypeLabel(AppLocalizations l10n, TankType type) => switch (type) {
  TankType.freshwater => l10n.freshwaterType,
  TankType.marine => l10n.saltwaterType,
  TankType.planted => l10n.plantedTankType,
  TankType.biotope => l10n.biotopeTankType,
  TankType.shrimp => l10n.shrimpTankType,
};

String aquariumTypeLabel(AppLocalizations l10n, String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.contains('marine') ||
      normalized.contains('salt') ||
      normalized.contains('morsk')) {
    return l10n.saltwaterType;
  }
  if (normalized.contains('shrimp') || normalized.contains('krewet')) {
    return l10n.shrimpTankType;
  }
  if (normalized.contains('plant') || normalized.contains('roślin')) {
    return l10n.plantedTankType;
  }
  if (normalized.contains('biotope') || normalized.contains('biotop')) {
    return l10n.biotopeTankType;
  }
  return l10n.freshwaterType;
}

String aquariumTypeKey(String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  if (normalized.contains('marine') ||
      normalized.contains('salt') ||
      normalized.contains('morsk')) {
    return 'marine';
  }
  if (normalized.contains('shrimp') || normalized.contains('krewet')) {
    return 'shrimp';
  }
  if (normalized.contains('plant') || normalized.contains('roślin')) {
    return 'planted';
  }
  if (normalized.contains('biotope') || normalized.contains('biotop')) {
    return 'biotope';
  }
  return 'freshwater';
}

String creatureCategoryLabel(
  AppLocalizations l10n,
  CreatureCategory category,
) => switch (category) {
  CreatureCategory.fish => l10n.filterFish,
  CreatureCategory.shrimp => l10n.categoryShrimp,
  CreatureCategory.snail => l10n.categorySnails,
  CreatureCategory.crab => l10n.categoryCrabs,
  CreatureCategory.coral => l10n.categoryCorals,
  CreatureCategory.plant => l10n.filterPlants,
  CreatureCategory.other => l10n.categoryOther,
};

String plantPositionLabel(AppLocalizations l10n, PlantPosition position) =>
    switch (position) {
      PlantPosition.foreground => l10n.plantPositionForeground,
      PlantPosition.midground => l10n.plantPositionMidground,
      PlantPosition.background => l10n.plantPositionBackground,
      PlantPosition.epiphyte => l10n.plantPositionEpiphyte,
      PlantPosition.floating => l10n.plantPositionFloating,
      PlantPosition.carpet => l10n.plantPositionCarpet,
    };

String journalCategoryLabel(AppLocalizations l10n, JournalCategory category) =>
    switch (category) {
      JournalCategory.observation => l10n.journalCategoryObservation,
      JournalCategory.fishHealth => l10n.journalCategoryFishHealth,
      JournalCategory.plantGrowth => l10n.journalCategoryPlantGrowth,
      JournalCategory.algae => l10n.journalCategoryAlgae,
      JournalCategory.equipment => l10n.journalCategoryEquipment,
      JournalCategory.other => l10n.categoryOther,
    };

String speciesCategoryLabel(AppLocalizations l10n, String? value) {
  final normalized = (value ?? '').trim().toLowerCase();
  if (normalized.contains('shrimp') || normalized.contains('krewet')) {
    return l10n.categoryShrimp;
  }
  if (normalized.contains('snail') || normalized.contains('ślimak')) {
    return l10n.categorySnails;
  }
  if (normalized.contains('crab') || normalized.contains('krab')) {
    return l10n.categoryCrabs;
  }
  if (normalized.contains('coral') || normalized.contains('korale')) {
    return l10n.categoryCorals;
  }
  if (normalized.contains('plant') ||
      normalized.contains('flora') ||
      normalized.contains('roślin') ||
      normalized.contains('roslin')) {
    return l10n.filterPlants;
  }
  if (normalized.contains('invertebrate') || normalized.contains('bezkręg')) {
    return l10n.filterInvertebrates;
  }
  if (normalized.contains('fauna')) return l10n.categoryFauna;
  if (normalized.isEmpty ||
      normalized.contains('other') ||
      normalized.contains('inne')) {
    return l10n.categoryOther;
  }
  return l10n.filterFish;
}
