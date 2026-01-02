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
    wordSpacing: -0.35,
    tocEntriesPerPage: 27,
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
    fontSize: 30,
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
    translationFontSize: 11,
    translationLineHeight: 1.10,
    translationWidthFraction: 0.20,
    translationArabicScale: 0.80,
    wordSpacing: -0.35,
    tocEntriesPerPage: 21,
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
    wordSpacing: -0.5,
    tocEntriesPerPage: 16,
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
      required this.wordSpacing,
      required this.margins,
      required this.tocEntriesPerPage});

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
  final int tocFontSize;
  final int translationFontSize;
  final double translationLineHeight;

  /// Fraction of available width given to the translation column when enabled.
  final double translationWidthFraction;

  /// Scale applied to Arabic fonts when translation column is enabled to keep content on one page.
  final double translationArabicScale;

  /// Word spacing for Arabic text in em.
  final double wordSpacing;

  final BookMargins margins;
  final int tocEntriesPerPage;
}
