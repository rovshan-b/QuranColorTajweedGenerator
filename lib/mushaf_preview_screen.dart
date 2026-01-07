import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mushaf_db_initializer.dart';
import 'mushaf_db_reader.dart';
import 'mushaf_html_generator.dart';
import 'mushaf_image_generator.dart';
import 'mushaf_page_config.dart';
import 'quran_enc_translation_service.dart';
import 'mushaf_wbw_service.dart';
import 'local_translation_service.dart';

/// Screen for generating Mushaf HTML with Tajweed coloring
class MushafPreviewScreen extends StatefulWidget {
  const MushafPreviewScreen({super.key});

  @override
  State<MushafPreviewScreen> createState() => _MushafPreviewScreenState();
}

class _MushafPreviewScreenState extends State<MushafPreviewScreen> {
  bool _isGenerating = false;
  String _statusMessage = '';
  int _currentPage = 0;
  int _totalPages = 0;
  String? _outputPath;

  // Translation controls
  bool _includeTranslation = false;
  String? _selectedTranslationKey;
  List<TranslationInfo> _availableTranslations = const [];
  final QuranEncTranslationService _translationService =
      QuranEncTranslationService();
  final LocalTranslationService _localTranslationService =
      LocalTranslationService();

  // Word-by-word controls
  bool _includeWbw = false;
  String _selectedWbwLanguage = 'en';
  List<String> _availableWbwLanguages = [];

  // Page range for generation
  int _startPage = 1;
  int _endPage = 604;
  int _previewPage = 1;

  // Page size selection
  PageSize _selectedPageSize = PageSize.a4;
  List<PageSize> _customPresets = [];
  late SharedPreferences _prefs;

  // Output format settings
  String _outputFormat = 'HTML'; // 'HTML' or 'PNG'
  int _dpi = 300;
  bool _showDecorations = true;
  String _baseTextColor = '#000000';

  // Cover & Layout settings
  int _prefaceBlankPages = 1;
  String _coverBackgroundColor = '#1a472a'; // Default green
  bool _justifyTranslation = false;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedSettings();
    await MushafDbInitializer.initialize();
    await Future.wait([
      _loadTranslations(),
      _loadWbwLanguages(),
    ]);
  }

  void _loadSavedSettings() {
    final savedPageSizeJson = _prefs.getString('selected_page_size');
    if (savedPageSizeJson != null) {
      try {
        setState(() {
          _selectedPageSize = PageSize.fromJson(json.decode(savedPageSizeJson));
        });
      } catch (e) {
        debugPrint('Error loading saved page size: $e');
      }
    }

    final savedCustomPresetsJson = _prefs.getStringList('custom_presets');
    if (savedCustomPresetsJson != null) {
      try {
        setState(() {
          _customPresets = savedCustomPresetsJson
              .map((j) => PageSize.fromJson(json.decode(j)))
              .toList();
        });
      } catch (e) {
        debugPrint('Error loading custom presets: $e');
      }
    }

    _startPage = _prefs.getInt('start_page') ?? 1;
    _endPage = _prefs.getInt('end_page') ?? 604;
    _previewPage = _prefs.getInt('preview_page') ?? 1;
    _includeTranslation = _prefs.getBool('include_translation') ?? false;
    _includeWbw = _prefs.getBool('include_wbw') ?? false;
    _selectedWbwLanguage = _prefs.getString('wbw_language') ?? 'en';
    _selectedTranslationKey = _prefs.getString('translation_key');
    _prefaceBlankPages = _prefs.getInt('preface_blank_pages') ?? 1;
    _coverBackgroundColor =
        _prefs.getString('cover_background_color') ?? '#1a472a';
    _justifyTranslation = _prefs.getBool('justify_translation') ?? false;
    _outputFormat = _prefs.getString('output_format') ?? 'HTML';
    _dpi = _prefs.getInt('dpi') ?? 300;
    _showDecorations = _prefs.getBool('show_decorations') ?? true;
    _baseTextColor = _prefs.getString('base_text_color') ?? '#000000';
  }

  Future<void> _saveSettings() async {
    await _prefs.setString(
        'selected_page_size', json.encode(_selectedPageSize.toJson()));
    await _prefs.setStringList('custom_presets',
        _customPresets.map((p) => json.encode(p.toJson())).toList());
    await _prefs.setInt('start_page', _startPage);
    await _prefs.setInt('end_page', _endPage);
    await _prefs.setInt('preview_page', _previewPage);
    await _prefs.setBool('include_translation', _includeTranslation);
    await _prefs.setBool('include_wbw', _includeWbw);
    await _prefs.setString('wbw_language', _selectedWbwLanguage);
    if (_selectedTranslationKey != null) {
      await _prefs.setString('translation_key', _selectedTranslationKey!);
    }
    await _prefs.setInt('preface_blank_pages', _prefaceBlankPages);
    await _prefs.setString('cover_background_color', _coverBackgroundColor);
    await _prefs.setBool('justify_translation', _justifyTranslation);
    await _prefs.setString('output_format', _outputFormat);
    await _prefs.setInt('dpi', _dpi);
    await _prefs.setBool('show_decorations', _showDecorations);
    await _prefs.setString('base_text_color', _baseTextColor);
  }

  Future<void> _showSavePresetDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Preset'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            hintText: 'e.g. My Custom A4',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      setState(() {
        final newPreset = _selectedPageSize.copyWith(name: name);
        _customPresets.add(newPreset);
        _selectedPageSize = newPreset;
      });
      await _saveSettings();
    }
  }

  Future<void> _deletePreset(PageSize preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _customPresets.removeWhere((p) => p.name == preset.name);
      });
      await _saveSettings();
    }
  }

  void _showHelpDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required num value,
    required ValueChanged<num> onChanged,
    bool isDecimal = false,
    String? helpText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _NumberInput(
        label: label,
        value: value,
        isDecimal: isDecimal,
        enabled: enabled,
        onChanged: (v) {
          onChanged(v);
          _saveSettings();
        },
        suffix: helpText != null
            ? IconButton(
                icon: const Icon(Icons.help_outline, size: 18),
                onPressed: () => _showHelpDialog(label, helpText),
                tooltip: 'Help',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    String? helpText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _TextInput(
        label: label,
        value: value,
        enabled: enabled,
        onChanged: (v) {
          onChanged(v);
          _saveSettings();
        },
        suffix: helpText != null
            ? IconButton(
                icon: const Icon(Icons.help_outline, size: 18),
                onPressed: () => _showHelpDialog(label, helpText),
                tooltip: 'Help',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            : null,
      ),
    );
  }

  Future<void> _loadWbwLanguages() async {
    try {
      final langs = await MushafWbwService.fetchAvailableLanguages();
      if (mounted) {
        setState(() {
          _availableWbwLanguages = langs;
          // If current selection is not in the new list, reset to first available
          if (langs.isNotEmpty && !langs.contains(_selectedWbwLanguage)) {
            _selectedWbwLanguage = langs.contains('en') ? 'en' : langs.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading WBW languages: $e');
    }
  }

  Future<void> _loadTranslations() async {
    try {
      final apiTranslations = await _translationService.fetchTranslations();
      final localTranslations =
          await _localTranslationService.getLocalTranslations();

      final allTranslations = [...localTranslations, ...apiTranslations];

      if (allTranslations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to fetch translations. Check your connection and local resources.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      _availableTranslations = allTranslations;
      _selectedTranslationKey = _selectedTranslationKey ??
          (allTranslations.isNotEmpty ? allTranslations.first.key : null);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading translations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // No margin controllers to dispose (margins are per-PageSize)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_outputFormat == 'HTML'
            ? 'Mushaf HTML Generator'
            : 'Mushaf Image Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Output Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Output Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Format: '),
                        const SizedBox(width: 8),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                                value: 'HTML',
                                label: Text('HTML (PDF)'),
                                icon: Icon(Icons.html)),
                            ButtonSegment(
                                value: 'PNG',
                                label: Text('PNG + Coordinates'),
                                icon: Icon(Icons.image)),
                          ],
                          selected: {_outputFormat},
                          onSelectionChanged: (val) {
                            setState(() {
                              _outputFormat = val.first;
                              _saveSettings();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions Card
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _outputFormat == 'HTML'
                                ? 'How to generate PDF'
                                : 'How to generate Images',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _outputFormat == 'HTML'
                                ? '1. Configure your layout and click "Generate HTML".\n'
                                    '2. The file will open automatically in your browser.\n'
                                    '3. Use your browser\'s "Print" feature (Ctrl+P / Cmd+P) and select "Save as PDF".\n'
                                    '4. Ensure "Background graphics" is enabled in print settings for correct colors.'
                                : '1. Configure your image resolution (DPI).\n'
                                    '2. Click "Generate" to render PNG files.\n'
                                    '3. The folder containing the images and glyphs.db will open automatically.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Page size selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Layout & Typography',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: _showSavePresetDialog,
                              icon: const Icon(Icons.save_alt),
                              label: const Text('Save as Preset'),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<PageSize>(
                              onSelected: (preset) {
                                setState(() {
                                  _selectedPageSize = preset;
                                  _saveSettings();
                                });
                              },
                              itemBuilder: (context) => [
                                ...PageSize.presets
                                    .map((p) => PopupMenuItem<PageSize>(
                                          value: p,
                                          child: Text('Load ${p.name} Preset'),
                                        )),
                                if (_customPresets.isNotEmpty) ...[
                                  const PopupMenuDivider(),
                                  ..._customPresets.map((p) =>
                                      PopupMenuItem<PageSize>(
                                        value: p,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child:
                                                    Text('Custom: ${p.name}')),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: Colors.red),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deletePreset(p);
                                              },
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ],
                              child: const Chip(
                                label: Text('Load Preset'),
                                avatar: Icon(Icons.settings_backup_restore,
                                    size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Page Dimensions',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Width (mm)',
                                value: _selectedPageSize.widthMm,
                                helpText:
                                    'Physical width of the page in millimeters.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(widthMm: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Height (mm)',
                                value: _selectedPageSize.heightMm,
                                helpText:
                                    'Physical height of the page in millimeters.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(heightMm: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Padding (mm)',
                                value: _selectedPageSize.paddingMm,
                                helpText:
                                    'Internal padding between the page edge and the content area.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(paddingMm: v.toInt())))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Preface Blank Pages',
                                value: _prefaceBlankPages,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Number of blank pages to insert after the cover.',
                                onChanged: (v) => setState(() {
                                      _prefaceBlankPages = v.toInt();
                                      _saveSettings();
                                    }))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextInput(
                                label: 'Cover Color (Hex)',
                                value: _coverBackgroundColor,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Background color for the cover page (e.g. #1a472a).',
                                onChanged: (v) => setState(() {
                                      _coverBackgroundColor = v;
                                      _saveSettings();
                                    }))),
                        if (_outputFormat == 'PNG') ...[
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildNumberInput(
                                  label: 'Resolution (DPI)',
                                  value: _dpi,
                                  helpText:
                                      'Dots Per Inch. Higher values produce larger, higher-quality images.',
                                  onChanged: (v) => setState(() {
                                        _dpi = v.toInt();
                                        _saveSettings();
                                      }))),
                        ],
                      ],
                    ),
                    if (_outputFormat == 'PNG') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextInput(
                              label: 'Base Text Color (Hex)',
                              value: _baseTextColor,
                              helpText:
                                  'Text color for all non-colored text (e.g. #FFFFFF for White, #000000 for Black). Works in PNG mode.',
                              onChanged: (val) {
                                setState(() {
                                  _baseTextColor = val;
                                  _saveSettings();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Spacer(),
                          const SizedBox(width: 12),
                          const Spacer(),
                        ],
                      ),
                      SwitchListTile(
                        title: const Text('Show Page Header & Legend'),
                        subtitle: const Text(
                            'Includes surah name, page number, juz and tajweed color key'),
                        value: _showDecorations,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setState(() {
                            _showDecorations = val;
                            _saveSettings();
                          });
                        },
                      ),
                    ],
                    const Divider(),
                    const Text('Arabic Typography',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Font Size (px)',
                                value: _selectedPageSize.fontSize,
                                helpText:
                                    'Base size for the Arabic text in pixels.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(fontSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Line Height',
                                value: _selectedPageSize.lineHeight,
                                isDecimal: true,
                                helpText:
                                    'Vertical spacing between lines of Arabic text.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(lineHeight: v.toDouble())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Word Spacing',
                                value: _selectedPageSize.wordSpacing,
                                isDecimal: true,
                                helpText:
                                    'Horizontal spacing between Arabic words in em.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(wordSpacing: v.toDouble())))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Surah Header (px)',
                                value: _selectedPageSize.surahFontSize,
                                helpText:
                                    'Font size for the Surah name headers.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(surahFontSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Ayah Number (px)',
                                value: _selectedPageSize.ayaNumberFontSize,
                                helpText: 'Font size for the Ayah end markers.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            ayaNumberFontSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Page Header (px)',
                                value: _selectedPageSize.headerFontSize,
                                helpText:
                                    'Font size for the text at the top of the page (Surah name, page number, Juz).',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(headerFontSize: v.toInt())))),
                      ],
                    ),
                    const Divider(),
                    const Text('Margins (mm)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Gutter (Inner)',
                                value: _selectedPageSize.margins.gutterMm,
                                isDecimal: true,
                                helpText:
                                    'Margin on the binding side of the page (alternates left/right).',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(
                                            margins: _selectedPageSize.margins
                                                .copyWith(
                                                    gutterMm: v.toDouble()))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Outer',
                                value: _selectedPageSize.margins.outerMm,
                                isDecimal: true,
                                helpText:
                                    'Margin on the outside edge of the page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(
                                            margins: _selectedPageSize.margins
                                                .copyWith(
                                                    outerMm: v.toDouble()))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Top',
                                value: _selectedPageSize.margins.topMm,
                                isDecimal: true,
                                helpText: 'Margin at the top of the page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(
                                            margins: _selectedPageSize.margins
                                                .copyWith(
                                                    topMm: v.toDouble()))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Bottom',
                                value: _selectedPageSize.margins.bottomMm,
                                isDecimal: true,
                                helpText: 'Margin at the bottom of the page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(
                                            margins: _selectedPageSize.margins
                                                .copyWith(
                                                    bottomMm: v.toDouble()))))),
                      ],
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Include translation (outer column)'),
                      subtitle: _outputFormat == 'PNG'
                          ? const Text(
                              'Translation column is only supported in HTML format',
                              style: TextStyle(color: Colors.orange))
                          : null,
                      value: _includeTranslation && _outputFormat == 'HTML',
                      contentPadding: EdgeInsets.zero,
                      onChanged: _outputFormat == 'PNG'
                          ? null
                          : (val) {
                              setState(() {
                                _includeTranslation = val;
                                if (_includeTranslation &&
                                    _selectedTranslationKey == null) {
                                  _selectedTranslationKey =
                                      _availableTranslations.isNotEmpty
                                          ? _availableTranslations.first.key
                                          : 'english_saheeh';
                                }
                              });
                            },
                    ),
                    if (_includeTranslation && _outputFormat == 'HTML') ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedTranslationKey,
                        decoration: const InputDecoration(
                          labelText: 'Translation source',
                          border: OutlineInputBorder(),
                        ),
                        items: _availableTranslations
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.key,
                                child: Text('${t.name} (${t.language})'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedTranslationKey = val;
                          });
                        },
                      ),
                      if (_availableTranslations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'No translations fetched; using fallback if available.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                    const Text('Translation Column',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Width Fraction',
                                value: _selectedPageSize
                                    .translationWidthFraction,
                                isDecimal: true,
                                enabled: _includeTranslation &&
                                    _outputFormat == 'HTML',
                                helpText:
                                    'Percentage of page width allocated to the translation column.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            translationWidthFraction:
                                                v.toDouble())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Arabic Scale',
                                value: _selectedPageSize.translationArabicScale,
                                isDecimal: true,
                                enabled: _includeTranslation &&
                                    _outputFormat == 'HTML',
                                helpText:
                                    'How much to shrink the Arabic text when translation is enabled.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            translationArabicScale:
                                                v.toDouble())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Font Size (px)',
                                value: _selectedPageSize.translationFontSize,
                                enabled: _includeTranslation &&
                                    _outputFormat == 'HTML',
                                helpText:
                                    'Size of the translation text in pixels.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            translationFontSize: v.toInt())))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Line Height',
                                value: _selectedPageSize.translationLineHeight,
                                isDecimal: true,
                                enabled: _includeTranslation &&
                                    _outputFormat == 'HTML',
                                helpText:
                                    'Spacing between lines of translation text.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            translationLineHeight:
                                                v.toDouble())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Compact Threshold',
                                value: _selectedPageSize
                                    .translationCompactThreshold,
                                enabled: _includeTranslation &&
                                    _outputFormat == 'HTML',
                                helpText:
                                    'Character count above which translation switches to inline mode.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            translationCompactThreshold:
                                                v.toInt())))),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Justify translation text'),
                      value: _justifyTranslation,
                      contentPadding: EdgeInsets.zero,
                      onChanged:
                          (_includeTranslation && _outputFormat == 'HTML')
                              ? (val) {
                                  setState(() {
                                    _justifyTranslation = val;
                                    _saveSettings();
                                  });
                                }
                              : null,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Include word-by-word translation'),
                      subtitle: const Text(
                          'Displays translation under each Arabic word'),
                      value: _includeWbw,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          _includeWbw = val;
                        });
                      },
                    ),
                    if (_includeWbw) ...[
                      const SizedBox(height: 8),
                      if (_availableWbwLanguages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No WBW languages found in CSV.',
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _selectedWbwLanguage,
                          decoration: const InputDecoration(
                            labelText: 'WBW Language',
                            border: OutlineInputBorder(),
                          ),
                          items: _availableWbwLanguages
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(
                                      MushafWbwService.getLanguageName(lang)),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedWbwLanguage = val;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'WBW translations contributed by Greentech Apps Foundation',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text('Word-by-Word',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Font Size (px)',
                                value: _selectedPageSize.wbwFontSize,
                                enabled: _includeWbw,
                                helpText:
                                    'Size of the word-by-word translation text in pixels.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(wbwFontSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Arabic Scale',
                                value: _selectedPageSize.wbwArabicScale,
                                isDecimal: true,
                                enabled: _includeWbw,
                                helpText:
                                    'How much to shrink the Arabic text when word-by-word translation is enabled.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            wbwArabicScale: v.toDouble())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Arabic Line Height',
                                value: _selectedPageSize.wbwArabicLineHeight,
                                isDecimal: true,
                                enabled: _includeWbw,
                                helpText:
                                    'Line height for the Arabic text when word-by-word translation is enabled.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            wbwArabicLineHeight:
                                                v.toDouble())))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Trans. Line Height',
                                value: _selectedPageSize
                                    .wbwTranslationLineHeight,
                                isDecimal: true,
                                enabled: _includeWbw,
                                helpText:
                                    'Line height for the word-by-word translation text.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            wbwTranslationLineHeight:
                                                v.toDouble())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Max Width (mm)',
                                value: _selectedPageSize.wbwMaxWidthMm,
                                isDecimal: true,
                                enabled: _includeWbw,
                                helpText:
                                    'Maximum width allowed for a single word-by-word block in millimeters.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            wbwMaxWidthMm: v.toDouble())))),
                      ],
                    ),
                    const Divider(),
                    const Text('Legend & TOC',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Legend Font (px)',
                                value: _selectedPageSize.legendFontSize,
                                helpText:
                                    'Font size for the Tajweed color legend text.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(legendFontSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Legend Color Size',
                                value: _selectedPageSize.legendColorSize,
                                helpText:
                                    'Size of the color boxes in the Tajweed legend.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            legendColorSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Legend Gap',
                                value: _selectedPageSize.legendGap,
                                helpText:
                                    'Spacing between different items in the Tajweed legend.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(legendGap: v.toInt())))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Legend Item Gap',
                                value: _selectedPageSize.legendItemGap,
                                helpText:
                                    'Spacing between the color box and the label within a legend item.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(legendItemGap: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'Legend Padding',
                                value: _selectedPageSize.legendPadding,
                                helpText: 'Top padding for the legend section.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(legendPadding: v.toInt())))),
                        const SizedBox(width: 12),
                        const Spacer(),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildNumberInput(
                                label: 'TOC Font (px)',
                                value: _selectedPageSize.tocFontSize,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Font size for the Table of Contents entries.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize = _selectedPageSize
                                        .copyWith(tocFontSize: v.toInt())))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildNumberInput(
                                label: 'TOC Entries/Page',
                                value: _selectedPageSize.tocEntriesPerPage,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Number of Surah entries to display per page in the Table of Contents.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            tocEntriesPerPage: v.toInt())))),
                      ],
                    ),
                    const Divider(),
                    const Text('Custom Text',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextInput(
                                label: 'Cover Title',
                                value: _selectedPageSize.textConfig.coverTitle,
                                enabled: _outputFormat == 'HTML',
                                helpText: 'Main title on the cover page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            textConfig: _selectedPageSize
                                                .textConfig
                                                .copyWith(coverTitle: v))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextInput(
                                label: 'Cover Subtitle',
                                value: _selectedPageSize
                                    .textConfig.coverSubtitle,
                                enabled: _outputFormat == 'HTML',
                                helpText: 'Subtitle on the cover page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            textConfig: _selectedPageSize
                                                .textConfig
                                                .copyWith(coverSubtitle: v))))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextInput(
                                label: 'TOC Title',
                                value: _selectedPageSize.textConfig.tocTitle,
                                enabled: _outputFormat == 'HTML',
                                helpText: 'Title for the Table of Contents.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            textConfig: _selectedPageSize
                                                .textConfig
                                                .copyWith(tocTitle: v))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextInput(
                                label: 'Blank Page Text',
                                value: _selectedPageSize
                                    .textConfig.blankPageText,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Text displayed on the intentionally blank page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            textConfig: _selectedPageSize
                                                .textConfig
                                                .copyWith(blankPageText: v))))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextInput(
                                label: 'Translation Label',
                                value: _selectedPageSize
                                    .textConfig.translationLabel,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Label for the translation on the cover page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            textConfig: _selectedPageSize
                                                .textConfig
                                                .copyWith(
                                                    translationLabel: v))))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildTextInput(
                                label: 'WBW Label',
                                value: _selectedPageSize.textConfig.wbwLabel,
                                enabled: _outputFormat == 'HTML',
                                helpText:
                                    'Label for the word-by-word translation on the cover page.',
                                onChanged: (v) => setState(() =>
                                    _selectedPageSize =
                                        _selectedPageSize.copyWith(
                                            textConfig: _selectedPageSize
                                                .textConfig
                                                .copyWith(wbwLabel: v))))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Page Range & Preview Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generation Controls',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    // Preview Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Preview Page',
                            value: _previewPage,
                            helpText:
                                'The specific page to show when clicking the Preview button.',
                            onChanged: (v) => _previewPage = v.toInt(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isGenerating
                              ? null
                              : () => _generateHtml(isPreview: true),
                          icon: const Icon(Icons.remove_red_eye),
                          label: const Text('Preview'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Start/End Page Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberInput(
                            label: 'Start Page',
                            value: _startPage,
                            helpText:
                                'The first page of the Quran to include in the generated HTML.',
                            onChanged: (v) => _startPage = v.toInt(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberInput(
                            label: 'End Page',
                            value: _endPage,
                            helpText:
                                'The last page of the Quran to include in the generated HTML.',
                            onChanged: (v) => _endPage = v.toInt(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quran Mushaf has 604 pages total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate button
            Center(
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateHtml,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.file_download),
                label: Text(_isGenerating ? 'Generating...' : 'Generate'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress and status
            if (_isGenerating || _statusMessage.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_isGenerating && _totalPages > 0) ...[
                        LinearProgressIndicator(
                          value: _currentPage / _totalPages,
                        ),
                        const SizedBox(height: 8),
                        Text('Processing page $_currentPage of $_totalPages'),
                      ] else if (_statusMessage.isNotEmpty &&
                          !_isGenerating) ...[
                        const SizedBox(height: 8),
                        Text(_statusMessage),
                      ],
                    ],
                  ),
                ),
              ),

            // Output path
            if (_outputPath != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            _outputFormat == 'HTML'
                                ? 'HTML Generated Successfully!'
                                : 'Images Generated Successfully!',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        'Saved to: $_outputPath',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _openOutputFolder,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Open Folder'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Tajweed color legend
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tajweed Color Legend',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: const [
                        _ColorLegendItem(
                            color: Color(0xFF4CAF50), label: 'Lafzatullah'),
                        _ColorLegendItem(
                            color: Color(0xFF06B0B6), label: 'Izhar'),
                        _ColorLegendItem(
                            color: Color(0xFFB71C1C), label: 'Ikhfaa'),
                        _ColorLegendItem(
                            color: Color(0xFFF06292),
                            label: 'Idgham w/ Ghunna'),
                        _ColorLegendItem(
                            color: Color(0xFF2196F3), label: 'Iqlab'),
                        _ColorLegendItem(
                            color: Color(0xFF7B8F0A), label: 'Qalqala'),
                        _ColorLegendItem(
                            color: Color(0xFFFF9800), label: 'Ghunna'),
                        _ColorLegendItem(
                            color: Color(0xFF8E64D6), label: 'Prolonging'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateHtml({bool isPreview = false}) async {
    final start = isPreview ? _previewPage : _startPage;
    final end = isPreview ? _previewPage : _endPage;

    setState(() {
      _isGenerating = true;
      _statusMessage = 'Initializing databases...';
      _currentPage = 0;
      _totalPages = end - start + 1;
      _outputPath = null;
    });

    try {
      // Initialize databases
      await MushafDbInitializer.initialize();

      setState(() {
        _statusMessage = 'Opening databases...';
      });

      // Open database reader
      final dbReader = MushafDbReader();
      await dbReader.open();

      setState(() {
        _statusMessage = _outputFormat == 'HTML'
            ? 'Generating HTML...'
            : 'Generating PNGs...';
      });

      // Save to documents directory
      final docsDir = await getApplicationDocumentsDirectory();
      final mushafDir = Directory('${docsDir.path}/Mushafs');
      if (!await mushafDir.exists()) {
        await mushafDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String? outputFile;

      if (_outputFormat == 'HTML') {
        // Get selected translation name and language for cover page and surah headers
        String? translationName;
        String? translationLanguage;
        if (_includeTranslation && _selectedTranslationKey != null) {
          try {
            final info = _availableTranslations.firstWhere(
              (t) => t.key == _selectedTranslationKey,
            );
            translationName = '${info.name} (${info.language})';
            translationLanguage = info.language.toLowerCase();
          } catch (_) {
            translationName = _selectedTranslationKey;
            translationLanguage = 'en'; // fallback to English
          }
        }

        // Generate HTML using margins preset for selected PageSize
        final generator = MushafHtmlGenerator(
          dbReader,
          pageSize: _selectedPageSize,
          prefaceBlankPages: _prefaceBlankPages,
          coverBackgroundColor: _coverBackgroundColor,
          justifyTranslation: _justifyTranslation,
          includeTranslation: _includeTranslation,
          includeWbw: _includeWbw,
          wbwLanguage: _includeWbw ? _selectedWbwLanguage : null,
          wbwLanguageName: _includeWbw
              ? MushafWbwService.getLanguageName(_selectedWbwLanguage)
              : null,
          translationKey: _selectedTranslationKey,
          translationName: translationName,
          translationLanguage: translationLanguage,
          translationService: _includeTranslation ? _translationService : null,
          localTranslationService:
              _includeTranslation ? _localTranslationService : null,
        );
        final html = await generator.generateHtml(
          startPage: start,
          endPage: end,
          onProgress: (current, total) {
            setState(() {
              _currentPage = current;
              _totalPages = total;
              _statusMessage = 'Processing page $current of $total...';
            });
          },
        );

        setState(() {
          _statusMessage = 'Saving file...';
        });

        final prefix = isPreview
            ? 'preview_page_${start}'
            : 'mushaf_${_selectedPageSize.name}_pages_${start}_to_${end}';
        final fileName = '${prefix}_$timestamp.html';
        final file = File('${mushafDir.path}/$fileName');
        await file.writeAsString(html);
        outputFile = file.path;
      } else {
        // Generate PNGs
        final prefix = isPreview
            ? 'preview_image_${start}'
            : 'mushaf_${_selectedPageSize.name}_batch_${start}_to_${end}';
        final batchFolderName = '${prefix}_$timestamp';
        final batchDir = Directory('${mushafDir.path}/$batchFolderName');

        final generator = MushafImageGenerator(
          dbReader,
          pageSize: _selectedPageSize,
          dpi: _dpi,
          includeWbw: _includeWbw,
          wbwLanguage: _includeWbw ? _selectedWbwLanguage : null,
          showDecorations: _showDecorations,
          baseTextColor: _baseTextColor,
        );

        await generator.generateImages(
          startPage: start,
          endPage: end,
          outputDir: batchDir.path,
          onProgress: (current, total) {
            setState(() {
              _currentPage = current;
              _totalPages = total;
              _statusMessage = 'Rendering image $current of $total...';
            });
          },
        );
        outputFile = batchDir.path;
      }

      // Close database
      await dbReader.close();

      setState(() {
        _isGenerating = false;
        _statusMessage = 'Completed successfully!';
        _outputPath = outputFile;
      });

      // Open the generated file/folder in browser
      if (_outputFormat == 'HTML') {
        _openFileInBrowser(outputFile);
      } else {
        _openOutputFolder();
      }
    } catch (e) {
      debugPrint('Generation Error: $e');
      setState(() {
        _isGenerating = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  void _openFileInBrowser(String filePath) {
    if (Platform.isMacOS) {
      Process.run('open', [filePath]);
    } else if (Platform.isWindows) {
      Process.run('cmd', ['/c', 'start', '', filePath]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [filePath]);
    }
  }

  void _openOutputFolder() {
    if (_outputPath == null) return;

    final folder = FileSystemEntity.isDirectorySync(_outputPath!)
        ? _outputPath!
        : File(_outputPath!).parent.path;

    if (Platform.isMacOS) {
      Process.run('open', [folder]);
    } else if (Platform.isWindows) {
      Process.run('explorer.exe', [folder]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [folder]);
    }
  }
}

class _ColorLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _NumberInput extends StatefulWidget {
  final String label;
  final num value;
  final ValueChanged<num> onChanged;
  final bool isDecimal;
  final Widget? suffix;
  final bool enabled;

  const _NumberInput({
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDecimal = false,
    this.suffix,
    this.enabled = true,
  });

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if the value changed from outside (e.g. preset loaded)
    // and it's different from what's currently being typed
    if (widget.value != oldWidget.value) {
      final currentVal = widget.isDecimal
          ? double.tryParse(_controller.text)
          : int.tryParse(_controller.text);
      if (widget.value != currentVal) {
        _controller.text = widget.value.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: widget.suffix,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
      controller: _controller,
      onChanged: (val) {
        final parsed =
            widget.isDecimal ? double.tryParse(val) : int.tryParse(val);
        if (parsed != null) {
          widget.onChanged(parsed);
        }
      },
    );
  }
}

class _TextInput extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final Widget? suffix;
  final bool enabled;

  const _TextInput({
    required this.label,
    required this.value,
    required this.onChanged,
    this.suffix,
    this.enabled = true,
  });

  @override
  State<_TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<_TextInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: widget.suffix,
      ),
      controller: _controller,
      onChanged: widget.onChanged,
    );
  }
}
