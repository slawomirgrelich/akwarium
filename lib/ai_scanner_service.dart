import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
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
        temperature: _rangeText(json['tempRange']),
        ph: _rangeText(json['phRange']),
        minimumVolume: _number(json['minTankVolume']),
        difficulty: _requiredText(json['difficulty'], 'difficulty'),
        description: _requiredText(json['description'], 'description'),
        compatibility: 'Wynik wygenerowany przez Gemini Vision.',
      );
    }
    final requirements = _asMap(json['wymagania']);
    return AiScanResult(
      polishName: _requiredText(json['nazwa_polska'], 'nazwa_polska'),
      latinName: _requiredText(json['nazwa_lacinska'], 'nazwa_lacinska'),
      type: _requiredText(json['typ'], 'typ'),
      temperature: _rangeText(requirements['temperatura']),
      ph: _rangeText(requirements['pH'] ?? requirements['ph']),
      minimumVolume: _number(requirements['min_pojemnosc_akwarium']),
      difficulty: _requiredText(requirements['poziom_trudnosci'], 'poziom_trudnosci'),
      description: _requiredText(json['opis'], 'opis'),
      compatibility: _requiredText(json['zgodnosc'], 'zgodnosc'),
    );
  }
}

class AiScannerService {
  AiScannerService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        apiKeyOverride = apiKey;

  static const endpoint = String.fromEnvironment('AI_SCANNER_ENDPOINT');
  static const defaultApiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const modelName = 'gemini-1.5-flash';
  static const fallbackModelName = 'gemini-1.5-pro';
  final http.Client _client;
  final String? apiKeyOverride;

  Future<AiScanResult> analyze(Uint8List imageBytes, String mimeType) async {
    if (endpoint.isEmpty) {
      return _analyzeWithGemini(imageBytes, mimeType);
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image_base64': base64Encode(imageBytes),
              'mime_type': mimeType,
              'system_prompt': _systemPrompt,
            }),
          )
          .timeout(const Duration(seconds: 45));
    } on http.ClientException {
      throw const AiScannerException('Brak połączenia z serwerem analizy.');
    } on TimeoutException {
      throw const AiScannerException('Serwer analizy nie odpowiedział na czas.');
    }

    if (response.statusCode == 422) {
      throw const AiScannerException('Nie rozpoznano gatunku. Wybierz wyraźniejsze zdjęcie organizmu.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiScannerException('Serwer analizy zwrócił błąd (${response.statusCode}).');
    }

    try {
      final decoded = jsonDecode(response.body);
      final payload = decoded is Map<String, dynamic> && decoded['result'] is Map
          ? Map<String, dynamic>.from(decoded['result'] as Map)
          : Map<String, dynamic>.from(decoded as Map);
      return AiScanResult.fromJson(payload);
    } on FormatException {
      throw const AiScannerException('Odpowiedź serwera ma nieprawidłowy format.');
    } on TypeError {
      throw const AiScannerException('Odpowiedź serwera nie zawiera danych gatunku.');
    }
  }

  Future<AiScanResult> _analyzeWithGemini(
    Uint8List imageBytes,
    String mimeType,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final environmentApiKey = defaultApiKey.trim();
    final apiKey = environmentApiKey.isNotEmpty
      ? environmentApiKey
      : apiKeyOverride ?? preferences.getString('gemini_api_key') ?? '';
    if (apiKey.trim().isEmpty) {
      throw const AiScannerException('Ustaw klucz API Gemini w profilu aplikacji.');
    }
    GenerativeAIException? lastModelError;
    for (final selectedModel in [modelName, fallbackModelName]) {
      try {
        final model = GenerativeModel(
          model: selectedModel,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
            temperature: 0.2,
          ),
        );
        final response = await model.generateContent([
          Content.multi([
            TextPart(_geminiPrompt),
            DataPart(mimeType, imageBytes),
          ]),
        ]).timeout(const Duration(seconds: 45));
        final text = response.text?.trim();
        if (text == null || text.isEmpty) {
          throw const AiScannerException('Gemini nie zwróciło wyniku analizy.');
        }
        final decoded = jsonDecode(text);
        return AiScanResult.fromJson(Map<String, dynamic>.from(decoded as Map));
      } on GenerativeAIException catch (error) {
        lastModelError = error;
      }
    }
    throw AiScannerException(
      'Gemini nie mogło przeanalizować zdjęcia: ${lastModelError?.message ?? 'brak dostępnego modelu'}',
    );
  }

  static const _systemPrompt = '''Jesteś ekspertem akwarystyki. Rozpoznaj rybę, roślinę lub inny organizm na zdjęciu. Zwróć wyłącznie poprawny JSON bez markdownu, dokładnie w schemacie: {"nazwa_polska":"...","nazwa_lacinska":"...","typ":"ryba|roślina|inne","wymagania":{"temperatura":{"min":0,"max":0},"pH":{"min":0,"max":0},"min_pojemnosc_akwarium":0,"poziom_trudnosci":"Łatwy|Średni|Trudny"},"opis":"...","zgodnosc":"..."}. Jeśli nie da się rozpoznać organizmu, zwróć błąd HTTP 422. Nie zgaduj pewnego gatunku bez zaznaczenia tego w opisie.''';
  static const _geminiPrompt = '''Przeanalizuj to zdjęcie akwarystyczne. Rozpoznaj gatunek ryby, rośliny, bezkręgowca lub ewentualną chorobę. Zwróć wynik wyłącznie jako poprawny JSON z polami: namePl, nameLatin, category, description, phRange, tempRange, difficulty, minTankVolume. Zakresy phRange i tempRange zwróć jako obiekty z polami min i max. category ustaw jako fish, plant, invertebrate lub disease. Wszystkie wartości tekstowe, w tym description i difficulty, napisz po polsku. Jeśli nie da się wiarygodnie rozpoznać obiektu, wpisz niepewność w description i podaj ostrożne zakresy.''';
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

Map<String, dynamic> _asMap(dynamic value) => value is Map
    ? Map<String, dynamic>.from(value)
    : <String, dynamic>{};

String _requiredText(dynamic value, String field) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) throw AiScannerException('Brak pola $field w odpowiedzi AI.');
  return text;
}

String _rangeText(dynamic value) {
  final range = _asMap(value);
  if (range.isEmpty) return 'Brak danych';
  return '${range['min'] ?? '?'}-${range['max'] ?? '?'}';
}

int _number(dynamic value) => value is num ? value.round() : int.tryParse('$value') ?? 0;