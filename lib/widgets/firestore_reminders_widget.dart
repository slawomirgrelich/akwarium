import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../local_reminder_service.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';
import '../models/aquarium_reminder.dart';
import '../utils/recurrence_interval.dart';
import '../services/database_service.dart';
import '../utils/app_snackbar.dart';

class FirestoreRemindersWidget extends StatefulWidget {
  const FirestoreRemindersWidget({this.compact = false, super.key});

  final bool compact;

  @override
  State<FirestoreRemindersWidget> createState() =>
      _FirestoreRemindersWidgetState();
}

class _FirestoreRemindersWidgetState extends State<FirestoreRemindersWidget> {
  final _database = DatabaseService();
  final _auth = FirebaseAuth.instance;
  bool _showAllCompactTasks = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = _auth.currentUser?.uid;
    final tankId = context.watch<AquariumProvider>().resolveAquariumId();
    if (userId == null || tankId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<AquariumReminder>>(
      stream: _database.getRemindersStream(userId, tankId),
      builder: (context, snapshot) {
        final reminders = snapshot.data ?? const <AquariumReminder>[];
        final pending = reminders.where((item) => !item.isCompleted).toList();
        final overdue = pending.where((item) => item.isOverdue).toList();
        final upcoming = pending.where((item) => !item.isOverdue).toList();
        final completed = reminders.where((item) => item.isCompleted).toList();
        final openReminders = [...overdue, ...upcoming]
          ..sort((first, second) => first.dueDate.compareTo(second.dueDate));
        final compactPreview =
            widget.compact && !_showAllCompactTasks && openReminders.length > 3;
        final visibleOpenReminders = compactPreview
            ? openReminders.take(3).toList()
            : openReminders;
        final visibleOverdue = visibleOpenReminders
            .where((item) => item.isOverdue)
            .toList();
        final visibleUpcoming = visibleOpenReminders
            .where((item) => !item.isOverdue)
            .toList();
        final visibleCompleted = widget.compact && !_showAllCompactTasks
            ? const <AquariumReminder>[]
            : completed;
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
                  if (visibleOverdue.isNotEmpty)
                    _ReminderGroup(
                      title: l10n.overdueTasks,
                      color: Colors.red,
                      reminders: visibleOverdue,
                      onComplete: (item) => _complete(userId, tankId, item),
                      onSnooze: (item) =>
                          _snooze(context, userId, tankId, item),
                      onEdit: (item) => _edit(context, userId, tankId, item),
                    ),
                  if (visibleUpcoming.isNotEmpty)
                    _ReminderGroup(
                      title: l10n.todayAndUpcomingTasks,
                      color: Theme.of(context).colorScheme.primary,
                      reminders: visibleUpcoming,
                      onComplete: (item) => _complete(userId, tankId, item),
                      onSnooze: (item) =>
                          _snooze(context, userId, tankId, item),
                      onEdit: (item) => _edit(context, userId, tankId, item),
                    ),
                  if (visibleCompleted.isNotEmpty)
                    _ReminderGroup(
                      title: l10n.completedTasks,
                      color: Colors.blueGrey,
                      reminders: visibleCompleted,
                      onComplete: (item) => _complete(userId, tankId, item),
                      onSnooze: (item) =>
                          _snooze(context, userId, tankId, item),
                      onEdit: (item) => _edit(context, userId, tankId, item),
                    ),
                  if (widget.compact && pending.length > 3)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(
                          () => _showAllCompactTasks = !_showAllCompactTasks,
                        ),
                        child: Text(
                          _showAllCompactTasks
                              ? l10n.showFewerTasks
                              : l10n.showMoreTasks,
                        ),
                      ),
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
    final l10n = AppLocalizations.of(context)!;
    if (reminder.taskType == ReminderTaskType.waterChange &&
        context.read<AquariumProvider>().selectedAquarium?.isArchived == true) {
      context.showAppSnackBar(
        SnackBar(content: Text(l10n.archivedHistoryNotice)),
      );
      return;
    }
    try {
      final AquariumReminder updated;
      if (reminder.isCompleted) {
        updated = reminder.copyWith(isCompleted: false);
        await _database.updateReminder(userId, tankId, updated);
      } else {
        final completedAt = DateTime.now();
        if (reminder.taskType == ReminderTaskType.waterChange) {
          context.read<AquariumProvider>().addWaterChange(
            waterChangeForReminder(
              reminderId: reminder.id,
              aquariumId: tankId,
              title: reminder.title,
              completedAt: completedAt,
            ),
          );
        }
        updated = await _database.completeReminder(
          userId,
          tankId,
          reminder,
          completedAt: completedAt,
        );
      }
      if (updated.isCompleted || !updated.isEnabled) {
        await LocalReminderService.instance.cancel(updated.id.hashCode.abs());
      } else {
        await _schedule(updated, l10n.scheduledAquariumTaskNotification);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Aquarium reminder completion failed: $error\n$stackTrace');
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(content: Text(l10n.aquariumTaskUpdateFailed)),
        );
      }
    }
  }

  Future<void> _snooze(
    BuildContext context,
    String userId,
    String tankId,
    AquariumReminder reminder,
  ) async {
    final notificationBody = AppLocalizations.of(context)!
        .scheduledAquariumTaskNotification;
    final snoozed = reminder.copyWith(
      dueDate: reminder.dueDate.add(const Duration(days: 1)),
      isCompleted: false,
    );
    await _database.updateReminder(userId, tankId, snoozed);
    await _schedule(snoozed, notificationBody);
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
      builder: (_) => const AquariumReminderDialog(),
    );
    if (reminder == null || !context.mounted) return;
    final saved = await _database.addReminder(userId, tankId, reminder);
    await _schedule(saved, notificationBody);
  }

  Future<void> _edit(
    BuildContext context,
    String userId,
    String tankId,
    AquariumReminder existing,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final notificationBody = l10n.scheduledAquariumTaskNotification;
    final reminder = await showDialog<AquariumReminder>(
      context: context,
      builder: (_) => AquariumReminderDialog(initial: existing),
    );
    if (reminder == null || !context.mounted) return;
    final updated = reminder.copyWith(
      id: existing.id,
      tankId: tankId,
      isCompleted: existing.isCompleted,
      lastCompletedAt: existing.lastCompletedAt,
      isEnabled: existing.isEnabled,
    );
    try {
      await _database.updateReminder(userId, tankId, updated);
      if (updated.isCompleted || !updated.isEnabled) {
        await LocalReminderService.instance.cancel(updated.id.hashCode.abs());
      } else {
        await _schedule(updated, notificationBody);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Aquarium reminder edit failed: $error\n$stackTrace');
      if (context.mounted) {
        context.showAppSnackBar(
          SnackBar(content: Text(l10n.aquariumTaskUpdateFailed)),
        );
      }
    }
  }

  Future<void> _schedule(AquariumReminder reminder, String body) {
    return LocalReminderService.instance.schedule(
      ScheduledReminder(
        id: reminder.id.hashCode.abs(),
        title: reminder.title,
        body: body,
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
    required this.onEdit,
  });

  final String title;
  final Color color;
  final List<AquariumReminder> reminders;
  final ValueChanged<AquariumReminder> onComplete;
  final ValueChanged<AquariumReminder> onSnooze;
  final ValueChanged<AquariumReminder> onEdit;

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
            subtitle: Text(
              item.repeatCount == null
                  ? '${_formatDate(item.dueDate)} · ${_formatTime(item.dueDate)}'
                  : '${_formatDate(item.dueDate)} · ${_formatTime(item.dueDate)} · '
                        '${item.repeatCount == 1 && item.intervalUnit == RecurrenceUnit.days ? l10n.dailyRecurrence : '${l10n.repeatEveryLabel} ${item.repeatCount} ${switch (item.intervalUnit) {
                                RecurrenceUnit.days => l10n.daysUnitShort,
                                RecurrenceUnit.weeks => l10n.weeksUnit,
                                RecurrenceUnit.months => l10n.monthsUnit,
                              }}'}',
            ),
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
                  tooltip: l10n.editReminder,
                  onPressed: () => onEdit(item),
                  icon: const Icon(Icons.edit_outlined),
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

class AquariumReminderDialog extends StatefulWidget {
  const AquariumReminderDialog({this.initial, super.key});

  final AquariumReminder? initial;

  @override
  State<AquariumReminderDialog> createState() => _AquariumReminderDialogState();
}

class _AquariumReminderDialogState extends State<AquariumReminderDialog> {
  final _title = TextEditingController();
  final _interval = TextEditingController(text: '1');
  ReminderTaskType _type = ReminderTaskType.custom;
  bool _recurring = false;
  RecurrenceUnit _intervalUnit = RecurrenceUnit.weeks;
  DateTime _dueDate = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _title.text = initial.title;
      _type = initial.taskType;
      _recurring = initial.repeatCount != null;
      _interval.text = '${initial.repeatCount ?? 1}';
      _intervalUnit = initial.intervalUnit;
      _dueDate = initial.dueDate;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _interval.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? l10n.addReminderDialogTitle
            : l10n.editReminderDialogTitle,
      ),
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.repeatCyclically),
              subtitle: Text(l10n.autoScheduleNextDate),
              value: _recurring,
              onChanged: (value) => setState(() => _recurring = value),
            ),
            if (_recurring)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _interval,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.repeatEveryLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<RecurrenceUnit>(
                      initialValue: _intervalUnit,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.intervalUnitLabel,
                      ),
                      items: RecurrenceUnit.values
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(switch (unit) {
                                RecurrenceUnit.days => l10n.daysUnitShort,
                                RecurrenceUnit.weeks => l10n.weeksUnit,
                                RecurrenceUnit.months => l10n.monthsUnit,
                              }),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _intervalUnit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.dueDate),
              subtitle: Text(
                '${_formatDate(_dueDate)} · ${_formatTime(_dueDate)}',
              ),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(
                    tooltip: l10n.dueDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: _pickDate,
                  ),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .timePickerDialHelpText,
                    icon: const Icon(Icons.schedule_outlined),
                    onPressed: _pickTime,
                  ),
                ],
              ),
              onTap: _pickDate,
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
            final intervalCount = int.tryParse(_interval.text.trim());
            if (_recurring && (intervalCount == null || intervalCount < 1)) {
              return;
            }
            final initial = widget.initial;
            Navigator.pop(
              context,
              AquariumReminder(
                id: initial?.id ?? '',
                tankId: initial?.tankId ?? '',
                title: _title.text.trim(),
                taskType: _type,
                dueDate: _dueDate,
                repeatIntervalDays: _recurring
                    ? recurrenceIntervalDays(intervalCount!, _intervalUnit)
                    : null,
                intervalCount: _recurring ? intervalCount : null,
                intervalUnit: _intervalUnit,
                isCompleted: initial?.isCompleted ?? false,
                lastCompletedAt: initial?.lastCompletedAt,
                isEnabled: initial?.isEnabled ?? true,
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _dueDate,
    );
    if (date != null && mounted) {
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
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
    );
    if (time != null && mounted) {
      setState(
        () => _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          time.hour,
          time.minute,
        ),
      );
    }
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

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
