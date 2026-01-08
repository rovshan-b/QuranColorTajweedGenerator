import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:mushaf_generator/mushaf_page_config.dart';
import 'package:mushaf_generator/quran_enc_translation_service.dart';
import 'package:mushaf_generator/mushaf_wbw_service.dart';
import 'package:mushaf_generator/ui/widgets/custom_inputs.dart';

class TranslationTab extends StatelessWidget {
  final PageSize selectedPageSize;
  final String outputFormat;
  final bool includeTranslation;
  final String translationSource;
  final String? tarteelFilePath;
  final String? tanzilFilePath;
  final String? selectedTranslationKey;
  final List<TranslationInfo> availableTranslations;
  final bool includeWbw;
  final String selectedWbwLanguage;
  final List<String> availableWbwLanguages;
  final bool justifyTranslation;
  final Function(bool) onIncludeTranslationChanged;
  final Function(String) onTranslationSourceChanged;
  final Function(String) onPickFile;
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
    required this.translationSource,
    this.tarteelFilePath,
    this.tanzilFilePath,
    required this.selectedTranslationKey,
    required this.availableTranslations,
    required this.includeWbw,
    required this.selectedWbwLanguage,
    required this.availableWbwLanguages,
    required this.justifyTranslation,
    required this.onIncludeTranslationChanged,
    required this.onTranslationSourceChanged,
    required this.onPickFile,
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: translationSource,
                      decoration: const InputDecoration(
                        labelText: 'Translation Source',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'QuranEnc',
                          child: Text('QuranEnc (API)'),
                        ),
                        DropdownMenuItem(
                          value: 'Tarteel',
                          child: Text('Tarteel (SQLite DB)'),
                        ),
                        DropdownMenuItem(
                          value: 'Tanzil',
                          child: Text('Tanzil (Text File)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) onTranslationSourceChanged(val);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (translationSource == 'QuranEnc')
                      DropdownButtonFormField<String>(
                        value: selectedTranslationKey,
                        decoration: const InputDecoration(
                          labelText: 'Select QuranEnc Translation',
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
                      )
                    else if (translationSource == 'Tarteel')
                      _buildFilePicker(
                        context,
                        'Tarteel SQLite File',
                        tarteelFilePath,
                        () => onPickFile('Tarteel'),
                        downloadUrl:
                            'https://qul.tarteel.ai/resources/translation',
                        downloadInstructions:
                            'Extract if translation is in zip archive and then select extracted file',
                      )
                    else if (translationSource == 'Tanzil')
                      _buildFilePicker(
                        context,
                        'Tanzil Text File',
                        tanzilFilePath,
                        () => onPickFile('Tanzil'),
                        downloadUrl: 'https://tanzil.net/trans/',
                        downloadInstructions:
                            'Select "Text (with aya numbers)" format',
                      ),
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
                                    translationWidthFraction: v.toDouble())),
                          ),
                        ),
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
                                    translationArabicScale: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Font Size (px)',
                            value:
                                selectedPageSize.translationFontSize.toDouble(),
                            enabled:
                                includeTranslation && outputFormat == 'HTML',
                            suffix: _buildHelpIcon('Font Size (px)',
                                'Size of the translation text in pixels.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(translationFontSize: v.toInt())),
                          ),
                        ),
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
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(translationLineHeight: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Compact Threshold',
                            value: selectedPageSize.translationCompactThreshold
                                .toDouble(),
                            enabled:
                                includeTranslation && outputFormat == 'HTML',
                            suffix: _buildHelpIcon('Compact Threshold',
                                'Character count above which translation switches to inline mode.'),
                            onChanged: (v) => onPageSizeChanged(
                                selectedPageSize.copyWith(
                                    translationCompactThreshold: v.toInt())),
                          ),
                        ),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NumberInput(
                            label: 'Font Size (px)',
                            value: selectedPageSize.wbwFontSize.toDouble(),
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('Font Size (px)',
                                'Size of the word-by-word translation text in pixels.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(wbwFontSize: v.toInt())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Arabic Scale',
                            value: selectedPageSize.wbwArabicScale,
                            isDecimal: true,
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('Arabic Scale',
                                'How much to shrink the Arabic text when word-by-word translation is enabled.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(wbwArabicScale: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Arabic Line Height',
                            value: selectedPageSize.wbwArabicLineHeight,
                            isDecimal: true,
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('Arabic Line Height',
                                'Line height for the Arabic text when word-by-word translation is enabled.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(wbwArabicLineHeight: v.toDouble())),
                          ),
                        ),
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
                                    wbwTranslationLineHeight: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Max Width (mm)',
                            value: selectedPageSize.wbwMaxWidthMm,
                            isDecimal: true,
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('Max Width (mm)',
                                'Maximum width allowed for a single word-by-word block in millimeters.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(wbwMaxWidthMm: v.toDouble())),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(
    BuildContext context,
    String label,
    String? path,
    VoidCallback onPick, {
    String? downloadUrl,
    String? downloadInstructions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  path != null ? p.basename(path) : 'No file selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: path != null ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPick,
              child: const Text('Pick File'),
            ),
          ],
        ),
        if (downloadUrl != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final uri = Uri.parse(downloadUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.link, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Download from: ',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        TextSpan(
                          text: downloadUrl,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                        if (downloadInstructions != null)
                          TextSpan(
                            text: '\n$downloadInstructions',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
