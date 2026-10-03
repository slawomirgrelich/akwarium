import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AiScanResult {
  const AiScanResult({
    required this.polishName,
    required this.latinName,
    required this.type,
    required this.temperature,
    required this.ph,
    required this.minimumVolume,
    required this.difficulty,
    required this.description,
    required this.compatibility,
    this.isMock = false,
  });

  final String polishName;
  final String latinName;
  final String type;
  final String temperature;
  final String ph;
  final int minimumVolume;
  final String difficulty;
  final String description;
  final String compatibility;
  final bool isMock;

  factory AiScanResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('namePl')) {
      return AiScanResult(
        polishName: _requiredText(json['namePl'], 'namePl'),
        latinName: _requiredText(json['nameLatin'], 'nameLatin'),
        type: _requiredText(json['category'], 'category'),
        temperature: _rangeText(
          json['tempRange'] ?? json['temp'],
          fallback: '22 - 26',
        ),
        ph: _rangeText(json['phRange'] ?? json['ph'], fallback: '6.5 - 7.5'),
        minimumVolume: _numberOrDefault(
          json['minTankVolume'] ?? json['tankSize'],
        ),
        difficulty: _textOrFallback(json['difficulty'], 'Łatwy'),
        description: _requiredText(json['description'], 'description'),
        compatibility: 'Wynik wygenerowany przez Gemini Vision.',
      );
    }
    final requirements = _asMap(json['wymagania']);
    return AiScanResult(
      polishName: _requiredText(json['nazwa_polska'], 'nazwa_polska'),
      latinName: _requiredText(json['nazwa_lacinska'], 'nazwa_lacinska'),
      type: _requiredText(json['typ'], 'typ'),
      temperature: _rangeText(requirements['temperatura'], fallback: '22 - 26'),
      ph: _rangeText(
        requirements['pH'] ?? requirements['ph'],
        fallback: '6.5 - 7.5',
      ),
      minimumVolume: _numberOrDefault(requirements['min_pojemnosc_akwarium']),
      difficulty: _textOrFallback(requirements['poziom_trudnosci'], 'Łatwy'),
      description: _requiredText(json['opis'], 'opis'),
      compatibility: _requiredText(json['zgodnosc'], 'zgodnosc'),
    );
  }
}

enum AiDiagnosisCategory { fishDisease, plantIssue, algae, other }

class AiDiagnosisResult {
  const AiDiagnosisResult({
    required this.problemName,
    required this.category,
    required this.confidence,
    required this.summary,
    required this.actions,
  });

  final String problemName;
  final AiDiagnosisCategory category;
  final int confidence;
  final String summary;
  final List<String> actions;

  factory AiDiagnosisResult.fromJson(Map<String, dynamic> json) {
    final name = json['problemName']?.toString().trim() ?? '';
    final summary = json['summary']?.toString().trim() ?? '';
    final rawActions = json['actions'];
    final actions = rawActions is List
        ? rawActions
              .whereType<String>()
              .map((action) => action.trim())
              .where((action) => action.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final rawConfidence = json['confidence'];
    final confidence = rawConfidence is num
        ? rawConfidence.round()
        : int.tryParse('$rawConfidence');
    if (name.isEmpty ||
        summary.isEmpty ||
        actions.isEmpty ||
        confidence == null ||
        confidence < 0 ||
        confidence > 100) {
      throw const AiDiagnosisException(AiDiagnosisFailure.invalidResponse);
    }

    return AiDiagnosisResult(
      problemName: name,
      category: switch (json['category']?.toString().toLowerCase()) {
        'fish_disease' || 'fish disease' => AiDiagnosisCategory.fishDisease,
        'plant_issue' || 'plant problem' => AiDiagnosisCategory.plantIssue,
        'algae' => AiDiagnosisCategory.algae,
        _ => AiDiagnosisCategory.other,
      },
      confidence: confidence,
      summary: summary,
      actions: actions,
    );
  }
}

enum AiDiagnosisFailure {
  missingApiKey,
  invalidApiKey,
  network,
  timeout,
  overloaded,
  invalidResponse,
  requestFailed,
  invalidImage,
  cameraPermissionDenied,
  cameraUnavailable,
  imagePicker,
  unavailable,
}

class AiDiagnosisException implements Exception {
  const AiDiagnosisException(this.failure);

  final AiDiagnosisFailure failure;
}

class AiScannerService {
  AiScannerService({http.Client? client, String? apiKey, bool? useMock})
    : _client = client ?? http.Client(),
      apiKeyOverride = apiKey,
      useMock =
          useMock ??
          (kDebugMode &&
              const bool.fromEnvironment(
                'AI_SCANNER_MOCK',
                defaultValue: false,
              ));

  static const defaultApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _models = ['gemini-3.8-flash', 'gemini-2.5-flash'];
  final http.Client _client;
  final String? apiKeyOverride;
  final bool useMock;

  void close() => _client.close();

  Future<AiDiagnosisResult> diagnose({
    required Uint8List imageBytes,
    required String mimeType,
    required String languageCode,
  }) async {
    if (useMock) return _mockDiagnosis(languageCode);

    final apiKey = await _effectiveApiKey();
    if (apiKey.isEmpty) {
      throw const AiDiagnosisException(AiDiagnosisFailure.missingApiKey);
    }

    for (var index = 0; index < _models.length; index++) {
      http.Response response;
      try {
        response = await _client
            .post(
              Uri.https(
                'generativelanguage.googleapis.com',
                '/v1beta/models/${_models[index]}:generateContent',
                {'key': apiKey},
              ),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': _diagnosisPrompt(languageCode)},
                      {
                        'inline_data': {
                          'mime_type': mimeType,
                          'data': base64Encode(imageBytes),
                        },
                      },
                    ],
                  },
                ],
                'generationConfig': {
                  'response_mime_type': 'application/json',
                  'temperature': 0.2,
                },
              }),
            )
            .timeout(const Duration(seconds: 45));
      } on TimeoutException {
        throw const AiDiagnosisException(AiDiagnosisFailure.timeout);
      } on http.ClientException {
        throw const AiDiagnosisException(AiDiagnosisFailure.network);
      } on Object {
        throw const AiDiagnosisException(AiDiagnosisFailure.unavailable);
      }

      if (response.statusCode == 404 && index < _models.length - 1) continue;
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AiDiagnosisException(AiDiagnosisFailure.invalidApiKey);
      }
      if (response.statusCode == 429 || response.statusCode == 503) {
        throw const AiDiagnosisException(AiDiagnosisFailure.overloaded);
      }
      if (response.statusCode != 200) {
        throw const AiDiagnosisException(AiDiagnosisFailure.requestFailed);
      }

      try {
        final payload = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        final candidates = payload['candidates'];
        if (candidates is! List || candidates.isEmpty) {
          throw const AiDiagnosisException(AiDiagnosisFailure.invalidResponse);
        }
        final candidate = Map<String, dynamic>.from(candidates.first as Map);
        final content = Map<String, dynamic>.from(candidate['content'] as Map);
        final parts = content['parts'];
        if (parts is! List || parts.isEmpty) {
          throw const AiDiagnosisException(AiDiagnosisFailure.invalidResponse);
        }
        final text = (parts.first as Map)['text']?.toString() ?? '';
        final cleaned = text.replaceAll(RegExp(r'```(?:json)?|```'), '').trim();
        if (cleaned.isEmpty) {
          throw const AiDiagnosisException(AiDiagnosisFailure.invalidResponse);
        }
        return AiDiagnosisResult.fromJson(
          Map<String, dynamic>.from(jsonDecode(cleaned) as Map),
        );
      } on AiDiagnosisException {
        rethrow;
      } on Object {
        throw const AiDiagnosisException(AiDiagnosisFailure.invalidResponse);
      }
    }

    throw const AiDiagnosisException(AiDiagnosisFailure.requestFailed);
  }

  Future<String> _effectiveApiKey() async {
    final environmentApiKey = defaultApiKey.trim();
    if (environmentApiKey.isNotEmpty) return environmentApiKey;
    final overrideKey = apiKeyOverride?.trim() ?? '';
    if (overrideKey.isNotEmpty) return overrideKey;
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getString('gemini_api_key')?.trim() ?? '';
    } on Object {
      throw const AiDiagnosisException(AiDiagnosisFailure.unavailable);
    }
  }

  String _diagnosisPrompt(String languageCode) {
    final language = languageCode == 'pl' ? 'Polish' : 'English';
    return '''
You are a cautious aquarium health assistant. Analyze the attached aquarium photo for visible fish disease, plant problems, or algae. Do not claim a definite veterinary diagnosis; describe the most likely visible issue and recommend safe, observable next steps. Do not prescribe medication doses.
Respond only with valid JSON, written in $language, with this exact shape:
{"problemName":"short issue name","category":"fish_disease|plant_issue|algae|other","confidence":0,"summary":"brief explanation","actions":["specific safe step 1","specific safe step 2"]}
Confidence must be an integer from 0 to 100. If the photo does not show a recognizable issue, say so clearly, lower confidence, and recommend checking water parameters or taking a clearer photo.
''';
  }

  AiDiagnosisResult _mockDiagnosis(String languageCode) {
    final isPolish = languageCode == 'pl';
    return AiDiagnosisResult(
      problemName: isPolish
          ? 'Możliwy problem zdrowotny'
          : 'Possible health issue',
      category: AiDiagnosisCategory.fishDisease,
      confidence: 72,
      summary: isPolish
          ? 'To demonstracyjny wynik. Obejrzyj rybę w dobrym świetle i porównaj objawy z pozostałymi mieszkańcami.'
          : 'This is a demo result. Observe the fish in good light and compare its symptoms with other tank inhabitants.',
      actions: isPolish
          ? const [
              'Sprawdź pH, temperaturę, amoniak i azotyny.',
              'Odizoluj rybę tylko wtedy, gdy objawy są widoczne lub stan się pogarsza.',
              'Skonsultuj leczenie z doświadczonym akwarystą przed użyciem preparatów.',
            ]
          : const [
              'Check pH, temperature, ammonia and nitrite.',
              'Isolate the fish only if symptoms are visible or its condition worsens.',
              'Consult an experienced aquarist before using treatments.',
            ],
    );
  }

  Future<void> testApiKey(String apiKey) async {
    final key = apiKey.trim();
    if (key.isEmpty) {
      throw const AiDiagnosisException(AiDiagnosisFailure.missingApiKey);
    }

    try {
      for (var index = 0; index < _models.length; index++) {
        final response = await _client
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/'
                '${_models[index]}:generateContent?key=$key',
              ),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': 'Odpowiedz jednym słowem: OK'},
                    ],
                  },
                ],
                'generationConfig': {'maxOutputTokens': 8},
              }),
            )
            .timeout(const Duration(seconds: 20));
        if (response.statusCode == 404 && index < _models.length - 1) {
          continue;
        }
        if (response.statusCode != 200) {
          if (response.statusCode == 401 || response.statusCode == 403) {
            throw const AiDiagnosisException(AiDiagnosisFailure.invalidApiKey);
          }
          if (response.statusCode == 429 || response.statusCode == 503) {
            throw const AiDiagnosisException(AiDiagnosisFailure.overloaded);
          }
          throw const AiDiagnosisException(AiDiagnosisFailure.requestFailed);
        }
        return;
      }
    } on TimeoutException {
      throw const AiDiagnosisException(AiDiagnosisFailure.timeout);
    } on http.ClientException {
      throw const AiDiagnosisException(AiDiagnosisFailure.network);
    }
  }

  Future<AiScanResult> analyze(Uint8List imageBytes, String mimeType) async {
    return _analyzeWithGemini(imageBytes);
  }

  Future<AiScanResult> _analyzeWithGemini(Uint8List imageBytes) async {
    final environmentApiKey = defaultApiKey.trim();
    final preferences = await SharedPreferences.getInstance();
    final storedApiKey = preferences.getString('gemini_api_key')?.trim() ?? '';
    final apiKey = environmentApiKey.isNotEmpty
        ? environmentApiKey
        : apiKeyOverride?.trim() ?? storedApiKey;
    if (apiKey.trim().isEmpty) {
      throw const AiScannerException(
        'Klucz API Gemini jest pusty. Sprawdź GitHub Secrets lub Ustawienia Profilu.',
      );
    }
    var overloadFailures = 0;
    for (var index = 0; index < _models.length; index++) {
      try {
        final requestUrl =
            'https://generativelanguage.googleapis.com/v1beta/models/'
            '${_models[index]}:generateContent?key=$apiKey';
        debugPrint(
          'Requesting Gemini API via: '
          '${requestUrl.replaceAll(apiKey, 'HIDDEN_KEY')}',
        );
        final response = await _client
            .post(
              Uri.parse(requestUrl),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': _geminiPrompt},
                      {
                        'inline_data': {
                          'mime_type': 'image/jpeg',
                          'data': base64Encode(imageBytes),
                        },
                      },
                    ],
                  },
                ],
                'generationConfig': {'response_mime_type': 'application/json'},
              }),
            )
            .timeout(const Duration(seconds: 45));
        if (response.statusCode != 200) {
          if (response.statusCode == 503 || response.statusCode == 429) {
            overloadFailures++;
            if (index < _models.length - 1) {
              await Future<void>.delayed(const Duration(milliseconds: 1500));
              continue;
            }
            throw const AiScannerException(
              'Serwery AI są obecnie przeciążone. Spróbuj ponownie za chwilę.',
            );
          }
          if (response.statusCode == 404 && index < _models.length - 1) {
            debugPrint(
              'Gemini model ${_models[index]} is unavailable; trying fallback.',
            );
            continue;
          }
          throw AiScannerException(
            'HTTP ${response.statusCode}:${response.body}',
          );
        }
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>? ?? const [];
        final candidate = candidates.isEmpty
            ? const <String, dynamic>{}
            : Map<String, dynamic>.from(candidates.first as Map);
        final content = Map<String, dynamic>.from(
          candidate['content'] as Map? ?? const {},
        );
        final parts = content['parts'] as List<dynamic>? ?? const [];
        final text = parts.isEmpty
            ? ''
            : (parts.first as Map)['text']?.toString().trim() ?? '';
        if (text.isEmpty) {
          throw const AiScannerException('Gemini nie zwróciło wyniku analizy.');
        }
        final cleanedText = text.replaceAll(RegExp(r'```json|```'), '').trim();
        return AiScanResult.fromJson(
          Map<String, dynamic>.from(jsonDecode(cleanedText) as Map),
        );
      } on TimeoutException {
        throw const AiScannerException('Analiza Gemini trwała zbyt długo.');
      } on http.ClientException catch (error) {
        throw AiScannerException('Błąd połączenia z Gemini: ${error.message}');
      } on FormatException {
        throw const AiScannerException(
          'Gemini zwróciło nieprawidłowy format JSON.',
        );
      }
    }
    if (overloadFailures == _models.length) {
      throw const AiScannerException(
        'Serwery AI są obecnie przeciążone. Spróbuj ponownie za chwilę.',
      );
    }
    throw const AiScannerException('Gemini nie zwróciło wyniku analizy.');
  }

  static const _geminiPrompt = '''Przeanalizuj to zdjęcie akwarystyczne. Zwróć WYŁĄCZNIE poprawny JSON bez żadnego dodatkowego tekstu ani znaczników markdown codeblock.
Wymagane pola w JSON:
- namePl (String, nazwa polska)
- nameLatin (String, nazwa łacińska)
- category (String, np. Ryba, Roślina, Bezkręgowiec)
- description (String, krótki opis)
- phRange (String, np. '6.0 - 7.5')
- tempRange (String, np. '22 - 28')
- difficulty (String, np. Łatwy, Średni, Trudny)
- minTankVolume (int lub String, np. 50)''';
}

class MockAiScannerService {
  static const result = AiScanResult(
    polishName: 'Neonek Innesa',
    latinName: 'Paracheirodon innesi',
    type: 'ryba',
    temperature: '20-26',
    ph: '5.0-7.5',
    minimumVolume: 60,
    difficulty: 'Łatwy',
    description: 'Spokojna ryba ławicowa, która najlepiej prezentuje się w grupie. Preferuje zacienione miejsca i roślinne akwaria.',
    compatibility: 'Trzymaj minimum 6 sztuk. Unikaj dużych, drapieżnych ryb i zapewnij spokojnych współmieszkańców.',
    isMock: true,
  );
}

class AiScannerException implements Exception {
  const AiScannerException(this.message);

  final String message;

  @override
  String toString() => message;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String _requiredText(dynamic value, String field) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) {
    throw AiScannerException('Brak pola $field w odpowiedzi AI.');
  }
  return text;
}

String _rangeText(dynamic value, {String fallback = 'Brak danych'}) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  final range = _asMap(value);
  if (range.isEmpty) return fallback;
  return '${range['min'] ?? '?'} - ${range['max'] ?? '?'}';
}

String _textOrFallback(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _numberOrDefault(Object? value) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  return parsed > 0 ? parsed : 50;
}
