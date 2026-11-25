import '../local_reminder_service.dart';
import '../models/aquarium_routine.dart';
import 'aquarium_journal_service.dart';

class RoutineIntegrationService {
  RoutineIntegrationService({
    AquariumJournalService? journalService,
    Future<void> Function(ScheduledReminder)? scheduleReminder,
  }) : _journalService = journalService ?? AquariumJournalService(),
       _scheduleReminder =
           scheduleReminder ?? LocalReminderService.instance.schedule;

  final AquariumJournalService _journalService;
  final Future<void> Function(ScheduledReminder) _scheduleReminder;

  Future<void> addTemplate({
    required String aquariumId,
    required AquariumRoutineTemplate template,
    DateTime? startAt,
  }) async {
    final start = startAt ?? DateTime.now();
    final overview = JournalEntryModel(
      id: '',
      aquariumId: aquariumId,
      timestamp: start,
      entryType: JournalEntryType.cleaning,
      title: template.title,
      notes:
          '${template.description}\n\n${template.steps.map((step) => '• ${step.title}').join('\n')}',
      tags: const ['szablon', 'rutyna'],
      category: 'routine',
    );
    await _journalService.addJournalEntry(overview);
    for (final step in template.steps) {
      await addStepReminder(
        aquariumId: aquariumId,
        template: template,
        step: step,
        startAt: start,
      );
    }
  }

  Future<void> addStepReminder({
    required String aquariumId,
    required AquariumRoutineTemplate template,
    required AquariumRoutineStep step,
    DateTime? startAt,
  }) async {
    final dueDate = _dueDate(startAt ?? DateTime.now(), step.dayOffset);
    final id =
        'routine-${template.id}-${step.id}-${DateTime.now().microsecondsSinceEpoch}';
    final reminder = ReminderModel(
      id: id,
      aquariumId: aquariumId,
      title: step.title,
      intervalDays: 1,
      intervalCount: 1,
      nextDueDate: dueDate,
      isRecurring: false,
      isCompleted: false,
      isProFeature: false,
    );
    await _journalService.addReminder(reminder);
    await _scheduleReminder(
      ScheduledReminder(
        id: id.hashCode & 0x7fffffff,
        title: step.title,
        body: '${template.title}: ${step.description}',
        date: dueDate,
      ),
    );
  }

  Future<void> addStepJournalEntry({
    required String aquariumId,
    required AquariumRoutineTemplate template,
    required AquariumRoutineStep step,
  }) => _journalService.addJournalEntry(
    JournalEntryModel(
      id: '',
      aquariumId: aquariumId,
      timestamp: DateTime.now(),
      entryType: step.entryType,
      title: step.title,
      notes: '${template.title}\n\n${step.description}',
      tags: const ['szablon', 'rutyna'],
      category: 'routine',
    ),
  );

  DateTime _dueDate(DateTime start, int dayOffset) {
    if (dayOffset == 0 && start.isAfter(DateTime.now())) return start;
    if (dayOffset == 0) {
      return DateTime.now().add(const Duration(minutes: 5));
    }
    final day = DateTime(start.year, start.month, start.day + dayOffset, 9);
    return day.isAfter(DateTime.now()) ? day : day.add(const Duration(days: 1));
  }
}
