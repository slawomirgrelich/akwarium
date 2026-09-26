import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/pro_access_service.dart';
import '../widgets/pro_paywall_dialog.dart';

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

  void _showProRequiredDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Funkcja PRO'),
        content: const Text(
          'Funkcja dostępna w planie PRO. Aktywuj darmowy okres próbny!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Później'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ProPaywallDialog.show(context);
            },
            child: const Text('Aktywuj PRO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProUser = context.watch<ProAccessService>().isProUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia powiadomień')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            child: Column(
              children: [
                InkWell(
                  onTap: isProUser ? null : _showProRequiredDialog,
                  child: SwitchListTile(
                    title: const Text('Przypomnienia o zadaniach'),
                    subtitle: const Text('Podmiany, filtr i pielęgnacja'),
                    value: isProUser && _remindersEnabled,
                    onChanged: isProUser
                        ? (value) => _setPreference(
                            key: _remindersKey,
                            value: value,
                            update: () => _remindersEnabled = value,
                          )
                        : null,
                  ),
                ),
                InkWell(
                  onTap: isProUser ? null : _showProRequiredDialog,
                  child: SwitchListTile(
                    title: const Text('Pomiary wody'),
                    subtitle: const Text('Przypomnienie o regularnym teście'),
                    value: isProUser && _waterTestsEnabled,
                    onChanged: isProUser
                        ? (value) => _setPreference(
                            key: _waterTestsKey,
                            value: value,
                            update: () => _waterTestsEnabled = value,
                          )
                        : null,
                  ),
                ),
                InkWell(
                  onTap: isProUser ? null : _showProRequiredDialog,
                  child: SwitchListTile(
                    title: const Text('Tygodniowe podsumowanie'),
                    subtitle: const Text('Najważniejsze zmiany w akwarium'),
                    value: isProUser && _weeklySummaryEnabled,
                    onChanged: isProUser
                        ? (value) => _setPreference(
                            key: _weeklySummaryKey,
                            value: value,
                            update: () => _weeklySummaryEnabled = value,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isProUser ? 'Powiadomienia PRO są aktywne dla tego urządzenia.' : 'Powiadomienia push i cykliczne harmonogramy wymagają aktywnego planu PRO.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
