// Generates the app's tajweed mushaf pages (PNG + glyphs.db) headless.
// Not part of the normal run: APP_PAGES_OUT must be set.
//   APP_PAGES_OUT=<dir> APP_PAGES_FROM=1 APP_PAGES_TO=604 APP_PAGES_FONT=24 \
//   APP_PAGES_DARK=0 flutter test test/tools/app_pages_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_generator/mushaf_db_initializer.dart';
import 'package:mushaf_generator/mushaf_db_reader.dart';
import 'package:mushaf_generator/mushaf_image_generator.dart';
import 'package:mushaf_generator/mushaf_page_config.dart';
import 'package:mushaf_generator/tajweed_rule.dart';

void main() {
  final env = Platform.environment;
  final out = env['APP_PAGES_OUT'];

  test('app mushaf pages', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final support = Directory.systemTemp.createTempSync('app_pages');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => support.path,
    );
    const fonts = {
      'Kitab': [
        'assets/fonts/Kitab-Regular.ttf',
        'assets/fonts/Kitab-Bold.ttf'
      ],
      'Amiri': ['assets/fonts/AmiriQuran.ttf'],
      'Basmala': ['assets/fonts/ArabicSymbols.otf'],
    };
    for (final family in fonts.keys) {
      final loader = FontLoader(family);
      for (final f in fonts[family]!) {
        loader.addFont(rootBundle.load(f));
      }
      await loader.load();
    }
    await MushafDbInitializer.initialize();
    final reader = MushafDbReader();
    await reader.open();

    final dark = env['APP_PAGES_DARK'] == '1';
    final marginMm = double.parse(env['APP_PAGES_MARGIN_MM'] ?? '3');
    final size = PageSize.a5.copyWith(
      name: 'App',
      heightMm: 225,
      fontSize: int.parse(env['APP_PAGES_FONT'] ?? '29'),
      surahFontSize: int.parse(env['APP_PAGES_SURAH_FONT'] ?? '18'),
      lineHeight: 1.0,
      margins: BookMargins(
        gutterMm: marginMm,
        outerMm: marginMm,
        topMm: 3,
        bottomMm: 3,
      ),
    );
    final generator = MushafImageGenerator(
      reader,
      pageSize: size,
      dpi: 200,
      showDecorations: false,
      baseTextColor: dark ? '#FFFFFF' : '#000000',
      // The app's own tajweed colours for the page's brightness.
      tajweedColors: {
        for (final rule in TajweedRule.values)
          if (rule != TajweedRule.none)
            rule:
                _hex(rule.colorFor(dark ? Brightness.dark : Brightness.light)!),
      },
    );
    await generator.generateImages(
      startPage: int.parse(env['APP_PAGES_FROM'] ?? '1'),
      endPage: int.parse(env['APP_PAGES_TO'] ?? '604'),
      outputDir: out!,
    );
  }, skip: out == null ? 'set APP_PAGES_OUT' : false, timeout: Timeout.none);
}

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
