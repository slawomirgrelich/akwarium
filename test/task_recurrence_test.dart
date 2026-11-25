import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/utils/recurrence_date.dart';
import 'package:akwarium/utils/recurrence_interval.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily and weekly recurrence preserve the configured reminder time', () {
    final completedAt = DateTime(2026, 10, 2, 17, 45);
    final scheduledDate = DateTime(2026, 10, 1, 9, 30);

    expect(
      nextRecurrenceDateAfter(completedAt, scheduledDate, 1),
      DateTime(2026, 10, 3, 9, 30),
    );
    expect(
      nextRecurrenceDateAfter(completedAt, scheduledDate, 7),
      DateTime(2026, 10, 9, 9, 30),
    );
  });

  test(
    'recurring aquarium tasks retain their configured time and daily state',
    () {
      final now = DateTime.now();
      final task = AquariumTask(
        id: 'daily-task',
        aquariumId: 'tank-1',
        title: 'Karmienie',
        description: '',
        recurrence: TaskRecurrence.daily,
        intervalDays: 1,
        nextDueDate: DateTime(now.year, now.month, now.day, 9),
        reminderMinutes: 9 * 60,
      );

      final completed = task.completed(now);

      expect(completed.nextDueDate.hour, 9);
      expect(completed.nextDueDate.minute, 0);
      expect(completed.isCompletedToday, isTrue);
      expect(
        AquariumTask.fromJson(completed.toJson()).recurrence,
        TaskRecurrence.daily,
      );
    },
  );

  test('a completion from a previous day does not stay marked as today', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final task = AquariumTask(
      id: 'task',
      aquariumId: 'tank-1',
      title: 'Test',
      description: '',
      recurrence: TaskRecurrence.weekly,
      intervalDays: 7,
      nextDueDate: DateTime.now(),
      lastCompletedDate: yesterday,
      isCompletedToday: true,
    );

    expect(task.isCompletedForCurrentDay, isFalse);
  });

  test('a completed one-time task stays completed on later days', () {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final task = AquariumTask(
      id: 'one-time',
      aquariumId: 'tank-1',
      title: 'Jednorazowe zadanie',
      description: '',
      recurrence: TaskRecurrence.once,
      intervalDays: 1,
      nextDueDate: yesterday,
      lastCompletedDate: yesterday,
      isCompletedToday: true,
    );

    expect(task.isCompletedForCurrentDay, isTrue);
  });

  test('non-positive recurrence intervals are rejected', () {
    expect(
      () => nextRecurrenceDateAfter(
        DateTime(2026, 10, 2),
        DateTime(2026, 10, 3, 9),
        0,
      ),
      throwsArgumentError,
    );
  });

  test('custom weeks and calendar months advance with the scheduled time', () {
    final completedAt = DateTime(2026, 1, 31, 17, 45);
    final scheduledDate = DateTime(2026, 1, 30, 9, 30);

    expect(
      nextRecurrenceDate(completedAt, scheduledDate, 4, RecurrenceUnit.weeks),
      DateTime(2026, 2, 28, 9, 30),
    );
    expect(
      nextRecurrenceDate(completedAt, scheduledDate, 1, RecurrenceUnit.months),
      DateTime(2026, 2, 28, 9, 30),
    );
  });

  test('upcoming summary counts all occurrences in the selected horizon', () {
    expect(
      countRecurrencesInRange(
        firstDueDate: DateTime(2026, 1, 2, 9),
        from: DateTime(2026, 1, 1),
        through: DateTime(2026, 2, 28, 23, 59),
        intervalCount: 1,
        unit: RecurrenceUnit.weeks,
      ),
      9,
    );
  });

  test('calendar finds weekly and multi-week recurring occurrences', () {
    final start = DateTime(2026, 11, 29, 9);
    expect(
      recurrenceOccurrenceOnDay(
        firstDueDate: start,
        day: DateTime(2026, 12, 6),
        intervalCount: 1,
        unit: RecurrenceUnit.weeks,
      ),
      DateTime(2026, 12, 6, 9),
    );
    expect(
      recurrenceOccurrenceOnDay(
        firstDueDate: start,
        day: DateTime(2026, 12, 27),
        intervalCount: 4,
        unit: RecurrenceUnit.weeks,
      ),
      DateTime(2026, 12, 27, 9),
    );
    expect(
      recurrenceOccurrenceOnDay(
        firstDueDate: start,
        day: DateTime(2027, 2, 28),
        intervalCount: 13,
        unit: RecurrenceUnit.weeks,
      ),
      DateTime(2027, 2, 28, 9),
    );
  });

  test('completion advances a recurring series beyond the completed date', () {
    expect(
      nextRecurrenceAfterCompletion(
        DateTime(2026, 12, 6, 8),
        DateTime(2026, 11, 29, 9),
        1,
        RecurrenceUnit.weeks,
      ),
      DateTime(2026, 12, 13, 9),
    );
  });

  test('recurring tasks round-trip through Firestore timestamp fields', () {
    final dueDate = DateTime(2026, 10, 9, 9, 30);
    final completedDate = DateTime(2026, 10, 2, 9, 30);
    final task = AquariumTask(
      id: 'weekly-task',
      aquariumId: 'tank-1',
      title: 'Podmiana wody',
      description: '',
      recurrence: TaskRecurrence.everyXDays,
      intervalDays: 7,
      nextDueDate: dueDate,
      lastCompletedDate: completedDate,
      isCompletedToday: true,
    );

    final data = task.toFirestore();
    final restored = AquariumTask.fromJson(data);

    expect(data['nextDueDate'], Timestamp.fromDate(dueDate));
    expect(data['lastCompletedDate'], Timestamp.fromDate(completedDate));
    expect(restored.recurrence, TaskRecurrence.everyXDays);
    expect(restored.intervalDays, 7);
    expect(restored.nextDueDate, dueDate);
    expect(restored.lastCompletedDate, completedDate);
  });
}
