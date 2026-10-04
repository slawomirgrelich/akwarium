class AquariumDiagnosticInput {
  const AquariumDiagnosticInput({
    required this.ph,
    required this.no3,
    required this.po4,
    this.co2MgPerLiter,
    required this.previousPh,
    required this.lightHours,
  });

  final double ph;
  final double no3;
  final double po4;
  final double? co2MgPerLiter;
  final double previousPh;
  final double lightHours;
}

enum DiagnosticSeverity { info, warning, critical }

enum AquariumDiagnosticFindingKey {
  cyanobacteriaRisk,
  greenAlgaeRisk,
  dangerousCo2,
  lowCo2,
  redAlgaeRisk,
  excessiveLighting,
  stableParameters,
}

enum AquariumDiagnosticActionKey {
  stabilizeNo3,
  supplementPo4,
  reduceCo2AndIncreaseSurfaceMovement,
  stabilizeCo2,
  stabilizeCo2AndCirculation,
  reduceLighting,
  continueRegularTesting,
  maintainRedfieldRatio,
}

class AquariumDiagnosticFinding {
  const AquariumDiagnosticFinding({
    required this.key,
    required this.severity,
  });

  final AquariumDiagnosticFindingKey key;
  final DiagnosticSeverity severity;
}

class AquariumDiagnosticResult {
  const AquariumDiagnosticResult({
    required this.redfieldRatio,
    required this.findings,
    required this.actionPlan,
  });

  final double? redfieldRatio;
  final List<AquariumDiagnosticFinding> findings;
  final List<AquariumDiagnosticActionKey> actionPlan;

  bool get hasWarnings => findings.any(
        (finding) => finding.severity != DiagnosticSeverity.info,
      );
}

class AquariumDiagnosticService {
  AquariumDiagnosticResult diagnose(AquariumDiagnosticInput input) {
    final findings = <AquariumDiagnosticFinding>[];
    final actionPlan = <AquariumDiagnosticActionKey>[];
    final ratio = input.po4 <= 0 ? null : input.no3 / input.po4;

    if (input.no3 < 5 && input.po4 > 0.2) {
      findings.add(
        const AquariumDiagnosticFinding(
          key: AquariumDiagnosticFindingKey.cyanobacteriaRisk,
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add(AquariumDiagnosticActionKey.stabilizeNo3);
    }

    if (input.po4 < 0.2 && input.no3 > 10) {
      findings.add(
        const AquariumDiagnosticFinding(
          key: AquariumDiagnosticFindingKey.greenAlgaeRisk,
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add(AquariumDiagnosticActionKey.supplementPo4);
    }

    final co2 = input.co2MgPerLiter;
    if (co2 != null) {
      if (co2 > 30) {
        findings.add(
          const AquariumDiagnosticFinding(
            key: AquariumDiagnosticFindingKey.dangerousCo2,
            severity: DiagnosticSeverity.critical,
          ),
        );
        actionPlan.add(
          AquariumDiagnosticActionKey.reduceCo2AndIncreaseSurfaceMovement,
        );
      } else if (co2 < 15) {
        findings.add(
          const AquariumDiagnosticFinding(
            key: AquariumDiagnosticFindingKey.lowCo2,
            severity: DiagnosticSeverity.warning,
          ),
        );
        actionPlan.add(AquariumDiagnosticActionKey.stabilizeCo2);
      }
    }

    if ((input.ph - input.previousPh).abs() >= 0.4 ||
        (co2 != null && co2 >= 30)) {
      findings.add(
        const AquariumDiagnosticFinding(
          key: AquariumDiagnosticFindingKey.redAlgaeRisk,
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add(AquariumDiagnosticActionKey.stabilizeCo2AndCirculation);
    }

    if (input.lightHours > 9) {
      findings.add(
        const AquariumDiagnosticFinding(
          key: AquariumDiagnosticFindingKey.excessiveLighting,
          severity: DiagnosticSeverity.info,
        ),
      );
      actionPlan.add(AquariumDiagnosticActionKey.reduceLighting);
    }

    if (findings.isEmpty) {
      findings.add(
        const AquariumDiagnosticFinding(
          key: AquariumDiagnosticFindingKey.stableParameters,
          severity: DiagnosticSeverity.info,
        ),
      );
      actionPlan.add(AquariumDiagnosticActionKey.continueRegularTesting);
    }

    if (ratio != null && actionPlan.isEmpty) {
      actionPlan.add(AquariumDiagnosticActionKey.maintainRedfieldRatio);
    }

    return AquariumDiagnosticResult(
      redfieldRatio: ratio,
      findings: findings,
      actionPlan: actionPlan,
    );
  }
}