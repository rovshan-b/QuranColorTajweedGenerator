import 'dart:convert';

import 'package:flutter/services.dart';
import 'mushaf_db_reader.dart';
import 'mushaf_word_mapper.dart';
import 'tajweed_color_mapper.dart';
import 'tajweed_rule.dart';
import 'quran_metadata.dart';
import 'mushaf_page_config.dart';
import 'quran_enc_translation_service.dart';
import 'mushaf_wbw_service.dart';
import 'local_translation_service.dart';
import 'tanzil_translation_service.dart';

/// Generates HTML output for Mushaf pages with Tajweed coloring
class MushafHtmlGenerator {
  final MushafDbReader _dbReader;
  final MushafWordMapper _wordMapper;
  final MushafWbwService _wbwService;
  final PageSize pageSize;
  final BookMargins margins;
  final bool includeTranslation;
  final String translationSource;
  final String? tarteelFilePath;
  final String? tanzilFilePath;
  final bool includeWbw;
  final String? wbwLanguage;
  final QuranEncTranslationService? translationService;
  final LocalTranslationService? localTranslationService;
  final TanzilTranslationService? tanzilTranslationService;
  final String? translationKey;
  final String? translationName;
  final String? translationLanguage;
  final String? wbwLanguageName;
  final int prefaceBlankPages;
  final bool startOnRightSide;
  final String coverBackgroundColor;
  final String baseTextColor;
  final Map<TajweedRule, String>? tajweedColors;
  final Map<TajweedRule, bool>? tajweedHighlighting;
  final bool justifyTranslation;
  final Map<int, String>? customSurahNames;
  final Map<String, String>? customLocalizedLabels;

  // Global labels
  final String coverTitle;
  final String coverSubtitle;
  final String tocTitle;
  final String blankPageText;
  final String translationLabel;
  final String wbwLabel;

  // Debug flag for translation stats - set to true to see char count and font size on each page
  static const bool _debugTranslationStats = false;

  // Cached base64 encoded fonts
  String? _kitabRegularBase64;
  String? _kitabBoldBase64;

  MushafHtmlGenerator(
    this._dbReader, {
    this.pageSize = PageSize.a4,
    BookMargins? margins,
    this.includeTranslation = false,
    this.translationSource = 'QuranEnc',
    this.tarteelFilePath,
    this.tanzilFilePath,
    this.includeWbw = false,
    this.wbwLanguage,
    this.translationService,
    this.localTranslationService,
    this.tanzilTranslationService,
    this.translationKey,
    this.translationName,
    this.translationLanguage,
    this.wbwLanguageName,
    this.prefaceBlankPages = 1,
    this.startOnRightSide = true,
    this.coverBackgroundColor = '#1a472a',
    this.baseTextColor = '#000000',
    this.tajweedColors,
    this.tajweedHighlighting,
    this.justifyTranslation = true,
    this.customSurahNames,
    this.customLocalizedLabels,
    this.coverTitle = 'ٱلْقُرْآنُ ٱلْكَرِيمُ',
    this.coverSubtitle = 'The Noble Quran',
    this.tocTitle = 'Table of Contents',
    this.blankPageText = 'This page is intentionally left blank',
    this.translationLabel = 'Translation',
    this.wbwLabel = 'Word by Word',
  })  : margins = margins ?? pageSize.margins,
        _wordMapper = MushafWordMapper(),
        _wbwService = MushafWbwService();

  /// Load and cache fonts as base64
  Future<void> _loadFonts() async {
    if (_kitabRegularBase64 != null) return;

    final regularData = await rootBundle.load('assets/fonts/Kitab-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Kitab-Bold.ttf');

    _kitabRegularBase64 = base64Encode(regularData.buffer.asUint8List());
    _kitabBoldBase64 = base64Encode(boldData.buffer.asUint8List());
  }

  /// Convert a `TajweedRule` to a kebab-case CSS key used for class names.
  String _tajweedRuleKey(TajweedRule r) {
    switch (r) {
      case TajweedRule.LAFZATULLAH:
        return 'lafzatullah';
      case TajweedRule.izhar:
        return 'izhar';
      case TajweedRule.ikhfaa:
        return 'ikhfaa';
      case TajweedRule.idghamWithGhunna:
        return 'idgham-ghunna';
      case TajweedRule.iqlab:
        return 'iqlab';
      case TajweedRule.qalqala:
        return 'qalqala';
      case TajweedRule.idghamWithoutGhunna:
        return 'idgham-no-ghunna';
      case TajweedRule.ghunna:
        return 'ghunna';
      case TajweedRule.prolonging:
        return 'prolonging';
      case TajweedRule.alefTafreeq:
        return 'alef-tafreeq';
      case TajweedRule.hamzatulWasli:
        return 'hamzatul-wasli';
      case TajweedRule.none:
        return 'default';
    }
  }

  /// Generates HTML for the specified page range
  Future<String> generateHtml({
    required int startPage,
    required int endPage,
    void Function(int currentPage, int totalPages)? onProgress,
  }) async {
    // Load fonts first
    await _loadFonts();

    // Load WBW if enabled
    if (includeWbw && wbwLanguage != null) {
      await _wbwService.load(wbwLanguage!);
    }

    final buffer = StringBuffer();

    // Write HTML header with styles
    buffer.writeln(_generateHtmlHeader());

    // Add cover page
    buffer.writeln(_generateCoverPage());

    // Add configured number of empty pages after cover
    // Physical page starts at 2 (1 is cover)
    for (int i = 0; i < prefaceBlankPages; i++) {
      buffer.writeln(_generateEmptyPage());
    }

    // Generate content for each page
    for (int pageNum = startPage; pageNum <= endPage; pageNum++) {
      onProgress?.call(pageNum - startPage + 1, endPage - startPage + 1);
      final pageHtml = await _generatePageHtml(pageNum);
      buffer.writeln(pageHtml);
    }

    // Generate Table of Contents at the end
    final int contentPagesCount = endPage - startPage + 1;
    // Continuation parity: TOC starts after contentPagesCount
    final tocResult = await _generateTableOfContents(
      startSequenceIndex: contentPagesCount + 1,
    );
    buffer.writeln(tocResult['html']);

    // Write HTML footer
    buffer.writeln(_generateHtmlFooter());

    return buffer.toString();
  }

  String _generateHtmlHeader() {
    final nobleQuran = coverSubtitle;

    double arabicScale = 1.0;
    if (includeTranslation) {
      arabicScale *= pageSize.translationArabicScale;
    }
    if (includeWbw) {
      arabicScale *= pageSize.wbwArabicScale;
    }

    final bodyFontSize = pageSize.fontSize * arabicScale;
    final bodyLineHeight =
        includeWbw ? pageSize.wbwArabicLineHeight : pageSize.lineHeight;
    final surahFontSize = pageSize.surahFontSize * arabicScale;
    final ayaNumberFontSize = pageSize.ayaNumberFontSize * arabicScale;
    final headerFontSize = pageSize.headerFontSize * arabicScale;

    // Build tajweed CSS classes from rule-color mapper
    final tajweedCss = TajweedRule.values.map((r) {
      final key = _tajweedRuleKey(r);
      final isHighlighted = tajweedHighlighting?[r] ?? true;
      final color = isHighlighted
          ? (tajweedColors?[r] ?? tajweedRuleToHex(r))
          : baseTextColor;
      return '.tajweed-$key { color: $color; }';
    }).join('\n    ');

    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$nobleQuran</title>
  <style>
    @font-face {
      font-family: 'Kitab';
      src: url('data:font/truetype;base64,$_kitabRegularBase64') format('truetype');
      font-weight: normal;
    }
    @font-face {
      font-family: 'Kitab';
      src: url('data:font/truetype;base64,$_kitabBoldBase64') format('truetype');
      font-weight: bold;
    }
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      -webkit-print-color-adjust: exact !important;
      print-color-adjust: exact !important;
      color-adjust: exact !important;
    }
    
    body {
      font-family: 'Kitab', 'Amiri', 'Traditional Arabic', serif;
      background-color: #FFFEF5;
      color: $baseTextColor;
      direction: rtl;
      text-rendering: optimizeLegibility;
      -webkit-font-smoothing: antialiased;
      font-feature-settings: "liga" 1, "calt" 1, "kern" 1, "rlig" 1;
    }
    
    .page {
      width: ${pageSize.widthMm}mm;
      min-height: ${pageSize.heightMm}mm;
      margin: 20px auto;
      padding-top: ${margins.topMm}mm;
      padding-bottom: ${margins.bottomMm}mm;
      background: #FFF;
      box-shadow: 0 0 10px rgba(0,0,0,0.1);
      page-break-after: always;
      display: flex;
      flex-direction: column;
    }
    
    /* RTL book: inner (gutter) margin is towards the spine.
       After the cover the physical page numbering is used.
       For RTL books the gutter should be on LEFT for odd physical pages (right-side pages)
       and on RIGHT for even physical pages (left-side pages).
    */
    .page-odd {
      /* odd physical page: gutter on LEFT */
      padding-right: ${margins.outerMm}mm;
      padding-left: ${margins.gutterMm}mm;
    }

    .page-even {
      /* even physical page: gutter on RIGHT */
      padding-right: ${margins.gutterMm}mm;
      padding-left: ${margins.outerMm}mm;
    }
    
    .page-content {
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    
    .lines-wrapper {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: center;
      padding: 8px 12px;
      margin: 0;
      position: relative;
      background: transparent;
      direction: rtl;
    }

    /* Table of Contents wrapper: top-aligned, separate from ayah lines-wrapper */
    .toc-wrapper {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      align-items: stretch;
      padding: 12px 18px;
      margin: 0;
      position: relative;
      background: transparent;
      direction: ltr;
    }
    
    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: ${headerFontSize.toStringAsFixed(2)}px;
      margin-bottom: ${(pageSize.paddingMm * 0.3).round()}mm;
      padding-bottom: ${(pageSize.paddingMm * 0.2).round()}mm;
      border-bottom: 1px solid #ccc;
      color: #555;
    }
    
    .page-header-surah {
      flex: 1;
      text-align: right;
    }
    
    .page-header-number {
      flex: 1;
      text-align: center;
      font-weight: bold;
    }
    
    .page-header-juz {
      flex: 1;
      text-align: left;
    }
    
    .line {
      font-size: ${bodyFontSize.toStringAsFixed(2)}px;
      line-height: ${bodyLineHeight.toStringAsFixed(2)};
      margin: 0;
      padding: 2px 0;
      white-space: nowrap;
    }
    
    .line-centered {
      text-align: center;
    }
    
    .line-justified {
      text-align: justify;
      text-align-last: justify;
      text-justify: inter-word;
      word-spacing: ${pageSize.wordSpacing}em;
      letter-spacing: -0.05em;
    }
    
    .surah-header {
      text-align: center;
      font-size: ${surahFontSize.toStringAsFixed(2)}px;
      font-weight: bold;
      padding: 8px 0;
      margin: 5px 0;
      background: linear-gradient(to right, #D4AF37, #F5E6B3, #D4AF37);
      border-radius: 8px;
      color: #333;
    }
    
    .basmallah {
      text-align: center;
      font-size: ${bodyFontSize.toStringAsFixed(2)}px;
      padding: 10px 0;
      color: $baseTextColor;
    }
    
    .aya-number {
      font-size: ${ayaNumberFontSize.toStringAsFixed(2)}px;
      color: $baseTextColor;
      padding: 0 2px;
    }
    
    .word-container {
      display: inline-flex;
      flex-direction: column;
      align-items: center;
      vertical-align: top;
      margin: 0 2px;
    }

    .word {
      display: inline;
      white-space: nowrap;
      letter-spacing: 0;
    }
    
    .word span {
      display: inline;
      letter-spacing: 0;
      font-feature-settings: "liga" 1, "calt" 1, "kern" 1;
      -webkit-font-feature-settings: "liga" 1, "calt" 1, "kern" 1;
    }

    .wbw-text {
      display: block;
      width: 100%;
      max-width: ${pageSize.wbwMaxWidthMm}mm;
      font-size: ${pageSize.wbwFontSize}px;
      font-family: sans-serif;
      line-height: ${pageSize.wbwTranslationLineHeight};
      margin-top: 2px;
      text-align: center;
      text-align-last: center;
      white-space: normal;
      word-spacing: normal;
      letter-spacing: normal;
      direction: ltr;
      margin-left: auto;
      margin-right: auto;
      align-self: center;
    }

    .wbw-even { color: #666; }
    .wbw-odd { color: #7d7542; }
    
    /* Tajweed color classes */
    $tajweedCss
    
    /* Legend styles */
    .legend {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: ${pageSize.legendGap}px;
      margin-top: auto;
      padding-top: ${pageSize.legendPadding}px;
      border-top: 1px solid #ddd;
      direction: ltr;
    }
    .legend-item {
      display: flex;
      align-items: center;
      gap: ${pageSize.legendItemGap}px;
      direction: ltr;
    }
    .legend-color {
      width: ${pageSize.legendColorSize}px;
      height: ${pageSize.legendColorSize}px;
      border-radius: 2px;
    }
    .legend-label {
      font-size: ${pageSize.legendFontSize}px;
      font-family: sans-serif;
      color: #333;
    }

    /* Flow layout for translation mode */
    .page-body {
      display: block;
      direction: ltr;
      margin: auto 0;
    }

    .pane-ar {
      width: ${(1 - pageSize.translationWidthFraction) * 100}%;
      direction: rtl;
      min-width: 0;
      margin-bottom: 10px;
    }
    
    .page-odd .pane-ar {
      float: left;
      margin-right: ${(pageSize.paddingMm * 0.35).toStringAsFixed(1)}mm;
    }
    
    .page-even .pane-ar {
      float: right;
      margin-left: ${(pageSize.paddingMm * 0.35).toStringAsFixed(1)}mm;
    }

    .pane-tr {
      padding: 0;
      margin: 0;
      min-width: 0;
    }

    .translation-wrapper {
      display: block;
      font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
      line-height: ${pageSize.translationLineHeight};
      ${justifyTranslation ? 'text-align: justify;' : ''}
      text-justify: inter-word;
    }

    .translation-line {
      font-size: inherit;
      line-height: inherit;
      color: #333;
      direction: ltr;
      ${justifyTranslation ? 'text-align: justify;' : ''}
      text-justify: inter-word;
      word-break: break-word;
      hyphens: auto;
      margin-bottom: 4px;
    }

    .translation-compact .translation-line {
      display: inline;
      margin-bottom: 0;
      margin-right: 4px;
    }
    
    .translation-compact .translation-line::after {
      content: " ";
    }

    .translation-ayah {
      display: inline-block;
      font-weight: 600;
      margin-right: 6px;
      color: #666;
    }

    .translation-surah-header {
      display: block;
      font-weight: 700;
      font-size: 1.15em;
      color: #2d5a3d;
      margin-top: 8px;
      margin-bottom: 6px;
      padding-bottom: 3px;
      text-align: center;
    }

    .translation-text {
      color: #222;
    }

    .translation-separator {
      border-top: 1px solid #d4d1c1;
      margin: 4px 0;
      display: block;
      overflow: hidden; /* Ensures separator stays outside the floated Arabic block */
    }
    
    /* Cover page styles */
    .cover {
      width: ${pageSize.widthMm}mm;
      height: ${pageSize.heightMm}mm;
      margin: 20px auto;
      background: $coverBackgroundColor;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      color: #d4af37;
      page-break-after: always;
      box-shadow: 0 0 20px rgba(0,0,0,0.3);
    }
    .cover-ornament {
      font-size: ${(pageSize.fontSize * 1.5).round()}px;
      margin-bottom: 20px;
      opacity: 0.8;
    }
    .cover-title {
      font-size: ${(pageSize.surahFontSize * 1.8).round()}px;
      font-weight: bold;
      margin-bottom: 10px;
      text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
    }
    .cover-subtitle {
      font-size: ${(pageSize.surahFontSize * 0.8).round()}px;
      margin-bottom: 40px;
      opacity: 0.9;
      direction: ltr;
    }
    .cover-basmallah {
      font-size: ${pageSize.surahFontSize}px;
      margin: 40px 0;
    }
    .cover-footer {
      font-size: ${(pageSize.fontSize * 0.5).round()}px;
      font-family: sans-serif;
      opacity: 0.7;
      margin-top: 60px;
      color: #c4a030;
    }
    
    @media print {
      .cover {
        margin: 0;
        box-shadow: none;
        page-break-after: always;
        counter-reset: page 0;
      }
      .page {
        margin: 0;
        box-shadow: none;
        page-break-after: always;
      }
      .page-header {
        font-size: ${(headerFontSize * 0.9).round()}px;
      }
      .line {
        font-size: ${(bodyFontSize * 0.99).round()}px;
        line-height: ${(bodyLineHeight * 1.00).toStringAsFixed(2)};
      }
      .surah-header {
        font-size: ${(surahFontSize * 0.85).round()}px;
        padding: 3px 0;
        margin: 1px 0;
      }
      .basmallah {
        font-size: ${(bodyFontSize * 0.99).round()}px;
        padding: 3px 0;
      }
      .aya-number {
        font-size: ${(ayaNumberFontSize * 0.99).round()}px;
      }
    }
  </style>
</head>
<body>
''';
  }

  String _generateHtmlFooter() {
    return '''
</body>
</html>
''';
  }

  String _generateCoverPage() {
    final lang = translationLanguage ?? 'en';
    final tajweedCoding = _getLabel('tajweed_coding', lang);

    final translationInfo = (includeTranslation && translationName != null)
        ? '<div class="cover-footer">$translationLabel: $translationName</div>'
        : '';
    final wbwInfo = (includeWbw && wbwLanguageName != null)
        ? '<div class="cover-footer">$wbwLabel: $wbwLanguageName</div>'
        : '';

    return '''
<div class="cover">
  <div class="cover-ornament">❁ ❁ ❁</div>
  <div class="cover-title">${coverTitle}</div>
  <div class="cover-subtitle">${coverSubtitle}</div>
  <div class="cover-basmallah">بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ</div>
  <div class="cover-ornament">❁ ❁ ❁</div>
  <div class="cover-footer">$tajweedCoding</div>
  $translationInfo
  $wbwInfo
</div>
''';
  }

  String _generateEmptyPage() {
    return '''
<div class="page">
  <div class="page-content" style="display: flex; justify-content: center; align-items: center; height: 100%;">
    <div style="text-align: center; color: #bbb; font-family: sans-serif; font-size: 14px;">
      <p dir="rtl" style="margin-bottom: 8px;">هذه الصفحة تركت فارغة عمداً</p>
      <p dir="ltr">$blankPageText</p>
    </div>
  </div>
</div>''';
  }

  Future<String> _generatePageHtml(int pageNumber) async {
    final buffer = StringBuffer();
    final lines = await _dbReader.getPageLines(pageNumber);

    if (lines.isEmpty) {
      throw Exception(
          'Critical Error: No layout lines found for page $pageNumber in the layout database.');
    }

    // Find the first surah/ayah on this page for header info
    int? firstSurah;
    int? firstAyah;
    for (final line in lines) {
      if (line.lineType == 'surah_name' && line.surahNumber != null) {
        firstSurah = line.surahNumber;
        firstAyah = 1; // Surah header means we're at ayah 1
        break;
      } else if (line.lineType == 'ayah' && line.firstWordId != null) {
        // Get the first word to determine surah/ayah
        final firstWord = await _dbReader.getWord(line.firstWordId!);
        if (firstWord != null) {
          firstSurah = firstWord.surah;
          firstAyah = firstWord.ayah;
          break;
        } else {
          throw Exception(
              'Critical Error: Could not find first word (ID: ${line.firstWordId}) for page $pageNumber header.');
        }
      }
    }

    // Default to surah 1, ayah 1 if we couldn't determine
    firstSurah ??= 1;
    firstAyah ??= 1;

    // Get surah name and juz for header
    if (firstSurah <= 0 || firstSurah > surahNames.length) {
      throw Exception(
          'Invalid Surah Number for page $pageNumber: $firstSurah (header generation)');
    }
    final surahName = 'سُورَةُ ${surahNames[firstSurah - 1]}';

    final juzNumber = getJuzForPosition(firstSurah, firstAyah);
    final juzName = juzNumber > 0 && juzNumber <= juzNames.length
        ? juzNames[juzNumber - 1]
        : '';

    // Determine odd/even class for RTL book margins
    // Parity depends ONLY on Mushaf pageNumber and startOnRightSide toggle.
    // This ensures Mushaf Page 1 is always on the preferred side regardless of preface.
    final bool isRight = (pageNumber.isOdd == startOnRightSide);
    final pageClass = isRight ? 'page-odd' : 'page-even';

    // Buffers for Arabic content and translation tracking
    final arabicBuffer = StringBuffer();
    bool inLinesWrapper = false;
    final Map<int, Set<int>> ayahsBySurah = {};
    final Set<String> ayahSeen = {};
    final List<MapEntry<int, int>> ayahOrder = [];

    for (final line in lines) {
      switch (line.lineType) {
        case 'surah_name':
          if (inLinesWrapper) {
            arabicBuffer.writeln('</div>');
            inLinesWrapper = false;
          }
          arabicBuffer.writeln(_generateSurahHeader(line.surahNumber ?? 1));
          break;
        case 'basmallah':
          if (!inLinesWrapper) {
            arabicBuffer.writeln('<div class="lines-wrapper">');
            inLinesWrapper = true;
          }
          arabicBuffer.writeln(_generateBasmallah());
          break;
        case 'ayah':
          if (!inLinesWrapper) {
            arabicBuffer.writeln('<div class="lines-wrapper">');
            inLinesWrapper = true;
          }
          final words =
              await _dbReader.getWords(line.firstWordId!, line.lastWordId!);
          final lineHtml = await _generateAyahLine(line, preloadedWords: words);
          arabicBuffer.writeln(lineHtml);

          // Collect ayahs present on this page for translation
          for (final w in words) {
            if (w.isAyaNumber) continue;
            final key = '${w.surah}:${w.ayah}';
            if (ayahSeen.add(key)) {
              ayahOrder.add(MapEntry(w.surah, w.ayah));
              ayahsBySurah.putIfAbsent(w.surah, () => <int>{}).add(w.ayah);
            }
          }
          break;
      }
    }

    if (inLinesWrapper) {
      arabicBuffer.writeln('</div>');
    }

    buffer.writeln('<div id="page-${pageNumber}" class="page $pageClass">');
    buffer.writeln('<div class="page-content">');
    buffer.writeln('<div class="page-header">');
    buffer.writeln('<span class="page-header-surah">$surahName</span>');
    buffer.writeln('<span class="page-header-number">$pageNumber</span>');
    buffer.writeln('<span class="page-header-juz">$juzName</span>');
    buffer.writeln('</div>');

    if (includeTranslation &&
        translationService != null &&
        translationKey != null) {
      final translationHtml =
          await _buildTranslationColumn(ayahOrder, ayahsBySurah);
      buffer.writeln('<div class="page-body">');
      buffer.writeln('<div class="pane-ar">');
      buffer.writeln(arabicBuffer.toString());
      buffer.writeln('</div>');
      buffer.writeln('<div class="pane-tr">');
      buffer.writeln(translationHtml);
      buffer.writeln('</div>');
      buffer.writeln('</div>');
    } else {
      buffer.writeln(arabicBuffer.toString());
    }

    buffer.writeln('</div>'); // close page-content
    buffer.writeln(_generateLegend(translationLanguage ?? 'en'));
    buffer.writeln('</div>'); // close page
    return buffer.toString();
  }

  String _generateLegend(String lang) {
    // Define legend entries with their corresponding TajweedRule and display label key
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

    final buffer = StringBuffer();
    buffer.writeln('<div class="legend">');

    for (final entry in legendEntries) {
      final rule = entry['rule'] as TajweedRule;
      final key = entry['key'] as String;
      final label = _getLabel(key, lang);
      final isHighlighted = tajweedHighlighting?[rule] ?? true;
      final color = isHighlighted
          ? (tajweedColors?[rule] ?? tajweedRuleToHex(rule))
          : baseTextColor;

      buffer.writeln('  <div class="legend-item">');
      buffer.writeln(
          '    <div class="legend-color" style="background: $color;"></div>');
      buffer.writeln('    <span class="legend-label">$label</span>');
      buffer.writeln('  </div>');
    }

    buffer.writeln('</div>');
    return buffer.toString();
  }

  Future<String> _buildTranslationColumn(
    List<MapEntry<int, int>> ayahOrder,
    Map<int, Set<int>> ayahsBySurah,
  ) async {
    final buffer = StringBuffer();
    if (!includeTranslation) {
      buffer.writeln('<div class="translation-wrapper"></div>');
      return buffer.toString();
    }

    // Fetch translations per surah.
    final Map<String, String> translationLookup = {};
    for (final entry in ayahsBySurah.entries) {
      final surah = entry.key;
      final ayahs = entry.value;

      Map<int, String> surahTranslations = {};

      if (translationSource == 'QuranEnc' &&
          translationKey != null &&
          translationService != null) {
        surahTranslations = await translationService!
            .fetchSurahTranslations(translationKey!, surah);
      } else if (translationSource == 'Tarteel' &&
          tarteelFilePath != null &&
          localTranslationService != null) {
        surahTranslations = await localTranslationService!
            .fetchSurahTranslationsFromPath(tarteelFilePath!, surah);
      } else if (translationSource == 'Tanzil' &&
          tanzilFilePath != null &&
          tanzilTranslationService != null) {
        surahTranslations = await tanzilTranslationService!
            .fetchSurahTranslations(tanzilFilePath!, surah);
      }

      for (final ayah in ayahs) {
        final key = '$surah:$ayah';
        final text = surahTranslations[ayah];
        if (text != null) {
          translationLookup[key] = text;
        }
      }
    }

    // Calculate total length to adjust font size dynamically
    int totalLength = 0;
    for (final text in translationLookup.values) {
      totalLength += text.length;
    }

    final double fontSize =
        pageSize.getAdjustedTranslationFontSize(totalLength);

    // Use compact mode (inline verses) if text is long to save vertical space
    final bool useCompactMode =
        totalLength > pageSize.translationCompactThreshold;
    final String wrapperClass = useCompactMode
        ? 'translation-wrapper translation-compact'
        : 'translation-wrapper';

    buffer.writeln(
        '<div class="$wrapperClass" style="font-size: ${fontSize.toStringAsFixed(1)}px;">');

    if (_debugTranslationStats) {
      buffer.writeln(
          '<div style="font-size: 10px; color: red; margin-bottom: 5px; font-family: sans-serif; direction: ltr; text-align: left;">'
          'DEBUG: Chars: $totalLength, Font: ${fontSize.toStringAsFixed(1)}px, Compact: $useCompactMode'
          '</div>');
    }

    int? lastSurah;
    for (final pair in ayahOrder) {
      final surah = pair.key;
      final ayah = pair.value;

      // Insert Surah header ONLY if it's the first ayah of the surah
      if (ayah == 1) {
        if (lastSurah != null && lastSurah != surah) {
          buffer.writeln('<div class="translation-separator"></div>');
        }

        // Add translated Surah name header
        final languageCode = translationLanguage ?? 'en';
        final translatedName = _getSurahName(surah, languageCode);
        buffer.writeln(
            '<div class="translation-surah-header">$translatedName</div>');
      }
      lastSurah = surah;

      final key = '${pair.key}:${pair.value}';
      final entry = translationLookup[key];
      if (entry == null) {
        throw Exception('Missing translation for Surah $surah Ayah $ayah. '
            'Generation stopped to prevent incomplete output.');
      }
      var text = entry;

      // Remove leading ayah numbers if they exist (e.g., "1. ", "1 ")
      text = text.replaceFirst(RegExp(r'^\d+[\.\s]+'), '').trimLeft();

      buffer.writeln('<div class="translation-line">');
      buffer.writeln('<span class="translation-ayah">${pair.value}. </span>');
      buffer.writeln(
          '<span class="translation-text">${_escapeHtml(text)}</span>');
      buffer.writeln('</div>');
    }
    buffer.writeln('</div>');

    return buffer.toString();
  }

  /// Scans the pages DB for `surah_name` lines and builds a paginated
  /// Table of Contents placed after the cover page.
  /// Returns a map with keys: 'html' (String) and 'pages' (int pages used).
  Future<Map<String, dynamic>> _generateTableOfContents(
      {int startSequenceIndex = 1}) async {
    // Map surahNumber -> first page where its header appears
    final Map<int, int> surahPageMap = {};

    final totalPages = await _dbReader.getPageCount();
    for (int p = 1; p <= totalPages; p++) {
      final lines = await _dbReader.getPageLines(p);
      for (final line in lines) {
        if (line.lineType == 'surah_name' && line.surahNumber != null) {
          final s = line.surahNumber!;
          if (!surahPageMap.containsKey(s)) {
            surahPageMap[s] = p;
          }
        }
      }
    }

    // Build ordered list for 1..114
    final entries = <Map<String, dynamic>>[];
    final lang = translationLanguage ?? 'en';

    for (int s = 1; s <= surahNames.length; s++) {
      final translatedName = _getSurahName(s, lang);
      entries.add({
        'surah': s,
        'name': translatedName,
        'page': surahPageMap[s] ?? '-',
      });
    }

    int entriesPerPage = pageSize.tocEntriesPerPage;

    final pages = <String>[];

    for (int i = 0; i < entries.length; i += entriesPerPage) {
      final chunk =
          entries.sublist(i, (i + entriesPerPage).clamp(0, entries.length));

      final buffer = StringBuffer();
      // Determine parity based on physical page number and global config
      final int currentPageIndex = i ~/ entriesPerPage;
      final int sequenceIndex = startSequenceIndex + currentPageIndex;
      final bool isRight = (sequenceIndex.isOdd == startOnRightSide);
      final pageClass = isRight ? 'page-odd' : 'page-even';

      buffer.writeln('<div class="page $pageClass">');
      buffer.writeln('<div class="page-content">');
      buffer.writeln('<div class="page-header">');
      buffer.writeln('<span class="page-header-surah"></span>');
      buffer.writeln('<span class="page-header-number">فهرس السور</span>');
      buffer.writeln('<span class="page-header-juz"></span>');
      buffer.writeln('</div>');

      buffer.writeln('<div class="toc-wrapper">');
      buffer.writeln(
          '<div style="padding:12px; font-family: sans-serif; width: 100%;">');
      buffer.writeln(
          '<h3 style="text-align:center; margin-bottom: 20px;">فهرس السور — $tocTitle</h3>');
      buffer.writeln('<div style="margin-top:14px; width: 100%;">');

      for (final e in chunk) {
        final surahNum = e['surah'];
        final name = e['name'];
        final page = e['page'];
        if (page is int) {
          buffer.writeln(
              '<div style="display:flex; justify-content:space-between; padding:6px 0; font-size:${pageSize.tocFontSize}px; border-bottom: 1px dotted #eee;">'
              '<a href="#page-${page}" style="text-decoration:none; color:inherit; flex: 1; text-align:left;">${surahNum}. ${name}</a>'
              '<a href="#page-${page}" style="text-decoration:none; color:inherit; width: 60px; text-align:right;">${page}</a>'
              '</div>');
        } else {
          buffer.writeln(
              '<div style="display:flex; justify-content:space-between; padding:6px 0; font-size:${pageSize.tocFontSize}px; border-bottom: 1px dotted #eee;">'
              '<span style="flex: 1; text-align:left;">${surahNum}. ${name}</span>'
              '<span style="width: 60px; text-align:right;">${page}</span>'
              '</div>');
        }
      }

      buffer.writeln('</div>');
      buffer.writeln('</div>');
      buffer.writeln('</div>'); // close lines-wrapper
      buffer.writeln('</div>'); // close page-content
      buffer.writeln('</div>'); // close page

      pages.add(buffer.toString());
    }

    final html = pages.join('\n');
    return {'html': html, 'pages': pages.length};
  }

  String _generateSurahHeader(int surahNumber) {
    if (surahNumber <= 0 || surahNumber > surahNames.length) {
      throw Exception(
          'Invalid Surah Number in header: $surahNumber. Must be between 1 and ${surahNames.length}.');
    }
    final surahName = surahNames[surahNumber - 1];

    return '''
<div class="surah-header">
  سُورَةُ $surahName
</div>
''';
  }

  String _generateBasmallah() {
    return '''
<div class="basmallah">
  بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ
</div>
''';
  }

  Future<String> _generateAyahLine(MushafLine line,
      {List<MushafWord>? preloadedWords}) async {
    if (line.firstWordId == null || line.lastWordId == null) {
      throw Exception(
          'Ayah line on page ${line.pageNumber} line ${line.lineNumber} has no word IDs!');
    }

    final words = preloadedWords ??
        await _dbReader.getWords(line.firstWordId!, line.lastWordId!);
    if (words.isEmpty) {
      throw Exception(
          'No words found for page ${line.pageNumber} line ${line.lineNumber} (word IDs ${line.firstWordId}-${line.lastWordId})');
    }

    final expectedCount = line.lastWordId! - line.firstWordId! + 1;
    if (words.length != expectedCount) {
      throw Exception(
          'Data Integrity Error: Page ${line.pageNumber} line ${line.lineNumber} expects words ${line.firstWordId}-${line.lastWordId} ($expectedCount words), but found ${words.length} in database.');
    }

    final buffer = StringBuffer();

    final alignmentClass = line.isCentered ? 'line-centered' : 'line-justified';
    buffer.write('<div class="line $alignmentClass">');

    int wordCounter = 0;
    for (final word in words) {
      if (word.isAyaNumber) {
        // Render aya number with special ornament styling
        buffer.write(_generateAyaNumber(word.text));
      } else {
        // Map word to tajweed tokens and render
        final tajweedWord = _wordMapper.mapWordToTokens(word);
        if (tajweedWord != null) {
          buffer.write(
              _generateColoredWord(tajweedWord, word, wordCounter % 2 == 0));
          wordCounter++;
        } else {
          // Fallback: render plain text - LOG THIS as it indicates a mapping problem
          //_plainTextFallbackCount++;
          //_plainTextFallbackWords
          //    .add('${word.surah}:${word.ayah}:${word.word} "${word.text}"');
          throw Exception(
              'PLAIN TEXT FALLBACK: ${word.surah}:${word.ayah}:${word.word} "${word.text}"');
          //buffer.write('<span class="word">${word.text}</span> ');
        }
      }
    }

    buffer.write('</div>');
    return buffer.toString();
  }

  String _generateAyaNumber(String arabicNumber) {
    final content = '<span class="aya-number">\u06DD$arabicNumber</span>';

    if (includeWbw) {
      return '<div class="word-container">$content<span class="wbw-text">&nbsp;</span></div> ';
    }

    return '$content ';
  }

  String _generateColoredWord(tajweedWord, MushafWord word, bool isEven) {
    final buffer = StringBuffer();

    if (includeWbw) {
      buffer.write('<div class="word-container">');
    }

    buffer.write('<span class="word">');

    final tokens = tajweedWord.tokens;
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      // Use class-based tajweed coloring
      final ruleKey = _tajweedRuleKey(token.rule);
      final className = 'tajweed-$ruleKey';
      // Escape any HTML special characters in the text
      final escapedText = _escapeHtml(token.text);

      buffer.write('<span class="$className">$escapedText</span>');
    }

    buffer.write('</span>');

    if (includeWbw) {
      final translation =
          _wbwService.getTranslation(word.surah, word.ayah, word.word);

      final colorClass = isEven ? 'wbw-even' : 'wbw-odd';
      if (translation != null && translation.isNotEmpty) {
        buffer.write(
            '<span class="wbw-text $colorClass">${_escapeHtml(translation)}</span>');
      } else {
        // Empty span to maintain layout if needed, or just skip
        buffer.write('<span class="wbw-text $colorClass">&nbsp;</span>');
      }
      buffer.write('</div>');
    }

    buffer.write(' ');
    return buffer.toString();
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _getSurahName(int surahNumber, String lang) {
    if (customSurahNames != null &&
        customSurahNames!.containsKey(surahNumber)) {
      return customSurahNames![surahNumber]!;
    }
    return getTranslatedSurahName(surahNumber, lang);
  }

  String _getLabel(String key, String lang) {
    if (customLocalizedLabels != null &&
        customLocalizedLabels!.containsKey(key)) {
      return customLocalizedLabels![key]!;
    }
    return getLocalizedText(key, lang);
  }
}
