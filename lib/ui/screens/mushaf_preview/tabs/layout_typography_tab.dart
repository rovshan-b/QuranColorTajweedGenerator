import 'package:flutter/material.dart';
import 'package:mushaf_generator/mushaf_page_config.dart';
import 'package:mushaf_generator/ui/widgets/custom_inputs.dart';
import 'package:mushaf_generator/ui/widgets/color_legend_item.dart';

class LayoutTypographyTab extends StatelessWidget {
  final PageSize selectedPageSize;
  final String outputFormat;
  final int prefaceBlankPages;
  final bool startOnRightSide;
  final int dpi;
  final bool showDecorations;

  final Function(PageSize) onPageSizeChanged;
  final Function(int) onPrefaceBlankPagesChanged;
  final Function(bool) onStartOnRightSideChanged;
  final Function(int) onDpiChanged;
  final Function(bool) onShowDecorationsChanged;
  final Function(String, String) onShowHelp;

  const LayoutTypographyTab({
    super.key,
    required this.selectedPageSize,
    required this.outputFormat,
    required this.prefaceBlankPages,
    required this.startOnRightSide,
    required this.dpi,
    required this.showDecorations,
    required this.onPageSizeChanged,
    required this.onPrefaceBlankPagesChanged,
    required this.onStartOnRightSideChanged,
    required this.onDpiChanged,
    required this.onShowDecorationsChanged,
    required this.onShowHelp,
  });

  Widget _buildHelpIcon(String title, String helpText) {
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 18),
      onPressed: () => onShowHelp(title, helpText),
      tooltip: 'Help',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page & Dimensions
          _buildSectionCard(
            context,
            title: 'Page Configuration',
            children: [
              const Text('Dimensions & Padding',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'Width (mm)',
                      value: selectedPageSize.widthMm,
                      suffix: _buildHelpIcon('Width (mm)',
                          'Physical width of the page in millimeters. Common sizes: A4 = 210mm, B5 = 176mm.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(widthMm: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Height (mm)',
                      value: selectedPageSize.heightMm,
                      suffix: _buildHelpIcon('Height (mm)',
                          'Physical height of the page in millimeters. Common sizes: A4 = 297mm, B5 = 250mm.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(heightMm: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Padding (mm)',
                      value: selectedPageSize.paddingMm,
                      suffix: _buildHelpIcon('Padding (mm)',
                          'Internal safety padding between the page edge and the main content area (headers, text, legend).'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(paddingMm: v.toInt())),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Margins (mm)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'Gutter (Inner)',
                      value: selectedPageSize.margins.gutterMm,
                      isDecimal: true,
                      suffix: _buildHelpIcon('Gutter (Inner) Margin',
                          'The inner margin located near the book\'s spine/binding. This is essential for professional printing to prevent text from disappearing into the fold. For RTL books, this alternates between left and right sides on every other page.'),
                      onChanged: (v) => onPageSizeChanged(
                        selectedPageSize.copyWith(
                          margins: selectedPageSize.margins
                              .copyWith(gutterMm: v.toDouble()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Outer',
                      value: selectedPageSize.margins.outerMm,
                      isDecimal: true,
                      suffix: _buildHelpIcon('Outer Margin',
                          'The absolute outer edge margin of the page, away from the binding.'),
                      onChanged: (v) => onPageSizeChanged(
                        selectedPageSize.copyWith(
                          margins: selectedPageSize.margins
                              .copyWith(outerMm: v.toDouble()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Top',
                      value: selectedPageSize.margins.topMm,
                      isDecimal: true,
                      suffix: _buildHelpIcon('Top Margin',
                          'Empty space at the top of the page, above the page headers.'),
                      onChanged: (v) => onPageSizeChanged(
                        selectedPageSize.copyWith(
                          margins: selectedPageSize.margins
                              .copyWith(topMm: v.toDouble()),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Bottom',
                      value: selectedPageSize.margins.bottomMm,
                      isDecimal: true,
                      suffix: _buildHelpIcon('Bottom Margin',
                          'Empty space at the bottom of the page, below the tajweed legend.'),
                      onChanged: (v) => onPageSizeChanged(
                        selectedPageSize.copyWith(
                          margins: selectedPageSize.margins
                              .copyWith(bottomMm: v.toDouble()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Arabic Typography
          _buildSectionCard(
            context,
            title: 'Arabic Typography',
            children: [
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'Text Size (px)',
                      value: selectedPageSize.fontSize,
                      suffix: _buildHelpIcon('Text Size (px)',
                          'Base size for the main Arabic Quran text in pixels. Note that this value is scaled down automatically when Translation or Word-by-Word modes are enabled.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(fontSize: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Line Height (factor)',
                      value: selectedPageSize.lineHeight,
                      isDecimal: true,
                      suffix: _buildHelpIcon('Line Height (factor)',
                          'A multiplier applied to the font size to determine vertical spacing between lines. Value of 1.0 means no extra space; default is ~1.7 to accommodate Tajweed markings.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(lineHeight: v.toDouble())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Word Spacing (em)',
                      value: selectedPageSize.wordSpacing,
                      isDecimal: true,
                      suffix: _buildHelpIcon('Word Spacing (em)',
                          'Adjustment for spacing between Arabic words in relative "em" units (1em = current font size). Negative values (e.g. -0.3) tighten the layout for better justification.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(wordSpacing: v.toDouble())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'Surah Header (px)',
                      value: selectedPageSize.surahFontSize,
                      suffix: _buildHelpIcon('Surah Header (px)',
                          'Font size in pixels for the Surah names displayed at the beginning of each Surah header.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(surahFontSize: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Ayah Number (px)',
                      value: selectedPageSize.ayaNumberFontSize,
                      suffix: _buildHelpIcon('Ayah Marker (px)',
                          'Font size in pixels for the ornate Ayah number symbols.'),
                      onChanged: (v) => onPageSizeChanged(selectedPageSize
                          .copyWith(ayaNumberFontSize: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Page Header (px)',
                      value: selectedPageSize.headerFontSize,
                      suffix: _buildHelpIcon('Page Header (px)',
                          'Size in pixels of the text displayed at the top of each page (Surah name, Page number, Juz name).'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(headerFontSize: v.toInt())),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. Decorations (TOC & Legend)
          _buildSectionCard(
            context,
            title: 'TOC & Legend',
            children: [
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'TOC Font (px)',
                      value: selectedPageSize.tocFontSize,
                      enabled: outputFormat == 'HTML',
                      suffix: _buildHelpIcon('TOC Font Size',
                          'Size of Surah names and page numbers in the Table of Contents pages.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(tocFontSize: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'TOC Entries/Pg',
                      value: selectedPageSize.tocEntriesPerPage,
                      enabled: outputFormat == 'HTML',
                      suffix: _buildHelpIcon('Entries Per TOC Page',
                          'The number of Surahs listed on a single Table of Contents page.'),
                      onChanged: (v) => onPageSizeChanged(selectedPageSize
                          .copyWith(tocEntriesPerPage: v.toInt())),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'Legend Font (px)',
                      value: selectedPageSize.legendFontSize,
                      suffix: _buildHelpIcon('Legend Text Size',
                          'Font size for the Tajweed coding key at the bottom of the page.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(legendFontSize: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Legend Gap (px)',
                      value: selectedPageSize.legendGap,
                      suffix: _buildHelpIcon('Legend Gap (px)',
                          'Spacing between individual items (e.g., between "Ikhfaa" and "Izhar") in the legend.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(legendGap: v.toInt())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NumberInput(
                      label: 'Legend Top (px)',
                      value: selectedPageSize.legendPadding,
                      suffix: _buildHelpIcon('Legend Top Padding (px)',
                          'The spacing between the bottom of the Quranic text area and the start of the Tajweed legend.'),
                      onChanged: (v) => onPageSizeChanged(
                          selectedPageSize.copyWith(legendPadding: v.toInt())),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4. Output Specifics
          _buildSectionCard(
            context,
            title: 'Output & Covers',
            children: [
              Row(
                children: [
                  Expanded(
                    child: NumberInput(
                      label: 'Preface Blank Pages',
                      value: prefaceBlankPages,
                      enabled: outputFormat == 'HTML',
                      suffix: _buildHelpIcon('Preface Blank Pages',
                          'Number of empty pages to insert after the cover. This is useful for technical printing requirements (e.g., leaving space for a dedicated Preface or Dedication).'),
                      onChanged: (v) => onPrefaceBlankPagesChanged(v.toInt()),
                    ),
                  ),
                  if (outputFormat == 'PNG') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: NumberInput(
                        label: 'Resolution (DPI)',
                        value: dpi,
                        suffix: _buildHelpIcon('Resolution (DPI)',
                            'Dots Per Inch. Determines the quality of generated images. Standard printing requires 300 DPI or higher.'),
                        onChanged: (v) => onDpiChanged(v.toInt()),
                      ),
                    ),
                  ],
                ],
              ),
              SwitchListTile(
                title: Row(
                  children: [
                    const Text('Start Mushaf Page 1 on Right Side'),
                    const SizedBox(width: 8),
                    _buildHelpIcon('Right Side Start',
                        'Standard for RTL books like the Quran. This toggle determines the "parity" of your pages: Odd pages will be assigned a Right-side gutter and Even pages a Left-side gutter. Disable this only for special digital layouts.'),
                  ],
                ),
                subtitle: const Text(
                    'Ensures gutter and translation columns are on the correct side for printing.'),
                value: startOnRightSide,
                contentPadding: EdgeInsets.zero,
                onChanged: onStartOnRightSideChanged,
              ),
              if (outputFormat == 'PNG') ...[
                SwitchListTile(
                  title: Row(
                    children: [
                      const Text('Show Page Header & Legend'),
                      const SizedBox(width: 8),
                      _buildHelpIcon('Decorations Toggle',
                          'If disabled, resulting images will only contain the central Quranic text block without any headers or the Tajweed legend.'),
                    ],
                  ),
                  subtitle: const Text(
                      'Includes surah name, page number, juz and tajweed key'),
                  value: showDecorations,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onShowDecorationsChanged,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      List<Widget>? actions,
      required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (actions != null)
                  Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
