import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'mushaf_preview_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Tajweed Mushaf Generator',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });

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
