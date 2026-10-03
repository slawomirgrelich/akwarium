import 'package:akwarium/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('action snackbars are floating and last three seconds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => context.showAppSnackBar(
                SnackBar(
                  content: const Text('Saved'),
                  action: SnackBarAction(label: 'Undo', onPressed: () {}),
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 3));
    expect(snackBar.behavior, SnackBarBehavior.floating);
  });
}
