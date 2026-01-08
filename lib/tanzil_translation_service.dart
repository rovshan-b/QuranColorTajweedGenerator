import 'dart:io';

class TanzilTranslationService {
  /// Verifies that a Tanzil text file has exactly 6236 lines.
  Future<bool> verifyFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final lines = await file.readAsLines();
      // Tanzil files often have metadata or empty lines at end,
      // but we expect exactly 6236 ayas.
      int validAyas = 0;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        final parts = trimmed.split('|');
        if (parts.length >= 3) {
          validAyas++;
        }

        if (validAyas == 6236) break;
      }

      return validAyas == 6236;
    } catch (e) {
      return false;
    }
  }

  /// Parses the Tanzil file and extracts translations for a specific surah.
  /// Expects format: sura|aya|text
  Future<Map<int, String>> fetchSurahTranslations(
      String filePath, int surahNumber) async {
    final result = <int, String>{};
    try {
      final file = File(filePath);
      if (!await file.exists()) return result;

      final lines = await file.readAsLines();
      int count = 0;
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        final parts = trimmed.split('|');
        if (parts.length < 3) continue;

        final s = int.tryParse(parts[0]);
        final a = int.tryParse(parts[1]);
        final text = parts[2];

        if (s == surahNumber && a != null) {
          result[a] = text;
        }

        count++;
        if (count >= 6236) break;
      }
    } catch (e) {
      print('Error parsing Tanzil file: $e');
    }
    return result;
  }
}
