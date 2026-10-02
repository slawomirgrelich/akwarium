DateTime nextRecurrenceDateAfter(
  DateTime completedAt,
  DateTime scheduledDate,
  int intervalDays,
) {
  if (intervalDays < 1) {
    throw ArgumentError.value(
      intervalDays,
      'intervalDays',
      'Must be positive.',
    );
  }
  final nextDay = completedAt.add(Duration(days: intervalDays));
  return DateTime(
    nextDay.year,
    nextDay.month,
    nextDay.day,
    scheduledDate.hour,
    scheduledDate.minute,
    scheduledDate.second,
    scheduledDate.millisecond,
    scheduledDate.microsecond,
  );
}
