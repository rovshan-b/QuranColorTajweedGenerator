import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tajweed/mushaf_preview_screen.dart';
import 'package:tajweed/tajweed_viewer.dart';

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

  // This widget is the root of your application.
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tajweed Mushaf Generator'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.menu_book,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                'Quran Mushaf with Tajweed',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Generate beautifully colored Quran pages with Tajweed rules',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MushafPreviewScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate Mushaf HTML'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TajweedExample(),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Tajweed Demo'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TajweedExample extends StatelessWidget {
  const TajweedExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tajweed Demo'),
      ),
      body: const TajweedViewer(),
    );
  }
}
