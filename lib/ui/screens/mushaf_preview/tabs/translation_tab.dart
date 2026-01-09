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
                    title: Row(
                      children: [
                        const Text('Include translation (outer column)'),
                        const SizedBox(width: 8),
                        _buildHelpIcon('Full Translation',
                            'Enables a side column containing the full ayah translation. This mode is currently optimized for HTML (PDF) output and will adjust the Arabic text size to fit both columns on a single page.'),
                      ],
                    ),
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
                            label: 'Width (factor)',
                            value: selectedPageSize.translationWidthFraction,
                            isDecimal: true,
                            enabled:
                                includeTranslation && outputFormat == 'HTML',
                            suffix: _buildHelpIcon('Width Fraction (factor)',
                                'The fraction of the page width dedicated to the translation column (e.g., 0.25 = 25%).'),
                            onChanged: (v) => onPageSizeChanged(
                                selectedPageSize.copyWith(
                                    translationWidthFraction: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Arabic Scale (factor)',
                            value: selectedPageSize.translationArabicScale,
                            isDecimal: true,
                            enabled:
                                includeTranslation && outputFormat == 'HTML',
                            suffix: _buildHelpIcon('Arabic Scale (factor)',
                                'A scaling multiplier applied to Arabic text to make room for the translation column. 0.8 means 80% of original size.'),
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
                            suffix: _buildHelpIcon('Translation Font Size (px)',
                                'The base font size in pixels for the translation column text.'),
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
                            label: 'Line Height (factor)',
                            value: selectedPageSize.translationLineHeight,
                            isDecimal: true,
                            enabled:
                                includeTranslation && outputFormat == 'HTML',
                            suffix: _buildHelpIcon('Line Height (factor)',
                                'Vertical spacing multiplier between lines of translated text.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(translationLineHeight: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Compact Limit (count)',
                            value: selectedPageSize.translationCompactThreshold
                                .toDouble(),
                            enabled:
                                includeTranslation && outputFormat == 'HTML',
                            suffix: _buildHelpIcon('Compact Limit (count)',
                                'If the total character count of translations on a page exceeds this number, the layout switches to a "compact" mode (inline text) to ensure everything fits on one physical page.'),
                            onChanged: (v) => onPageSizeChanged(
                                selectedPageSize.copyWith(
                                    translationCompactThreshold: v.toInt())),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: Row(
                        children: [
                          const Text('Justify translation text'),
                          const SizedBox(width: 8),
                          _buildHelpIcon('Justify Text',
                              'If enabled, the translation text stretches to fill the entire column width (flush left and right edges).'),
                        ],
                      ),
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
                    title: Row(
                      children: [
                        const Text('Include word-by-word translation'),
                        const SizedBox(width: 8),
                        _buildHelpIcon('Word-by-Word (WBW)',
                            'Places a small translation directly under each individual Arabic word. This significantly increases the vertical height of each line.'),
                      ],
                    ),
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
                            suffix: _buildHelpIcon('WBW Font Size (px)',
                                'Size in pixels of the small translation text appearing under words.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(wbwFontSize: v.toInt())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Arabic Scale (factor)',
                            value: selectedPageSize.wbwArabicScale,
                            isDecimal: true,
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('Arabic Scale (factor)',
                                'Scaling multiplier applied to the main Arabic text to make room for word-by-word labels.'),
                            onChanged: (v) => onPageSizeChanged(selectedPageSize
                                .copyWith(wbwArabicScale: v.toDouble())),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'Line Height (factor)',
                            value: selectedPageSize.wbwArabicLineHeight,
                            isDecimal: true,
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('Arabic Row Height (factor)',
                                'Line height multiplier for the Arabic text in WBW mode. This usually needs to be higher (e.g. 1.5 - 2.0) to avoid overlapping with translations.'),
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
                            label: 'Trans. Height (factor)',
                            value: selectedPageSize.wbwTranslationLineHeight,
                            isDecimal: true,
                            enabled: includeWbw,
                            suffix: _buildHelpIcon('WBW Line Height (factor)',
                                'Line height multiplier for the small translated labels.'),
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
                            suffix: _buildHelpIcon('Max Label Width (mm)',
                                'Maximum width in millimeters allowed for a single word\'s translation before it wraps to a new line.'),
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
