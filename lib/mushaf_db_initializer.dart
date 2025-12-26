import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Handles copying bundled database files from assets to app support directory.
class MushafDbInitializer {
  static const String _pagesDbAsset = 'resources/qpc-v4-tajweed-15-lines.db';
  static const String _wordsDbAsset = 'resources/uthmani.db';

  static String? _pagesDbPath;
  static String? _wordsDbPath;

  /// Returns true if databases are already initialized
  static bool get isInitialized => _pagesDbPath != null && _wordsDbPath != null;

  /// Path to the pages database (qpc-v4-tajweed-15-lines.db)
  static String get pagesDbPath {
    if (_pagesDbPath == null) {
      throw StateError(
          'Database not initialized. Call MushafDbInitializer.initialize() first.');
    }
    return _pagesDbPath!;
  }

  /// Path to the words database (uthmani.db)
  static String get wordsDbPath {
    if (_wordsDbPath == null) {
      throw StateError(
          'Database not initialized. Call MushafDbInitializer.initialize() first.');
    }
    return _wordsDbPath!;
  }

  /// Initializes the databases by copying them from assets to app support directory.
  /// This should be called once at app startup.
  static Future<void> initialize() async {
    if (isInitialized) return;

    final appSupportDir = await getApplicationSupportDirectory();
    final dbDir = Directory(path.join(appSupportDir.path, 'databases'));

    // Create databases directory if it doesn't exist
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // Copy pages database
    _pagesDbPath = await _copyAssetToFile(
      _pagesDbAsset,
      path.join(dbDir.path, 'qpc-v4-tajweed-15-lines.db'),
    );

    // Copy words database
    _wordsDbPath = await _copyAssetToFile(
      _wordsDbAsset,
      path.join(dbDir.path, 'uthmani.db'),
    );
  }

  /// Copies an asset file to the target path if it doesn't already exist.
  /// Returns the path to the copied file.
  static Future<String> _copyAssetToFile(
      String assetPath, String targetPath) async {
    final targetFile = File(targetPath);

    // Always copy to ensure we have the latest version
    // (In production, you might want to check version/hash)
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await targetFile.writeAsBytes(bytes, flush: true);

    return targetPath;
  }
}
