enum RecurrenceUnit { days, weeks, months }

extension RecurrenceUnitDays on RecurrenceUnit {
  int? get fixedDayCount => switch (this) {
    RecurrenceUnit.days => 1,
    RecurrenceUnit.weeks => 7,
    RecurrenceUnit.months => null,
  };
}

int recurrenceIntervalDays(int count, RecurrenceUnit unit) {
  if (count < 1) {
    throw ArgumentError.value(count, 'count', 'Must be positive.');
  }
  return switch (unit) {
    RecurrenceUnit.days => count,
    RecurrenceUnit.weeks => count * 7,
    RecurrenceUnit.months => count * 30,
  };
}

DateTime nextRecurrenceDate(
  DateTime completedAt,
  DateTime scheduledDate,
  int intervalCount,
  RecurrenceUnit unit,
) {
  if (intervalCount < 1) {
    throw ArgumentError.value(
      intervalCount,
      'intervalCount',
      'Must be positive.',
    );
  }
  if (unit != RecurrenceUnit.months) {
    final nextDay = completedAt.add(
      Duration(days: recurrenceIntervalDays(intervalCount, unit)),
    );
    return _withScheduledTime(nextDay, scheduledDate);
  }

  final targetMonth = DateTime(
    completedAt.year,
    completedAt.month + intervalCount,
  );
  final lastTargetDay = DateTime(
    targetMonth.year,
    targetMonth.month + 1,
    0,
  ).day;
  return DateTime(
    targetMonth.year,
    targetMonth.month,
    completedAt.day > lastTargetDay ? lastTargetDay : completedAt.day,
    scheduledDate.hour,
    scheduledDate.minute,
    scheduledDate.second,
    scheduledDate.millisecond,
    scheduledDate.microsecond,
  );
}

int countRecurrencesUntil({
  required DateTime firstDueDate,
  required DateTime through,
  required int intervalCount,
  required RecurrenceUnit unit,
}) {
  if (!firstDueDate.isAfter(through)) {
    var count = 1;
    var next = firstDueDate;
    while (true) {
      final previous = next;
      next = nextRecurrenceDate(previous, previous, intervalCount, unit);
      if (next.isAfter(through)) break;
      count++;
      if (next == previous) break;
    }
    return count;
  }
  return 0;
}

int countRecurrencesInRange({
  required DateTime firstDueDate,
  required DateTime from,
  required DateTime through,
  required int intervalCount,
  required RecurrenceUnit unit,
}) {
  var next = firstDueDate;
  var guard = 0;
  while (next.isBefore(from) && guard < 10000) {
    next = nextRecurrenceDate(next, next, intervalCount, unit);
    guard++;
  }
  if (next.isAfter(through)) return 0;

  var count = 1;
  while (guard < 10000) {
    next = nextRecurrenceDate(next, next, intervalCount, unit);
    if (next.isAfter(through)) break;
    count++;
    guard++;
  }
  return count;
}

RecurrenceUnit recurrenceUnitFromName(Object? value) {
  if (value is String) {
    for (final unit in RecurrenceUnit.values) {
      if (unit.name == value) return unit;
    }
  }
  return RecurrenceUnit.days;
}

({int count, RecurrenceUnit unit}) recurrenceFromLegacyDays(int days) {
  if (days < 1) {
    return (count: 1, unit: RecurrenceUnit.days);
  }
  if (days % 30 == 0) {
    return (count: days ~/ 30, unit: RecurrenceUnit.months);
  }
  if (days % 7 == 0) {
    return (count: days ~/ 7, unit: RecurrenceUnit.weeks);
  }
  return (count: days, unit: RecurrenceUnit.days);
}

DateTime _withScheduledTime(DateTime date, DateTime scheduledDate) => DateTime(
  date.year,
  date.month,
  date.day,
  scheduledDate.hour,
  scheduledDate.minute,
  scheduledDate.second,
  scheduledDate.millisecond,
  scheduledDate.microsecond,
);
