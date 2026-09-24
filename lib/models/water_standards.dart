import 'aquarium_model.dart';

enum WaterStatus { good, warning, critical }

enum WaterParameter { ph, no3, po4, fe, kh, gh, temp }

class WaterAssessment {
  const WaterAssessment({
    required this.status,
    required this.label,
    required this.message,
  });

  final WaterStatus status;
  final String label;
  final String message;

  bool get isGood => status == WaterStatus.good;
}

class WaterStandard {
  const WaterStandard({
    required this.parameter,
    required this.label,
    required this.unit,
    required this.optimalMin,
    required this.optimalMax,
    required this.chartMin,
    required this.chartMax,
  });

  final WaterParameter parameter;
  final String label;
  final String unit;
  final double optimalMin;
  final double optimalMax;
  final double chartMin;
  final double chartMax;
}

const waterStandards = <WaterParameter, WaterStandard>{
  WaterParameter.ph: WaterStandard(
    parameter: WaterParameter.ph,
    label: 'pH',
    unit: '',
    optimalMin: 6.5,
    optimalMax: 7.5,
    chartMin: 5,
    chartMax: 9,
  ),
  WaterParameter.no3: WaterStandard(
    parameter: WaterParameter.no3,
    label: 'NO3',
    unit: 'mg/l',
    optimalMin: 10,
    optimalMax: 25,
    chartMin: 0,
    chartMax: 60,
  ),
  WaterParameter.po4: WaterStandard(
    parameter: WaterParameter.po4,
    label: 'PO4',
    unit: 'mg/l',
    optimalMin: 0.5,
    optimalMax: 1.5,
    chartMin: 0,
    chartMax: 3,
  ),
  WaterParameter.fe: WaterStandard(
    parameter: WaterParameter.fe,
    label: 'Fe',
    unit: 'mg/l',
    optimalMin: 0.1,
    optimalMax: 0.5,
    chartMin: 0,
    chartMax: 1,
  ),
  WaterParameter.kh: WaterStandard(
    parameter: WaterParameter.kh,
    label: 'KH',
    unit: 'dKH',
    optimalMin: 3,
    optimalMax: 8,
    chartMin: 0,
    chartMax: 12,
  ),
  WaterParameter.gh: WaterStandard(
    parameter: WaterParameter.gh,
    label: 'GH',
    unit: 'dGH',
    optimalMin: 5,
    optimalMax: 12,
    chartMin: 0,
    chartMax: 18,
  ),
  WaterParameter.temp: WaterStandard(
    parameter: WaterParameter.temp,
    label: 'Temp.',
    unit: '°C',
    optimalMin: 22,
    optimalMax: 28,
    chartMin: 18,
    chartMax: 32,
  ),
};

double waterValue(WaterTest test, WaterParameter parameter) {
  switch (parameter) {
    case WaterParameter.ph:
      return test.ph;
    case WaterParameter.no3:
      return test.no3;
    case WaterParameter.po4:
      return test.po4;
    case WaterParameter.fe:
      return test.fe;
    case WaterParameter.kh:
      return test.kh;
    case WaterParameter.gh:
      return test.gh;
    case WaterParameter.temp:
      return test.temp;
  }
}

WaterAssessment assessWaterValue(WaterParameter parameter, double value) {
  final standard = waterStandards[parameter]!;
  if (parameter == WaterParameter.no3 && value > 50) {
    return const WaterAssessment(
      status: WaterStatus.critical,
      label: 'Krytyczny',
      message: 'Krytyczny poziom NO3. Zalecana podmiana wody 30%.',
    );
  }
  if (parameter == WaterParameter.ph && (value < 6 || value > 8)) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      label: 'Uwaga',
      message: 'pH poza bezpiecznym zakresem 6.0-8.0.',
    );
  }
  if (parameter == WaterParameter.no3 && value > 30) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      label: 'Uwaga',
      message: 'Wysoki poziom NO3. Zalecana podmiana wody 30%.',
    );
  }
  if (parameter == WaterParameter.po4 && value < 0.2) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      label: 'Uwaga',
      message: 'Niski PO4 zwiększa ryzyko zielenic.',
    );
  }
  if (parameter == WaterParameter.po4 && value > 2) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      label: 'Uwaga',
      message: 'Wysoki PO4 zwiększa ryzyko krasnorostów.',
    );
  }
  if (value < standard.chartMin || value > standard.chartMax) {
    return WaterAssessment(
      status: WaterStatus.warning,
      label: 'Uwaga',
      message: '${standard.label} poza zakresem pomiarowym.',
    );
  }
  if (value < standard.optimalMin || value > standard.optimalMax) {
    return WaterAssessment(
      status: WaterStatus.warning,
      label: 'Poza optimum',
      message:
          '${standard.label} poza optimum ${standard.optimalMin}-${standard.optimalMax}${standard.unit.isEmpty ? '' : ' ${standard.unit}'}.',
    );
  }
  return const WaterAssessment(
    status: WaterStatus.good,
    label: 'W normie',
    message: 'Parametr znajduje się w optymalnym zakresie.',
  );
}

List<WaterAssessment> assessWaterTest(WaterTest test) {
  return WaterParameter.values
      .map((parameter) => assessWaterValue(parameter, waterValue(test, parameter)))
      .toList();
}

double? redfieldRatio(WaterTest test) {
  if (test.po4 <= 0) return null;
  return test.no3 / test.po4;
}

WaterAssessment? latestWaterAlert(WaterTest? test) {
  if (test == null) return null;
  final assessments = assessWaterTest(test);
  for (final assessment in assessments) {
    if (assessment.status == WaterStatus.critical) return assessment;
  }
  for (final assessment in assessments) {
    if (assessment.status == WaterStatus.warning) return assessment;
  }
  final ratio = redfieldRatio(test);
  if (ratio != null && (ratio < 10 || ratio > 16)) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      label: 'Uwaga',
      message: 'Stosunek NO3:PO4 poza sugerowanym zakresem 10:1-16:1.',
    );
  }
  return null;
}