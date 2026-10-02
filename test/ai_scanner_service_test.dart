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
}
