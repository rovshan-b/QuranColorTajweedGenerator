// Generates the Tanzil app's tajweed mushaf pages (PNG + glyphs.db) headless.
// Not part of the normal run: APP_PAGES_OUT must be set.
//
// The settings reproduce the app's set exactly (all 77,432 glyph boxes of
// with_tajweed.zip): A5 widened to 148 x 225 mm, 200 dpi, font 29, surah
// font 18, line height 1.0, 3 mm side margins, no header or legend.
//
//   APP_PAGES_OUT=<light> flutter test test/tools/app_pages_test.dart
//   APP_PAGES_OUT=<dark> APP_PAGES_DARK=1 flutter test test/tools/app_pages_test.dart
//   (APP_PAGES_FROM / APP_PAGES_TO for a range; APP_PAGES_FONT,
//   APP_PAGES_SURAH_FONT, APP_PAGES_MARGIN_MM to experiment)
//
// The dark run gives the same glyphs.db as the light one. Then, for the zip
// the app downloads (unpacked into the mushaf's folder):
//   images/pageNNN.webp        <- light pageNNN.png
//   images/page_dark_NNN.webp  <- dark pageNNN.png
//   databases/glyphs.db
// each page by `cwebp -q 90 -m 6` (how-to-convert-pngs-to-webp.txt). A new
// set goes to a new zip name and a new folder in the app (with_tajweed_v2.zip):
// older app versions keep downloading theirs.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_generator/mushaf_db_initializer.dart';
import 'package:mushaf_generator/mushaf_db_reader.dart';
import 'package:mushaf_generator/mushaf_image_generator.dart';
import 'package:mushaf_generator/mushaf_page_config.dart';
import 'package:mushaf_generator/tajweed_color_mapper.dart';

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
      tajweedColors: dark ? defaultDarkTajweedColors : defaultTajweedColors,
    );
    await generator.generateImages(
      startPage: int.parse(env['APP_PAGES_FROM'] ?? '1'),
      endPage: int.parse(env['APP_PAGES_TO'] ?? '604'),
      outputDir: out!,
    );
  }, skip: out == null ? 'set APP_PAGES_OUT' : false, timeout: Timeout.none);
}
