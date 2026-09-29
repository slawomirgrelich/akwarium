import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../local_reminder_service.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';
import '../models/aquarium_reminder.dart';
import '../services/database_service.dart';

class FirestoreRemindersWidget extends StatefulWidget {
  const FirestoreRemindersWidget({super.key});

  @override
  State<FirestoreRemindersWidget> createState() =>
      _FirestoreRemindersWidgetState();
}

class _FirestoreRemindersWidgetState extends State<FirestoreRemindersWidget> {
  final _database = DatabaseService();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = _auth.currentUser?.uid;
    final tankId = context.watch<AquariumProvider>().activeAquariumId;
    if (userId == null || tankId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<AquariumReminder>>(
      stream: _database.getRemindersStream(userId, tankId),
      builder: (context, snapshot) {
        final reminders = snapshot.data ?? const <AquariumReminder>[];
        final pending = reminders.where((item) => !item.isCompleted).toList();
        final overdue = pending.where((item) => item.isOverdue).toList();
        final upcoming = pending.where((item) => !item.isOverdue).toList();
        final completed = reminders.where((item) => item.isCompleted).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.upcomingTasks,
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (overdue.isNotEmpty)
                      _CountBadge(count: overdue.length, color: Colors.red),
                    IconButton(
                      tooltip: l10n.addReminder,
                      onPressed: () => _openForm(context, userId, tankId),
                      icon: const Icon(Icons.add_alert_outlined),
                    ),
                  ],
                ),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  Text(l10n.remindersLoadError)
                else if (reminders.isEmpty)
                  Text(l10n.noScheduledTasks)
                else ...[
                  if (overdue.isNotEmpty)
                    _ReminderGroup(
                      title: l10n.overdueTasks,
                      color: Colors.red,
                      reminders: overdue,
                      onComplete: (item) => _complete(userId, tankId, item),
                      onSnooze: (item) => _snooze(userId, tankId, item),
                    ),
                  if (upcoming.isNotEmpty)
                    _ReminderGroup(
                      title: l10n.todayAndUpcomingTasks,
                      color: Theme.of(context).colorScheme.primary,
                      reminders: upcoming,
                      onComplete: (item) => _complete(userId, tankId, item),
                      onSnooze: (item) => _snooze(userId, tankId, item),
                    ),
                  if (completed.isNotEmpty)
                    _ReminderGroup(
                      title: l10n.completedTasks,
                      color: Colors.blueGrey,
                      reminders: completed,
                      onComplete: (item) => _complete(userId, tankId, item),
                      onSnooze: (item) => _snooze(userId, tankId, item),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _complete(
    String userId,
    String tankId,
    AquariumReminder reminder,
  ) async {
    await _database.completeReminder(userId, tankId, reminder);
    await LocalReminderService.instance.cancel(reminder.id.hashCode.abs());
  }

  Future<void> _snooze(
    String userId,
    String tankId,
    AquariumReminder reminder,
  ) async {
    final snoozed = reminder.copyWith(
      dueDate: reminder.dueDate.add(const Duration(days: 1)),
      isCompleted: false,
    );
    await _database.updateReminder(userId, tankId, snoozed);
  }

  Future<void> _openForm(
    BuildContext context,
    String userId,
    String tankId,
  ) async {
    final notificationBody = AppLocalizations.of(context)!
        .scheduledAquariumTaskNotification;
    final reminder = await showDialog<AquariumReminder>(
      context: context,
      builder: (_) => const _ReminderDialog(),
    );
    if (reminder == null || !context.mounted) return;
    await _database.addReminder(userId, tankId, reminder);
    await LocalReminderService.instance.schedule(
      ScheduledReminder(
        id: reminder.id.isEmpty
            ? reminder.hashCode.abs()
            : reminder.id.hashCode.abs(),
        title: reminder.title,
        body: notificationBody,
        date: reminder.dueDate,
      ),
    );
  }
}

class _ReminderGroup extends StatelessWidget {
  const _ReminderGroup({
    required this.title,
    required this.color,
    required this.reminders,
    required this.onComplete,
    required this.onSnooze,
  });

  final String title;
  final Color color;
  final List<AquariumReminder> reminders;
  final ValueChanged<AquariumReminder> onComplete;
  final ValueChanged<AquariumReminder> onSnooze;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
        ...reminders.map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              item.isCompleted ? Icons.check_circle : Icons.schedule,
              color: color,
            ),
            title: Text(
              item.title.trim().isEmpty ? l10n.unnamedReminder : item.title,
            ),
            subtitle: Text(_formatDate(item.dueDate)),
            trailing: Wrap(
              spacing: 0,
              children: [
                if (!item.isCompleted)
                  IconButton(
                    tooltip: l10n.snoozeOneDay,
                    onPressed: () => onSnooze(item),
                    icon: const Icon(Icons.next_plan_outlined),
                  ),
                IconButton(
                  tooltip: item.isCompleted
                      ? l10n.markReminderIncomplete
                      : l10n.markReminderComplete,
                  onPressed: () => onComplete(item),
                  icon: Icon(item.isCompleted ? Icons.undo : Icons.check),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: color,
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _ReminderDialog extends StatefulWidget {
  const _ReminderDialog();

  @override
  State<_ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<_ReminderDialog> {
  final _title = TextEditingController();
  ReminderTaskType _type = ReminderTaskType.custom;
  int? _repeatDays;
  DateTime _dueDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addReminderDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.taskName),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderTaskType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.taskTypeLabel),
              items: ReminderTaskType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_taskLabel(l10n, type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _repeatDays,
              decoration: InputDecoration(labelText: l10n.repeatLabel),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.oneTime)),
                DropdownMenuItem(value: 7, child: Text(l10n.everyDays(7))),
                DropdownMenuItem(value: 14, child: Text(l10n.everyDays(14))),
                DropdownMenuItem(value: 30, child: Text(l10n.everyDays(30))),
              ],
              onChanged: (value) => setState(() => _repeatDays = value),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${l10n.dueDate}: ${_formatDate(_dueDate)}'),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                  initialDate: _dueDate,
                );
                if (date != null) {
                  setState(
                    () => _dueDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _dueDate.hour,
                      _dueDate.minute,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_title.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              AquariumReminder(
                id: '',
                tankId: '',
                title: _title.text.trim(),
                taskType: _type,
                dueDate: _dueDate,
                repeatIntervalDays: _repeatDays,
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

String _taskLabel(AppLocalizations l10n, ReminderTaskType type) =>
    switch (type) {
      ReminderTaskType.waterChange => l10n.reminderTaskWaterChange,
      ReminderTaskType.filterClean => l10n.reminderTaskFilterClean,
      ReminderTaskType.waterTest => l10n.reminderTaskWaterTest,
      ReminderTaskType.fertilizer => l10n.reminderTaskFertilizer,
      ReminderTaskType.custom => l10n.reminderTaskCustom,
    };

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
