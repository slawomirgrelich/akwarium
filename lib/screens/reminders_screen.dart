import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/pro_access_service.dart';
import '../widgets/firestore_reminders_widget.dart';
import '../widgets/pro_paywall_dialog.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isProUser = context.watch<ProAccessService>().isProUser;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersScreenTitle)),
      body: isProUser
          ? const SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: FirestoreRemindersWidget(),
            )
          : Center(
              child: FilledButton.icon(
                onPressed: () => ProPaywallDialog.show(context),
                icon: const Icon(Icons.lock_outline),
                label: Text(l10n.activateProForReminders),
              ),
            ),
    );
  }
}
