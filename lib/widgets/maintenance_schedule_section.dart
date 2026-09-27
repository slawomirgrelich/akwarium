import 'package:flutter/material.dart';

import '../services/aquarium_journal_service.dart';

class MaintenanceScheduleSection extends StatefulWidget {
  const MaintenanceScheduleSection({required this.aquariumId, super.key});

  final String aquariumId;

  @override
  State<MaintenanceScheduleSection> createState() =>
      _MaintenanceScheduleSectionState();
}

class _MaintenanceScheduleSectionState extends State<MaintenanceScheduleSection> {
  final _service = AquariumJournalService();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Harmonogram pielęgnacji',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Dodaj zadanie',
                  onPressed: _addTask,
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
                  return const Text('Nie udało się wczytać harmonogramu.');
                }
                final tasks = snapshot.data ?? const <MaintenanceTaskModel>[];
                if (tasks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Nie dodano jeszcze zadań pielęgnacyjnych.'),
                  );
                }
                return Column(
                  children: tasks
                      .map(
                        (task) => _MaintenanceTaskTile(
                          task: task,
                          onComplete: () => _completeTask(task),
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

  Future<void> _addTask() async {
    final task = await showDialog<MaintenanceTaskModel>(
      context: context,
      builder: (_) => _MaintenanceTaskDialog(aquariumId: widget.aquariumId),
    );
    if (task == null) return;
    try {
      await _service.addMaintenanceTask(task);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się dodać zadania: $error')),
        );
      }
    }
  }

  Future<void> _completeTask(MaintenanceTaskModel task) async {
    try {
      await _service.completeMaintenanceTask(task);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wykonano: ${task.title}')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się zaktualizować zadania: $error')),
        );
      }
    }
  }
}

class _MaintenanceTaskTile extends StatelessWidget {
  const _MaintenanceTaskTile({required this.task, required this.onComplete});

  final MaintenanceTaskModel task;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
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
        ? 'Po terminie!'
        : dueToday
        ? 'Dzisiaj'
        : 'Za $daysRemaining dni';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(_taskIcon(task.taskType), color: color),
      title: Text(task.title),
      subtitle: Text(
        'Co ${task.repeatFrequencyDays} dni · ostatnio: ${_dateLabel(task.lastPerformedDate)}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          InkWell(
            onTap: onComplete,
            child: Text(
              'Wykonaj',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaintenanceTaskDialog extends StatefulWidget {
  const _MaintenanceTaskDialog({required this.aquariumId});

  final String aquariumId;

  @override
  State<_MaintenanceTaskDialog> createState() => _MaintenanceTaskDialogState();
}

class _MaintenanceTaskDialogState extends State<_MaintenanceTaskDialog> {
  static const _taskOptions = <String, String>{
    'waterChange': 'Podmiana wody',
    'filterCleaning': 'Czyszczenie filtra',
    'plantTrimming': 'Przycinanie roślin',
    'fertilizing': 'Nawożenie',
    'custom': 'Inne zadanie',
  };

  String _taskType = 'waterChange';
  int _frequencyDays = 7;
  DateTime _lastPerformedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dodaj zadanie pielęgnacyjne'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _taskType,
            decoration: const InputDecoration(labelText: 'Rodzaj zadania'),
            items: _taskOptions.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _taskType = value);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _frequencyDays,
            decoration: const InputDecoration(labelText: 'Powtarzaj co'),
            items: const [7, 14, 30, 60, 90]
                .map((days) => DropdownMenuItem(
                      value: days,
                      child: Text('$days dni'),
                    ))
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) setState(() => _frequencyDays = value);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ostatnio wykonano'),
            subtitle: Text(_dateLabel(_lastPerformedDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickLastPerformedDate,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () {
            final title = _taskOptions[_taskType]!;
            Navigator.pop(
              context,
              MaintenanceTaskModel(
                id: '',
                aquariumId: widget.aquariumId,
                taskType: _taskType,
                title: title,
                repeatFrequencyDays: _frequencyDays,
                lastPerformedDate: _lastPerformedDate,
                nextDueDate: _lastPerformedDate.add(
                  Duration(days: _frequencyDays),
                ),
              ),
            );
          },
          child: const Text('Dodaj'),
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
}

IconData _taskIcon(String taskType) => switch (taskType) {
  'waterChange' => Icons.water_drop_outlined,
  'filterCleaning' => Icons.filter_alt_outlined,
  'plantTrimming' => Icons.content_cut_outlined,
  'fertilizing' => Icons.grass_outlined,
  _ => Icons.task_alt_outlined,
};

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
