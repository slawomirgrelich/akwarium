import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../local_reminder_service.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';
import '../services/aquarium_journal_service.dart';
import '../services/pro_access_service.dart';
import '../widgets/pro_paywall_dialog.dart';

class JournalAndRemindersScreen extends StatefulWidget {
  const JournalAndRemindersScreen({super.key});

  @override
  State<JournalAndRemindersScreen> createState() =>
      _JournalAndRemindersScreenState();
}

class _JournalAndRemindersScreenState extends State<JournalAndRemindersScreen> {
  final _service = AquariumJournalService();
  JournalEntryType? _entryFilter;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AquariumProvider>();
    final aquariumId = provider.activeAquariumId;
    return StreamBuilder<List<JournalEntryModel>>(
      stream: _service.getJournalEntries(aquariumId),
      builder: (context, journalSnapshot) {
        return StreamBuilder<List<ReminderModel>>(
          stream: _service.getReminders(aquariumId),
          builder: (context, reminderSnapshot) {
            if (journalSnapshot.connectionState == ConnectionState.waiting &&
                reminderSnapshot.connectionState == ConnectionState.waiting &&
                !journalSnapshot.hasData &&
                !reminderSnapshot.hasData) {
              return const _JournalScaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final journal = _mergeJournalEntries(
              journalSnapshot.data ?? const <JournalEntryModel>[],
              provider.journalEntries,
            );
            final reminders = reminderSnapshot.data ?? const <ReminderModel>[];
            final error = journalSnapshot.error ?? reminderSnapshot.error;
            if (error != null && journal.isEmpty && reminders.isEmpty) {
              return _JournalScaffold(
                body: _JournalError(message: _messageFor(error)),
              );
            }

            return _JournalScaffold(
              onAdd: () => _openEntryForm(context, aquariumId),
              body: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.timeline), text: l10n.timeline),
                        Tab(
                          icon: Icon(Icons.calendar_month),
                          text: l10n.calendar,
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _TimelineTab(
                            entries: journal,
                            filter: _entryFilter,
                            onFilterChanged: (value) =>
                                setState(() => _entryFilter = value),
                          ),
                          _CalendarTab(
                            reminders: reminders,
                            selectedDay: _selectedDay,
                            focusedDay: _focusedDay,
                            onDaySelected: (selected, focused) => setState(() {
                              _selectedDay = selected;
                              _focusedDay = focused;
                            }),
                            onAdd: () => _openReminderForm(
                              context,
                              aquariumId,
                              reminders,
                            ),
                            onComplete: (reminder) =>
                                _completeReminder(context, reminder),
                            onDelete: (reminder) =>
                                _deleteReminder(context, reminder),
                            isProUser: context
                                .watch<ProAccessService>()
                                .isProUser,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<JournalEntryModel> _mergeJournalEntries(
    List<JournalEntryModel> cloudEntries,
    List<JournalEntry> localEntries,
  ) {
    final entriesById = <String, JournalEntryModel>{
      for (final entry in cloudEntries) entry.id: entry,
    };
    for (final entry in localEntries) {
      entriesById[entry.id] = JournalEntryModel(
        id: entry.id,
        aquariumId: entry.aquariumId,
        timestamp: entry.timestamp,
        entryType: switch (entry.type) {
          'waterChange' => JournalEntryType.waterChange,
          'filter' => JournalEntryType.filter,
          'trimming' => JournalEntryType.trimming,
          'medication' => JournalEntryType.medication,
          _ => JournalEntryType.cleaning,
        },
        title: entry.title,
        notes: entry.description,
      );
    }
    return entriesById.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> _openEntryForm(BuildContext context, String aquariumId) async {
    final entry = await showDialog<JournalEntryModel>(
      context: context,
      builder: (_) => const _JournalEntryFormDialog(),
    );
    if (entry == null || !context.mounted) return;
    try {
      await _service.addJournalEntry(
        JournalEntryModel(
          id: entry.id,
          aquariumId: aquariumId,
          timestamp: entry.timestamp,
          entryType: entry.entryType,
          title: entry.title,
          notes: entry.notes,
          percentageWaterChanged: entry.percentageWaterChanged,
        ),
      );
      if (context.mounted) _showMessage(context, 'Wpis został dodany.');
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _openReminderForm(
    BuildContext context,
    String aquariumId,
    List<ReminderModel> reminders,
  ) async {
    final isPro = context.read<ProAccessService>().isProUser;
    final activeCount = reminders.where((item) => !item.isCompleted).length;
    if (!isPro && activeCount >= 2) {
      await ProPaywallDialog.show(context);
      return;
    }

    final reminder = await showDialog<ReminderModel>(
      context: context,
      builder: (_) => const _ReminderFormDialog(),
    );
    if (reminder == null || !context.mounted) return;
    if (!isPro && reminder.isProFeature) {
      await ProPaywallDialog.show(context);
      return;
    }

    final saved = reminder.copyWith(aquariumId: aquariumId);
    try {
      await _service.addReminder(saved);
      if (isPro) await _scheduleReminder(saved);
      if (context.mounted) {
        _showMessage(context, 'Przypomnienie zostało dodane.');
      }
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _completeReminder(
    BuildContext context,
    ReminderModel reminder,
  ) async {
    final isPro = context.read<ProAccessService>().isProUser;
    try {
      await _service.markReminderCompleted(reminder);
      if (isPro && reminder.isRecurring) {
        await _scheduleReminder(
          reminder.copyWith(
            nextDueDate: reminder.nextDueDate.add(
              Duration(days: reminder.intervalDays),
            ),
            isCompleted: false,
          ),
        );
      } else {
        await LocalReminderService.instance.cancel(
          _notificationId(reminder.id),
        );
      }
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _deleteReminder(
    BuildContext context,
    ReminderModel reminder,
  ) async {
    try {
      await _service.deleteReminder(reminder);
      await LocalReminderService.instance.cancel(_notificationId(reminder.id));
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _scheduleReminder(ReminderModel reminder) {
    return LocalReminderService.instance.schedule(
      AquariumReminder(
        id: _notificationId(reminder.id),
        title: reminder.title,
        body: reminder.isRecurring
            ? 'Powtarza się co ${reminder.intervalDays} dni'
            : 'Czas wykonać zadanie w akwarium',
        date: reminder.nextDueDate,
      ),
    );
  }

  int _notificationId(String id) => id.hashCode & 0x7fffffff;

  String _messageFor(Object error) {
    if (error is AquariumJournalServiceException) return error.message;
    return 'Nie udało się wczytać dziennika.';
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }
}

class _JournalScaffold extends StatelessWidget {
  const _JournalScaffold({required this.body, this.onAdd});

  final Widget body;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F6),
      appBar: AppBar(
        title: const Text('Dziennik akwarysty'),
        actions: [
          if (onAdd != null)
            IconButton(
              tooltip: 'Dodaj wpis',
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: body,
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({
    required this.entries,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<JournalEntryModel> entries;
  final JournalEntryType? filter;
  final ValueChanged<JournalEntryType?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = entries
        .where((entry) => filter == null || entry.entryType == filter)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(l10n.allEntries),
                selected: filter == null,
                onSelected: (_) => onFilterChanged(null),
              ),
              ...JournalEntryType.values.map(
                (type) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(type.label),
                    selected: filter == type,
                    onSelected: (_) => onFilterChanged(type),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (filtered.isEmpty)
          _JournalEmpty(icon: Icons.timeline, text: l10n.noEntriesForFilter)
        else
          ...filtered.map((entry) => _JournalTimelineCard(entry: entry)),
      ],
    );
  }
}

class _JournalTimelineCard extends StatelessWidget {
  const _JournalTimelineCard({required this.entry});

  final JournalEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.12),
          child: Icon(_iconFor(entry.entryType), color: Colors.teal),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${entry.entryType.label} · ${_formatDate(entry.timestamp)}\n${entry.notes}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: entry.percentageWaterChanged == null
            ? null
            : Text('${entry.percentageWaterChanged!.toStringAsFixed(0)}%'),
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({
    required this.reminders,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onAdd,
    required this.onComplete,
    required this.onDelete,
    required this.isProUser,
  });

  final List<ReminderModel> reminders;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final VoidCallback onAdd;
  final ValueChanged<ReminderModel> onComplete;
  final ValueChanged<ReminderModel> onDelete;
  final bool isProUser;

  @override
  Widget build(BuildContext context) {
    final selected = reminders
        .where((reminder) => isSameDay(reminder.nextDueDate, selectedDay))
        .toList();
    final upcoming =
        reminders.where((reminder) => !reminder.isCompleted).toList()
          ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Nadchodzące zadania',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isProUser) const ProBadge(compact: true),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Dodaj przypomnienie',
              onPressed: onAdd,
              icon: const Icon(Icons.add_task),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: SizedBox(
            height: 360,
            child: Builder(
              builder: (context) {
                try {
                  return TableCalendar<ReminderModel>(
                    locale: 'pl_PL',
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2035),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                    onDaySelected: onDaySelected,
                    eventLoader: (day) => reminders
                        .where(
                          (reminder) => isSameDay(reminder.nextDueDate, day),
                        )
                        .toList(),
                    calendarStyle: const CalendarStyle(
                      markerDecoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(formatButtonVisible: false),
                  );
                } catch (error) {
                  return _CalendarFallback(error: error);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isSameDay(selectedDay, DateTime.now()) ? 'Na dziś' : 'Wybrany dzień',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (selected.isEmpty)
          const _JournalEmpty(
            icon: Icons.event_available,
            text: 'Brak zadań na ten dzień.',
          )
        else
          ...selected.map(
            (reminder) => _ReminderTile(
              reminder: reminder,
              onComplete: () => onComplete(reminder),
              onDelete: () => onDelete(reminder),
            ),
          ),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Najbliższe zadania',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...upcoming
              .take(5)
              .map(
                (reminder) => _ReminderTile(
                  reminder: reminder,
                  onComplete: () => onComplete(reminder),
                  onDelete: () => onDelete(reminder),
                ),
              ),
        ],
      ],
    );
  }
}

class _CalendarFallback extends StatelessWidget {
  const _CalendarFallback({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Nie udało się wczytać kalendarza. Spróbuj ponownie później.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.onComplete,
    required this.onDelete,
  });

  final ReminderModel reminder;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final overdue =
        reminder.nextDueDate.isBefore(DateTime.now()) && !reminder.isCompleted;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          reminder.isCompleted
              ? Icons.check_circle
              : Icons.notifications_active_outlined,
          color: reminder.isCompleted
              ? Colors.teal
              : overdue
              ? Colors.red
              : Colors.orange,
        ),
        title: Text(reminder.title),
        subtitle: Text(
          '${_formatDate(reminder.nextDueDate)}${reminder.isRecurring ? ' · co ${reminder.intervalDays} dni' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: reminder.isCompleted
                  ? 'Oznacz jako niewykonane'
                  : 'Oznacz jako wykonane',
              onPressed: onComplete,
              icon: Icon(
                reminder.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: reminder.isCompleted ? Colors.teal : Colors.orange,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opcje przypomnienia',
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('Usuń')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntryFormDialog extends StatefulWidget {
  const _JournalEntryFormDialog();

  @override
  State<_JournalEntryFormDialog> createState() =>
      _JournalEntryFormDialogState();
}

class _JournalEntryFormDialogState extends State<_JournalEntryFormDialog> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _percentage = TextEditingController();
  JournalEntryType _type = JournalEntryType.waterChange;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _percentage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowa czynność'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tytuł'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<JournalEntryType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Typ czynności'),
              items: JournalEntryType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            if (_type == JournalEntryType.waterChange) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _percentage,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Podmieniona woda',
                  suffixText: '%',
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notatka'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(onPressed: _save, child: const Text('Zapisz')),
      ],
    );
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    Navigator.pop(
      context,
      JournalEntryModel(
        id: '',
        aquariumId: '',
        timestamp: DateTime.now(),
        entryType: _type,
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        percentageWaterChanged: double.tryParse(
          _percentage.text.trim().replaceAll(',', '.'),
        ),
      ),
    );
  }
}

class _ReminderFormDialog extends StatefulWidget {
  const _ReminderFormDialog();

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  final _title = TextEditingController();
  final _interval = TextEditingController(text: '7');
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 1));
  bool _recurring = false;

  @override
  void dispose() {
    _title.dispose();
    _interval.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowe przypomnienie'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Nazwa zadania',
                prefixIcon: Icon(Icons.task_alt),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Termin'),
              subtitle: Text(_formatDate(_nextDueDate)),
              onTap: _selectDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Powtarzaj cyklicznie'),
              subtitle: const Text('Automatycznie planuj kolejny termin'),
              value: _recurring,
              onChanged: (value) => setState(() => _recurring = value),
            ),
            if (_recurring)
              TextField(
                controller: _interval,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Powtarzaj co',
                  suffixText: 'dni · funkcja PRO',
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        FilledButton(onPressed: _save, child: const Text('Zapisz')),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _nextDueDate,
    );
    if (date != null && mounted) setState(() => _nextDueDate = date);
  }

  void _save() {
    final interval = int.tryParse(_interval.text) ?? 0;
    if (_title.text.trim().isEmpty || (_recurring && interval < 1)) return;
    Navigator.pop(
      context,
      ReminderModel(
        id: '',
        aquariumId: '',
        title: _title.text.trim(),
        intervalDays: _recurring ? interval : 1,
        nextDueDate: _nextDueDate,
        isRecurring: _recurring,
        isCompleted: false,
        isProFeature: _recurring,
      ),
    );
  }
}

class _JournalEmpty extends StatelessWidget {
  const _JournalEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.teal.shade300),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _JournalError extends StatelessWidget {
  const _JournalError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

IconData _iconFor(JournalEntryType type) {
  switch (type) {
    case JournalEntryType.waterChange:
      return Icons.water_drop_outlined;
    case JournalEntryType.filter:
      return Icons.filter_alt_outlined;
    case JournalEntryType.trimming:
      return Icons.content_cut;
    case JournalEntryType.medication:
      return Icons.medication_outlined;
    case JournalEntryType.cleaning:
      return Icons.cleaning_services_outlined;
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
