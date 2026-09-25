import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/algae_assistant_service.dart';

void main() {
  test('offline mock returns a concrete algae action plan', () async {
    final result = await AlgaeAssistantService().diagnose(
      const AlgaeDiagnosticInput(
        algaeType: 'Zielenice',
        no3: 30,
        po4: 0.5,
        fe: 0.2,
        ph: 7,
        kh: 5,
        lightHours: 8,
        co2: false,
        substrate: 'Żwirek / piasek',
      ),
    );

    expect(result.isMock, isTrue);
    expect(result.cause, contains('NO3'));
    expect(result.actions, isNotEmpty);
    expect(result.actions.first, contains('30%'));
  });
}