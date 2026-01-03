import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'quran_enc_translation_service.dart';

/// Service for reading translations from local SQLite databases.
class LocalTranslationService {
  /// Returns a list of available local translations from the bundled JSON manifest.
  Future<List<TranslationInfo>> getLocalTranslations() async {
    try {
      final jsonContent =
          await rootBundle.loadString('assets/translations/translations.json');
      final List<dynamic> translations = json.decode(jsonContent);

      return translations.map((item) {
        return TranslationInfo(
          key: 'local:${item['file']}',
          name: item['name'] as String,
          language: item['language_iso_code'] as String? ??
              item['language'] as String,
        );
      }).toList();
    } catch (e) {
      print('Error loading local translations manifest: $e');
      return [];
    }
  }

  /// Fetch all ayah translations for a given surah from a local database.
  Future<Map<int, String>> fetchSurahTranslations(
      String fileName, int surahNumber) async {
    final result = <int, String>{};
    Database? db;

    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final dbPath = p.join(appSupportDir.path, 'translations', fileName);

      if (!await File(dbPath).exists()) {
        return result;
      }

      db = await openDatabase(dbPath, readOnly: true);

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
    } catch (e) {
      print('Error reading local translation: $e');
    } finally {
      await db?.close();
    }

    return result;
  }
}
