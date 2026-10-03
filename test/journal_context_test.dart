import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/screens/journal_and_reminders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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
}
