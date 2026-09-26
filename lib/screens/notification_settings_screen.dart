import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pro_access_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _remindersEnabled = true;
  bool _waterTestsEnabled = true;
  bool _weeklySummaryEnabled = false;

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
                SwitchListTile(
                  title: const Text('Przypomnienia o zadaniach'),
                  subtitle: const Text('Podmiany, filtr i pielęgnacja'),
                  value: isProUser && _remindersEnabled,
                  onChanged: isProUser
                      ? (value) => setState(() => _remindersEnabled = value)
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Pomiary wody'),
                  subtitle: const Text('Przypomnienie o regularnym teście'),
                  value: isProUser && _waterTestsEnabled,
                  onChanged: isProUser
                      ? (value) => setState(() => _waterTestsEnabled = value)
                      : null,
                ),
                SwitchListTile(
                  title: const Text('Tygodniowe podsumowanie'),
                  subtitle: const Text('Najważniejsze zmiany w akwarium'),
                  value: isProUser && _weeklySummaryEnabled,
                  onChanged: isProUser
                      ? (value) => setState(() => _weeklySummaryEnabled = value)
                      : null,
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
