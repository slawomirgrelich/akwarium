import 'package:flutter_test/flutter_test.dart';

import 'package:akwarium/algae_assistant_service.dart';

void main() {
  test('serializes an optional measured CO2 value with its unit', () {
    const input = AlgaeDiagnosticInput(
      algaeType: 'Zielenice',
      no3: 30,
      po4: 0.5,
      fe: 0.2,
      ph: 7,
      kh: 5,
      lightHours: 8,
      co2: false,
      co2MgPerLiter: 22.5,
      substrate: 'Żwirek / piasek',
    );

    final parameters = input.toJson()['parametry_wody'] as Map<String, dynamic>;

    expect(parameters['CO2_mg_L'], 22.5);
    expect(input.toJson()['co2'], isFalse);
  });

  test('omits CO2 when its water measurement is unavailable', () {
    const input = AlgaeDiagnosticInput(
      algaeType: 'Zielenice',
      no3: 30,
      po4: 0.5,
      fe: 0.2,
      ph: 7,
      kh: 5,
      lightHours: 8,
      co2: false,
      substrate: 'Żwirek / piasek',
    );

    expect(
      (input.toJson()['parametry_wody'] as Map<String, dynamic>),
      isNot(contains('CO2_mg_L')),
    );
  });

  test('offline diagnosis considers a recorded CO2 concentration', () async {
    final result = await AlgaeAssistantService().diagnose(
      const AlgaeDiagnosticInput(
        algaeType: 'Zielenice',
        no3: 15,
        po4: 1,
        fe: 0.2,
        ph: 7,
        kh: 5,
        lightHours: 8,
        co2: false,
        co2MgPerLiter: 10,
        substrate: 'Żwirek / piasek',
      ),
    );

    expect(result.cause, contains('10.0 mg/L'));
  });

  test('does not say CO2 is absent when a normal level was recorded', () async {
    final result = await AlgaeAssistantService().diagnose(
      const AlgaeDiagnosticInput(
        algaeType: 'Zielenice',
        no3: 15,
        po4: 1,
        fe: 0.2,
        ph: 7,
        kh: 5,
        lightHours: 8,
        co2: false,
        co2MgPerLiter: 22,
        substrate: 'Żwirek / piasek',
      ),
    );

    expect(result.cause, isNot(contains('Brak CO2')));
  });

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
