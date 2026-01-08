import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Service for reading translations from local SQLite databases.
class LocalTranslationService {
  /// Verifies that an external Tarteel (SQLite) file has exactly 6236 ayas in the 'translation' table.
  Future<bool> verifyFile(String filePath) async {
    Database? db;
    try {
      if (!await File(filePath).exists()) return false;
      db = await openDatabase(filePath, readOnly: true);
      final result = await db.rawQuery('SELECT COUNT(*) FROM translation');
      final count = result.isNotEmpty ? (result.first.values.first as int?) : 0;
      return count == 6236;
    } catch (e) {
      return false;
    } finally {
      await db?.close();
    }
  }

  /// Fetch translations from an external SQLite file at the given path.
  Future<Map<int, String>> fetchSurahTranslationsFromPath(
      String filePath, int surahNumber) async {
    final result = <int, String>{};
    Database? db;

    try {
      if (!await File(filePath).exists()) {
        throw Exception('Tarteel translation database not found at: $filePath');
      }

      db = await openDatabase(filePath, readOnly: true);

      final List<Map<String, dynamic>> maps = await db.query(
        'translation',
        columns: ['ayah', 'text'],
        where: 'sura = ?',
        whereArgs: [surahNumber],
      );

      for (final map in maps) {
        final ayah = map['ayah'] as int?;
        final text = map['text'] as String?;
        if (ayah != null && text != null) {
          result[ayah] = text;
        }
      }

      if (result.isEmpty) {
        throw Exception(
            'No translations found for Surah $surahNumber in $filePath. '
            'Please ensure the database contains a "translation" table with "sura", "ayah", and "text" columns.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error reading external local translation: $e');
    } finally {
      await db?.close();
    }

    return result;
  }
}
