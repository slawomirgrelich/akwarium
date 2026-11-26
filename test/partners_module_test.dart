import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/l10n/app_localizations.dart';
import 'package:akwarium/models/partner_model.dart';
import 'package:akwarium/screens/admin_dashboard_screen.dart';
import 'package:akwarium/screens/partners_screen.dart';

void main() {
  test(
    'partner model parses optional fields and inactive state defensively',
    () {
      final partner = Partner.fromMap('green', {
        'name': 'Zielony Pasjonat',
        'category': 'creator',
        'description': 'Praktyczne porady akwarystyczne.',
        'url': 'https://www.youtube.com/@KarolAkwarysta',
        'promoCode': '  ',
        'promoText': null,
        'tipText': 'Najpierw sprawdź parametry.',
        'order': 10,
        'isActive': false,
      });

      expect(partner.category, PartnerCategory.creator);
      expect(partner.promoCode, isNull);
      expect(partner.promoText, isNull);
      expect(partner.isActive, isFalse);
    },
  );

  test('partner filtering keeps all partners and filters creator or shop', () {
    final creator = _partner('creator', PartnerCategory.creator);
    final shop = _partner('shop', PartnerCategory.shop);
    final breeder = _partner('breeder', PartnerCategory.breeder);

    expect(filterPartners([creator, shop, breeder], PartnerFilter.all), [
      creator,
      shop,
      breeder,
    ]);
    expect(filterPartners([creator, shop, breeder], PartnerFilter.creators), [
      creator,
    ]);
    expect(filterPartners([creator, shop, breeder], PartnerFilter.shops), [
      shop,
    ]);
  });

  test('partner draft serializes hidden admin data for Firestore', () {
    const draft = PartnerDraft(
      name: ' Zielony Pasjonat ',
      category: PartnerCategory.creator,
      subtitle: '',
      description: ' Praktyczne porady ',
      url: ' https://www.youtube.com/@KarolAkwarysta ',
      promoCode: ' ',
      promoText: null,
      tipText: 'Sprawdzaj parametry regularnie.',
      order: 10,
      isActive: false,
    );

    expect(draft.toFirestoreMap(), {
      'name': 'Zielony Pasjonat',
      'category': 'creator',
      'subtitle': null,
      'description': 'Praktyczne porady',
      'url': 'https://www.youtube.com/@KarolAkwarysta',
      'promoCode': null,
      'promoText': null,
      'tipText': 'Sprawdzaj parametry regularnie.',
      'order': 10,
      'isActive': false,
    });
  });

  testWidgets('admin partner editor saves complete hidden partner', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    PartnerDraft? saved;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AdminPartnerEditorDialog(
                  onSave: (draft) async => saved = draft,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nazwa'),
      'Zielony Pasjonat',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Opis'),
      'Praktyczne poradniki akwarystyczne.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adres URL'),
      'https://www.youtube.com/@KarolAkwarysta',
    );
    final saveButton = find.widgetWithText(FilledButton, 'Zapisz');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(saved!.name, 'Zielony Pasjonat');
    expect(saved!.category, PartnerCategory.creator);
    expect(saved!.isActive, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 412.0, 1280.0]) {
    testWidgets('partners screen fits ${width.toInt()} px in light and dark', (
      tester,
    ) async {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.binding.setSurfaceSize(Size(width, 800));
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('pl'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(useMaterial3: true, brightness: brightness),
            home: PartnersScreen(
              partnersStream: Stream.value([
                _partner(
                  'Zielony Pasjonat',
                  PartnerCategory.creator,
                  promoCode: 'AKWARYSTAPRO',
                ),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Zielony Pasjonat'), findsOneWidget);
        expect(find.byType(SegmentedButton<PartnerFilter>), findsOneWidget);
        expect(find.text('Kopiuj kod'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      await tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('empty promo is not rendered as a copy action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pl'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PartnersScreen(
          partnersStream: Stream.value([
            _partner('Bez kodu', PartnerCategory.shop),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kopiuj kod'), findsNothing);
    expect(find.text('Bez kodu'), findsOneWidget);
  });
}

Partner _partner(String name, PartnerCategory category, {String? promoCode}) {
  return Partner(
    id: name,
    name: name,
    category: category,
    subtitle: 'Polecany partner',
    description: 'Praktyczne informacje dla akwarystów.',
    url: 'https://www.youtube.com/@KarolAkwarysta',
    promoCode: promoCode,
    promoText: promoCode == null ? null : '-10% na wybrane produkty',
    tipText: 'Wprowadzaj zmiany parametrów stopniowo.',
    order: 1,
    isActive: true,
  );
}
