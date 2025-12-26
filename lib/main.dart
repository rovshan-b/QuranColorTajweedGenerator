import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tajweed/mushaf_preview_screen.dart';

void main() {
  // Initialize sqflite_ffi for desktop platforms
  sqfliteFfiInit();
  // Use databaseFactoryFfi for desktop SQLite support
  // The warning about changing default factory is expected for desktop apps
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tajweed Mushaf Generator',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const MushafPreviewScreen(),
    );
  }
}
