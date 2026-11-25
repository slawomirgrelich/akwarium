import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/screens/journal_and_reminders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:akwarium/services/aquarium_journal_service.dart';

void main() {
  testWidgets('journal does not query Firestore without an active aquarium', (
    tester,
  ) async {
    final provider = AquariumProvider();
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const JournalAndRemindersScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('timeline delete control does not open entry details', (
    tester,
  ) async {
    var opened = 0;
    var deleted = 0;
    final entry = JournalEntryModel(
      id: 'entry',
      aquariumId: 'tank',
      timestamp: DateTime(2026, 11, 29, 9),
      entryType: JournalEntryType.cleaning,
      title: 'Pełny wpis',
      notes: 'Treść',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: JournalTimelineCard(
            entry: entry,
            onOpen: () => opened++,
            onDelete: () => deleted++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();
    expect(deleted, 1);
    expect(opened, 0);

    await tester.tap(find.text('Pełny wpis'));
    await tester.pump();
    expect(opened, 1);
  });
}
