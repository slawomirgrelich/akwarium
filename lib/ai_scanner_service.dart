import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

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

  factory AiScanResult.fromJson(Map<String, dynamic> json) {
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
  AiScannerService({http.Client? client}) : _client = client ?? http.Client();

  static const endpoint = String.fromEnvironment('AI_SCANNER_ENDPOINT');
  final http.Client _client;

  Future<AiScanResult> analyze(Uint8List imageBytes, String mimeType) async {
    if (endpoint.isEmpty) {
      throw const AiScannerException(
        'Skaner nie jest jeszcze skonfigurowany. Uruchom aplikację z AI_SCANNER_ENDPOINT wskazującym serwer analizy.',
      );
    }

    final response = await _client
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

  static const _systemPrompt = '''Jesteś ekspertem akwarystyki. Rozpoznaj rybę, roślinę lub inny organizm na zdjęciu. Zwróć wyłącznie poprawny JSON bez markdownu, dokładnie w schemacie: {"nazwa_polska":"...","nazwa_lacinska":"...","typ":"ryba|roślina|inne","wymagania":{"temperatura":{"min":0,"max":0},"pH":{"min":0,"max":0},"min_pojemnosc_akwarium":0,"poziom_trudnosci":"Łatwy|Średni|Trudny"},"opis":"...","zgodnosc":"..."}. Jeśli nie da się rozpoznać organizmu, zwróć błąd HTTP 422. Nie zgaduj pewnego gatunku bez zaznaczenia tego w opisie.''';
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