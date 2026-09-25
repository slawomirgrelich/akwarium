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
  testWidgets('pokazuje ekran logowania bez aktywnej sesji', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AkwarystaProApp());

    expect(find.text('Witaj ponownie'), findsOneWidget);
    expect(find.text('Zaloguj się'), findsOneWidget);
    expect(find.text('Zapomniałeś hasła?'), findsOneWidget);
  });

  testWidgets('waliduje formularz logowania', (WidgetTester tester) async {
    await tester.pumpWidget(const AkwarystaProApp());

    await tester.tap(find.text('Zaloguj się'));
    await tester.pump();

    expect(find.text('Wpisz adres e-mail.'), findsOneWidget);
    expect(find.text('Hasło musi mieć co najmniej 6 znaków.'), findsOneWidget);
  });
}
