import 'dart:convert';
import 'dart:typed_data';

import 'package:akwarium/ai_scanner_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'falls back when a Gemini model is unavailable and retains the saved key',
    () async {
      SharedPreferences.setMockInitialValues({
        'gemini_api_key': 'manual-test-key',
      });
      final requestedModels = <String>[];
      final client = MockClient((request) async {
        requestedModels.add(request.url.path);
        if (request.url.path.contains('gemini-3.8-flash')) {
          return http.Response('{}', 404);
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text': jsonEncode({
                          'namePl': 'Neon Innesa',
                          'nameLatin': 'Paracheirodon innesi',
                          'category': 'Ryba',
                          'tempRange': '20-26',
                          'phRange': '5.0-7.5',
                          'minTankVolume': 60,
                          'difficulty': 'Łatwa',
                          'description': 'Ryba stadna.',
                        }),
                      },
                    ],
                  },
                },
              ],
            }),
          ),
          200,
        );
      });

      final result = await AiScannerService(client: client)
          .analyze(Uint8List(0), 'image/jpeg');
      final preferences = await SharedPreferences.getInstance();

      expect(requestedModels, hasLength(2));
      expect(requestedModels.last, contains('gemini-2.5-flash'));
      expect(result.polishName, 'Neon Innesa');
      expect(preferences.getString('gemini_api_key'), 'manual-test-key');
      client.close();
    },
    skip: AiScannerService.defaultApiKey.isNotEmpty
        ? 'Uses an environment key instead of the stored key.'
        : false,
  );

  test('Gemini key validation falls back from unavailable models', () async {
    final requestedModels = <String>[];
    final client = MockClient((request) async {
      requestedModels.add(request.url.path);
      return http.Response(
        '{}',
        request.url.path.contains('gemini-3.8-flash') ? 404 : 200,
      );
    });

    await AiScannerService(client: client).testApiKey('manual-test-key');

    expect(requestedModels, hasLength(2));
    expect(requestedModels.last, contains('gemini-2.5-flash'));
    client.close();
  });

  test(
    'diagnosis request parses confidence and next steps from Gemini JSON',
    () async {
      SharedPreferences.setMockInitialValues({});
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final contents = body['contents'] as List<dynamic>;
        final parts =
            (contents.single as Map<String, dynamic>)['parts'] as List<dynamic>;
        expect(
          (parts.first as Map<String, dynamic>)['text'],
          contains('English'),
        );
        expect(
          (parts[1] as Map<String, dynamic>)['inline_data']['mime_type'],
          'image/png',
        );
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'problemName': 'Possible ich',
                        'category': 'fish_disease',
                        'confidence': 91,
                        'summary': 'Several small white spots are visible.',
                        'actions': [
                          'Check ammonia and nitrite.',
                          'Observe the other fish.',
                        ],
                      }),
                    },
                  ],
                },
              },
            ],
          }),
          200,
        );
      });
      final service = AiScannerService(client: client, apiKey: 'test-key');

      final result = await service.diagnose(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/png',
        languageCode: 'en',
      );

      expect(result.problemName, 'Possible ich');
      expect(result.category, AiDiagnosisCategory.fishDisease);
      expect(result.confidence, 91);
      expect(result.actions, hasLength(2));
      service.close();
    },
  );

  test('diagnosis mock mode returns a localized safe demo result', () async {
    final client = MockClient((_) async => http.Response('', 500));
    final service = AiScannerService(client: client, useMock: true);

    final result = await service.diagnose(
      imageBytes: Uint8List.fromList([1]),
      mimeType: 'image/jpeg',
      languageCode: 'pl',
    );

    expect(result.confidence, inInclusiveRange(0, 100));
    expect(result.summary, contains('demonstracyjny'));
    expect(result.actions, isNotEmpty);
    service.close();
  });

  test(
    'diagnosis parses structured result and forwards image MIME and locale',
    () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final contents = body['contents'] as List<dynamic>;
        final parts = (contents.first as Map<String, dynamic>)['parts'] as List;
        expect((parts.first as Map)['text'], contains('English'));
        expect((parts[1] as Map)['inline_data']['mime_type'], 'image/png');
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text': jsonEncode({
                        'problemName': 'Possible ich',
                        'category': 'fish_disease',
                        'confidence': 91,
                        'summary': 'Several small white spots are visible.',
                        'actions': [
                          'Check ammonia and nitrite.',
                          'Observe the other fish.',
                        ],
                      }),
                    },
                  ],
                },
              },
            ],
          }),
          200,
        );
      });
      final service = AiScannerService(client: client, apiKey: 'test-key');

      final result = await service.diagnose(
        imageBytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/png',
        languageCode: 'en',
      );

      expect(result.problemName, 'Possible ich');
      expect(result.category, AiDiagnosisCategory.fishDisease);
      expect(result.confidence, 91);
      expect(result.actions, hasLength(2));
      service.close();
    },
  );

  test(
    'diagnosis mock mode returns a localized safe result without network',
    () async {
      final client = MockClient((_) async => http.Response('', 500));
      final service = AiScannerService(client: client, useMock: true);

      final result = await service.diagnose(
        imageBytes: Uint8List.fromList([1]),
        mimeType: 'image/jpeg',
        languageCode: 'pl',
      );

      expect(result.confidence, inInclusiveRange(0, 100));
      expect(result.summary, contains('demonstracyjny'));
      expect(result.actions, isNotEmpty);
      service.close();
    },
  );
}
