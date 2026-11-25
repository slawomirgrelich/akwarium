import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/aquarium_model.dart';
import 'package:akwarium/models/aquarium_routine.dart';
import 'package:akwarium/screens/routine_templates_screen.dart';
import 'package:akwarium/services/aquarium_journal_service.dart';
import 'package:akwarium/services/routine_progress_service.dart';

void main() {
  test('routine progress is isolated by aquarium and template', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final service = RoutineProgressService(preferences: preferences);

    await service.save('tank-a', 'weekly', {'check', 'test'});
    await service.save('tank-b', 'weekly', {'filter'});

    expect(await service.load('tank-a', 'weekly'), {'check', 'test'});
    expect(await service.load('tank-b', 'weekly'), {'filter'});
    expect(await service.load('tank-a', 'restart'), isEmpty);
  });

  testWidgets('routine schedule is usable on a compact screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final provider = AquariumProvider(
      aquariums: [
        AquariumProfile(
          id: 'tank-1',
          name: 'Test',
          volumeNetLiters: 100,
          setupDate: DateTime(2026, 1, 1),
          type: TankType.freshwater,
        ),
      ],
      activeAquariumId: 'tank-1',
    );
    addTearDown(provider.dispose);
    final template = AquariumRoutineTemplate(
      id: 'test',
      title: 'Rutyna testowa',
      description: 'Opis rutyny.',
      duration: '7 dni',
      assetPath: 'assets/templates/weekly_routine.webp',
      steps: const [
        AquariumRoutineStep(
          id: 'step',
          dayOffset: 1,
          title: 'Bardzo długa nazwa kroku odpowiednia dla polskiego ekranu',
          description: 'Opis kroku, który może bezpiecznie zawijać tekst.',
          entryType: JournalEntryType.cleaning,
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AquariumProvider>.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RoutineTemplateDetailsScreen(template: template),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(template.title), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
