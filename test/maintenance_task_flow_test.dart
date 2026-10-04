import 'package:akwarium/services/aquarium_journal_service.dart';
import 'package:akwarium/services/maintenance_reminder_scheduler.dart';
import 'package:akwarium/local_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('maintenance task state', () {
    test(
      'round-trips task state and scheduled time through Firestore data',
      () {
        final performedAt = DateTime(2026, 10, 2, 17, 45, 12);
        final nextDueDate = DateTime(2026, 10, 9, 9, 30, 20);
        final task = MaintenanceTaskModel(
          id: 'weekly-water-change',
          aquariumId: 'planted-tank',
          taskType: 'waterChange',
          title: 'Water change',
          repeatFrequencyDays: 7,
          lastPerformedDate: performedAt,
          nextDueDate: nextDueDate,
        );

        final restored = MaintenanceTaskModel.fromMap(task.toMap());

        expect(restored.id, task.id);
        expect(restored.aquariumId, task.aquariumId);
        expect(restored.taskType, task.taskType);
        expect(restored.repeatFrequencyDays, 7);
        expect(restored.lastPerformedDate, performedAt);
        expect(restored.nextDueDate, nextDueDate);
      },
    );

    test(
      'completion advances from performed date and preserves reminder time',
      () {
        final performedAt = DateTime(2026, 10, 2, 17, 45);
        final task = MaintenanceTaskModel(
          id: 'fertilize',
          aquariumId: 'planted-tank',
          taskType: 'fertilizing',
          title: 'Fertilize plants',
          repeatFrequencyDays: 3,
          lastPerformedDate: DateTime(2026, 9, 29, 9),
          nextDueDate: DateTime(2026, 10, 2, 9, 30),
        );

        final completed = task.completed(performedAt);

        expect(completed.lastPerformedDate, performedAt);
        expect(completed.nextDueDate, DateTime(2026, 10, 5, 9, 30));
        expect(completed.taskType, task.taskType);
        expect(completed.id, task.id);

        final restored = MaintenanceTaskModel.fromMap(completed.toMap());
        expect(restored.lastPerformedDate, performedAt);
        expect(restored.nextDueDate, completed.nextDueDate);
      },
    );

    test('completion rejects a non-positive recurrence interval', () {
      final task = MaintenanceTaskModel(
        id: 'invalid-task',
        aquariumId: 'tank',
        taskType: 'filterCleaning',
        title: 'Clean filter',
        repeatFrequencyDays: 0,
        lastPerformedDate: DateTime(2026, 10, 1),
        nextDueDate: DateTime(2026, 10, 1),
      );

      expect(() => task.completed(DateTime(2026, 10, 1)), throwsArgumentError);
    });
  });

  group('maintenance reminder scheduling', () {
    late List<int> cancelledIds;
    late List<ScheduledReminder> scheduled;
    late MaintenanceReminderScheduler scheduler;

    setUp(() {
      cancelledIds = [];
      scheduled = [];
      scheduler = MaintenanceReminderScheduler(
        cancelNotification: (id) async => cancelledIds.add(id),
        scheduleNotification: (reminder) async => scheduled.add(reminder),
      );
    });

    test('reschedules changed tasks and cancels removed tasks', () async {
      final now = DateTime(2026, 10, 1, 8);
      final initial = _task(
        dueDate: DateTime(2026, 10, 2, 9),
        title: 'Water change',
      );
      await scheduler.syncTasks(
        [initial],
        notificationBody: 'Maintenance reminder',
        now: now,
      );
      await scheduler.syncTasks(
        [initial],
        notificationBody: 'Maintenance reminder',
        now: now,
      );

      final edited = _task(
        dueDate: DateTime(2026, 10, 3, 10),
        title: 'Weekly water change',
      );
      await scheduler.syncTasks(
        [edited],
        notificationBody: 'Maintenance reminder',
        now: now,
      );
      await scheduler.syncTasks(
        const [],
        notificationBody: 'Maintenance reminder',
        now: now,
      );

      final id = maintenanceTaskNotificationId(initial);
      expect(cancelledIds, [id, id, id]);
      expect(scheduled, hasLength(2));
      expect(scheduled.first.title, 'Water change');
      expect(scheduled.last.title, 'Weekly water change');
      expect(scheduled.last.date, edited.nextDueDate);
    });

    test(
      'an overdue task due today is rescheduled one minute from now',
      () async {
        final now = DateTime(2026, 10, 4, 10, 15);
        final task = _task(
          dueDate: DateTime(2026, 10, 4, 8),
          title: 'Trim plants',
          taskType: 'plantTrimming',
        );

        await scheduler.syncTasks(
          [task],
          notificationBody: 'Maintenance reminder',
          now: now,
        );

        expect(scheduled.single.date, DateTime(2026, 10, 4, 10, 16));
      },
    );

    test(
      'a task overdue from an earlier day cancels but is not rescheduled',
      () async {
        final task = _task(
          dueDate: DateTime(2026, 10, 3, 8),
          title: 'Clean filter',
          taskType: 'filterCleaning',
        );

        await scheduler.syncTasks(
          [task],
          notificationBody: 'Maintenance reminder',
          now: DateTime(2026, 10, 4, 10),
        );

        expect(cancelledIds, [maintenanceTaskNotificationId(task)]);
        expect(scheduled, isEmpty);
      },
    );

    test('notification IDs are stable and scoped to an aquarium', () {
      final first = _task(
        dueDate: DateTime(2026, 10, 5, 9),
        title: 'Dose fertilizer',
      );
      final second = MaintenanceTaskModel(
        id: first.id,
        aquariumId: 'another-tank',
        taskType: first.taskType,
        title: first.title,
        repeatFrequencyDays: first.repeatFrequencyDays,
        lastPerformedDate: first.lastPerformedDate,
        nextDueDate: first.nextDueDate,
      );

      expect(
        maintenanceTaskNotificationId(first),
        maintenanceTaskNotificationId(first),
      );
      expect(
        maintenanceTaskNotificationId(first),
        isNot(maintenanceTaskNotificationId(second)),
      );
    });
  });
}

MaintenanceTaskModel _task({
  required DateTime dueDate,
  required String title,
  String taskType = 'waterChange',
}) => MaintenanceTaskModel(
  id: 'task-1',
  aquariumId: 'tank-1',
  taskType: taskType,
  title: title,
  repeatFrequencyDays: 7,
  lastPerformedDate: DateTime(2026, 9, 28, 9),
  nextDueDate: dueDate,
);
