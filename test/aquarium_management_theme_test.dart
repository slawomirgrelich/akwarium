import 'package:akwarium/aquarium_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('management icons contrast in $brightness mode', (
      tester,
    ) async {
      late Color iconColor;
      late Color surfaceColor;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true, brightness: brightness),
          home: Builder(
            builder: (context) {
              iconColor = aquariumManagementIconColor(context);
              surfaceColor = aquariumManagementIconSurface(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(iconColor.a, 1);
      int channel(double value) => (value * 255).round().clamp(0, 255);
      expect(
        (channel(iconColor.r) - channel(surfaceColor.r)).abs() +
            (channel(iconColor.g) - channel(surfaceColor.g)).abs() +
            (channel(iconColor.b) - channel(surfaceColor.b)).abs(),
        greaterThan(35),
      );
    });
  }
}
