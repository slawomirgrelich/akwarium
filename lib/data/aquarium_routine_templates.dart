import '../l10n/app_localizations.dart';
import '../models/aquarium_routine.dart';
import '../services/aquarium_journal_service.dart';

List<AquariumRoutineTemplate> aquariumRoutineTemplates(AppLocalizations l10n) =>
    [
      AquariumRoutineTemplate(
        id: 'nitrogen-cycle',
        title: l10n.routineNitrogenTitle,
        description: l10n.routineNitrogenDescription,
        duration: l10n.routineNitrogenDuration,
        assetPath: 'assets/templates/nitrogen_cycle.webp',
        steps: [
          AquariumRoutineStep(
            id: 'prepare',
            dayOffset: 0,
            title: l10n.routineNitrogenStep1Title,
            description: l10n.routineNitrogenStep1Description,
            entryType: JournalEntryType.cleaning,
          ),
          AquariumRoutineStep(
            id: 'start-filter',
            dayOffset: 1,
            title: l10n.routineNitrogenStep2Title,
            description: l10n.routineNitrogenStep2Description,
            entryType: JournalEntryType.filter,
          ),
          AquariumRoutineStep(
            id: 'nitrogen-source',
            dayOffset: 3,
            title: l10n.routineNitrogenStep3Title,
            description: l10n.routineNitrogenStep3Description,
            entryType: JournalEntryType.waterTest,
          ),
          AquariumRoutineStep(
            id: 'monitor-peaks',
            dayOffset: 14,
            title: l10n.routineNitrogenStep4Title,
            description: l10n.routineNitrogenStep4Description,
            entryType: JournalEntryType.waterTest,
          ),
          AquariumRoutineStep(
            id: 'finish-cycle',
            dayOffset: 28,
            title: l10n.routineNitrogenStep5Title,
            description: l10n.routineNitrogenStep5Description,
            entryType: JournalEntryType.waterTest,
          ),
        ],
      ),
      AquariumRoutineTemplate(
        id: 'weekly-stable',
        title: l10n.routineWeeklyTitle,
        description: l10n.routineWeeklyDescription,
        duration: l10n.routineWeeklyDuration,
        assetPath: 'assets/templates/weekly_routine.webp',
        steps: [
          AquariumRoutineStep(
            id: 'visual-check',
            dayOffset: 0,
            title: l10n.routineWeeklyStep1Title,
            description: l10n.routineWeeklyStep1Description,
            entryType: JournalEntryType.cleaning,
          ),
          AquariumRoutineStep(
            id: 'water-test',
            dayOffset: 1,
            title: l10n.routineWeeklyStep2Title,
            description: l10n.routineWeeklyStep2Description,
            entryType: JournalEntryType.waterTest,
          ),
          AquariumRoutineStep(
            id: 'water-change',
            dayOffset: 3,
            title: l10n.routineWeeklyStep3Title,
            description: l10n.routineWeeklyStep3Description,
            entryType: JournalEntryType.waterChange,
          ),
          AquariumRoutineStep(
            id: 'filter',
            dayOffset: 5,
            title: l10n.routineWeeklyStep4Title,
            description: l10n.routineWeeklyStep4Description,
            entryType: JournalEntryType.filter,
          ),
          AquariumRoutineStep(
            id: 'record',
            dayOffset: 7,
            title: l10n.routineWeeklyStep5Title,
            description: l10n.routineWeeklyStep5Description,
            entryType: JournalEntryType.cleaning,
          ),
        ],
      ),
      AquariumRoutineTemplate(
        id: 'biological-restart',
        title: l10n.routineRestartTitle,
        description: l10n.routineRestartDescription,
        duration: l10n.routineRestartDuration,
        assetPath: 'assets/templates/biological_restart.webp',
        steps: [
          AquariumRoutineStep(
            id: 'assess',
            dayOffset: 0,
            title: l10n.routineRestartStep1Title,
            description: l10n.routineRestartStep1Description,
            entryType: JournalEntryType.waterTest,
          ),
          AquariumRoutineStep(
            id: 'preserve-media',
            dayOffset: 0,
            title: l10n.routineRestartStep2Title,
            description: l10n.routineRestartStep2Description,
            entryType: JournalEntryType.filter,
          ),
          AquariumRoutineStep(
            id: 'condition-water',
            dayOffset: 1,
            title: l10n.routineRestartStep3Title,
            description: l10n.routineRestartStep3Description,
            entryType: JournalEntryType.waterChange,
          ),
          AquariumRoutineStep(
            id: 'daily-checks',
            dayOffset: 3,
            title: l10n.routineRestartStep4Title,
            description: l10n.routineRestartStep4Description,
            entryType: JournalEntryType.waterTest,
          ),
          AquariumRoutineStep(
            id: 'stable-again',
            dayOffset: 7,
            title: l10n.routineRestartStep5Title,
            description: l10n.routineRestartStep5Description,
            entryType: JournalEntryType.cleaning,
          ),
        ],
      ),
    ];
