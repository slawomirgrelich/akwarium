import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../aquarium_calculators_service.dart';
import '../local_reminder_service.dart';
import '../aquarium_management_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/aquarium_model.dart';
import '../models/aquarium_reminder.dart';
import '../services/aquarium_journal_service.dart';
import '../services/database_service.dart';
import '../services/firestore_service.dart';
import '../services/pro_access_service.dart';
import '../widgets/firestore_reminders_widget.dart' show AquariumReminderDialog;
import '../widgets/pro_paywall_dialog.dart';

import 'package:akwarium/utils/app_snackbar.dart';

String _journalTypeLabel(AppLocalizations l10n, JournalEntryType type) =>
    switch (type) {
      JournalEntryType.waterChange => l10n.filterWaterChange,
      JournalEntryType.filter => l10n.filterFilter,
      JournalEntryType.trimming => l10n.filterTrimming,
      JournalEntryType.medication => l10n.filterMeds,
      JournalEntryType.cleaning => l10n.filterCleaning,
      JournalEntryType.waterTest => l10n.waterTestTitle,
    };

class JournalAndRemindersScreen extends StatefulWidget {
  const JournalAndRemindersScreen({super.key});

  @override
  State<JournalAndRemindersScreen> createState() =>
      _JournalAndRemindersScreenState();
}

class _JournalAndRemindersScreenState extends State<JournalAndRemindersScreen> {
  static final _emptyDashboardReminders = Stream<List<AquariumReminder>>.value(
    const [],
  ).asBroadcastStream();

  AquariumJournalService? _service;
  DatabaseService? _database;
  Stream<List<AquariumReminder>>? _dashboardRemindersStream;
  String? _dashboardRemindersUserId;
  String? _dashboardRemindersAquariumId;
  final _pendingWaterChangeMigrations = <String>{};
  JournalEntryType? _entryFilter;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  AquariumJournalService get _journalService =>
      _service ??= AquariumJournalService();

  Stream<List<AquariumReminder>> _remindersForDashboard(
    String? userId,
    String aquariumId,
  ) {
    if (userId == null || userId.isEmpty) return _emptyDashboardReminders;
    if (_dashboardRemindersUserId == userId &&
        _dashboardRemindersAquariumId == aquariumId &&
        _dashboardRemindersStream != null) {
      return _dashboardRemindersStream!;
    }
    _database ??= DatabaseService();
    _dashboardRemindersUserId = userId;
    _dashboardRemindersAquariumId = aquariumId;
    return _dashboardRemindersStream = _database!.getRemindersStream(
      userId,
      aquariumId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AquariumProvider>();
    final aquariumId = provider.resolveAquariumId();
    if (aquariumId.isEmpty) {
      return _JournalScaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.addAquariumToStart, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AquariumManagementScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addTank),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final dashboardUserId = FirebaseAuth.instance.currentUser?.uid;
    final dashboardRemindersStream = _remindersForDashboard(
      dashboardUserId,
      aquariumId,
    );

    return StreamBuilder<List<JournalEntryModel>>(
      stream: _journalService.getJournalEntries(aquariumId),
      builder: (context, journalSnapshot) {
        return StreamBuilder<List<ReminderModel>>(
          stream: _journalService.getReminders(aquariumId),
          builder: (context, reminderSnapshot) {
            return StreamBuilder<List<AquariumReminder>>(
              stream: dashboardRemindersStream,
              builder: (context, dashboardReminderSnapshot) {
                if (journalSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    reminderSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    dashboardReminderSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    !journalSnapshot.hasData &&
                    !reminderSnapshot.hasData &&
                    !dashboardReminderSnapshot.hasData) {
                  return const _JournalScaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final journal = _mergeJournalEntries(
                  journalSnapshot.data ?? const <JournalEntryModel>[],
                  provider.journalEntries,
                );
                _migrateJournalWaterChanges(
                  provider,
                  aquariumId,
                  journalSnapshot.data ?? const <JournalEntryModel>[],
                );
                final reminders =
                    reminderSnapshot.data ?? const <ReminderModel>[];
                final dashboardReminders =
                    dashboardReminderSnapshot.data ??
                    const <AquariumReminder>[];
                final error =
                    journalSnapshot.error ??
                    reminderSnapshot.error ??
                    dashboardReminderSnapshot.error;
                if (error != null &&
                    journal.isEmpty &&
                    reminders.isEmpty &&
                    dashboardReminders.isEmpty) {
                  return _JournalScaffold(
                    body: _JournalError(message: _messageFor(context, error)),
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
                            Tab(
                              icon: Icon(Icons.timeline),
                              text: l10n.tabTimeline,
                            ),
                            Tab(
                              icon: Icon(Icons.calendar_month),
                              text: l10n.tabCalendar,
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _TimelineTab(
                                entries: journal,
                                filter: _entryFilter,
                                waterTestIds: provider.waterTests
                                    .map((test) => test.id)
                                    .toSet(),
                                onFilterChanged: (value) =>
                                    setState(() => _entryFilter = value),
                                onDeleteWaterTest: (entry) =>
                                    _deleteWaterTest(context, entry),
                              ),
                              _CalendarTab(
                                reminders: reminders,
                                dashboardReminders: dashboardReminders,
                                selectedDay: _selectedDay,
                                focusedDay: _focusedDay,
                                onDaySelected: (selected, focused) =>
                                    setState(() {
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
                                onEdit: (reminder) =>
                                    _editReminder(context, reminder),
                                onCompleteDashboardReminder: (reminder) =>
                                    _completeDashboardReminder(
                                      context,
                                      dashboardUserId,
                                      aquariumId,
                                      reminder,
                                    ),
                                onEditDashboardReminder: (reminder) =>
                                    _editDashboardReminder(
                                      context,
                                      dashboardUserId,
                                      aquariumId,
                                      reminder,
                                    ),
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
          'waterTest' => JournalEntryType.waterTest,
          _ => JournalEntryType.cleaning,
        },
        title: entry.title,
        notes: entry.description,
      );
    }
    return entriesById.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _migrateJournalWaterChanges(
    AquariumProvider provider,
    String aquariumId,
    List<JournalEntryModel> entries,
  ) {
    final aquarium = provider.aquariums
        .where((item) => item.id == aquariumId)
        .firstOrNull;
    if (aquarium == null) return;
    final existingIds = provider.waterChanges
        .map((change) => change.id)
        .toSet();
    for (final entry in entries) {
      if (entry.entryType != JournalEntryType.waterChange ||
          entry.id.isEmpty ||
          existingIds.contains(entry.id) ||
          !_pendingWaterChangeMigrations.add(entry.id)) {
        continue;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pendingWaterChangeMigrations.remove(entry.id);
        if (!mounted ||
            provider.waterChanges.any((change) => change.id == entry.id)) {
          return;
        }
        final percentage = entry.percentageWaterChanged;
        if (percentage != null &&
            (!percentage.isFinite || percentage <= 0 || percentage > 100)) {
          debugPrint(
            'Skipping invalid legacy water-change percentage '
            'for journal entry ${entry.id}.',
          );
          return;
        }
        provider.addWaterChange(
          WaterChange(
            id: entry.id,
            aquariumId: aquariumId,
            date: entry.timestamp,
            volumeLiters: percentage == null
                ? null
                : waterChangeVolumeLiters(
                    amount: percentage,
                    netVolumeLiters: aquarium.volumeNetLiters,
                    isPercent: true,
                  ),
            notes: [
              if (percentage != null) '${percentage.toStringAsFixed(0)}%',
              if (entry.notes.trim().isNotEmpty) entry.notes.trim(),
            ].join(' · '),
          ),
        );
      });
    }
  }

  Future<void> _openEntryForm(BuildContext context, String aquariumId) async {
    final provider = context.read<AquariumProvider>();
    aquariumId = provider.resolveAquariumId(aquariumId);
    if (aquariumId.isEmpty) {
      _showMessage(
        context,
        AppLocalizations.of(context)!.addAquariumToStart,
        error: true,
      );
      return;
    }

    final entry = await showDialog<JournalEntryModel>(
      context: context,
      builder: (_) => const _JournalEntryFormDialog(),
    );
    if (entry == null || !context.mounted) return;
    final savedEntry = JournalEntryModel(
      id: entry.id.isEmpty
          ? DateTime.now().microsecondsSinceEpoch.toString()
          : entry.id,
      aquariumId: aquariumId,
      timestamp: entry.timestamp,
      entryType: entry.entryType,
      title: entry.title,
      notes: entry.notes,
      percentageWaterChanged: entry.percentageWaterChanged,
    );
    try {
      if (entry.entryType == JournalEntryType.waterChange) {
        final aquarium = provider.selectedAquarium;
        final percentage = entry.percentageWaterChanged;
        if (aquarium == null || aquarium.isArchived) {
          _showMessage(
            context,
            AppLocalizations.of(context)!.addAquariumToStart,
            error: true,
          );
          return;
        }
        if (percentage == null ||
            !percentage.isFinite ||
            percentage <= 0 ||
            percentage > 100) {
          _showMessage(
            context,
            AppLocalizations.of(context)!.invalidWaterChangeAmount,
            error: true,
          );
          return;
        }
        provider.addWaterChange(
          WaterChange(
            id: savedEntry.id,
            aquariumId: aquariumId,
            date: savedEntry.timestamp,
            volumeLiters: waterChangeVolumeLiters(
              amount: percentage,
              netVolumeLiters: aquarium.volumeNetLiters,
              isPercent: true,
            ),
            notes: [
              '${percentage.toStringAsFixed(0)}%',
              if (savedEntry.notes.trim().isNotEmpty) savedEntry.notes.trim(),
            ].join(' · '),
          ),
        );
      } else {
        await _journalService.addJournalEntry(savedEntry);
      }
      if (context.mounted) {
        _showMessage(context, AppLocalizations.of(context)!.entryAddedMessage);
      }
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _editReminder(
    BuildContext context,
    ReminderModel existing,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final isPro = context.read<ProAccessService>().isProUser;
    final edited = await showDialog<ReminderModel>(
      context: context,
      builder: (_) => _ReminderFormDialog(initial: existing),
    );
    if (edited == null || !context.mounted) return;
    if (!isPro && edited.isProFeature) {
      await ProPaywallDialog.show(context);
      return;
    }

    try {
      await _journalService.updateReminder(edited);
      if (edited.isCompleted || !isPro) {
        await LocalReminderService.instance.cancel(_notificationId(edited.id));
      } else {
        await _scheduleReminder(l10n, edited);
      }
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _completeDashboardReminder(
    BuildContext context,
    String? userId,
    String aquariumId,
    AquariumReminder reminder,
  ) async {
    if (userId == null || userId.isEmpty) {
      _showMessage(
        context,
        AppLocalizations.of(context)!.firebaseGenericError,
        error: true,
      );
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (reminder.taskType == ReminderTaskType.waterChange &&
        context.read<AquariumProvider>().selectedAquarium?.isArchived == true) {
      _showMessage(context, l10n.archivedHistoryNotice, error: true);
      return;
    }
    try {
      final AquariumReminder updated;
      if (reminder.isCompleted) {
        updated = reminder.copyWith(isCompleted: false);
        await (_database ??= DatabaseService()).updateReminder(
          userId,
          aquariumId,
          updated,
        );
      } else {
        final completedAt = DateTime.now();
        if (reminder.taskType == ReminderTaskType.waterChange) {
          context.read<AquariumProvider>().addWaterChange(
            waterChangeForReminder(
              reminderId: reminder.id,
              aquariumId: aquariumId,
              title: reminder.title,
              completedAt: completedAt,
            ),
          );
        }
        updated = await (_database ??= DatabaseService()).completeReminder(
          userId,
          aquariumId,
          reminder,
          completedAt: completedAt,
        );
      }
      if (updated.isCompleted || !updated.isEnabled) {
        await LocalReminderService.instance.cancel(updated.id.hashCode.abs());
      } else {
        await _scheduleDashboardReminder(updated, l10n);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Dashboard reminder completion failed: $error\n$stackTrace');
      if (context.mounted) {
        _showMessage(context, l10n.aquariumTaskUpdateFailed, error: true);
      }
    }
  }

  Future<void> _editDashboardReminder(
    BuildContext context,
    String? userId,
    String aquariumId,
    AquariumReminder existing,
  ) async {
    if (userId == null || userId.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final edited = await showDialog<AquariumReminder>(
      context: context,
      builder: (_) => AquariumReminderDialog(initial: existing),
    );
    if (edited == null || !context.mounted) return;
    final updated = edited.copyWith(
      id: existing.id,
      tankId: aquariumId,
      isCompleted: existing.isCompleted,
      lastCompletedAt: existing.lastCompletedAt,
      isEnabled: existing.isEnabled,
    );
    try {
      await (_database ??= DatabaseService()).updateReminder(
        userId,
        aquariumId,
        updated,
      );
      if (updated.isCompleted || !updated.isEnabled) {
        await LocalReminderService.instance.cancel(updated.id.hashCode.abs());
      } else {
        await _scheduleDashboardReminder(updated, l10n);
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Dashboard reminder edit failed: $error\n$stackTrace');
      if (context.mounted) {
        _showMessage(context, l10n.aquariumTaskUpdateFailed, error: true);
      }
    }
  }

  Future<void> _scheduleDashboardReminder(
    AquariumReminder reminder,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    return LocalReminderService.instance.schedule(
      ScheduledReminder(
        id: reminder.id.hashCode.abs(),
        title: reminder.title,
        body: l10n.scheduledAquariumTaskNotification,
        date: reminder.dueDate.isAfter(now)
            ? reminder.dueDate
            : now.add(const Duration(minutes: 1)),
      ),
    );
  }

  Future<void> _openReminderForm(
    BuildContext context,
    String aquariumId,
    List<ReminderModel> reminders,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    aquariumId = context.read<AquariumProvider>().resolveAquariumId(aquariumId);
    if (aquariumId.isEmpty) {
      _showMessage(context, l10n.addAquariumToStart, error: true);
      return;
    }

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
      await _journalService.addReminder(saved);
      if (isPro) await _scheduleReminder(l10n, saved);
      if (context.mounted) {
        _showMessage(context, l10n.reminderAddedMessage);
      }
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _completeReminder(
    BuildContext context,
    ReminderModel reminder,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final aquariumId = context.read<AquariumProvider>().resolveAquariumId(
      reminder.aquariumId,
    );
    if (aquariumId.isEmpty) {
      _showMessage(context, l10n.addAquariumToStart, error: true);
      return;
    }

    reminder = reminder.copyWith(aquariumId: aquariumId);
    final isPro = context.read<ProAccessService>().isProUser;
    try {
      final updated = await _journalService.markReminderCompleted(reminder);
      if (updated.isRecurring) {
        if (isPro) {
          await _scheduleReminder(l10n, updated);
        } else {
          await LocalReminderService.instance.cancel(
            _notificationId(updated.id),
          );
        }
      } else if (!updated.isCompleted) {
        await _scheduleReminder(l10n, updated);
      } else {
        await LocalReminderService.instance.cancel(_notificationId(updated.id));
      }
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _deleteReminder(
    BuildContext context,
    ReminderModel reminder,
  ) async {
    final aquariumId = context.read<AquariumProvider>().resolveAquariumId(
      reminder.aquariumId,
    );
    if (aquariumId.isEmpty) {
      _showMessage(
        context,
        AppLocalizations.of(context)!.addAquariumToStart,
        error: true,
      );
      return;
    }

    try {
      await _journalService.deleteReminder(
        reminder.copyWith(aquariumId: aquariumId),
      );
      await LocalReminderService.instance.cancel(_notificationId(reminder.id));
    } on AquariumJournalServiceException catch (error) {
      if (context.mounted) _showMessage(context, error.message, error: true);
    }
  }

  Future<void> _deleteWaterTest(
    BuildContext context,
    JournalEntryModel entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final aquariumId = context.read<AquariumProvider>().resolveAquariumId(
      entry.aquariumId,
    );
    if (aquariumId.isEmpty) {
      _showMessage(context, l10n.addAquariumToStart, error: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.waterTestDeleteTitle),
        content: Text(l10n.waterTestDeletePrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await FirestoreService().deleteWaterParameter(aquariumId, entry.id);
      if (context.mounted) _showMessage(context, l10n.waterTestDeletedMessage);
    } on FirestoreServiceException catch (error) {
      debugPrint('Water-test deletion failed: $error');
      if (context.mounted) {
        _showMessage(context, l10n.waterTestDeleteFailed, error: true);
      }
    }
  }

  Future<void> _scheduleReminder(
    AppLocalizations l10n,
    ReminderModel reminder,
  ) {
    return LocalReminderService.instance.schedule(
      ScheduledReminder(
        id: _notificationId(reminder.id),
        title: reminder.title,
        body: reminder.isRecurring
            ? reminder.intervalDays == 1
                  ? l10n.dailyRecurrence
                  : l10n.everyDays(reminder.intervalDays)
            : l10n.scheduledAquariumTaskNotification,
        date: reminder.nextDueDate,
      ),
    );
  }

  int _notificationId(String id) => id.hashCode & 0x7fffffff;

  String _messageFor(BuildContext context, Object error) {
    if (error is AquariumJournalServiceException) return error.message;
    return AppLocalizations.of(context)!.journalLoadError;
  }

  void _showMessage(
    BuildContext context,
    String message, {
    bool error = false,
  }) {
    context.showAppSnackBar(
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.journalTitle),
        actions: [
          if (onAdd != null)
            IconButton(
              tooltip: l10n.addEntryTooltip,
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
    required this.waterTestIds,
    required this.onFilterChanged,
    required this.onDeleteWaterTest,
  });

  final List<JournalEntryModel> entries;
  final JournalEntryType? filter;
  final Set<String> waterTestIds;
  final ValueChanged<JournalEntryType?> onFilterChanged;
  final ValueChanged<JournalEntryModel> onDeleteWaterTest;

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
                    label: Text(_journalTypeLabel(l10n, type)),
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
          ...filtered.map(
            (entry) => _JournalTimelineCard(
              entry: entry,
              onDeleteWaterTest:
                  entry.entryType == JournalEntryType.waterTest &&
                      waterTestIds.contains(entry.id)
                  ? () => onDeleteWaterTest(entry)
                  : null,
            ),
          ),
      ],
    );
  }
}

class _JournalTimelineCard extends StatelessWidget {
  const _JournalTimelineCard({
    required this.entry,
    required this.onDeleteWaterTest,
  });

  final JournalEntryModel entry;
  final VoidCallback? onDeleteWaterTest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.12),
          child: Icon(_iconFor(entry.entryType), color: Colors.teal),
        ),
        title: Text(
          entry.entryType == JournalEntryType.waterTest
              ? l10n.waterTestTitle
              : entry.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_journalTypeLabel(l10n, entry.entryType)} · ${_formatDate(entry.timestamp)}\n${entry.notes}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: onDeleteWaterTest != null
            ? IconButton(
                tooltip: l10n.deleteAction,
                onPressed: onDeleteWaterTest,
                icon: const Icon(Icons.delete_outline),
              )
            : entry.percentageWaterChanged == null
            ? null
            : Text('${entry.percentageWaterChanged!.toStringAsFixed(0)}%'),
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({
    required this.reminders,
    required this.dashboardReminders,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onAdd,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
    required this.onCompleteDashboardReminder,
    required this.onEditDashboardReminder,
    required this.isProUser,
  });

  final List<ReminderModel> reminders;
  final List<AquariumReminder> dashboardReminders;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final VoidCallback onAdd;
  final ValueChanged<ReminderModel> onComplete;
  final ValueChanged<ReminderModel> onDelete;
  final ValueChanged<ReminderModel> onEdit;
  final ValueChanged<AquariumReminder> onCompleteDashboardReminder;
  final ValueChanged<AquariumReminder> onEditDashboardReminder;
  final bool isProUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calendarReminders = <_CalendarReminderItem>[
      ...reminders.map(_CalendarReminderItem.fromJournalReminder),
      ...dashboardReminders.map(_CalendarReminderItem.fromDashboardReminder),
    ]..sort((first, second) => first.dueDate.compareTo(second.dueDate));
    final selected = calendarReminders
        .where((reminder) => isSameDay(reminder.dueDate, selectedDay))
        .toList();
    final upcoming = calendarReminders
        .where((reminder) => !reminder.isCompleted)
        .toList();

    Widget reminderTile(_CalendarReminderItem item) {
      if (item.journalReminder case final reminder?) {
        return _ReminderTile(
          reminder: reminder,
          onComplete: () => onComplete(reminder),
          onDelete: () => onDelete(reminder),
          onEdit: () => onEdit(reminder),
        );
      }
      final reminder = item.dashboardReminder!;
      return _DashboardReminderTile(
        reminder: reminder,
        onComplete: () => onCompleteDashboardReminder(reminder),
        onEdit: () => onEditDashboardReminder(reminder),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.upcomingTasks,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isProUser) const ProBadge(compact: true),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: l10n.addReminderTooltip,
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
                  return TableCalendar<_CalendarReminderItem>(
                    locale: Localizations.localeOf(context).languageCode,
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2035),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                    onDaySelected: onDaySelected,
                    eventLoader: (day) => calendarReminders
                        .where((reminder) => isSameDay(reminder.dueDate, day))
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
          isSameDay(selectedDay, DateTime.now())
              ? l10n.forToday
              : l10n.selectedDay,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (selected.isEmpty)
          _JournalEmpty(icon: Icons.event_available, text: l10n.noTasksForDay)
        else
          ...selected.map(reminderTile),
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            l10n.upcomingTasks,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...upcoming.take(5).map(reminderTile),
        ],
      ],
    );
  }
}

class _CalendarReminderItem {
  const _CalendarReminderItem.fromJournalReminder(this.journalReminder)
    : dashboardReminder = null;

  const _CalendarReminderItem.fromDashboardReminder(this.dashboardReminder)
    : journalReminder = null;

  final ReminderModel? journalReminder;
  final AquariumReminder? dashboardReminder;

  DateTime get dueDate =>
      journalReminder?.nextDueDate ?? dashboardReminder!.dueDate;

  bool get isCompleted =>
      journalReminder?.isCompleted ?? dashboardReminder!.isCompleted;
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
          AppLocalizations.of(context)!.calendarLoadError,
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
    required this.onEdit,
  });

  final ReminderModel reminder;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          '${_formatDate(reminder.nextDueDate)}${reminder.isRecurring ? ' · ${l10n.everyDays(reminder.intervalDays)}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: reminder.isCompleted
                  ? l10n.markReminderIncomplete
                  : l10n.markReminderComplete,
              onPressed: onComplete,
              icon: Icon(
                reminder.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: reminder.isCompleted ? Colors.teal : Colors.orange,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: l10n.reminderOptionsTooltip,
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.editAction)),
                PopupMenuItem(value: 'delete', child: Text(l10n.deleteAction)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardReminderTile extends StatelessWidget {
  const _DashboardReminderTile({
    required this.reminder,
    required this.onComplete,
    required this.onEdit,
  });

  final AquariumReminder reminder;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repeatDays = reminder.repeatIntervalDays;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          reminder.isCompleted ? Icons.check_circle : Icons.schedule,
          color: reminder.isCompleted ? Colors.teal : Colors.orange,
        ),
        title: Text(reminder.title),
        subtitle: Text(
          '${_formatDate(reminder.dueDate)} · '
          '${repeatDays == null
              ? l10n.oneTime
              : repeatDays == 1
              ? l10n.dailyRecurrence
              : l10n.everyDays(repeatDays)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.editReminder,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: reminder.isCompleted
                  ? l10n.markReminderIncomplete
                  : l10n.markReminderComplete,
              onPressed: onComplete,
              icon: Icon(
                reminder.isCompleted ? Icons.check_circle : Icons.check,
              ),
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
  bool _waterChangeAsPercent = true;
  String? _waterChangeError;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _percentage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.newActivity),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.title),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<JournalEntryType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.activityType),
              items: JournalEntryType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_journalTypeLabel(l10n, type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            if (_type == JournalEntryType.waterChange) ...[
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.waterChangeLiters),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.waterChangePercent),
                  ),
                ],
                selected: {_waterChangeAsPercent},
                onSelectionChanged: (selection) =>
                    setState(() => _waterChangeAsPercent = selection.single),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _percentage,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() => _waterChangeError = null),
                decoration: InputDecoration(
                  labelText: l10n.waterReplaced,
                  suffixText: _waterChangeAsPercent ? '%' : l10n.liters,
                  errorText: _waterChangeError,
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.note),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    double? percentageWaterChanged;
    if (_type == JournalEntryType.waterChange) {
      final l10n = AppLocalizations.of(context)!;
      final amount = double.tryParse(
        _percentage.text.trim().replaceAll(',', '.'),
      );
      final aquarium = context.read<AquariumProvider>().selectedAquarium;
      if (aquarium == null ||
          aquarium.isArchived ||
          amount == null ||
          !amount.isFinite ||
          amount <= 0 ||
          (_waterChangeAsPercent && amount > 100) ||
          (!_waterChangeAsPercent && amount > aquarium.volumeNetLiters)) {
        setState(() => _waterChangeError = l10n.invalidWaterChangeAmount);
        return;
      }
      percentageWaterChanged = _waterChangeAsPercent
          ? amount
          : amount / aquarium.volumeNetLiters * 100;
    }
    Navigator.pop(
      context,
      JournalEntryModel(
        id: '',
        aquariumId: '',
        timestamp: DateTime.now(),
        entryType: _type,
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        percentageWaterChanged: percentageWaterChanged,
      ),
    );
  }
}

class _ReminderFormDialog extends StatefulWidget {
  const _ReminderFormDialog({this.initial});

  final ReminderModel? initial;

  @override
  State<_ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<_ReminderFormDialog> {
  final _customTitle = TextEditingController();
  final _interval = TextEditingController(text: '7');
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 1));
  bool _recurring = false;
  _ReminderTaskPreset _preset = _ReminderTaskPreset.waterChange;
  String? _customTitleError;
  String? _intervalError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _customTitle.text = initial.title;
      _interval.text = initial.intervalDays.toString();
      _nextDueDate = initial.nextDueDate;
      _recurring = initial.isRecurring;
      _preset = _ReminderTaskPreset.custom;
    }
  }

  @override
  void dispose() {
    _customTitle.dispose();
    _interval.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.initial == null
            ? l10n.newReminder
            : l10n.editReminderDialogTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<_ReminderTaskPreset>(
              initialValue: _preset,
              decoration: InputDecoration(labelText: l10n.reminderTaskPreset),
              items: [
                DropdownMenuItem(
                  value: _ReminderTaskPreset.waterChange,
                  child: Text(l10n.reminderTaskWaterChange),
                ),
                DropdownMenuItem(
                  value: _ReminderTaskPreset.filter,
                  child: Text(l10n.reminderTaskFilter),
                ),
                DropdownMenuItem(
                  value: _ReminderTaskPreset.waterTest,
                  child: Text(l10n.reminderTaskWaterTest),
                ),
                DropdownMenuItem(
                  value: _ReminderTaskPreset.fertilizer,
                  child: Text(l10n.reminderTaskFertilizer),
                ),
                DropdownMenuItem(
                  value: _ReminderTaskPreset.custom,
                  child: Text(l10n.reminderTaskCustom),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _preset = value;
                    _customTitleError = null;
                  });
                }
              },
            ),
            if (_preset == _ReminderTaskPreset.custom) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _customTitle,
                decoration: InputDecoration(
                  labelText: l10n.taskName,
                  prefixIcon: const Icon(Icons.edit_note),
                  errorText: _customTitleError,
                ),
                onChanged: (_) => setState(() => _customTitleError = null),
              ),
            ],
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.dueDate),
              subtitle: Text(
                '${_formatDate(_nextDueDate)} · ${_formatTime(_nextDueDate)}',
              ),
              trailing: IconButton(
                tooltip: MaterialLocalizations.of(context)
                    .timePickerDialHelpText,
                icon: const Icon(Icons.schedule_outlined),
                onPressed: _selectTime,
              ),
              onTap: _selectDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.repeatCyclically),
              subtitle: Text(l10n.autoScheduleNextDate),
              value: _recurring,
              onChanged: (value) => setState(() => _recurring = value),
            ),
            if (_recurring)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _interval,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.repeatEveryLabel,
                        suffixText: l10n.daysProFeature,
                        errorText: _intervalError,
                      ),
                      onChanged: (_) => setState(() => _intervalError = null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _interval.text = '1',
                    child: Text(l10n.dailyRecurrence),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _nextDueDate.isAfter(DateTime(2100))
          ? DateTime(2100)
          : _nextDueDate.isBefore(DateTime(2000))
          ? now
          : _nextDueDate,
    );
    if (date != null && mounted) {
      setState(
        () => _nextDueDate = DateTime(
          date.year,
          date.month,
          date.day,
          _nextDueDate.hour,
          _nextDueDate.minute,
        ),
      );
    }
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_nextDueDate),
    );
    if (selected != null && mounted) {
      setState(
        () => _nextDueDate = DateTime(
          _nextDueDate.year,
          _nextDueDate.month,
          _nextDueDate.day,
          selected.hour,
          selected.minute,
        ),
      );
    }
  }

  void _save() {
    final interval = int.tryParse(_interval.text) ?? 0;
    if (_preset == _ReminderTaskPreset.custom &&
        _customTitle.text.trim().isEmpty) {
      setState(
        () =>
            _customTitleError = AppLocalizations.of(context)!
                .reminderCustomNameRequired,
      );
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    if (_recurring && interval < 1) {
      setState(() => _intervalError = l10n.reminderInvalidInterval);
      return;
    }
    Navigator.pop(
      context,
      ReminderModel(
        id: widget.initial?.id ?? '',
        aquariumId: widget.initial?.aquariumId ?? '',
        title: _preset == _ReminderTaskPreset.custom
            ? _customTitle.text.trim()
            : switch (_preset) {
                _ReminderTaskPreset.waterChange => l10n.reminderTaskWaterChange,
                _ReminderTaskPreset.filter => l10n.reminderTaskFilter,
                _ReminderTaskPreset.waterTest => l10n.reminderTaskWaterTest,
                _ReminderTaskPreset.fertilizer => l10n.reminderTaskFertilizer,
                _ReminderTaskPreset.custom => _customTitle.text.trim(),
              },
        intervalDays: _recurring ? interval : 1,
        nextDueDate: _nextDueDate,
        isRecurring: _recurring,
        isCompleted: widget.initial?.isCompleted ?? false,
        isProFeature: _recurring,
      ),
    );
  }
}

enum _ReminderTaskPreset { waterChange, filter, waterTest, fertilizer, custom }

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
    case JournalEntryType.waterTest:
      return Icons.science_outlined;
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
