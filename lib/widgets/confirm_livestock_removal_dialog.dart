import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

Future<bool> confirmLivestockRemoval(
  BuildContext context,
  String speciesName,
) async {
  final l10n = AppLocalizations.of(context)!;
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.deleteAction),
          content: Text(l10n.deleteLivestockConfirmation(speciesName)),
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
      ) ??
      false;
}
