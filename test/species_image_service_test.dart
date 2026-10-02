import 'dart:convert';

import 'package:akwarium/services/species_image_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('finds a matching reusable Commons thumbnail and attribution', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'commons.wikimedia.org');
      expect(request.url.queryParameters['origin'], '*');
      expect(request.url.queryParameters['gsrsearch'], '"Caridina dennerli"');
      return http.Response(
        jsonEncode({
          'query': {
            'pages': {
              '1': {
                'title': 'File:Unrelated animal.jpg',
                'imageinfo': [
                  {
                    'thumburl': 'https://upload.wikimedia.org/wikipedia/commons/unrelated.jpg',
                    'extmetadata': {
                      'LicenseShortName': {'value': 'CC BY 4.0'},
                      'ObjectName': {'value': 'Unrelated animal'},
                    },
                  },
                ],
              },
              '2': {
                'title': 'File:Caridina_dennerli.jpg',
                'imageinfo': [
                  {
                    'thumburl': 'https://upload.wikimedia.org/wikipedia/commons/caridina.jpg',
                    'extmetadata': {
                      'LicenseShortName': {'value': 'CC BY-SA 4.0'},
                      'Artist': {
                        'value': '<a href="/wiki/User:Artist">Artist</a>',
                      },
                      'ObjectName': {'value': 'Caridina dennerli'},
                    },
                  },
                ],
              },
            },
          },
        }),
        200,
      );
    });
    final service = SpeciesImageService(client: client);

    final image = await service.findByScientificName('Caridina dennerli');

    expect(
      image?.url,
      'https://upload.wikimedia.org/wikipedia/commons/caridina.jpg',
    );
    expect(image?.attribution, contains('Artist'));
    expect(image?.attribution, contains('CC BY-SA 4.0'));
    client.close();
  });

  test(
    'does not return non-commercial, no-derivatives, or unrelated images',
    () async {
      final client = MockClient((request) async {
        final query = request.url.queryParameters['gsrsearch']!;
        final license = query.contains('NC')
            ? 'CC BY-NC 4.0'
            : query.contains('ND')
            ? 'CC BY-ND 4.0'
            : 'CC BY 4.0';
        return http.Response(
          jsonEncode({
            'query': {
              'pages': {
                '1': {
                  'title': 'File:Caridina dennerli.jpg',
                  'imageinfo': [
                    {
                      'thumburl': 'https://upload.wikimedia.org/wikipedia/commons/caridina.jpg',
                      'extmetadata': {
                        'LicenseShortName': {'value': license},
                        'ObjectName': {'value': 'Caridina dennerli'},
                      },
                    },
                  ],
                },
              },
            },
          }),
          200,
        );
      });
      final service = SpeciesImageService(client: client);

      expect(
        await service.findByScientificName('Caridina dennerli NC'),
        isNull,
      );
      expect(
        await service.findByScientificName('Caridina dennerli ND'),
        isNull,
      );
      expect(await service.findByScientificName('Caridina mariae'), isNull);
      client.close();
    },
  );

  test('caches Commons lookups by scientific name', () async {
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response(
        jsonEncode({
          'query': {
            'pages': {
              '1': {
                'title': 'File:Caridina dennerli.jpg',
                'imageinfo': [
                  {
                    'thumburl': 'https://upload.wikimedia.org/wikipedia/commons/caridina.jpg',
                    'extmetadata': {
                      'LicenseShortName': {'value': 'CC0'},
                      'ObjectName': {'value': 'Caridina dennerli'},
                    },
                  },
                ],
              },
            },
          },
        }),
        200,
      );
    });
    final service = SpeciesImageService(client: client);

    await Future.wait([
      service.findByScientificName('Caridina dennerli'),
      service.findByScientificName('Caridina dennerli'),
    ]);

    expect(requests, 1);
    client.close();
  });
}
