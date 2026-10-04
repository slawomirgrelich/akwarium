import '../local_reminder_service.dart';
import 'aquarium_journal_service.dart';

class MaintenanceReminderScheduler {
  MaintenanceReminderScheduler({
    Future<void> Function(int id)? cancelNotification,
    Future<void> Function(ScheduledReminder reminder)? scheduleNotification,
  }) : _cancelNotification =
           cancelNotification ?? LocalReminderService.instance.cancel,
       _scheduleNotification =
           scheduleNotification ?? LocalReminderService.instance.schedule;

  final Future<void> Function(int id) _cancelNotification;
  final Future<void> Function(ScheduledReminder reminder) _scheduleNotification;
  final Map<String, MaintenanceTaskModel> _trackedTasks = {};

  Future<void> syncTasks(
    List<MaintenanceTaskModel> tasks, {
    required String notificationBody,
    DateTime? now,
  }) async {
    final activeKeys = tasks.map(_taskKey).toSet();
    final removedKeys = _trackedTasks.keys
        .where((key) => !activeKeys.contains(key))
        .toList(growable: false);
    for (final key in removedKeys) {
      final removed = _trackedTasks.remove(key)!;
      await _cancelNotification(maintenanceTaskNotificationId(removed));
    }
    for (final task in tasks) {
      await scheduleTask(task, notificationBody: notificationBody, now: now);
    }
  }

  Future<void> scheduleTask(
    MaintenanceTaskModel task, {
    required String notificationBody,
    DateTime? now,
  }) async {
    if (task.id.isEmpty) return;
    final key = _taskKey(task);
    final previous = _trackedTasks[key];
    if (previous != null &&
        previous.title == task.title &&
        previous.nextDueDate == task.nextDueDate) {
      return;
    }

    _trackedTasks[key] = task;
    final notificationId = maintenanceTaskNotificationId(task);
    await _cancelNotification(notificationId);

    final currentTime = now ?? DateTime.now();
    final scheduledDate = _scheduledDate(task.nextDueDate, currentTime);
    if (scheduledDate == null) return;

    await _scheduleNotification(
      ScheduledReminder(
        id: notificationId,
        title: task.title,
        body: notificationBody,
        date: scheduledDate,
      ),
    );
  }

  Future<void> cancelTask(MaintenanceTaskModel task) async {
    _trackedTasks.remove(_taskKey(task));
    if (task.id.isNotEmpty) {
      await _cancelNotification(maintenanceTaskNotificationId(task));
    }
  }
}

DateTime? _scheduledDate(DateTime dueDate, DateTime now) {
  if (dueDate.isAfter(now)) return dueDate;

  final dueToday =
      dueDate.year == now.year &&
      dueDate.month == now.month &&
      dueDate.day == now.day;
  return dueToday ? now.add(const Duration(minutes: 1)) : null;
}

String _taskKey(MaintenanceTaskModel task) => '${task.aquariumId}:${task.id}';

int maintenanceTaskNotificationId(MaintenanceTaskModel task) {
  final value = _taskKey(task);
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0x7fffffff;
  }
  return hash;
}
