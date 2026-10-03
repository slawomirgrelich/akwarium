import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../local_reminder_service.dart';
import '../services/aquarium_journal_service.dart';

import 'package:akwarium/utils/app_snackbar.dart';

class MaintenanceScheduleSection extends StatefulWidget {
  const MaintenanceScheduleSection({required this.aquariumId, super.key});

  final String aquariumId;

  @override
  State<MaintenanceScheduleSection> createState() =>
      _MaintenanceScheduleSectionState();
}

class _MaintenanceScheduleSectionState
    extends State<MaintenanceScheduleSection> {
  final _service = AquariumJournalService();
  final _scheduledDates = <String, DateTime>{};
  StreamSubscription<List<MaintenanceTaskModel>>? _taskSubscription;

  @override
  void initState() {
    super.initState();
    _listenForTaskChanges();
  }

  @override
  void didUpdateWidget(covariant MaintenanceScheduleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aquariumId != widget.aquariumId) {
      _listenForTaskChanges();
    }
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  void _listenForTaskChanges() {
    _taskSubscription?.cancel();
    _scheduledDates.clear();
    _taskSubscription = _service.getMaintenanceTasks(widget.aquariumId).listen((
      tasks,
    ) {
      unawaited(_syncTaskNotifications(tasks));
    }, onError: (Object _) {});
  }

  Future<void> _syncTaskNotifications(List<MaintenanceTaskModel> tasks) async {
    for (final task in tasks) {
      await _scheduleTaskNotification(task);
    }
  }

  Future<void> _scheduleTaskNotification(MaintenanceTaskModel task) async {
    final l10n = AppLocalizations.of(context)!;
    if (task.id.isEmpty || _scheduledDates[task.id] == task.nextDueDate) return;
    _scheduledDates[task.id] = task.nextDueDate;

    final now = DateTime.now();
    var scheduledDate = task.nextDueDate;
    if (!scheduledDate.isAfter(now)) {
      final isDueToday =
          scheduledDate.year == now.year &&
          scheduledDate.month == now.month &&
          scheduledDate.day == now.day;
      if (!isDueToday) return;
      scheduledDate = now.add(const Duration(minutes: 1));
    }

    final reminderId = _notificationId(task);
    await LocalReminderService.instance.cancel(reminderId);
    await LocalReminderService.instance.schedule(
      ScheduledReminder(
        id: reminderId,
        title: task.title,
        body: l10n.scheduledAquariumTaskNotification,
        date: scheduledDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    l10n.maintenanceScheduleTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: l10n.addTask,
                  onPressed: () => _openTaskForm(),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            StreamBuilder<List<MaintenanceTaskModel>>(
              stream: _service.getMaintenanceTasks(widget.aquariumId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Text(l10n.maintenanceLoadError);
                }
                final tasks = snapshot.data ?? const <MaintenanceTaskModel>[];
                if (tasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.maintenanceEmpty),
                  );
                }
                return Column(
                  children: tasks
                      .map(
                        (task) => _MaintenanceTaskTile(
                          task: task,
                          onComplete: () => _completeTask(task),
                          onEdit: () => _openTaskForm(task),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTaskForm([MaintenanceTaskModel? existingTask]) async {
    final task = await showDialog<MaintenanceTaskModel>(
      context: context,
      builder: (_) => _MaintenanceTaskDialog(
        aquariumId: widget.aquariumId,
        existingTask: existingTask,
      ),
    );
    if (task == null) return;
    try {
      final savedTask = await _service.saveMaintenanceTask(task);
      await _scheduleTaskNotification(savedTask);
    } on Object catch (error) {
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.maintenanceTaskAddedError('$error'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _completeTask(MaintenanceTaskModel task) async {
    try {
      final performedAt = DateTime.now();
      await _service.completeMaintenanceTask(task, completedAt: performedAt);
      final nextDue = DateTime(
        performedAt.year,
        performedAt.month,
        performedAt.day,
        task.nextDueDate.hour,
        task.nextDueDate.minute,
      ).add(Duration(days: task.repeatFrequencyDays));
      await _scheduleTaskNotification(
        MaintenanceTaskModel(
          id: task.id,
          aquariumId: task.aquariumId,
          taskType: task.taskType,
          title: task.title,
          repeatFrequencyDays: task.repeatFrequencyDays,
          lastPerformedDate: performedAt,
          nextDueDate: nextDue,
        ),
      );
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!
                  .maintenanceTaskCompleted(task.title),
            ),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        context.showAppSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!
                  .maintenanceTaskUpdateError('$error'),
            ),
          ),
        );
      }
    }
  }
}

class _MaintenanceTaskTile extends StatelessWidget {
  const _MaintenanceTaskTile({
    required this.task,
    required this.onComplete,
    required this.onEdit,
  });

  final MaintenanceTaskModel task;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(
      task.nextDueDate.year,
      task.nextDueDate.month,
      task.nextDueDate.day,
    );
    final daysRemaining = dueDay.difference(today).inDays;
    final overdue = daysRemaining < 0;
    final dueToday = daysRemaining == 0;
    final color = overdue
        ? Theme.of(context).colorScheme.error
        : dueToday
        ? Colors.orange.shade800
        : Theme.of(context).colorScheme.primary;
    final status = overdue
        ? l10n.taskOverdue
        : dueToday
        ? l10n.forToday
        : l10n.taskDueInDays(daysRemaining);
    final frequency = task.repeatFrequencyDays == 1
        ? l10n.dailyRecurrence
        : l10n.everyDays(task.repeatFrequencyDays);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(_taskIcon(task.taskType), color: color),
      title: Text(
        task.taskType == 'custom'
            ? task.title
            : _maintenanceTaskLabel(l10n, task.taskType),
      ),
      subtitle: Text(
        '$frequency · ${l10n.lastPerformedOn(_dateLabel(task.lastPerformedDate))}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.editTaskTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
              TextButton(onPressed: onComplete, child: Text(l10n.performTask)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaintenanceTaskDialog extends StatefulWidget {
  const _MaintenanceTaskDialog({required this.aquariumId, this.existingTask});

  final String aquariumId;
  final MaintenanceTaskModel? existingTask;

  @override
  State<_MaintenanceTaskDialog> createState() => _MaintenanceTaskDialogState();
}

class _MaintenanceTaskDialogState extends State<_MaintenanceTaskDialog> {
  static const _taskTypes = [
    'feeding',
    'waterChange',
    'filterCleaning',
    'plantTrimming',
    'fertilizing',
    'quickCheck',
    'custom',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _frequencyController;
  late String _taskType;
  late bool _isDaily;
  late DateTime _lastPerformedDate;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    final existingTask = widget.existingTask;
    _taskType = existingTask?.taskType ?? 'waterChange';
    _isDaily = existingTask?.repeatFrequencyDays == 1;
    _frequencyController = TextEditingController(
      text: '${existingTask?.repeatFrequencyDays ?? 7}',
    );
    _lastPerformedDate = existingTask?.lastPerformedDate ?? DateTime.now();
    _reminderTime = TimeOfDay.fromDateTime(_lastPerformedDate);
  }

  @override
  void dispose() {
    _frequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.existingTask != null;
    return AlertDialog(
      title: Text(
        isEditing ? l10n.editMaintenanceTask : l10n.addMaintenanceTask,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.65,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _taskTypes.contains(_taskType)
                      ? _taskType
                      : 'custom',
                  decoration: InputDecoration(
                    labelText: l10n.maintenanceTaskTypeLabel,
                  ),
                  items: _taskTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_maintenanceTaskLabel(l10n, type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _taskType = value);
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.dailyRecurrence),
                  value: _isDaily,
                  onChanged: (value) {
                    setState(() {
                      _isDaily = value;
                      if (value) _frequencyController.text = '1';
                    });
                  },
                ),
                if (!_isDaily) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _frequencyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.repeatEveryDays,
                      suffixText: l10n.daysUnit,
                    ),
                    validator: (value) {
                      final days = int.tryParse(value?.trim() ?? '');
                      if (days == null || days < 1) {
                        return l10n.enterPositiveDays;
                      }
                      return null;
                    },
                  ),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.maintenanceLastPerformed),
                  subtitle: Text(_dateLabel(_lastPerformedDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickLastPerformedDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.reminderTimeLabel),
                  subtitle: Text(_reminderTime.format(context)),
                  trailing: const Icon(Icons.access_time_outlined),
                  onTap: _pickReminderTime,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            final frequencyDays = _isDaily
                ? 1
                : int.parse(_frequencyController.text.trim());
            final lastPerformed = DateTime(
              _lastPerformedDate.year,
              _lastPerformedDate.month,
              _lastPerformedDate.day,
              _reminderTime.hour,
              _reminderTime.minute,
            );
            final title = _maintenanceTaskLabel(l10n, _taskType);
            Navigator.pop(
              context,
              MaintenanceTaskModel(
                id: widget.existingTask?.id ?? '',
                aquariumId: widget.aquariumId,
                taskType: _taskType,
                title: title,
                repeatFrequencyDays: frequencyDays,
                lastPerformedDate: lastPerformed,
                nextDueDate: lastPerformed.add(Duration(days: frequencyDays)),
              ),
            );
          },
          child: Text(isEditing ? l10n.save : l10n.add),
        ),
      ],
    );
  }

  Future<void> _pickLastPerformedDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _lastPerformedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => _lastPerformedDate = selected);
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (selected != null) setState(() => _reminderTime = selected);
  }
}

String _maintenanceTaskLabel(AppLocalizations l10n, String taskType) =>
    switch (taskType) {
      'feeding' => l10n.maintenanceTaskFeeding,
      'waterChange' => l10n.maintenanceTaskWaterChange,
      'filterCleaning' => l10n.maintenanceTaskFilterCleaning,
      'plantTrimming' => l10n.maintenanceTaskPlantTrimming,
      'fertilizing' => l10n.maintenanceTaskFertilizing,
      'quickCheck' => l10n.maintenanceTaskQuickCheck,
      _ => l10n.maintenanceTaskCustom,
    };

int _notificationId(MaintenanceTaskModel task) {
  final value = '${task.aquariumId}:${task.id}';
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash = ((hash ^ codeUnit) * 0x01000193) & 0x7fffffff;
  }
  return hash;
}

IconData _taskIcon(String taskType) => switch (taskType) {
  'feeding' => Icons.set_meal_outlined,
  'waterChange' => Icons.water_drop_outlined,
  'filterCleaning' => Icons.filter_alt_outlined,
  'plantTrimming' => Icons.content_cut_outlined,
  'fertilizing' => Icons.grass_outlined,
  'quickCheck' => Icons.fact_check_outlined,
  _ => Icons.task_alt_outlined,
};

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
