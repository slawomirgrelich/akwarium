import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/pro_access_service.dart';
import '../widgets/pro_paywall_dialog.dart';
import '../l10n/app_localizations.dart';
import 'reminders_screen.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _remindersKey = 'notifications_reminders_enabled';
  static const _waterTestsKey = 'notifications_water_tests_enabled';
  static const _weeklySummaryKey = 'notifications_weekly_summary_enabled';

  bool _remindersEnabled = true;
  bool _waterTestsEnabled = true;
  bool _weeklySummaryEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _remindersEnabled = preferences.getBool(_remindersKey) ?? true;
      _waterTestsEnabled = preferences.getBool(_waterTestsKey) ?? true;
      _weeklySummaryEnabled = preferences.getBool(_weeklySummaryKey) ?? false;
    });
  }

  Future<void> _setPreference({
    required String key,
    required bool value,
    required VoidCallback update,
  }) async {
    setState(update);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }

  void _showProRequiredDialog() => ProPaywallDialog.show(
    context,
    headline: 'Funkcja PRO - aktywuj darmowy okres próbny',
  );

  Widget _titleWithProBadge(String title, bool isProUser) => Row(
    children: [
      Expanded(child: Text(title)),
      if (!isProUser) const SizedBox(width: 8),
      if (!isProUser) const ProBadge(compact: true),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isProUser = context.watch<ProAccessService>().isProUser;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: _titleWithProBadge(l10n.taskReminders, isProUser),
                  subtitle: Text(l10n.taskRemindersSubtitle),
                  value: isProUser && _remindersEnabled,
                  onChanged: (value) {
                    if (!isProUser) {
                      _showProRequiredDialog();
                      return;
                    }
                    _setPreference(
                      key: _remindersKey,
                      value: value,
                      update: () => _remindersEnabled = value,
                    );
                  },
                ),
                SwitchListTile(
                  title: _titleWithProBadge(l10n.waterTestReminders, isProUser),
                  subtitle: Text(l10n.waterTestRemindersSubtitle),
                  value: isProUser && _waterTestsEnabled,
                  onChanged: (value) {
                    if (!isProUser) {
                      _showProRequiredDialog();
                      return;
                    }
                    _setPreference(
                      key: _waterTestsKey,
                      value: value,
                      update: () => _waterTestsEnabled = value,
                    );
                  },
                ),
                SwitchListTile(
                  title: _titleWithProBadge(l10n.weeklySummary, isProUser),
                  subtitle: Text(l10n.weeklySummarySubtitle),
                  value: isProUser && _weeklySummaryEnabled,
                  onChanged: (value) {
                    if (!isProUser) {
                      _showProRequiredDialog();
                      return;
                    }
                    _setPreference(
                      key: _weeklySummaryKey,
                      value: value,
                      update: () => _weeklySummaryEnabled = value,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isProUser
                ? () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(builder: (_) => const RemindersScreen()),
                  )
                : _showProRequiredDialog,
            icon: const Icon(Icons.checklist_outlined),
            label: const Text('Zarządzaj przypomnieniami zadań'),
          ),
          const SizedBox(height: 12),
          Text(
            isProUser
                ? l10n.proNotificationsNote
                : l10n.proNotificationsRequired,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
