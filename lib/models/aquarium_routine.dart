import '../services/aquarium_journal_service.dart';

class AquariumRoutineTemplate {
  const AquariumRoutineTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.assetPath,
    required this.steps,
  });

  final String id;
  final String title;
  final String description;
  final String duration;
  final String assetPath;
  final List<AquariumRoutineStep> steps;
}

class AquariumRoutineStep {
  const AquariumRoutineStep({
    required this.id,
    required this.dayOffset,
    required this.title,
    required this.description,
    required this.entryType,
  });

  final String id;
  final int dayOffset;
  final String title;
  final String description;
  final JournalEntryType entryType;
}
