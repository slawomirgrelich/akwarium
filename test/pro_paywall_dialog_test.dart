import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/services/pro_access_service.dart';
import 'package:akwarium/widgets/pro_paywall_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('opens PRO safely when no store plugin is registered', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      final proAccess = ProAccessService();
      addTearDown(proAccess.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<ProAccessService>.value(
          value: proAccess,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pl'),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => ProPaywallDialog.show(context),
                  child: const Text('Otwórz PRO'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Otwórz PRO'));
      await tester.pumpAndSettle();

      expect(find.byType(ProPaywallDialog), findsOneWidget);
      expect(
        find.text('Sklep jest niedostępny. Spróbuj ponownie później.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
