import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class AlgaeDiagnosticInput {
  const AlgaeDiagnosticInput({
    required this.algaeType,
    required this.no3,
    required this.po4,
    required this.fe,
    required this.ph,
    required this.kh,
    required this.lightHours,
    required this.co2,
    required this.substrate,
    this.imageBytes,
    this.imageMimeType,
  });

  final String algaeType;
  final double no3;
  final double po4;
  final double fe;
  final double ph;
  final double kh;
  final double lightHours;
  final bool co2;
  final String substrate;
  final Uint8List? imageBytes;
  final String? imageMimeType;

  Map<String, dynamic> toJson() => {
    'glon': algaeType,
    'parametry_wody': {'NO3': no3, 'PO4': po4, 'Fe': fe, 'pH': ph, 'KH': kh},
    'czas_swiecenia_godziny': lightHours,
    'co2': co2,
    'podloze': substrate,
    if (imageBytes != null) 'image_base64': base64Encode(imageBytes!),
    if (imageMimeType != null) 'mime_type': imageMimeType,
  };
}

class AlgaeDiagnosticResult {
  const AlgaeDiagnosticResult({
    required this.algaeName,
    required this.cause,
    required this.actions,
    this.isMock = false,
  });

  final String algaeName;
  final String cause;
  final List<String> actions;
  final bool isMock;

  factory AlgaeDiagnosticResult.fromJson(Map<String, dynamic> json) {
    final rawActions = json['plan_dzialania'] ?? json['plan'] ?? const [];
    if (rawActions is! List || rawActions.isEmpty) {
      throw const AlgaeAssistantException('Odpowiedź nie zawiera planu działania.');
    }
    return AlgaeDiagnosticResult(
      algaeName: _text(json['glon'] ?? json['algae'], 'glon'),
      cause: _text(json['przyczyna'] ?? json['cause'], 'przyczyna'),
      actions: rawActions.map((item) => item.toString()).toList(),
    );
  }
}

class AlgaeAssistantService {
  AlgaeAssistantService({http.Client? client}) : _client = client ?? http.Client();

  static const endpoint = String.fromEnvironment('ALGAE_ASSISTANT_ENDPOINT');
  static const allowMock = bool.fromEnvironment(
    'ALGAE_ASSISTANT_ALLOW_MOCK',
    defaultValue: true,
  );
  final http.Client _client;

  Future<AlgaeDiagnosticResult> diagnose(AlgaeDiagnosticInput input) async {
    if (endpoint.isEmpty) {
      if (allowMock) return _mock(input);
      throw const AlgaeAssistantException('Asystent glonów nie jest skonfigurowany.');
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              ...input.toJson(),
              'system_prompt': _systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 45));
    } on http.ClientException {
      if (allowMock) return _mock(input);
      throw const AlgaeAssistantException('Brak połączenia z serwerem diagnostyki.');
    } on TimeoutException {
      if (allowMock) return _mock(input);
      throw const AlgaeAssistantException('Serwer diagnostyki nie odpowiedział na czas.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AlgaeAssistantException('Serwer diagnostyki zwrócił błąd (${response.statusCode}).');
    }
    try {
      final decoded = jsonDecode(response.body);
      final payload = decoded is Map<String, dynamic> && decoded['result'] is Map
          ? Map<String, dynamic>.from(decoded['result'] as Map)
          : Map<String, dynamic>.from(decoded as Map);
      return AlgaeDiagnosticResult.fromJson(payload);
    } on FormatException {
      throw const AlgaeAssistantException('Odpowiedź diagnostyki ma nieprawidłowy format.');
    } on TypeError {
      throw const AlgaeAssistantException('Odpowiedź diagnostyki nie zawiera danych.');
    }
  }

  AlgaeDiagnosticResult _mock(AlgaeDiagnosticInput input) {
    final ratio = input.po4 <= 0 ? double.infinity : input.no3 / input.po4;
    final cause = ratio > 30
        ? 'Stosunek NO3 do PO4 wynosi ${ratio.isFinite ? ratio.toStringAsFixed(0) : 'bardzo dużo'}:1 - za mało fosforu sprzyja zielenicom.'
        : input.fe > 0.5
            ? 'Podwyższone Fe (${input.fe.toStringAsFixed(2)} mg/l) może wzmacniać wzrost glonów przy długim świeceniu.'
            : !input.co2
                ? 'Brak CO2 ogranicza konkurencyjny wzrost roślin, przez co glony łatwiej wykorzystują światło i składniki.'
                : 'Najbardziej prawdopodobna jest nierównowaga światła, nawożenia i cyrkulacji w zbiorniku.';
    return AlgaeDiagnosticResult(
      algaeName: input.algaeType,
      cause: cause,
      actions: [
        'Podmień 30% wody i usuń glony mechanicznie.',
        'Skróć świecenie do 6 godzin dziennie na najbliższy tydzień.',
        ratio > 30 ? 'Uzupełnij PO4 ostrożnie i dąż do stabilnego NO3:PO4 około 10-20:1.' : 'Skoryguj nawożenie dopiero po 3-4 dniach stabilnych pomiarów.',
        'Sprawdź cyrkulację i oczyść filtr bez wymiany całego wkładu biologicznego.',
      ],
      isMock: true,
    );
  }

  static const _systemPrompt = '''Jesteś diagnostą akwarystycznym. Na podstawie typu glonu, parametrów NO3, PO4, Fe, pH, KH, światła, CO2, podłoża i zdjęcia określ najbardziej prawdopodobną przyczynę. Uwzględnij stosunek Redfielda NO3:PO4, nadmiar Fe, brak CO2, zbyt długie światło i cyrkulację. Zwróć wyłącznie JSON: {"glon":"...","przyczyna":"...","plan_dzialania":["krok 1","krok 2"]}. Plan ma mieć konkretne, bezpieczne czynności i nie zalecać gwałtownych zmian parametrów.''';
}

class AlgaeAssistantException implements Exception {
  const AlgaeAssistantException(this.message);

  final String message;

  @override
  String toString() => message;
}

String _text(dynamic value, String field) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) throw AlgaeAssistantException('Brak pola $field w odpowiedzi.');
  return text;
}