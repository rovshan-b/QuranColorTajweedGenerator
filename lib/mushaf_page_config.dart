/// Page configuration for Mushaf HTML/PDF generation

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

/// Page size configuration for HTML/PDF output
enum PageSize {
  a3(
    name: 'A3',
    widthMm: 297,
    heightMm: 420,
    fontSize: 46,
    lineHeight: 1.7,
    paddingMm: 22,
    surahFontSize: 46,
    ayaNumberFontSize: 34,
    legendFontSize: 12,
    legendColorSize: 14,
    legendGap: 16,
    legendItemGap: 6,
    legendPadding: 16,
    headerFontSize: 24,
    tocFontSize: 24,
    translationFontSize: 14,
    translationLineHeight: 1.2,
    translationWidthFraction: 0.25,
    translationArabicScale: 0.75,
    wbwFontSize: 12,
    wbwArabicScale: 0.70,
    wbwArabicLineHeight: 2.0,
    wbwTranslationLineHeight: 1.1,
    wbwMaxWidthMm: 12.0,
    wordSpacing: -0.35,
    tocEntriesPerPage: 27,
    translationCompactThreshold: 3000,
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
    fontSize: 26,
    lineHeight: 1.7,
    paddingMm: 15,
    surahFontSize: 36,
    ayaNumberFontSize: 28,
    legendFontSize: 10,
    legendColorSize: 12,
    legendGap: 12,
    legendItemGap: 4,
    legendPadding: 12,
    headerFontSize: 20,
    tocFontSize: 18,
    translationFontSize: 9,
    translationLineHeight: 1.10,
    translationWidthFraction: 0.20,
    translationArabicScale: 0.80,
    wbwFontSize: 6,
    wbwArabicScale: 0.75,
    wbwArabicLineHeight: 1.5,
    wbwTranslationLineHeight: 1.0,
    wbwMaxWidthMm: 10.0,
    wordSpacing: -0.35,
    tocEntriesPerPage: 21,
    translationCompactThreshold: 1600,
    margins: BookMargins(
      gutterMm: 26.0,
      outerMm: 26.0,
      topMm: 15.0,
      bottomMm: 15.0,
    ),
  ),
  b5(
    name: 'B5',
    widthMm: 176,
    heightMm: 250,
    fontSize: 20,
    lineHeight: 1.4,
    paddingMm: 12,
    surahFontSize: 32,
    ayaNumberFontSize: 24,
    legendFontSize: 8,
    legendColorSize: 10,
    legendGap: 8,
    legendItemGap: 3,
    legendPadding: 8,
    headerFontSize: 17,
    tocFontSize: 15,
    translationFontSize: 7,
    translationLineHeight: 1.2,
    translationWidthFraction: 0.23,
    translationArabicScale: 0.85,
    wbwFontSize: 5,
    wbwArabicScale: 0.85,
    wbwArabicLineHeight: 1.3,
    wbwTranslationLineHeight: 1.0,
    wbwMaxWidthMm: 8.0,
    wordSpacing: -0.3,
    tocEntriesPerPage: 19,
    translationCompactThreshold: 1000,
    margins: BookMargins(
      gutterMm: 26.0,
      outerMm: 26.0,
      topMm: 14.0,
      bottomMm: 14.0,
    ),
  ),
  a5(
    name: 'A5',
    widthMm: 148,
    heightMm: 210,
    fontSize: 20,
    lineHeight: 1.5,
    paddingMm: 12,
    surahFontSize: 26,
    ayaNumberFontSize: 20,
    legendFontSize: 6,
    legendColorSize: 8,
    legendGap: 5,
    legendItemGap: 2,
    legendPadding: 6,
    headerFontSize: 14,
    tocFontSize: 12,
    translationFontSize: 8,
    translationLineHeight: 1.0,
    translationWidthFraction: 0.25,
    translationArabicScale: 0.80,
    wbwFontSize: 6,
    wbwArabicScale: 0.70,
    wbwArabicLineHeight: 1.8,
    wbwTranslationLineHeight: 1.0,
    wbwMaxWidthMm: 6.0,
    wordSpacing: -0.5,
    tocEntriesPerPage: 16,
    translationCompactThreshold: 1000,
    margins: BookMargins(
      gutterMm: 26.0,
      outerMm: 26.0,
      topMm: 12.0,
      bottomMm: 12.0,
    ),
  );

  const PageSize(
      {required this.name,
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
      required this.tocFontSize,
      required this.translationFontSize,
      required this.translationLineHeight,
      required this.translationWidthFraction,
      required this.translationArabicScale,
      required this.wbwFontSize,
      required this.wbwArabicScale,
      required this.wbwArabicLineHeight,
      required this.wbwTranslationLineHeight,
      required this.wbwMaxWidthMm,
      required this.wordSpacing,
      required this.margins,
      required this.tocEntriesPerPage,
      required this.translationCompactThreshold});

  /// Display name of the page size (e.g., 'A4').
  final String name;

  /// Page width in millimeters.
  final int widthMm;

  /// Page height in millimeters.
  final int heightMm;

  /// Base font size for Arabic text in pixels.
  final int fontSize;

  /// Line height multiplier for Arabic text.
  final double lineHeight;

  /// Internal page padding in millimeters.
  final int paddingMm;

  /// Font size for Surah headers in pixels.
  final int surahFontSize;

  /// Font size for Ayah number markers in pixels.
  final int ayaNumberFontSize;

  /// Font size for the Tajweed legend labels in pixels.
  final int legendFontSize;

  /// Size (width/height) of the color boxes in the legend in pixels.
  final int legendColorSize;

  /// Gap between legend items in pixels.
  final int legendGap;

  /// Gap between the color box and label within a legend item in pixels.
  final int legendItemGap;

  /// Top padding for the legend section in pixels.
  final int legendPadding;

  /// Font size for the page header (Surah name, page number, Juz) in pixels.
  final int headerFontSize;

  /// Font size for Table of Contents entries in pixels.
  final int tocFontSize;

  /// Font size for the translation column text in pixels.
  final int translationFontSize;

  /// Line height multiplier for the translation column text.
  final double translationLineHeight;

  /// Fraction of available width given to the translation column when enabled.
  final double translationWidthFraction;

  /// Scale applied to Arabic fonts when translation column is enabled to keep content on one page.
  final double translationArabicScale;

  /// Font size for word-by-word translation.
  final int wbwFontSize;

  /// Scale applied to Arabic fonts when word-by-word translation is enabled.
  final double wbwArabicScale;

  /// Line height for Arabic text when word-by-word translation is enabled.
  final double wbwArabicLineHeight;

  /// Line height for word-by-word translation text.
  final double wbwTranslationLineHeight;

  /// Maximum width for word-by-word translation text in mm.
  final double wbwMaxWidthMm;

  /// Word spacing for Arabic text in em.
  final double wordSpacing;

  /// Margin configuration for the page.
  final BookMargins margins;

  /// Number of Surah entries to display per page in the Table of Contents.
  final int tocEntriesPerPage;

  /// Character count threshold to switch to compact translation mode.
  final int translationCompactThreshold;

  /// Calculates adjusted translation font size based on text length.
  double getAdjustedTranslationFontSize(int totalLength) {
    double size = translationFontSize.toDouble();

    // Adjust based on character count
    if (totalLength < 600) {
      size += 2;
    } else if (totalLength < 1200) {
      size += 1;
    } else if (totalLength > 2200) {
      size -= 1;
    } else if (totalLength > 3200) {
      size -= 2;
    }

    // Ensure font doesn't get too small to read
    return size < 7 ? 7 : size;
  }
}
