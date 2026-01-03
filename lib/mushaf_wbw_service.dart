import 'package:flutter/services.dart';

/// Service to load and provide word-by-word translations from CSV.
class MushafWbwService {
  /// Map of sura:ayah:word -> translation
  final Map<String, String> _wbwCache = {};
  bool _isLoaded = false;

  /// Available languages in the CSV
  static const List<String> availableLanguages = [
    'bn',
    'in',
    'en',
    'fr',
    'zh',
    'ur',
    'ta',
    'tr',
    'dv',
    'en_trans',
    'de',
    'hi',
    'inh',
    'ml',
    'ru',
    'fa',
    'sd',
    'sq'
  ];

  /// Mapping of language codes to full names
  static const Map<String, String> languageNames = {
    'bn': 'Bengali',
    'in': 'Indonesian',
    'en': 'English',
    'fr': 'French',
    'zh': 'Chinese',
    'ur': 'Urdu',
    'ta': 'Tamil',
    'tr': 'Turkish',
    'dv': 'Divehi',
    'en_trans': 'English Transliteration',
    'de': 'German',
    'hi': 'Hindi',
    'inh': 'Ingush',
    'ml': 'Malayalam',
    'ru': 'Russian',
    'fa': 'Persian',
    'sd': 'Sindhi',
    'sq': 'Albanian',
  };

  /// Returns the full name for a language code, or the code itself if not found.
  static String getLanguageName(String code) {
    return languageNames[code] ?? code.toUpperCase();
  }

  /// Load the CSV and index it for the selected language.
  Future<void> load(String languageCode) async {
    if (_isLoaded) _wbwCache.clear();

    final csvData = await rootBundle.loadString('assets/words/words.csv');
    final lines = csvData.split('\n');

    if (lines.isEmpty) return;

    // Parse header to find language index
    final header = lines[0].split(',');
    final langIndex = header.indexOf(languageCode);
    if (langIndex == -1)
      throw Exception('Language $languageCode not found in CSV');

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // Simple CSV split (doesn't handle quoted commas, but our CSV seems simple)
      // Actually, looking at the CSV, some fields have quotes and commas.
      // Let's use a slightly better parser or a regex.
      final parts = _splitCsvLine(line);
      if (parts.length <= langIndex) continue;

      final sura = parts[0];
      final ayah = parts[1];
      final word = parts[2];
      final translation = parts[langIndex];

      // Handle '*' placeholder as empty string
      final cleanTranslation = translation == '*' ? '' : translation;

      _wbwCache['$sura:$ayah:$word'] = cleanTranslation;
    }

    _isLoaded = true;
  }

  /// Simple CSV line splitter that handles quoted fields
  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    StringBuffer current = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }

  /// Get translation for a specific word.
  String? getTranslation(int sura, int ayah, int word) {
    return _wbwCache['$sura:$ayah:$word'];
  }

  bool get isLoaded => _isLoaded;
}
