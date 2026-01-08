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
                              'Physical width of the page in millimeters.'),
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(widthMm: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Height (mm)',
                          value: selectedPageSize.heightMm,
                          suffix: _buildHelpIcon('Height (mm)',
                              'Physical height of the page in millimeters.'),
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(heightMm: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Padding (mm)',
                          value: selectedPageSize.paddingMm,
                          suffix: _buildHelpIcon('Padding (mm)',
                              'Internal padding between the page edge and content.'),
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(paddingMm: v.toInt())))),
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
                          suffix: _buildHelpIcon(
                              'Gutter (Inner)', 'Inner margin near the spine.'),
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(
                                  margins: selectedPageSize.margins
                                      .copyWith(gutterMm: v.toDouble()))))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Outer',
                          value: selectedPageSize.margins.outerMm,
                          isDecimal: true,
                          suffix: _buildHelpIcon(
                              'Outer', 'Outer margin away from the spine.'),
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(
                                  margins: selectedPageSize.margins
                                      .copyWith(outerMm: v.toDouble()))))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Top',
                          value: selectedPageSize.margins.topMm,
                          isDecimal: true,
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(
                                  margins: selectedPageSize.margins
                                      .copyWith(topMm: v.toDouble()))))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Bottom',
                          value: selectedPageSize.margins.bottomMm,
                          isDecimal: true,
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(
                                  margins: selectedPageSize.margins
                                      .copyWith(bottomMm: v.toDouble()))))),
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
                          suffix: _buildHelpIcon(
                              'Text Size (px)', 'Base size for Arabic text.'),
                          onChanged: (v) => onPageSizeChanged(
                              selectedPageSize.copyWith(fontSize: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Line Height',
                          value: selectedPageSize.lineHeight,
                          isDecimal: true,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(lineHeight: v.toDouble())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Word Spacing',
                          value: selectedPageSize.wordSpacing,
                          isDecimal: true,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(wordSpacing: v.toDouble())))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: NumberInput(
                          label: 'Surah Header',
                          value: selectedPageSize.surahFontSize,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(surahFontSize: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Ayah Number',
                          value: selectedPageSize.ayaNumberFontSize,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(ayaNumberFontSize: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Page Header',
                          value: selectedPageSize.headerFontSize,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(headerFontSize: v.toInt())))),
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
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(tocFontSize: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'TOC Entries/Pg',
                          value: selectedPageSize.tocEntriesPerPage,
                          enabled: outputFormat == 'HTML',
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(tocEntriesPerPage: v.toInt())))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: NumberInput(
                          label: 'Legend Font (px)',
                          value: selectedPageSize.legendFontSize,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(legendFontSize: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Legend Gap',
                          value: selectedPageSize.legendGap,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(legendGap: v.toInt())))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: NumberInput(
                          label: 'Legend Padding',
                          value: selectedPageSize.legendPadding,
                          onChanged: (v) => onPageSizeChanged(selectedPageSize
                              .copyWith(legendPadding: v.toInt())))),
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
                          onChanged: (v) =>
                              onPrefaceBlankPagesChanged(v.toInt()))),
                  if (outputFormat == 'PNG') ...[
                    const SizedBox(width: 12),
                    Expanded(
                        child: NumberInput(
                            label: 'Resolution (DPI)',
                            value: dpi,
                            onChanged: (v) => onDpiChanged(v.toInt()))),
                  ],
                ],
              ),
              SwitchListTile(
                title: const Text('Start Mushaf Page 1 on Right Side'),
                subtitle: const Text(
                    'Ensures gutter and translation columns are on the correct side for printing.'),
                value: startOnRightSide,
                contentPadding: EdgeInsets.zero,
                onChanged: onStartOnRightSideChanged,
              ),
              if (outputFormat == 'PNG') ...[
                SwitchListTile(
                  title: const Text('Show Page Header & Legend'),
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
