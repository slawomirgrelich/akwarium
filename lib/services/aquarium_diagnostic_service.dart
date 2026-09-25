class AquariumDiagnosticInput {
  const AquariumDiagnosticInput({
    required this.ph,
    required this.no3,
    required this.po4,
    required this.co2Ppm,
    required this.previousPh,
    required this.lightHours,
  });

  final double ph;
  final double no3;
  final double po4;
  final double co2Ppm;
  final double previousPh;
  final double lightHours;
}

enum DiagnosticSeverity { info, warning, critical }

class AquariumDiagnosticFinding {
  const AquariumDiagnosticFinding({
    required this.title,
    required this.message,
    required this.severity,
  });

  final String title;
  final String message;
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
  final List<String> actionPlan;

  bool get hasWarnings => findings.any(
        (finding) => finding.severity != DiagnosticSeverity.info,
      );
}

class AquariumDiagnosticService {
  AquariumDiagnosticResult diagnose(AquariumDiagnosticInput input) {
    final findings = <AquariumDiagnosticFinding>[];
    final actionPlan = <String>[];
    final ratio = input.po4 <= 0 ? null : input.no3 / input.po4;

    if (input.no3 < 5 && input.po4 > 0.2) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Ryzyko sinic',
          message: 'Bardzo niski NO3 przy obecnym PO4 może sprzyjać sinicom.',
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add('Przywróć mierzalny, stabilny poziom NO3 bez gwałtownego nawożenia.');
    }

    if (input.po4 < 0.2 && input.no3 > 10) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Ryzyko zielenic',
          message: 'Niski PO4 przy wyższym NO3 może sprzyjać zielenicom.',
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add('Sprawdź i uzupełniaj PO4 stopniowo, kontrolując NO3.');
    }

    if (input.co2Ppm > 30) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Niebezpieczny poziom CO2',
          message: 'CO2 powyżej 30 ppm może powodować przyduchę ryb.',
          severity: DiagnosticSeverity.critical,
        ),
      );
      actionPlan.add('Natychmiast ogranicz CO2 i zwiększ ruch tafli wody.');
    } else if (input.co2Ppm < 15) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Niestabilne lub niskie CO2',
          message: 'Niski poziom CO2 może osłabiać rośliny i sprzyjać krasnorostom.',
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add('Ustabilizuj podawanie CO2 i obserwuj reakcję roślin przez kilka dni.');
    }

    if ((input.ph - input.previousPh).abs() >= 0.4 || input.co2Ppm >= 30) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Ryzyko krasnorostów',
          message: 'Wahania pH/CO2 osłabiają rośliny i sprzyjają krasnorostom.',
          severity: DiagnosticSeverity.warning,
        ),
      );
      actionPlan.add('Utrzymuj stałe CO2 oraz popraw cyrkulację w całym zbiorniku.');
    }

    if (input.lightHours > 9) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Długi czas świecenia',
          message: 'Ponad 9 godzin światła może wzmacniać presję glonów.',
          severity: DiagnosticSeverity.info,
        ),
      );
      actionPlan.add('Na czas stabilizacji skróć świecenie do 6–8 godzin.');
    }

    if (findings.isEmpty) {
      findings.add(
        const AquariumDiagnosticFinding(
          title: 'Parametry wyglądają stabilnie',
          message: 'Nie znaleziono typowych sygnałów nierównowagi.',
          severity: DiagnosticSeverity.info,
        ),
      );
      actionPlan.add('Kontynuuj regularne pomiary i utrzymuj stały harmonogram podmian.');
    }

    if (ratio != null && actionPlan.isEmpty) {
      actionPlan.add('Utrzymuj NO3:PO4 w stabilnym zakresie około 10–20:1.');
    }

    return AquariumDiagnosticResult(
      redfieldRatio: ratio,
      findings: findings,
      actionPlan: actionPlan,
    );
  }
}