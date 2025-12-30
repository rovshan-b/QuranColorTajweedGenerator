import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tajweed/mushaf_db_reader.dart';
import 'package:tajweed/mushaf_word_mapper.dart';
import 'package:tajweed/tajweed_color_mapper.dart';
import 'package:tajweed/tajweed_rule.dart';

/// Book margins configuration for printing
/// For RTL books (Arabic): gutter is on RIGHT for odd pages, LEFT for even pages
class BookMargins {
  /// Inner margin (near spine/binding) in mm
  final double gutterMm;

  /// Outer margin (away from spine) in mm
  final double outerMm;

  /// Top margin in mm
  final double topMm;

  /// Bottom margin in mm
  final double bottomMm;

  const BookMargins({
    this.gutterMm = 20.0,
    this.outerMm = 12.0,
    this.topMm = 15.0,
    this.bottomMm = 15.0,
  });

  /// Default margins for book printing
  static const BookMargins defaultMargins = BookMargins();
}

/// Surah names in Arabic for headers
const List<String> surahNames = [
  'ٱلْفَاتِحَة', // 1
  'ٱلْبَقَرَة', // 2
  'آلِ عِمْرَان', // 3
  'ٱلنِّسَاء', // 4
  'ٱلْمَائِدَة', // 5
  'ٱلْأَنْعَام', // 6
  'ٱلْأَعْرَاف', // 7
  'ٱلْأَنفَال', // 8
  'ٱلتَّوْبَة', // 9
  'يُونُس', // 10
  'هُود', // 11
  'يُوسُف', // 12
  'ٱلرَّعْد', // 13
  'إِبْرَاهِيم', // 14
  'ٱلْحِجْر', // 15
  'ٱلنَّحْل', // 16
  'ٱلْإِسْرَاء', // 17
  'ٱلْكَهْف', // 18
  'مَرْيَم', // 19
  'طه', // 20
  'ٱلْأَنبِيَاء', // 21
  'ٱلْحَجّ', // 22
  'ٱلْمُؤْمِنُون', // 23
  'ٱلنُّور', // 24
  'ٱلْفُرْقَان', // 25
  'ٱلشُّعَرَاء', // 26
  'ٱلنَّمْل', // 27
  'ٱلْقَصَص', // 28
  'ٱلْعَنكَبُوت', // 29
  'ٱلرُّوم', // 30
  'لُقْمَان', // 31
  'ٱلسَّجْدَة', // 32
  'ٱلْأَحْزَاب', // 33
  'سَبَأ', // 34
  'فَاطِر', // 35
  'يس', // 36
  'ٱلصَّافَّات', // 37
  'ص', // 38
  'ٱلزُّمَر', // 39
  'غَافِر', // 40
  'فُصِّلَتْ', // 41
  'ٱلشُّورَىٰ', // 42
  'ٱلزُّخْرُف', // 43
  'ٱلدُّخَان', // 44
  'ٱلْجَاثِيَة', // 45
  'ٱلْأَحْقَاف', // 46
  'مُحَمَّد', // 47
  'ٱلْفَتْح', // 48
  'ٱلْحُجُرَات', // 49
  'ق', // 50
  'ٱلذَّارِيَات', // 51
  'ٱلطُّور', // 52
  'ٱلنَّجْم', // 53
  'ٱلْقَمَر', // 54
  'ٱلرَّحْمَٰن', // 55
  'ٱلْوَاقِعَة', // 56
  'ٱلْحَدِيد', // 57
  'ٱلْمُجَادِلَة', // 58
  'ٱلْحَشْر', // 59
  'ٱلْمُمْتَحَنَة', // 60
  'ٱلصَّفّ', // 61
  'ٱلْجُمُعَة', // 62
  'ٱلْمُنَافِقُون', // 63
  'ٱلتَّغَابُن', // 64
  'ٱلطَّلَاق', // 65
  'ٱلتَّحْرِيم', // 66
  'ٱلْمُلْك', // 67
  'ٱلْقَلَم', // 68
  'ٱلْحَاقَّة', // 69
  'ٱلْمَعَارِج', // 70
  'نُوح', // 71
  'ٱلْجِنّ', // 72
  'ٱلْمُزَّمِّل', // 73
  'ٱلْمُدَّثِّر', // 74
  'ٱلْقِيَامَة', // 75
  'ٱلْإِنسَان', // 76
  'ٱلْمُرْسَلَات', // 77
  'ٱلنَّبَأ', // 78
  'ٱلنَّازِعَات', // 79
  'عَبَسَ', // 80
  'ٱلتَّكْوِير', // 81
  'ٱلْإِنفِطَار', // 82
  'ٱلْمُطَفِّفِين', // 83
  'ٱلْإِنشِقَاق', // 84
  'ٱلْبُرُوج', // 85
  'ٱلطَّارِق', // 86
  'ٱلْأَعْلَىٰ', // 87
  'ٱلْغَاشِيَة', // 88
  'ٱلْفَجْر', // 89
  'ٱلْبَلَد', // 90
  'ٱلشَّمْس', // 91
  'ٱللَّيْل', // 92
  'ٱلضُّحَىٰ', // 93
  'ٱلشَّرْح', // 94
  'ٱلتِّين', // 95
  'ٱلْعَلَق', // 96
  'ٱلْقَدْر', // 97
  'ٱلْبَيِّنَة', // 98
  'ٱلزَّلْزَلَة', // 99
  'ٱلْعَادِيَات', // 100
  'ٱلْقَارِعَة', // 101
  'ٱلتَّكَاثُر', // 102
  'ٱلْعَصْر', // 103
  'ٱلْهُمَزَة', // 104
  'ٱلْفِيل', // 105
  'قُرَيْش', // 106
  'ٱلْمَاعُون', // 107
  'ٱلْكَوْثَر', // 108
  'ٱلْكَافِرُون', // 109
  'ٱلنَّصْر', // 110
  'ٱلْمَسَد', // 111
  'ٱلْإِخْلَاص', // 112
  'ٱلْفَلَق', // 113
  'ٱلنَّاس', // 114
];

/// Juz names in Arabic
const List<String> juzNames = [
  'ٱلْجُزْءُ ٱلْأَوَّلُ', // 1
  'ٱلْجُزْءُ ٱلثَّانِي', // 2
  'ٱلْجُزْءُ ٱلثَّالِثُ', // 3
  'ٱلْجُزْءُ ٱلرَّابِعُ', // 4
  'ٱلْجُزْءُ ٱلْخَامِسُ', // 5
  'ٱلْجُزْءُ ٱلسَّادِسُ', // 6
  'ٱلْجُزْءُ ٱلسَّابِعُ', // 7
  'ٱلْجُزْءُ ٱلثَّامِنُ', // 8
  'ٱلْجُزْءُ ٱلتَّاسِعُ', // 9
  'ٱلْجُزْءُ ٱلْعَاشِرُ', // 10
  'ٱلْجُزْءُ ٱلْحَادِي عَشَرَ', // 11
  'ٱلْجُزْءُ ٱلثَّانِي عَشَرَ', // 12
  'ٱلْجُزْءُ ٱلثَّالِثَ عَشَرَ', // 13
  'ٱلْجُزْءُ ٱلرَّابِعَ عَشَرَ', // 14
  'ٱلْجُزْءُ ٱلْخَامِسَ عَشَرَ', // 15
  'ٱلْجُزْءُ ٱلسَّادِسَ عَشَرَ', // 16
  'ٱلْجُزْءُ ٱلسَّابِعَ عَشَرَ', // 17
  'ٱلْجُزْءُ ٱلثَّامِنَ عَشَرَ', // 18
  'ٱلْجُزْءُ ٱلتَّاسِعَ عَشَرَ', // 19
  'ٱلْجُزْءُ ٱلْعِشْرُونَ', // 20
  'ٱلْجُزْءُ ٱلْحَادِي وَٱلْعِشْرُونَ', // 21
  'ٱلْجُزْءُ ٱلثَّانِي وَٱلْعِشْرُونَ', // 22
  'ٱلْجُزْءُ ٱلثَّالِثُ وَٱلْعِشْرُونَ', // 23
  'ٱلْجُزْءُ ٱلرَّابِعُ وَٱلْعِشْرُونَ', // 24
  'ٱلْجُزْءُ ٱلْخَامِسُ وَٱلْعِشْرُونَ', // 25
  'ٱلْجُزْءُ ٱلسَّادِسُ وَٱلْعِشْرُونَ', // 26
  'ٱلْجُزْءُ ٱلسَّابِعُ وَٱلْعِشْرُونَ', // 27
  'ٱلْجُزْءُ ٱلثَّامِنُ وَٱلْعِشْرُونَ', // 28
  'ٱلْجُزْءُ ٱلتَّاسِعُ وَٱلْعِشْرُونَ', // 29
  'ٱلْجُزْءُ ٱلثَّلَاثُونَ', // 30
];

/// Juz start positions defined by surah and ayah
/// Each entry is [surah, ayah] where the Juz begins
const List<List<int>> juzStartPositions = [
  [1, 1], // Juz 1
  [2, 142], // Juz 2
  [2, 253], // Juz 3
  [3, 93], // Juz 4
  [4, 24], // Juz 5
  [4, 148], // Juz 6
  [5, 82], // Juz 7
  [6, 111], // Juz 8
  [7, 88], // Juz 9
  [8, 41], // Juz 10
  [9, 93], // Juz 11
  [11, 6], // Juz 12
  [12, 53], // Juz 13
  [15, 1], // Juz 14
  [17, 1], // Juz 15
  [18, 75], // Juz 16
  [21, 1], // Juz 17
  [23, 1], // Juz 18
  [25, 21], // Juz 19
  [27, 56], // Juz 20
  [29, 46], // Juz 21
  [33, 31], // Juz 22
  [36, 28], // Juz 23
  [39, 32], // Juz 24
  [41, 47], // Juz 25
  [46, 1], // Juz 26
  [51, 31], // Juz 27
  [58, 1], // Juz 28
  [67, 1], // Juz 29
  [78, 1], // Juz 30
];

/// Get Juz number (1-30) for a given surah and ayah
int getJuzForPosition(int surah, int ayah) {
  for (int i = juzStartPositions.length - 1; i >= 0; i--) {
    final juzSurah = juzStartPositions[i][0];
    final juzAyah = juzStartPositions[i][1];
    // Check if current position is at or after this Juz start
    if (surah > juzSurah || (surah == juzSurah && ayah >= juzAyah)) {
      return i + 1;
    }
  }
  return 1;
}

/// Page size configuration for HTML/PDF output
enum PageSize {
  a3(
    name: 'A3',
    widthMm: 297,
    heightMm: 420,
    fontSize: 48,
    lineHeight: 2.0,
    paddingMm: 22,
    surahFontSize: 46,
    ayaNumberFontSize: 34,
    legendFontSize: 12,
    legendColorSize: 14,
    legendGap: 16,
    legendItemGap: 6,
    legendPadding: 16,
    headerFontSize: 24,
    margins: BookMargins(
      gutterMm: 26.0,
      outerMm: 26.0,
      topMm: 18.0,
      bottomMm: 18.0,
    ),
  ),
  a4(
    name: 'A4',
    widthMm: 210,
    heightMm: 297,
    fontSize: 32,
    lineHeight: 2.0,
    paddingMm: 15,
    surahFontSize: 36,
    ayaNumberFontSize: 28,
    legendFontSize: 10,
    legendColorSize: 12,
    legendGap: 12,
    legendItemGap: 4,
    legendPadding: 12,
    headerFontSize: 20,
    margins: BookMargins(
      gutterMm: 26.0,
      outerMm: 26.0,
      topMm: 15.0,
      bottomMm: 15.0,
    ),
  ),
  a5(
    name: 'A5',
    widthMm: 148,
    heightMm: 210,
    fontSize: 18,
    lineHeight: 1.95,
    paddingMm: 12,
    surahFontSize: 26,
    ayaNumberFontSize: 20,
    legendFontSize: 6,
    legendColorSize: 8,
    legendGap: 5,
    legendItemGap: 2,
    legendPadding: 6,
    headerFontSize: 14,
    margins: BookMargins(
      gutterMm: 26.0,
      outerMm: 26.0,
      topMm: 12.0,
      bottomMm: 12.0,
    ),
  );

  const PageSize({
    required this.name,
    required this.widthMm,
    required this.heightMm,
    required this.fontSize,
    required this.lineHeight,
    required this.paddingMm,
    required this.surahFontSize,
    required this.ayaNumberFontSize,
    required this.legendFontSize,
    required this.legendColorSize,
    required this.legendGap,
    required this.legendItemGap,
    required this.legendPadding,
    required this.headerFontSize,
    required this.margins,
  });

  final String name;
  final int widthMm;
  final int heightMm;
  final int fontSize;
  final double lineHeight;
  final int paddingMm;
  final int surahFontSize;
  final int ayaNumberFontSize;
  final int legendFontSize;
  final int legendColorSize;
  final int legendGap;
  final int legendItemGap;
  final int legendPadding;
  final int headerFontSize;
  final BookMargins margins;
}

/// Generates HTML output for Mushaf pages with Tajweed coloring
class MushafHtmlGenerator {
  final MushafDbReader _dbReader;
  final MushafWordMapper _wordMapper;
  final PageSize pageSize;
  final BookMargins margins;

  // Cached base64 encoded fonts
  String? _kitabRegularBase64;
  String? _kitabBoldBase64;

  MushafHtmlGenerator(
    this._dbReader, {
    this.pageSize = PageSize.a4,
    BookMargins? margins,
  })  : margins = margins ?? pageSize.margins,
        _wordMapper = MushafWordMapper();

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

    final buffer = StringBuffer();

    // Write HTML header with styles
    buffer.writeln(_generateHtmlHeader());

    // Add cover page
    buffer.writeln(_generateCoverPage());

    // Generate content for each page
    for (int pageNum = startPage; pageNum <= endPage; pageNum++) {
      onProgress?.call(pageNum - startPage + 1, endPage - startPage + 1);
      final pageHtml = await _generatePageHtml(pageNum);
      buffer.writeln(pageHtml);
    }

    // Write HTML footer
    buffer.writeln(_generateHtmlFooter());

    return buffer.toString();
  }

  String _generateHtmlHeader() {
    // Build tajweed CSS classes from rule-color mapper
    final tajweedCss = TajweedRule.values.map((r) {
      final key = _tajweedRuleKey(r);
      final hex = tajweedRuleToHex(r);
      return '.tajweed-$key { color: $hex; }';
    }).join('\n    ');

    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Quran Mushaf with Tajweed</title>
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
      color: #000;
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
    }
    
    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: ${pageSize.headerFontSize}px;
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
      font-size: ${pageSize.fontSize}px;
      line-height: ${pageSize.lineHeight};
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
      word-spacing: -5px;
    }
    
    .surah-header {
      text-align: center;
      font-size: ${pageSize.surahFontSize}px;
      font-weight: bold;
      padding: 8px 0;
      margin: 5px 0;
      background: linear-gradient(to right, #D4AF37, #F5E6B3, #D4AF37);
      border-radius: 8px;
      color: #333;
    }
    
    .basmallah {
      text-align: center;
      font-size: ${pageSize.fontSize}px;
      padding: 10px 0;
      color: #000;
    }
    
    .aya-number {
      font-size: ${pageSize.ayaNumberFontSize}px;
      color: #000;
      padding: 0 2px;
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
    
    /* Cover page styles */
    .cover {
      width: ${pageSize.widthMm}mm;
      height: ${pageSize.heightMm}mm;
      margin: 20px auto;
      background: linear-gradient(135deg, #1a472a 0%, #2d5a3d 50%, #1a472a 100%);
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
        font-size: ${(pageSize.headerFontSize * 0.9).round()}px;
      }
      .line {
        font-size: ${(pageSize.fontSize * 0.99).round()}px;
        line-height: ${pageSize.lineHeight * 0.80};
      }
      .surah-header {
        font-size: ${(pageSize.surahFontSize * 0.85).round()}px;
        padding: 3px 0;
        margin: 1px 0;
      }
      .basmallah {
        font-size: ${(pageSize.fontSize * 0.99).round()}px;
        padding: 3px 0;
      }
      .aya-number {
        font-size: ${(pageSize.ayaNumberFontSize * 0.99).round()}px;
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
    return '''
<div class="cover">
  <div class="cover-ornament">❁ ❁ ❁</div>
  <div class="cover-title">ٱلْقُرْآنُ ٱلْكَرِيمُ</div>
  <div class="cover-subtitle">The Noble Quran</div>
  <div class="cover-basmallah">بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ</div>
  <div class="cover-ornament">❁ ❁ ❁</div>
  <div class="cover-footer">With Tajweed Color Coding</div>
</div>
''';
  }

  Future<String> _generatePageHtml(int pageNumber) async {
    final buffer = StringBuffer();
    final lines = await _dbReader.getPageLines(pageNumber);

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
        }
      }
    }

    // Default to surah 1, ayah 1 if we couldn't determine
    firstSurah ??= 1;
    firstAyah ??= 1;

    // Get surah name and juz for header
    final surahName = firstSurah > 0 && firstSurah <= surahNames.length
        ? 'سُورَةُ ${surahNames[firstSurah - 1]}'
        : '';
    final juzNumber = getJuzForPosition(firstSurah, firstAyah);
    final juzName = juzNumber > 0 && juzNumber <= juzNames.length
        ? juzNames[juzNumber - 1]
        : '';

    // Determine odd/even class for RTL book margins
    // Account for cover page: physical page = pageNumber + 1 (cover is page 1)
    // So Quran page 1 is physical page 2 (even), page 2 is physical page 3 (odd), etc.
    final physicalPageNumber = pageNumber + 1;
    final pageClass = physicalPageNumber.isOdd ? 'page-odd' : 'page-even';

    buffer.writeln('<div class="page $pageClass">');
    buffer.writeln('<div class="page-content">');
    buffer.writeln('<div class="page-header">');
    buffer.writeln('<span class="page-header-surah">$surahName</span>');
    buffer.writeln('<span class="page-header-number">$pageNumber</span>');
    buffer.writeln('<span class="page-header-juz">$juzName</span>');
    buffer.writeln('</div>');

    // Track if we're inside a lines-wrapper
    bool inLinesWrapper = false;

    for (final line in lines) {
      switch (line.lineType) {
        case 'surah_name':
          // Close lines-wrapper if open, render header, then reopen
          if (inLinesWrapper) {
            buffer.writeln('</div>'); // close lines-wrapper
            inLinesWrapper = false;
          }
          buffer.writeln(_generateSurahHeader(line.surahNumber ?? 1));
          break;
        case 'basmallah':
          // Open lines-wrapper if not already open
          if (!inLinesWrapper) {
            buffer.writeln('<div class="lines-wrapper">');
            inLinesWrapper = true;
          }
          buffer.writeln(_generateBasmallah());
          break;
        case 'ayah':
          // Open lines-wrapper if not already open
          if (!inLinesWrapper) {
            buffer.writeln('<div class="lines-wrapper">');
            inLinesWrapper = true;
          }
          final lineHtml = await _generateAyahLine(line);
          buffer.writeln(lineHtml);
          break;
      }
    }

    // Close lines-wrapper if still open
    if (inLinesWrapper) {
      buffer.writeln('</div>'); // close lines-wrapper
    }

    buffer.writeln('</div>'); // close page-content
    buffer.writeln(_generateLegend());
    buffer.writeln('</div>'); // close page
    return buffer.toString();
  }

  String _generateLegend() {
    return '''
<div class="legend">
  <div class="legend-item">
    <div class="legend-color" style="background: #4CAF50;"></div>
    <span class="legend-label">LAFZATULLAH</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #06B0B6;"></div>
    <span class="legend-label">Izhar</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #B71C1C;"></div>
    <span class="legend-label">Ikhfaa</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #F06292;"></div>
    <span class="legend-label">Idgham + Ghunna</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #9E9E9E;"></div>
    <span class="legend-label">Idgham</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #2196F3;"></div>
    <span class="legend-label">Iqlab</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #7B8F0A;"></div>
    <span class="legend-label">Qalqala</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #FF9800;"></div>
    <span class="legend-label">Ghunna</span>
  </div>
  <div class="legend-item">
    <div class="legend-color" style="background: #8E64D6;"></div>
    <span class="legend-label">Madd</span>
  </div>
</div>
''';
  }

  String _generateSurahHeader(int surahNumber) {
    final surahName = surahNumber > 0 && surahNumber <= surahNames.length
        ? surahNames[surahNumber - 1]
        : 'سورة';

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

  Future<String> _generateAyahLine(MushafLine line) async {
    if (line.firstWordId == null || line.lastWordId == null) {
      throw Exception(
          'Ayah line on page ${line.pageNumber} line ${line.lineNumber} has no word IDs!');
      //return '<div class="line line-centered"></div>';
    }

    final words = await _dbReader.getWords(line.firstWordId!, line.lastWordId!);
    if (words.isEmpty) {
      throw Exception(
          'No words found for page ${line.pageNumber} line ${line.lineNumber} (word IDs ${line.firstWordId}-${line.lastWordId})');
    }
    final buffer = StringBuffer();

    final alignmentClass = line.isCentered ? 'line-centered' : 'line-justified';
    buffer.write('<div class="line $alignmentClass">');

    for (final word in words) {
      if (word.isAyaNumber) {
        // Render aya number with special ornament styling
        buffer.write(_generateAyaNumber(word.text));
      } else {
        // Map word to tajweed tokens and render
        final tajweedWord = _wordMapper.mapWordToTokens(word);
        if (tajweedWord != null) {
          buffer.write(_generateColoredWord(tajweedWord));
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
    // Use the end-of-ayah ornament ۝ (U+06DD) with the number
    return '<span class="aya-number">\u06DD$arabicNumber</span> ';
  }

  String _generateColoredWord(tajweedWord) {
    final buffer = StringBuffer();
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

    buffer.write('</span> ');
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
}
