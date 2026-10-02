import '../l10n/app_localizations.dart';
import '../services/aquarium_diagnostic_service.dart';

String diagnosticFindingTitle(
  AppLocalizations l10n,
  AquariumDiagnosticFindingKey key,
) {
  return switch (key) {
    AquariumDiagnosticFindingKey.cyanobacteriaRisk =>
      l10n.diagnosticCyanobacteriaRiskTitle,
    AquariumDiagnosticFindingKey.greenAlgaeRisk =>
      l10n.diagnosticGreenAlgaeRiskTitle,
    AquariumDiagnosticFindingKey.dangerousCo2 =>
      l10n.diagnosticDangerousCo2Title,
    AquariumDiagnosticFindingKey.lowCo2 => l10n.diagnosticLowCo2Title,
    AquariumDiagnosticFindingKey.redAlgaeRisk =>
      l10n.diagnosticRedAlgaeRiskTitle,
    AquariumDiagnosticFindingKey.excessiveLighting =>
      l10n.diagnosticExcessiveLightingTitle,
    AquariumDiagnosticFindingKey.stableParameters =>
      l10n.diagnosticStableParametersTitle,
  };
}

String diagnosticFindingMessage(
  AppLocalizations l10n,
  AquariumDiagnosticFindingKey key,
) {
  return switch (key) {
    AquariumDiagnosticFindingKey.cyanobacteriaRisk =>
      l10n.diagnosticCyanobacteriaRiskMessage,
    AquariumDiagnosticFindingKey.greenAlgaeRisk =>
      l10n.diagnosticGreenAlgaeRiskMessage,
    AquariumDiagnosticFindingKey.dangerousCo2 =>
      l10n.diagnosticDangerousCo2Message,
    AquariumDiagnosticFindingKey.lowCo2 => l10n.diagnosticLowCo2Message,
    AquariumDiagnosticFindingKey.redAlgaeRisk =>
      l10n.diagnosticRedAlgaeRiskMessage,
    AquariumDiagnosticFindingKey.excessiveLighting =>
      l10n.diagnosticExcessiveLightingMessage,
    AquariumDiagnosticFindingKey.stableParameters =>
      l10n.diagnosticStableParametersMessage,
  };
}

String diagnosticAction(
  AppLocalizations l10n,
  AquariumDiagnosticActionKey key,
) {
  return switch (key) {
    AquariumDiagnosticActionKey.stabilizeNo3 =>
      l10n.diagnosticActionStabilizeNo3,
    AquariumDiagnosticActionKey.supplementPo4 =>
      l10n.diagnosticActionSupplementPo4,
    AquariumDiagnosticActionKey.reduceCo2AndIncreaseSurfaceMovement =>
      l10n.diagnosticActionReduceCo2AndIncreaseSurfaceMovement,
    AquariumDiagnosticActionKey.stabilizeCo2 =>
      l10n.diagnosticActionStabilizeCo2,
    AquariumDiagnosticActionKey.stabilizeCo2AndCirculation =>
      l10n.diagnosticActionStabilizeCo2AndCirculation,
    AquariumDiagnosticActionKey.reduceLighting =>
      l10n.diagnosticActionReduceLighting,
    AquariumDiagnosticActionKey.continueRegularTesting =>
      l10n.diagnosticActionContinueRegularTesting,
    AquariumDiagnosticActionKey.maintainRedfieldRatio =>
      l10n.diagnosticActionMaintainRedfieldRatio,
  };
}
