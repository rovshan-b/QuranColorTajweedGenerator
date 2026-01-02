import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Lightweight client for QuranEnc translation API.
class TranslationInfo {
  final String key;
  final String name;
  final String language;

  const TranslationInfo(
      {required this.key, required this.name, required this.language});

  factory TranslationInfo.fromMap(Map<String, dynamic> map) {
    final key = (map['key'] ?? '').toString();
    final display = (map['title'] ?? map['key'] ?? '').toString();
    final lang = (map['language_iso_code'] ?? '').toString();
    return TranslationInfo(key: key, name: display, language: lang);
  }
}

class QuranEncTranslationService {
  static const String _baseUrl = 'https://quranenc.com/api/v1';

  /// Fetch available translations. Returns empty list on failure.
  Future<List<TranslationInfo>> fetchTranslations() async {
    final uri = Uri.parse('$_baseUrl/translations/list');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return const [];
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final List<dynamic> result = json['translations'] ?? [];

    final translations = result
        .whereType<Map<String, dynamic>>()
        .map<TranslationInfo>((m) => TranslationInfo.fromMap(m))
        .toList();

    // Sort translations alphabetically by name
    translations
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return translations;
  }

  /// Fetch all ayah translations for a given surah.
  /// Returns a map of aya number -> translation text.
  Future<Map<int, String>> fetchSurahTranslations(
      String translationKey, int surahNumber) async {
    final result = <int, String>{};

    try {
      // 1. Try to load from local cache first
      final cacheFile = await _getCacheFile(translationKey, surahNumber);
      if (await cacheFile.exists()) {
        final cachedData = await cacheFile.readAsString();
        final json = jsonDecode(cachedData);
        if (json is List) {
          return _parseTranslationList(json);
        }
      }

      // 2. If not in cache, fetch from API
      final uri =
          Uri.parse('$_baseUrl/translation/sura/$translationKey/$surahNumber');
      final resp = await http.get(uri);
      if (resp.statusCode != 200) return result;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = json['result'];

      if (list is List) {
        // 3. Save raw result to cache before parsing
        await cacheFile.writeAsString(jsonEncode(list));
        return _parseTranslationList(list);
      }
    } catch (_) {
      // Return partial/empty map on failure.
    }
    return result;
  }

  /// Helper to parse the list of translation items into a map
  Map<int, String> _parseTranslationList(List<dynamic> list) {
    final result = <int, String>{};
    // Regex to match footnote references like [1], [22], etc.
    final footnoteRegex = RegExp(r'\[\d+\]');

    for (final item in list) {
      if (item is Map<String, dynamic>) {
        final aya = int.tryParse(item['aya']?.toString() ?? '');
        String text = (item['translation'] ?? '').toString();

        // Remove footnote references and clean up whitespace
        text = text.replaceAll(footnoteRegex, '').trim();

        if (aya != null) {
          result[aya] = text;
        }
      }
    }
    return result;
  }

  /// Helper to get the cache file path for a specific surah translation
  Future<File> _getCacheFile(String key, int surah) async {
    final supportDir = await getApplicationSupportDirectory();
    final cacheDir = Directory(p.join(supportDir.path, 'translation_cache'));

    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    return File(p.join(cacheDir.path, 'tr_${key}_s$surah.json'));
  }
}
