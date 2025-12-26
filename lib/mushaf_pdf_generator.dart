import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:tajweed/mushaf_html_generator.dart';

/// Generates PDF from HTML content
class MushafPdfGenerator {
  final PageSize pageSize;

  MushafPdfGenerator({this.pageSize = PageSize.a4});

  /// Converts PageSize enum to PdfPageFormat
  PdfPageFormat get pdfPageFormat {
    // Convert mm to points (1 mm = 2.834645669291339 points)
    const mmToPoints = 2.834645669291339;
    return PdfPageFormat(
      pageSize.widthMm * mmToPoints,
      pageSize.heightMm * mmToPoints,
    );
  }

  /// Converts HTML string to PDF bytes using weasyprint
  Future<Uint8List> generatePdfFromHtml(String html, String outputPath) async {
    // Create temp HTML file
    final tempDir = Directory.systemTemp;
    final tempHtmlFile = File(
        '${tempDir.path}/mushaf_temp_${DateTime.now().millisecondsSinceEpoch}.html');

    // Full path to weasyprint (Homebrew on Apple Silicon)
    const weasyprintPath = '/opt/homebrew/bin/weasyprint';

    try {
      // Write HTML to temp file
      await tempHtmlFile.writeAsString(html);

      // Check if weasyprint exists
      if (!await File(weasyprintPath).exists()) {
        throw Exception(
            'weasyprint is not installed at $weasyprintPath. Please install it using:\n'
            'brew install weasyprint');
      }

      // Run weasyprint
      final result = await Process.run(weasyprintPath, [
        tempHtmlFile.path,
        outputPath,
      ]);

      if (result.exitCode != 0) {
        throw Exception('weasyprint failed: ${result.stderr}');
      }

      // Read the generated PDF
      final pdfFile = File(outputPath);
      return await pdfFile.readAsBytes();
    } finally {
      // Clean up temp file
      if (await tempHtmlFile.exists()) {
        await tempHtmlFile.delete();
      }
    }
  }
}
