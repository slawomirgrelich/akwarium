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

  static const defaultApiKey = String.fromEnvironment('GEMINI_API_KEY');
  final http.Client _client;
  final String? apiKeyOverride;

  Future<AiScanResult> analyze(Uint8List imageBytes, String mimeType) async {
    return _analyzeWithGemini(imageBytes);
  }

  Future<AiScanResult> _analyzeWithGemini(Uint8List imageBytes) async {
    final environmentApiKey = defaultApiKey.trim();
    final preferences = await SharedPreferences.getInstance();
    final storedApiKey = preferences.getString('gemini_api_key')?.trim() ?? '';
    final usesStoredApiKey = environmentApiKey.isEmpty && apiKeyOverride == null && storedApiKey.isNotEmpty;
    final apiKey = environmentApiKey.isNotEmpty
        ? environmentApiKey
        : apiKeyOverride?.trim() ?? storedApiKey;
    if (apiKey.trim().isEmpty) {
      throw const AiScannerException(
        'Klucz API Gemini jest pusty. Sprawdź GitHub Secrets lub Ustawienia Profilu.',
      );
    }
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-1.5-flash:generateContent?key=$apiKey';
    final requestUrls = [
      url,
      'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-2.0-flash:generateContent?key=$apiKey',
    ];
    for (final requestUrl in requestUrls) {
      try {
        debugPrint(
          'Requesting Gemini API via: '
          '${requestUrl.replaceAll(apiKey, 'HIDDEN_KEY')}',
        );
        final response = await _client.post(
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
          }),
        ).timeout(const Duration(seconds: 45));
        if (response.statusCode != 200) {
          if (response.statusCode == 404 && usesStoredApiKey) {
            await preferences.remove('gemini_api_key');
          }
          if (requestUrl != requestUrls.last) {
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
        final content = Map<String, dynamic>.from(candidate['content'] as Map? ?? const {});
        final parts = content['parts'] as List<dynamic>? ?? const [];
        final text = parts.isEmpty ? '' : (parts.first as Map)['text']?.toString().trim() ?? '';
        if (text.isEmpty) {
          throw const AiScannerException('Gemini nie zwróciło wyniku analizy.');
        }
        return AiScanResult.fromJson(
          Map<String, dynamic>.from(jsonDecode(_stripJsonMarkdown(text)) as Map),
        );
      } on TimeoutException {
        throw const AiScannerException('Analiza Gemini trwała zbyt długo.');
      } on http.ClientException catch (error) {
        throw AiScannerException('Błąd połączenia z Gemini: ${error.message}');
      } on FormatException {
        throw const AiScannerException('Gemini zwróciło nieprawidłowy format JSON.');
      }
    }
    throw const AiScannerException('Gemini nie zwróciło wyniku analizy.');
  }

  static String _stripJsonMarkdown(String text) {
    if (text.startsWith('```')) {
      return text
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    return text;
  }

  static const _geminiPrompt = 'Przeanalizuj to zdjęcie akwarystyczne. Rozpoznaj gatunek ryby, rośliny, bezkręgowca lub ewentualną chorobę. Zwróć wynik w formacie JSON z polami: namePl, nameLatin, category, description, phRange, tempRange, difficulty, minTankVolume.';
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