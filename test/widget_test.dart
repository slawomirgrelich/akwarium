// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/main.dart';

void main() {
  testWidgets('pokazuje cztery sekcje aplikacji', (WidgetTester tester) async {
    await tester.pumpWidget(const AkwarystaProApp());

    expect(find.text('Pulpit'), findsOneWidget);
    expect(find.text('Dziennik'), findsOneWidget);
    expect(find.text('Narzędzia'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Akwarium Roślinne'), findsOneWidget);
  });

  testWidgets('otwiera formularz testu wody', (WidgetTester tester) async {
    await tester.pumpWidget(const AkwarystaProApp());

    final actionTile = find.ancestor(
      of: find.text('Wpisz wyniki testu wody'),
      matching: find.byType(ListTile),
    );
    await tester.ensureVisible(actionTile);
    await tester.tap(actionTile);
    await tester.pumpAndSettle();

    expect(find.text('Test wody'), findsOneWidget);
    expect(find.text('Parametry wody'), findsOneWidget);
  });
}
