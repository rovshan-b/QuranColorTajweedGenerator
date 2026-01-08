import 'package:flutter/material.dart';
import 'package:mushaf_generator/mushaf_page_config.dart';
import 'package:mushaf_generator/quran_enc_translation_service.dart';
import 'package:mushaf_generator/mushaf_wbw_service.dart';
import 'package:mushaf_generator/ui/widgets/custom_inputs.dart';

class TranslationTab extends StatelessWidget {
  final PageSize selectedPageSize;
  final String outputFormat;
  final bool includeTranslation;
  final String? selectedTranslationKey;
  final List<TranslationInfo> availableTranslations;
  final bool includeWbw;
  final String selectedWbwLanguage;
  final List<String> availableWbwLanguages;
  final bool justifyTranslation;
  final Function(bool) onIncludeTranslationChanged;
  final Function(String?) onTranslationKeyChanged;
  final Function(bool) onIncludeWbwChanged;
  final Function(String) onWbwLanguageChanged;
  final Function(bool) onJustifyTranslationChanged;
  final Function(PageSize) onPageSizeChanged;
  final Function(String, String) onShowHelp;

  const TranslationTab({
    super.key,
    required this.selectedPageSize,
    required this.outputFormat,
    required this.includeTranslation,
    required this.selectedTranslationKey,
    required this.availableTranslations,
    required this.includeWbw,
    required this.selectedWbwLanguage,
    required this.availableWbwLanguages,
    required this.justifyTranslation,
    required this.onIncludeTranslationChanged,
    required this.onTranslationKeyChanged,
    required this.onIncludeWbwChanged,
    required this.onWbwLanguageChanged,
    required this.onJustifyTranslationChanged,
    required this.onPageSizeChanged,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Page Translation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Include translation (outer column)'),
                    subtitle: outputFormat == 'PNG'
                        ? const Text(
                            'Translation column is only supported in HTML format',
                            style: TextStyle(color: Colors.orange))
                        : null,
                    value: includeTranslation && outputFormat == 'HTML',
                    contentPadding: EdgeInsets.zero,
                    onChanged: outputFormat == 'PNG'
                        ? null
                        : onIncludeTranslationChanged,
                  ),
                  if (includeTranslation && outputFormat == 'HTML') ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedTranslationKey,
                      decoration: const InputDecoration(
                        labelText: 'Translation source',
                        border: OutlineInputBorder(),
                      ),
                      items: availableTranslations
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.key,
                              child: Text('${t.name} (${t.language})'),
                            ),
                          )
                          .toList(),
                      onChanged: onTranslationKeyChanged,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: NumberInput(
                              label: 'Width Fraction',
                              value: selectedPageSize.translationWidthFraction,
                              isDecimal: true,
                              enabled:
                                  includeTranslation && outputFormat == 'HTML',
                              suffix: _buildHelpIcon('Width Fraction',
                                  'Percentage of page width allocated to the translation column.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      translationWidthFraction:
                                          v.toDouble())))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: NumberInput(
                              label: 'Arabic Scale',
                              value: selectedPageSize.translationArabicScale,
                              isDecimal: true,
                              enabled:
                                  includeTranslation && outputFormat == 'HTML',
                              suffix: _buildHelpIcon('Arabic Scale',
                                  'How much to shrink the Arabic text when translation is enabled.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      translationArabicScale: v.toDouble())))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: NumberInput(
                              label: 'Font Size (px)',
                              value: selectedPageSize.translationFontSize,
                              enabled:
                                  includeTranslation && outputFormat == 'HTML',
                              suffix: _buildHelpIcon('Font Size (px)',
                                  'Size of the translation text in pixels.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      translationFontSize: v.toInt())))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: NumberInput(
                              label: 'Line Height',
                              value: selectedPageSize.translationLineHeight,
                              isDecimal: true,
                              enabled:
                                  includeTranslation && outputFormat == 'HTML',
                              suffix: _buildHelpIcon('Line Height',
                                  'Spacing between lines of translation text.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      translationLineHeight: v.toDouble())))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: NumberInput(
                              label: 'Compact Threshold',
                              value:
                                  selectedPageSize.translationCompactThreshold,
                              enabled:
                                  includeTranslation && outputFormat == 'HTML',
                              suffix: _buildHelpIcon('Compact Threshold',
                                  'Character count above which translation switches to inline mode.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      translationCompactThreshold:
                                          v.toInt())))),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Justify translation text'),
                    value: justifyTranslation,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (includeTranslation && outputFormat == 'HTML')
                        ? onJustifyTranslationChanged
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word-by-Word Translation',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Include word-by-word translation'),
                    subtitle: const Text(
                        'Displays translation under each Arabic word.\nTranslations contributed by "Greentech Apps Foundation".'),
                    isThreeLine: true,
                    value: includeWbw,
                    contentPadding: EdgeInsets.zero,
                    onChanged: onIncludeWbwChanged,
                  ),
                  if (includeWbw) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedWbwLanguage,
                      decoration: const InputDecoration(
                        labelText: 'WBW Language',
                        border: OutlineInputBorder(),
                      ),
                      items: availableWbwLanguages
                          .map(
                            (lang) => DropdownMenuItem(
                              value: lang,
                              child:
                                  Text(MushafWbwService.getLanguageName(lang)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          onWbwLanguageChanged(val);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: NumberInput(
                              label: 'Font Size (px)',
                              value: selectedPageSize.wbwFontSize,
                              enabled: includeWbw,
                              suffix: _buildHelpIcon('Font Size (px)',
                                  'Size of the word-by-word translation text in pixels.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      wbwFontSize: v.toInt())))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: NumberInput(
                              label: 'Arabic Scale',
                              value: selectedPageSize.wbwArabicScale,
                              isDecimal: true,
                              enabled: includeWbw,
                              suffix: _buildHelpIcon('Arabic Scale',
                                  'How much to shrink the Arabic text when word-by-word translation is enabled.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      wbwArabicScale: v.toDouble())))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: NumberInput(
                              label: 'Arabic Line Height',
                              value: selectedPageSize.wbwArabicLineHeight,
                              isDecimal: true,
                              enabled: includeWbw,
                              suffix: _buildHelpIcon('Arabic Line Height',
                                  'Line height for the Arabic text when word-by-word translation is enabled.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      wbwArabicLineHeight: v.toDouble())))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: NumberInput(
                              label: 'Trans. Line Height',
                              value: selectedPageSize.wbwTranslationLineHeight,
                              isDecimal: true,
                              enabled: includeWbw,
                              suffix: _buildHelpIcon('Trans. Line Height',
                                  'Line height for the word-by-word translation text.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      wbwTranslationLineHeight:
                                          v.toDouble())))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: NumberInput(
                              label: 'Max Width (mm)',
                              value: selectedPageSize.wbwMaxWidthMm,
                              isDecimal: true,
                              enabled: includeWbw,
                              suffix: _buildHelpIcon('Max Width (mm)',
                                  'Maximum width allowed for a single word-by-word block in millimeters.'),
                              onChanged: (v) => onPageSizeChanged(
                                  selectedPageSize.copyWith(
                                      wbwMaxWidthMm: v.toDouble())))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
