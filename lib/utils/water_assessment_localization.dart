import '../l10n/app_localizations.dart';
import '../models/water_standards.dart';

String waterAssessmentLabel(
  AppLocalizations l10n,
  WaterAssessment assessment,
) {
  return switch (assessment.messageKey) {
    WaterAssessmentMessageKey.criticalNo3 => l10n.waterAssessmentCritical,
    WaterAssessmentMessageKey.outsideOptimalRange =>
      l10n.waterAssessmentOutsideOptimum,
    WaterAssessmentMessageKey.withinOptimalRange =>
      l10n.waterAssessmentNormal,
    _ => l10n.waterAssessmentWarning,
  };
}

String waterAssessmentMessage(
  AppLocalizations l10n,
  WaterAssessment assessment,
) {
  return switch (assessment.messageKey) {
    WaterAssessmentMessageKey.criticalNo3 => l10n.waterAssessmentCriticalNo3,
    WaterAssessmentMessageKey.phOutsideSafeRange =>
      l10n.waterAssessmentPhOutsideSafeRange,
    WaterAssessmentMessageKey.highNo3 => l10n.waterAssessmentHighNo3,
    WaterAssessmentMessageKey.lowPo4 => l10n.waterAssessmentLowPo4,
    WaterAssessmentMessageKey.highPo4 => l10n.waterAssessmentHighPo4,
    WaterAssessmentMessageKey.outsideMeasurementRange =>
      l10n.waterAssessmentOutsideMeasurementRange(
        _localizedParameterLabel(l10n, assessment.parameter!),
      ),
    WaterAssessmentMessageKey.outsideOptimalRange =>
      l10n.waterAssessmentOutsideOptimalRange(
        _localizedParameterLabel(l10n, assessment.parameter!),
        assessment.minValue!,
        assessment.maxValue!,
        _localizedParameterUnit(assessment.parameter!),
      ),
    WaterAssessmentMessageKey.withinOptimalRange =>
      l10n.waterAssessmentWithinOptimalRange,
    WaterAssessmentMessageKey.redfieldRatio =>
      l10n.waterAssessmentRedfieldRatio,
  };
}

String _localizedParameterLabel(
  AppLocalizations l10n,
  WaterParameter parameter,
) {
  if (parameter == WaterParameter.temp) return l10n.temperature;
  return waterStandards[parameter]!.label;
}

String _localizedParameterUnit(WaterParameter parameter) {
  final unit = waterStandards[parameter]!.unit;
  return unit.isEmpty ? '' : ' $unit';
}
