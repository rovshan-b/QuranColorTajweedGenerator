import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'mushaf_db_reader.dart';
import 'mushaf_word_mapper.dart';
import 'tajweed_color_mapper.dart';
import 'tajweed_rule.dart';
import 'mushaf_page_config.dart';
import 'mushaf_wbw_service.dart';
import 'quran_metadata.dart';

class MushafImageGenerator {
  final MushafDbReader _dbReader;
  final MushafWordMapper _wordMapper;
  final MushafWbwService _wbwService;
  final PageSize pageSize;
  final int dpi;
  final double scale;
  final bool includeWbw;
  final String? wbwLanguage;
  final bool showDecorations;
  final String baseTextColor;
  late final ui.Color _baseColor;

  MushafImageGenerator(
    this._dbReader, {
    this.pageSize = PageSize.a4,
    this.dpi = 300,
    this.includeWbw = false,
    this.wbwLanguage,
    this.showDecorations = true,
    this.baseTextColor = '#000000',
  })  : _wordMapper = MushafWordMapper(),
        _wbwService = MushafWbwService(),
        scale = dpi / 96.0 {
    _baseColor = ui.Color(int.parse(baseTextColor.replaceFirst('#', '0xFF')));
  }

  Future<void> generateImages({
    required int startPage,
    required int endPage,
    required String outputDir,
    void Function(int currentPage, int totalPages)? onProgress,
  }) async {
    // 1. Ensure output directory exists
    final dir = Directory(outputDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // 1.5 Load WBW if enabled
    if (includeWbw && wbwLanguage != null) {
      await _wbwService.load(wbwLanguage!);
    }

    // 2. Initialize Glyphs Database
    final dbPath = p.join(outputDir, 'glyphs.db');
    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE glyphs(
            glyph_id int not null,
            page_number int not null,
            line_number int not null,
            sura_number int not null,
            ayah_number int not null,
            position int not null,
            min_x int not null,
            max_x int not null,
            min_y int not null,
            max_y int not null,
            primary key(glyph_id)
          )
        ''');
      },
    );

    // 3. Load Fonts if necessary (though in Flutter main isolate they should be loaded)
    // For off-screen rendering, we just use the family name.

    final totalPages = endPage - startPage + 1;
    final pixelWidth = (pageSize.widthMm / 25.4 * dpi).round();
    final pixelHeight = (pageSize.heightMm / 25.4 * dpi).round();

    for (int pageNum = startPage; pageNum <= endPage; pageNum++) {
      onProgress?.call(pageNum - startPage + 1, totalPages);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(
          recorder,
          ui.Rect.fromLTWH(
              0, 0, pixelWidth.toDouble(), pixelHeight.toDouble()));

      // Draw the page content
      await _drawPage(canvas, pageNum, pixelWidth, pixelHeight, db);

      final picture = recorder.endRecording();
      final img = await picture.toImage(pixelWidth, pixelHeight);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final fileName = 'page${pageNum.toString().padLeft(3, '0')}.png';
        final filePath = p.join(outputDir, fileName);
        await File(filePath).writeAsBytes(byteData.buffer.asUint8List());
      }
    }

    await db.close();
  }

  Future<void> _drawPage(ui.Canvas canvas, int pageNum, int pxWidth,
      int pxHeight, Database db) async {
    final lines = await _dbReader.getPageLines(pageNum);
    final margins = pageSize.margins;

    // Convert margins to physical pixels
    final topPx = (margins.topMm / 25.4 * dpi);
    final outerPx = (margins.outerMm / 25.4 * dpi);
    final gutterPx = (margins.gutterMm / 25.4 * dpi);

    // RTL Parity Logic:
    // Odd (Right Page): Gutter on Right, Outer on Left.
    // Even (Left Page): Gutter on Left, Outer on Right.
    // We assume Page 1 is Odd/Right.
    final isOdd = pageNum.isOdd;

    final leftPadding = isOdd ? outerPx : gutterPx;
    final rightPadding = isOdd ? gutterPx : outerPx;
    final drawWidth = pxWidth - leftPadding - rightPadding;

    // We start drawing from top margin
    double headerHeight =
        showDecorations ? (pageSize.headerFontSize * scale) + (10 * scale) : 0;

    // 1. Calculate Total Content Height for Vertical Centering
    double totalContentHeight = await _calculateContentHeight(
        lines, drawWidth, includeWbw ? pageSize.wbwArabicScale : 1.0);

    // 2. Determine Available Height and Offset
    // Available space between header bottom and page bottom margin
    final bottomPx = (margins.bottomMm / 25.4 * dpi);
    final legendHeight = showDecorations
        ? (pageSize.legendColorSize * scale) + (pageSize.legendPadding * scale)
        : 0;
    double availableHeight =
        pxHeight - topPx - headerHeight - bottomPx - legendHeight;
    double verticalOffset = 0;
    if (availableHeight > totalContentHeight) {
      verticalOffset = (availableHeight - totalContentHeight) / 2;
    } else if (totalContentHeight > availableHeight) {
      // Content overflow warning
      print('WARNING: Page $pageNum content overflow! '
          'Content height: ${totalContentHeight.toStringAsFixed(1)}px, '
          'Available height: ${availableHeight.toStringAsFixed(1)}px. '
          'Consider reducing font size or adjusting page dimensions.');
    }

    // 3. Draw Page Header (if enabled)
    if (showDecorations) {
      await _drawPageHeader(canvas, pageNum, pxWidth.toDouble(), topPx,
          leftPadding, rightPadding, drawWidth);
    }

    // 4. Draw Content starting at offset position
    double currentY = topPx + headerHeight + verticalOffset;
    int shrunkAyasCount = 0;

    for (final line in lines) {
      if (line.lineType == 'surah_name') {
        currentY = await _drawSurahHeader(
            canvas, line, pxWidth, currentY, leftPadding, drawWidth);
      } else if (line.lineType == 'basmallah') {
        currentY = await _drawBasmallah(
            canvas, line, pxWidth, currentY, leftPadding, drawWidth);
      } else if (line.lineType == 'ayah') {
        final result = await _drawAyahLine(canvas, line, pageNum, pxWidth,
            currentY, leftPadding, drawWidth, db, shrunkAyasCount);
        currentY = result.nextY;
        if (result.wasShrunk) shrunkAyasCount++;
      }
    }

    // 5. Draw Tajweed Legend (if enabled)
    if (showDecorations) {
      await _drawLegend(
          canvas, pxWidth, pxHeight, leftPadding, rightPadding, drawWidth);
    }
  }

  Future<double> _calculateContentHeight(
      List<MushafLine> lines, double drawWidth, double arabicScale) async {
    double totalHeight = 0;
    final fontSize = pageSize.fontSize * scale * arabicScale;
    final surahFontSize = pageSize.surahFontSize * scale;

    // Cache painter heights to avoid layout calls
    double? arabicPainterHeight;
    double? basmallahPainterHeight;

    for (final line in lines) {
      if (line.lineType == 'surah_name') {
        totalHeight += (surahFontSize * 2.3) + (10 * scale);
      } else if (line.lineType == 'basmallah') {
        if (basmallahPainterHeight == null) {
          final tp = TextPainter(
            text: TextSpan(
              text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
              style: TextStyle(
                  fontFamily: 'Kitab', fontSize: pageSize.fontSize * scale),
            ),
            textDirection: TextDirection.rtl,
          );
          tp.layout();
          basmallahPainterHeight = tp.height;
        }
        totalHeight += basmallahPainterHeight + (10 * scale);
      } else if (line.lineType == 'ayah') {
        if (arabicPainterHeight == null) {
          final tp = TextPainter(
            text: TextSpan(
              text: 'الحمد',
              style: TextStyle(fontFamily: 'Kitab', fontSize: fontSize),
            ),
            textDirection: TextDirection.rtl,
          );
          tp.layout();
          arabicPainterHeight = tp.height;
        }

        final multiplier =
            includeWbw ? pageSize.wbwArabicLineHeight : pageSize.lineHeight;
        totalHeight += (arabicPainterHeight * multiplier);
      }
    }
    return totalHeight;
  }

  Future<void> _drawPageHeader(
      ui.Canvas canvas,
      int pageNum,
      double pxWidth,
      double y,
      double leftPadding,
      double rightPadding,
      double drawWidth) async {
    final lines = await _dbReader.getPageLines(pageNum);

    // Find first surah/ayah for header
    int? firstSurah;
    int? firstAyah;
    for (final line in lines) {
      if (line.lineType == 'surah_name' && line.surahNumber != null) {
        firstSurah = line.surahNumber;
        firstAyah = 1;
        break;
      } else if (line.lineType == 'ayah' && line.firstWordId != null) {
        final firstWord = await _dbReader.getWord(line.firstWordId!);
        if (firstWord != null) {
          firstSurah = firstWord.surah;
          firstAyah = firstWord.ayah;
          break;
        }
      }
    }

    firstSurah ??= 1;
    firstAyah ??= 1;

    final headerFontSize = pageSize.headerFontSize * scale;
    final style = TextStyle(
      fontFamily: 'Kitab',
      fontSize: headerFontSize,
      color: _baseColor,
    );

    // 1. Draw Page Number (Center)
    final pageNumText = pageNum.toString();
    final centerPainter = TextPainter(
      text: TextSpan(
          text: pageNumText,
          style: style.copyWith(fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    centerPainter.layout();
    centerPainter.paint(
        canvas, ui.Offset((pxWidth - centerPainter.width) / 2, y));

    // 2. Draw Surah Name (Right Side)
    final name = (firstSurah > 0 && firstSurah <= 114)
        ? surahNames[firstSurah - 1]
        : 'سورة';
    final surahName = 'سُورَةُ $name';
    final rightPainter = TextPainter(
      text: TextSpan(text: surahName, style: style),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
    rightPainter.layout();
    rightPainter.paint(
        canvas, ui.Offset(pxWidth - rightPadding - rightPainter.width, y));

    // 3. Draw Juz Name (Left Side)
    final juzNum = getJuzForPosition(firstSurah, firstAyah);
    final juzName =
        (juzNum > 0 && juzNum <= juzNames.length) ? juzNames[juzNum - 1] : '';
    final leftPainter = TextPainter(
      text: TextSpan(text: juzName, style: style),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.left,
    );
    leftPainter.layout();
    leftPainter.paint(canvas, ui.Offset(leftPadding, y));

    // Draw thin line under header
    final linePaint = ui.Paint()
      ..color = _baseColor.withOpacity(0.2)
      ..strokeWidth = 1 * scale;
    canvas.drawLine(
      ui.Offset(leftPadding, y + centerPainter.height + 5 * scale),
      ui.Offset(pxWidth - rightPadding, y + centerPainter.height + 5 * scale),
      linePaint,
    );
  }

  Future<double> _drawSurahHeader(ui.Canvas canvas, MushafLine line,
      int pxWidth, double y, double leftPadding, double drawWidth) async {
    final surahNum = line.surahNumber ?? 1;
    final surahFontSize = pageSize.surahFontSize * scale;

    // Draw background (simplified gradient box)
    final rect =
        ui.Rect.fromLTWH(leftPadding, y, drawWidth, surahFontSize * 2.3);
    final paint = ui.Paint()
      ..shader = ui.Gradient.linear(
        rect.centerLeft,
        rect.centerRight,
        [
          const Color(0xFFD4AF37),
          const Color(0xFFF5E6B3),
          const Color(0xFFD4AF37)
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(
        ui.RRect.fromRectAndRadius(rect, const ui.Radius.circular(8)), paint);

    // Draw text
    final name =
        (surahNum > 0 && surahNum <= 114) ? surahNames[surahNum - 1] : 'سورة';
    final text = 'سُورَةُ $name';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Kitab',
          fontSize: surahFontSize,
          color: const Color(0xFF333333),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: drawWidth, maxWidth: drawWidth);
    textPainter.paint(canvas,
        ui.Offset(leftPadding, y + (rect.height - textPainter.height) / 2));

    return y + rect.height + (10 * scale);
  }

  Future<double> _drawBasmallah(ui.Canvas canvas, MushafLine line, int pxWidth,
      double y, double leftPadding, double drawWidth) async {
    final fontSize = pageSize.fontSize * scale;
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        style: TextStyle(
          fontFamily: 'Kitab',
          fontSize: fontSize,
          color: _baseColor,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
    textPainter.layout(minWidth: drawWidth, maxWidth: drawWidth);
    textPainter.paint(canvas, ui.Offset(leftPadding, y));

    return y + textPainter.height + (10 * scale);
  }

  Future<_AyahLineResult> _drawAyahLine(
      ui.Canvas canvas,
      MushafLine line,
      int pageNum,
      int pxWidth,
      double y,
      double leftPadding,
      double drawWidth,
      Database db,
      int shrunkAyasCount) async {
    final words = await _dbReader.getWords(line.firstWordId!, line.lastWordId!);
    final arabicScale = includeWbw ? pageSize.wbwArabicScale : 1.0;
    double currentFontSize = pageSize.fontSize * scale * arabicScale;
    bool wasShrunk = false;

    // 1. Prepare elements for manual layout
    List<_AyahLineElement> elements = [];
    double totalElementsWidth = 0;

    void measure() {
      elements = [];
      totalElementsWidth = 0;
      int currentPositionInLine = 1;

      for (final word in words) {
        TextPainter painter;
        bool trackInDb = false;

        if (word.isAyaNumber) {
          painter = TextPainter(
            text: TextSpan(
              text: '\u06DD${word.text}', // No trailing space here
              style: TextStyle(
                fontFamily: 'Kitab',
                fontSize: currentFontSize,
                color: _baseColor,
              ),
            ),
            textDirection: TextDirection.rtl,
          );
        } else {
          final tajweedWord = _wordMapper.mapWordToTokens(word);
          if (tajweedWord == null) continue;

          final spans = <TextSpan>[];
          for (final token in tajweedWord.tokens) {
            final color = token.rule == TajweedRule.none
                ? _baseColor
                : Color(int.parse(
                    tajweedRuleToHex(token.rule).replaceFirst('#', '0xFF')));
            spans.add(TextSpan(
              text: token.text,
              style: TextStyle(
                fontFamily: 'Kitab',
                fontSize: currentFontSize,
                color: color,
              ),
            ));
          }

          painter = TextPainter(
            text: TextSpan(children: spans),
            textDirection: TextDirection.rtl,
          );
          trackInDb = true;
        }

        painter.layout();
        elements.add(_AyahLineElement(
          painter: painter,
          word: trackInDb ? word : null,
          position: trackInDb ? currentPositionInLine++ : 0,
        ));
        totalElementsWidth += painter.width;
      }
    }

    // Initial measurement
    measure();

    // 2. Check for overlap and attempt shrinking if permitted
    if (totalElementsWidth > drawWidth && !line.isCentered) {
      if (shrunkAyasCount < 5) {
        final double originalWidth = totalElementsWidth;
        while (totalElementsWidth > drawWidth && currentFontSize > 5) {
          currentFontSize -= 0.2;
          measure();
        }
        wasShrunk = true;
        print(
            'INFO: Page $pageNum Line ${line.lineNumber} shrunk: ${originalWidth.toStringAsFixed(1)}px -> ${totalElementsWidth.toStringAsFixed(1)}px (Font: ${currentFontSize.toStringAsFixed(1)})');
      } else {
        print('WARNING: Page $pageNum Line ${line.lineNumber} word overlap! '
            'Total word width: ${totalElementsWidth.toStringAsFixed(1)}px exceeds line width: ${drawWidth.toStringAsFixed(1)}px. '
            'Skipping shrink process (limit of 5 exceeded).');
      }
    }

    if (elements.isEmpty) return _AyahLineResult(nextY: y, wasShrunk: false);

    // 3. Calculate Spacing
    double gap = 0;
    double currentX = 0;

    if (line.isCentered) {
      gap = currentFontSize * 0.25; // Standard space for centered lines
      final totalWidth = totalElementsWidth + (gap * (elements.length - 1));

      if (totalWidth > drawWidth) {
        print(
            'WARNING: Page $pageNum Line ${line.lineNumber} centered overflow! '
            'Width: ${totalWidth.toStringAsFixed(1)}px, Available: ${drawWidth.toStringAsFixed(1)}px');
      }

      // RTL: Start at leftPadding + (drawWidth - totalWidth) / 2
      // But we render from Right to Left!
      // Start X coord for the FIRST word (which is the rightmost in RTL)
      currentX = leftPadding + drawWidth - (drawWidth - totalWidth) / 2;
    } else {
      // Justified
      if (elements.length > 1) {
        gap = (drawWidth - totalElementsWidth) / (elements.length - 1);
      }
      currentX = leftPadding + drawWidth; // Start at the right edge

      if (gap < -0.01 && !wasShrunk) {
        print('WARNING: Page $pageNum Line ${line.lineNumber} word overlap! '
            'Total word width: ${totalElementsWidth.toStringAsFixed(1)}px exceeds line width: ${drawWidth.toStringAsFixed(1)}px');
      }
    }

    // 4. Render and Record
    final batch = db.batch();
    double maxHeight = 0;

    for (final element in elements) {
      final p = element.painter;
      // In RTL, we move left from currentX
      final renderX = currentX - p.width;
      p.paint(canvas, ui.Offset(renderX, y));

      if (p.height > maxHeight) maxHeight = p.height;

      // Extract coordinates for DB
      if (element.word != null) {
        final w = element.word!;
        final minX = renderX;
        final maxX = renderX + p.width;
        final minY = y;
        final maxY = y + p.height;

        batch.insert('glyphs', {
          'glyph_id': w.id,
          'page_number': pageNum,
          'line_number': line.lineNumber,
          'sura_number': w.surah,
          'ayah_number': w.ayah,
          'position': element.position,
          'min_x': minX.round(),
          'max_x': maxX.round(),
          'min_y': minY.round(),
          'max_y': maxY.round(),
        });

        if (includeWbw) {
          _drawWbwUnderWord(canvas, w, minX, maxX, maxY);
        }
      }

      // Move currentX to the left for the next word
      currentX -= (p.width + gap);
    }

    await batch.commit(noResult: true);

    double nextY = includeWbw
        ? y + maxHeight * pageSize.wbwArabicLineHeight
        : y + maxHeight * pageSize.lineHeight;

    return _AyahLineResult(nextY: nextY, wasShrunk: wasShrunk);
  }

  double _drawWbwUnderWord(ui.Canvas canvas, MushafWord word, double minX,
      double maxX, double arabicBottomY) {
    final translation =
        _wbwService.getTranslation(word.surah, word.ayah, word.word);
    if (translation == null || translation.isEmpty) return 0;

    final wbwFontSize = pageSize.wbwFontSize * scale;
    final wbwPainter = TextPainter(
      text: TextSpan(
        text: translation,
        style: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: wbwFontSize,
          color: _baseColor,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    double wordWidth = maxX - minX;
    double maxWidth = pageSize.wbwMaxWidthMm / 25.4 * dpi;

    wbwPainter.layout(maxWidth: maxWidth);

    // Center translation under the Arabic word
    double tx = minX + (wordWidth - wbwPainter.width) / 2;
    double ty = arabicBottomY + (1 * scale); // 1px gap

    wbwPainter.paint(canvas, ui.Offset(tx, ty));
    return wbwPainter.height + (1 * scale);
  }

  Future<void> _drawLegend(ui.Canvas canvas, int pxWidth, int pxHeight,
      double leftPadding, double rightPadding, double drawWidth) async {
    final lang = wbwLanguage ?? 'en';
    final legendEntries = [
      {'rule': TajweedRule.LAFZATULLAH, 'key': 'rule_lafzatullah'},
      {'rule': TajweedRule.izhar, 'key': 'rule_izhar'},
      {'rule': TajweedRule.ikhfaa, 'key': 'rule_ikhfaa'},
      {'rule': TajweedRule.idghamWithGhunna, 'key': 'rule_idgham_ghunna'},
      {'rule': TajweedRule.idghamWithoutGhunna, 'key': 'rule_idgham'},
      {'rule': TajweedRule.iqlab, 'key': 'rule_iqlab'},
      {'rule': TajweedRule.qalqala, 'key': 'rule_qalqala'},
      {'rule': TajweedRule.ghunna, 'key': 'rule_ghunna'},
      {'rule': TajweedRule.prolonging, 'key': 'rule_madd'},
    ];

    final legendFontSize = pageSize.legendFontSize * scale;
    final legendColorSize = pageSize.legendColorSize * scale;
    final legendGap = pageSize.legendGap * scale;
    final legendItemGap = pageSize.legendItemGap * scale;
    final legendPadding = pageSize.legendPadding * scale;
    final bottomMarginPx = (pageSize.margins.bottomMm / 25.4 * dpi);

    // Calculate vertical position (at the very bottom, above margin)
    final double legendHeight = legendColorSize + legendPadding;
    final double legendY = pxHeight - bottomMarginPx - legendHeight;

    // Draw thin line above legend
    final linePaint = ui.Paint()
      ..color = _baseColor.withOpacity(0.2)
      ..strokeWidth = 1 * scale;
    canvas.drawLine(
      ui.Offset(leftPadding, legendY),
      ui.Offset(pxWidth - rightPadding, legendY),
      linePaint,
    );

    final double itemsY = legendY + legendPadding;

    // Measure all items to center the whole row
    final itemPainters = <TextPainter>[];
    double totalRowWidth = 0;

    for (final entry in legendEntries) {
      final key = entry['key'] as String;
      final label = getLocalizedText(key, lang);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: legendFontSize,
            color: _baseColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      itemPainters.add(tp);
      totalRowWidth += legendColorSize + legendItemGap + tp.width + legendGap;
    }
    totalRowWidth -= legendGap; // remove last gap

    double currentX = leftPadding + (drawWidth - totalRowWidth) / 2;

    for (int i = 0; i < legendEntries.length; i++) {
      final entry = legendEntries[i];
      final rule = entry['rule'] as TajweedRule;
      final tp = itemPainters[i];

      // Draw color box
      final colorHex = tajweedRuleToHex(rule);
      final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      final boxRect =
          ui.Rect.fromLTWH(currentX, itemsY, legendColorSize, legendColorSize);
      canvas.drawRect(boxRect, ui.Paint()..color = color);

      currentX += legendColorSize + legendItemGap;

      // Draw text label
      tp.paint(canvas,
          ui.Offset(currentX, itemsY + (legendColorSize - tp.height) / 2));

      currentX += tp.width + legendGap;
    }
  }
}

/// Helper class for manual word-by-word layout in PNG generation
class _AyahLineElement {
  final TextPainter painter;
  final MushafWord? word;
  final int position;

  _AyahLineElement({
    required this.painter,
    this.word,
    required this.position,
  });
}

/// Helper to track results of ayah line rendering
class _AyahLineResult {
  final double nextY;
  final bool wasShrunk;

  _AyahLineResult({required this.nextY, required this.wasShrunk});
}
