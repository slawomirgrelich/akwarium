import 'aquarium_model.dart';

enum WaterStatus { good, warning, critical }

enum WaterParameter { ph, no3, po4, fe, kh, gh, temp }

enum WaterAssessmentMessageKey {
  criticalNo3,
  phOutsideSafeRange,
  highNo3,
  lowPo4,
  highPo4,
  outsideMeasurementRange,
  outsideOptimalRange,
  withinOptimalRange,
  redfieldRatio,
}

class WaterAssessment {
  const WaterAssessment({
    required this.status,
    required this.messageKey,
    this.parameter,
    this.minValue,
    this.maxValue,
  });

  final WaterStatus status;
  final WaterAssessmentMessageKey messageKey;
  final WaterParameter? parameter;
  final double? minValue;
  final double? maxValue;

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
    optimalMin: 0.02,
    optimalMax: 1.5,
    chartMin: 0,
    chartMax: 3,
  ),
  WaterParameter.fe: WaterStandard(
    parameter: WaterParameter.fe,
    label: 'Fe',
    unit: 'mg/l',
    optimalMin: 0.05,
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

double? waterValue(WaterTest test, WaterParameter parameter) {
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
  if (parameter == WaterParameter.fe &&
      value >= standard.chartMin &&
      value < standard.optimalMin) {
    return const WaterAssessment(
      status: WaterStatus.good,
      messageKey: WaterAssessmentMessageKey.withinOptimalRange,
      parameter: WaterParameter.fe,
    );
  }
  if (parameter == WaterParameter.po4 &&
      value >= standard.chartMin &&
      value < standard.optimalMin) {
    return const WaterAssessment(
      status: WaterStatus.good,
      messageKey: WaterAssessmentMessageKey.withinOptimalRange,
      parameter: WaterParameter.po4,
    );
  }
  if (parameter == WaterParameter.no3 && value > 50) {
    return const WaterAssessment(
      status: WaterStatus.critical,
      messageKey: WaterAssessmentMessageKey.criticalNo3,
      parameter: WaterParameter.no3,
    );
  }
  if (parameter == WaterParameter.ph && (value < 6 || value > 8)) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      messageKey: WaterAssessmentMessageKey.phOutsideSafeRange,
      parameter: WaterParameter.ph,
    );
  }
  if (parameter == WaterParameter.no3 && value > 30) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      messageKey: WaterAssessmentMessageKey.highNo3,
      parameter: WaterParameter.no3,
    );
  }
  if (parameter == WaterParameter.po4 && value > 2) {
    return const WaterAssessment(
      status: WaterStatus.warning,
      messageKey: WaterAssessmentMessageKey.highPo4,
      parameter: WaterParameter.po4,
    );
  }
  if (value < standard.chartMin || value > standard.chartMax) {
    return WaterAssessment(
      status: WaterStatus.warning,
      messageKey: WaterAssessmentMessageKey.outsideMeasurementRange,
      parameter: parameter,
    );
  }
  if (value < standard.optimalMin || value > standard.optimalMax) {
    return WaterAssessment(
      status: WaterStatus.warning,
      messageKey: WaterAssessmentMessageKey.outsideOptimalRange,
      parameter: parameter,
      minValue: standard.optimalMin,
      maxValue: standard.optimalMax,
    );
  }
  return WaterAssessment(
    status: WaterStatus.good,
    messageKey: WaterAssessmentMessageKey.withinOptimalRange,
    parameter: parameter,
  );
}

List<WaterAssessment> assessWaterTest(WaterTest test) {
  return [
    for (final parameter in WaterParameter.values)
      if (waterValue(test, parameter) case final value?)
        assessWaterValue(parameter, value),
  ];
}

double? redfieldRatio(WaterTest test) {
  final no3 = test.no3;
  final po4 = test.po4;
  if (no3 == null || po4 == null || po4 <= 0) return null;
  return no3 / po4;
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
      messageKey: WaterAssessmentMessageKey.redfieldRatio,
    );
  }
  return null;
}
