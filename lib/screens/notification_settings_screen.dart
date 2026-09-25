import 'package:flutter/material.dart';

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
                  value: _remindersEnabled,
                  onChanged: (value) =>
                      setState(() => _remindersEnabled = value),
                ),
                SwitchListTile(
                  title: const Text('Pomiary wody'),
                  subtitle: const Text('Przypomnienie o regularnym teście'),
                  value: _waterTestsEnabled,
                  onChanged: (value) =>
                      setState(() => _waterTestsEnabled = value),
                ),
                SwitchListTile(
                  title: const Text('Tygodniowe podsumowanie'),
                  subtitle: const Text('Najważniejsze zmiany w akwarium'),
                  value: _weeklySummaryEnabled,
                  onChanged: (value) =>
                      setState(() => _weeklySummaryEnabled = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Powiadomienia push i cykliczne harmonogramy wymagają aktywnego planu PRO.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
