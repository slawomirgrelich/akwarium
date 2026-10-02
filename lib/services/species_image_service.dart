import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SpeciesImageSource {
  const SpeciesImageSource({required this.url, required this.attribution});

  final String url;
  final String attribution;
}

class SpeciesImageService {
  SpeciesImageService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, Future<SpeciesImageSource?>> _cache = {};

  Future<SpeciesImageSource?> findByScientificName(String scientificName) {
    final name = scientificName.trim();
    if (name.isEmpty) return Future.value(null);

    final key = name.toLowerCase();
    return _cache.putIfAbsent(key, () => _searchCommons(name));
  }

  Future<SpeciesImageSource?> _searchCommons(String scientificName) async {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'search',
      'gsrsearch': '"$scientificName" -label -tag -museum -card -sheet',
      'gsrnamespace': '6',
      'gsrlimit': '10',
      'prop': 'imageinfo',
      'iiprop': 'url|extmetadata',
      'iiurlwidth': '320',
      'format': 'json',
      'origin': '*',
    });

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        debugPrint(
          'Commons image lookup returned HTTP ${response.statusCode} '
          'for "$scientificName".',
        );
        return null;
      }

      final decoded = jsonDecode(response.body);
      final root = _asMap(decoded);
      final query = _asMap(root?['query']);
      final pages = _asMap(query?['pages']);
      if (pages == null) return null;

      final requiredTokens = _scientificNameTokens(scientificName);
      if (requiredTokens.isEmpty) return null;
      for (final pageValue in pages.values) {
        final page = _asMap(pageValue);
        final imageInfoList = page?['imageinfo'];
        if (imageInfoList is! List || imageInfoList.isEmpty) continue;
        final imageInfo = _asMap(imageInfoList.first);
        final metadata = _asMap(imageInfo?['extmetadata']);
        if (imageInfo == null || metadata == null) continue;

        final license = _plainText(
          _asMap(metadata['LicenseShortName'])?['value']?.toString(),
        );
        if (!_isReusableLicense(license)) continue;

        final title = page?['title']?.toString() ?? '';
        final objectName = _plainText(
          _asMap(metadata['ObjectName'])?['value']?.toString(),
        );
        final description = _plainText(
          _asMap(metadata['ImageDescription'])?['value']?.toString(),
        );
        final searchableText = '$title $objectName $description'.toLowerCase();
        if (!_isLikelySpecimenImage(searchableText)) continue;
        if (requiredTokens.any(
          (token) => !searchableText.contains(token.toLowerCase()),
        )) {
          continue;
        }

        final thumbnailUrl = imageInfo['thumburl']?.toString();
        if (!_isWikimediaUrl(thumbnailUrl)) continue;
        final author = _plainText(
          _asMap(metadata['Artist'])?['value']?.toString(),
        );
        final attribution = [
          if (author.isNotEmpty) author else 'Creator not listed',
          license,
          'Wikimedia Commons',
        ].join(' · ');
        return SpeciesImageSource(url: thumbnailUrl!, attribution: attribution);
      }
      return null;
    } on TimeoutException {
      debugPrint('Commons image lookup timed out for "$scientificName".');
      return null;
    } on http.ClientException catch (error) {
      debugPrint(
        'Commons image lookup failed for "$scientificName": ${error.message}',
      );
      return null;
    } on FormatException catch (error) {
      debugPrint(
        'Commons returned invalid image metadata for "$scientificName": '
        '${error.message}',
      );
      return null;
    }
  }

  static List<String> _scientificNameTokens(String name) => name
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where(
        (token) =>
            token.length > 1 &&
            !const {'cf', 'sp', 'spp', 'var', 'subsp'}.contains(token),
      )
      .take(2)
      .toList(growable: false);

  static bool _isLikelySpecimenImage(String text) => !RegExp(
    r'\b(label|labels|labelled|labelling|tag|tags|tagged|tagging|museum|museums|card|cards|sheet|sheets)\b',
    caseSensitive: false,
  ).hasMatch(text);

  static bool _isReusableLicense(String license) {
    final normalized = license.toLowerCase();
    if (normalized.isEmpty ||
        normalized.contains('non-commercial') ||
        normalized.contains('noncommercial') ||
        normalized.contains('all rights reserved') ||
        RegExp(r'\bcc\b[^,;]*\bnc\b').hasMatch(normalized) ||
        RegExp(r'\bcc\b[^,;]*\bnd\b').hasMatch(normalized)) {
      return false;
    }
    return normalized.contains('cc by') ||
        normalized.contains('cc0') ||
        normalized.contains('public domain') ||
        normalized.startsWith('pd');
  }

  static bool _isWikimediaUrl(String? value) {
    final uri = value == null ? null : Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        (uri.host == 'wikimedia.org' || uri.host.endsWith('.wikimedia.org'));
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static String _plainText(String? value) => (value ?? '')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

final speciesImageService = SpeciesImageService();
