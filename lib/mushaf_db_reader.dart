import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tajweed/mushaf_db_initializer.dart';

/// Represents a line in the Mushaf page layout
class MushafLine {
  final int pageNumber;
  final int lineNumber;
  final String lineType; // 'ayah', 'surah_name', or 'basmallah'
  final bool isCentered;
  final int? firstWordId;
  final int? lastWordId;
  final int? surahNumber;

  MushafLine({
    required this.pageNumber,
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    this.firstWordId,
    this.lastWordId,
    this.surahNumber,
  });

  factory MushafLine.fromMap(Map<String, dynamic> map) {
    return MushafLine(
      pageNumber: _parseInt(map['page_number'])!,
      lineNumber: _parseInt(map['line_number'])!,
      lineType: map['line_type'] as String,
      isCentered: _parseInt(map['is_centered']) == 1,
      firstWordId: _parseInt(map['first_word_id']),
      lastWordId: _parseInt(map['last_word_id']),
      surahNumber: _parseInt(map['surah_number']),
    );
  }

  /// Helper to parse int from dynamic (handles String or int)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// Represents a word from the Quran text database
class MushafWord {
  final int id;
  final String location;
  final int surah;
  final int ayah;
  final int word;
  final String text;

  MushafWord({
    required this.id,
    required this.location,
    required this.surah,
    required this.ayah,
    required this.word,
    required this.text,
  });

  factory MushafWord.fromMap(Map<String, dynamic> map) {
    return MushafWord(
      id: _parseInt(map['id'])!,
      location: map['location'] as String,
      surah: _parseInt(map['surah'])!,
      ayah: _parseInt(map['ayah'])!,
      word: _parseInt(map['word'])!,
      text: map['text'] as String,
    );
  }

  /// Helper to parse int from dynamic (handles String or int)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Returns true if this word is an aya number marker (Arabic numeral)
  bool get isAyaNumber {
    // Arabic-Indic digits: ٠١٢٣٤٥٦٧٨٩
    final arabicDigits = RegExp(r'^[٠-٩]+$');
    return arabicDigits.hasMatch(text.trim());
  }
}

/// Reads Mushaf layout and word data from SQLite databases
class MushafDbReader {
  Database? _pagesDb;
  Database? _wordsDb;

  /// Initialize database connections
  Future<void> open() async {
    if (_pagesDb != null && _wordsDb != null) return;

    // Initialize sqflite_ffi for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    _pagesDb = await openDatabase(MushafDbInitializer.pagesDbPath);
    _wordsDb = await openDatabase(MushafDbInitializer.wordsDbPath);
  }

  /// Close database connections
  Future<void> close() async {
    await _pagesDb?.close();
    await _wordsDb?.close();
    _pagesDb = null;
    _wordsDb = null;
  }

  /// Get all lines for a specific page
  Future<List<MushafLine>> getPageLines(int pageNumber) async {
    if (_pagesDb == null) {
      throw StateError('Database not opened. Call open() first.');
    }

    final results = await _pagesDb!.query(
      'pages',
      where: 'page_number = ?',
      whereArgs: [pageNumber],
      orderBy: 'line_number ASC',
    );

    return results.map((row) => MushafLine.fromMap(row)).toList();
  }

  /// Get words by ID range (inclusive)
  Future<List<MushafWord>> getWords(int firstId, int lastId) async {
    if (_wordsDb == null) {
      throw StateError('Database not opened. Call open() first.');
    }

    final results = await _wordsDb!.query(
      'words',
      where: 'id >= ? AND id <= ?',
      whereArgs: [firstId, lastId],
      orderBy: 'id ASC',
    );

    return results.map((row) => MushafWord.fromMap(row)).toList();
  }

  /// Get a single word by ID
  Future<MushafWord?> getWord(int id) async {
    if (_wordsDb == null) {
      throw StateError('Database not opened. Call open() first.');
    }

    final results = await _wordsDb!.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return MushafWord.fromMap(results.first);
  }

  /// Get the total number of pages in the Mushaf
  Future<int> getPageCount() async {
    if (_pagesDb == null) {
      throw StateError('Database not opened. Call open() first.');
    }

    final result = await _pagesDb!.rawQuery(
      'SELECT MAX(page_number) as max_page FROM pages',
    );

    return result.first['max_page'] as int? ?? 0;
  }
}
