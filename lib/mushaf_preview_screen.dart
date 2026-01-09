import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'mushaf_db_initializer.dart';
import 'mushaf_db_reader.dart';
import 'mushaf_html_generator.dart';
import 'mushaf_image_generator.dart';
import 'mushaf_page_config.dart';
import 'tajweed_rule.dart';
import 'tajweed_color_mapper.dart';
import 'quran_enc_translation_service.dart';
import 'mushaf_wbw_service.dart';
import 'local_translation_service.dart';
import 'tanzil_translation_service.dart';

import 'package:mushaf_generator/ui/screens/mushaf_preview/tabs/general_labels_tab.dart';
import 'package:mushaf_generator/ui/screens/mushaf_preview/tabs/layout_typography_tab.dart';
import 'package:mushaf_generator/ui/screens/mushaf_preview/tabs/translation_tab.dart';
import 'package:mushaf_generator/ui/screens/mushaf_preview/tabs/colors_tab.dart';
import 'package:mushaf_generator/ui/screens/mushaf_preview/tabs/localization_tab.dart';
import 'package:mushaf_generator/ui/widgets/custom_inputs.dart';

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

  // Translation source configuration
  // Options: 'QuranEnc', 'Tarteel', 'Tanzil'
  String _translationSource = 'QuranEnc';
  String? _tarteelFilePath;
  String? _tanzilFilePath;

  List<TranslationInfo> _availableTranslations = const [];
  final QuranEncTranslationService _translationService =
      QuranEncTranslationService();
  final LocalTranslationService _localTranslationService =
      LocalTranslationService();
  final TanzilTranslationService _tanzilTranslationService =
      TanzilTranslationService();

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

  // Tajweed color customization
  Map<TajweedRule, String> _tajweedColors = {};
  Map<TajweedRule, bool> _tajweedHighlighting = {};

  // Custom Localization
  Map<int, String> _customSurahNames = {};
  Map<String, String> _customLocalizedLabels = {};

  // Cover & Layout settings
  int _prefaceBlankPages = 1;
  bool _startOnRightSide = true;
  String _coverBackgroundColor = '#1a472a'; // Default green
  bool _justifyTranslation = false;

  // Text Labels & Titles
  String _coverTitle = 'ٱلْقُرْآنُ ٱلْكَرِيمُ';
  String _coverSubtitle = 'The Noble Quran';
  String _tocTitle = 'Table of Contents';
  String _blankPageText = 'This page is intentionally left blank';
  String _translationLabel = 'Translation';
  String _wbwLabel = 'Word by Word';

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
    _translationSource = _prefs.getString('translation_source') ?? 'QuranEnc';
    _includeWbw = _prefs.getBool('include_wbw') ?? false;
    _selectedWbwLanguage = _prefs.getString('wbw_language') ?? 'en';
    _selectedTranslationKey = _prefs.getString('translation_key');
    _prefaceBlankPages = _prefs.getInt('preface_blank_pages') ?? 1;
    _startOnRightSide = _prefs.getBool('start_on_right_side') ?? true;
    _coverBackgroundColor =
        _prefs.getString('cover_background_color') ?? '#1a472a';
    _justifyTranslation = _prefs.getBool('justify_translation') ?? false;
    _outputFormat = _prefs.getString('output_format') ?? 'HTML';
    _dpi = _prefs.getInt('dpi') ?? 300;
    _showDecorations = _prefs.getBool('show_decorations') ?? true;
    _baseTextColor = _prefs.getString('base_text_color') ?? '#000000';

    // Load text labels
    _coverTitle = _prefs.getString('cover_title') ?? 'ٱلْقُرْآنُ ٱلْكَرِيمُ';
    _coverSubtitle = _prefs.getString('cover_subtitle') ?? 'The Noble Quran';
    _tocTitle = _prefs.getString('toc_title') ?? 'Table of Contents';
    _blankPageText = _prefs.getString('blank_page_text') ??
        'This page is intentionally left blank';
    _translationLabel = _prefs.getString('translation_label') ?? 'Translation';
    _wbwLabel = _prefs.getString('wbw_label') ?? 'Word by Word';

    // Load tajweed custom colors
    _tajweedColors = Map.from(defaultTajweedColors);
    final savedColors = _prefs.getString('tajweed_colors');
    if (savedColors != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(savedColors);
        decoded.forEach((key, value) {
          try {
            final rule = TajweedRule.values.firstWhere((r) => r.name == key);
            _tajweedColors[rule] = value as String;
          } catch (_) {}
        });
      } catch (_) {}
    }

    // Load tajweed highlighting
    _tajweedHighlighting = {for (var r in TajweedRule.values) r: true};
    final savedHighlighting = _prefs.getString('tajweed_highlighting');
    if (savedHighlighting != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(savedHighlighting);
        decoded.forEach((key, value) {
          try {
            final rule = TajweedRule.values.firstWhere((r) => r.name == key);
            _tajweedHighlighting[rule] = value as bool;
          } catch (_) {}
        });
      } catch (_) {}
    }

    // Load custom localization
    final savedSurahNames = _prefs.getString('custom_surah_names');
    if (savedSurahNames != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(savedSurahNames);
        _customSurahNames =
            decoded.map((k, v) => MapEntry(int.parse(k), v as String));
      } catch (_) {}
    }

    final savedLocalizedLabels = _prefs.getString('custom_localized_labels');
    if (savedLocalizedLabels != null) {
      try {
        _customLocalizedLabels =
            Map<String, String>.from(json.decode(savedLocalizedLabels));
      } catch (_) {}
    }
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
    await _prefs.setString('translation_source', _translationSource);
    await _prefs.setBool('include_wbw', _includeWbw);
    await _prefs.setString('wbw_language', _selectedWbwLanguage);
    if (_selectedTranslationKey != null) {
      await _prefs.setString('translation_key', _selectedTranslationKey!);
    }
    await _prefs.setInt('preface_blank_pages', _prefaceBlankPages);
    await _prefs.setBool('start_on_right_side', _startOnRightSide);
    await _prefs.setString('cover_background_color', _coverBackgroundColor);
    await _prefs.setBool('justify_translation', _justifyTranslation);
    await _prefs.setString('output_format', _outputFormat);
    await _prefs.setInt('dpi', _dpi);
    await _prefs.setBool('show_decorations', _showDecorations);
    await _prefs.setString('base_text_color', _baseTextColor);

    // Save text labels
    await _prefs.setString('cover_title', _coverTitle);
    await _prefs.setString('cover_subtitle', _coverSubtitle);
    await _prefs.setString('toc_title', _tocTitle);
    await _prefs.setString('blank_page_text', _blankPageText);
    await _prefs.setString('translation_label', _translationLabel);
    await _prefs.setString('wbw_label', _wbwLabel);

    // Save tajweed custom colors
    final colorsToSave = _tajweedColors.map((k, v) => MapEntry(k.name, v));
    await _prefs.setString('tajweed_colors', json.encode(colorsToSave));

    // Save tajweed highlighting
    final highlightingToSave =
        _tajweedHighlighting.map((k, v) => MapEntry(k.name, v));
    await _prefs.setString(
        'tajweed_highlighting', json.encode(highlightingToSave));

    // Save custom localization
    final surahNamesToSave = _customSurahNames
        .map((k, v) => MapEntry(k.toString(), v)); // JSON keys must be strings
    await _prefs.setString('custom_surah_names', json.encode(surahNamesToSave));
    await _prefs.setString(
        'custom_localized_labels', json.encode(_customLocalizedLabels));
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

      if (apiTranslations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Failed to fetch translations. Check your connection.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      _availableTranslations = apiTranslations;
      _selectedTranslationKey = _selectedTranslationKey ??
          (apiTranslations.isNotEmpty ? apiTranslations.first.key : null);
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

  Future<void> _pickTranslationFile(String source) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: source == 'Tarteel' ? ['db', 'sqlite'] : ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      bool isValid = false;

      if (source == 'Tarteel') {
        isValid = await _localTranslationService.verifyFile(path);
      } else {
        isValid = await _tanzilTranslationService.verifyFile(path);
      }

      if (isValid) {
        setState(() {
          if (source == 'Tarteel') {
            _tarteelFilePath = path;
          } else {
            _tanzilFilePath = path;
          }
        });
        await _saveSettings();
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Invalid File'),
              content: const Text(
                  'The selected file does not contain exactly 6236 ayahs. Please select a valid translation file.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
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
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_outputFormat == 'HTML'
              ? 'Mushaf HTML Generator'
              : 'Mushaf Image Generator'),
        ),
        body: Column(
          children: [
            _buildHeader(),
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 8),
                        Text('General & Labels'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.design_services, size: 20),
                        SizedBox(width: 8),
                        Text('Layout & Typography'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.translate, size: 20),
                        SizedBox(width: 8),
                        Text('Translation & WBW'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.palette, size: 20),
                        SizedBox(width: 8),
                        Text('Colors'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.language, size: 20),
                        SizedBox(width: 8),
                        Text('Localization'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  GeneralLabelsTab(
                    coverTitle: _coverTitle,
                    onCoverTitleChanged: (val) {
                      setState(() {
                        _coverTitle = val;
                        _saveSettings();
                      });
                    },
                    coverSubtitle: _coverSubtitle,
                    onCoverSubtitleChanged: (val) {
                      setState(() {
                        _coverSubtitle = val;
                        _saveSettings();
                      });
                    },
                    tocTitle: _tocTitle,
                    onTocTitleChanged: (val) {
                      setState(() {
                        _tocTitle = val;
                        _saveSettings();
                      });
                    },
                    blankPageText: _blankPageText,
                    onBlankPageTextChanged: (val) {
                      setState(() {
                        _blankPageText = val;
                        _saveSettings();
                      });
                    },
                    translationLabel: _translationLabel,
                    onTranslationLabelChanged: (val) {
                      setState(() {
                        _translationLabel = val;
                        _saveSettings();
                      });
                    },
                    wbwLabel: _wbwLabel,
                    onWbwLabelChanged: (val) {
                      setState(() {
                        _wbwLabel = val;
                        _saveSettings();
                      });
                    },
                    onShowHelp: _showHelpDialog,
                  ),
                  LayoutTypographyTab(
                    selectedPageSize: _selectedPageSize,
                    outputFormat: _outputFormat,
                    prefaceBlankPages: _prefaceBlankPages,
                    startOnRightSide: _startOnRightSide,
                    dpi: _dpi,
                    showDecorations: _showDecorations,
                    onPageSizeChanged: (val) {
                      setState(() {
                        _selectedPageSize = val;
                        _saveSettings();
                      });
                    },
                    onPrefaceBlankPagesChanged: (val) {
                      setState(() {
                        _prefaceBlankPages = val;
                        _saveSettings();
                      });
                    },
                    onStartOnRightSideChanged: (val) {
                      setState(() {
                        _startOnRightSide = val;
                        _saveSettings();
                      });
                    },
                    onDpiChanged: (val) {
                      setState(() {
                        _dpi = val;
                        _saveSettings();
                      });
                    },
                    onShowDecorationsChanged: (val) {
                      setState(() {
                        _showDecorations = val;
                        _saveSettings();
                      });
                    },
                    onShowHelp: _showHelpDialog,
                  ),
                  TranslationTab(
                    selectedPageSize: _selectedPageSize,
                    outputFormat: _outputFormat,
                    includeTranslation: _includeTranslation,
                    translationSource: _translationSource,
                    tarteelFilePath: _tarteelFilePath,
                    tanzilFilePath: _tanzilFilePath,
                    selectedTranslationKey: _selectedTranslationKey,
                    availableTranslations: _availableTranslations,
                    includeWbw: _includeWbw,
                    selectedWbwLanguage: _selectedWbwLanguage,
                    availableWbwLanguages: _availableWbwLanguages,
                    justifyTranslation: _justifyTranslation,
                    onIncludeTranslationChanged: (val) {
                      setState(() {
                        _includeTranslation = val;
                        if (_includeTranslation &&
                            _selectedTranslationKey == null) {
                          _selectedTranslationKey =
                              _availableTranslations.isNotEmpty
                                  ? _availableTranslations.first.key
                                  : 'english_saheeh';
                        }
                        _saveSettings();
                      });
                    },
                    onTranslationSourceChanged: (val) {
                      setState(() {
                        _translationSource = val;
                        _saveSettings();
                      });
                    },
                    onPickFile: _pickTranslationFile,
                    onTranslationKeyChanged: (val) {
                      setState(() {
                        _selectedTranslationKey = val;
                        _saveSettings();
                      });
                    },
                    onIncludeWbwChanged: (val) {
                      setState(() {
                        _includeWbw = val;
                        _saveSettings();
                      });
                    },
                    onWbwLanguageChanged: (val) {
                      setState(() {
                        _selectedWbwLanguage = val;
                        _saveSettings();
                      });
                    },
                    onJustifyTranslationChanged: (val) {
                      setState(() {
                        _justifyTranslation = val;
                        _saveSettings();
                      });
                    },
                    onPageSizeChanged: (val) {
                      setState(() {
                        _selectedPageSize = val;
                        _saveSettings();
                      });
                    },
                    onShowHelp: _showHelpDialog,
                  ),
                  ColorsTab(
                    coverBackgroundColor: _coverBackgroundColor,
                    baseTextColor: _baseTextColor,
                    tajweedColors: _tajweedColors,
                    tajweedHighlighting: _tajweedHighlighting,
                    onCoverBackgroundColorChanged: (val) {
                      setState(() {
                        _coverBackgroundColor = val;
                        _saveSettings();
                      });
                    },
                    onBaseTextColorChanged: (val) {
                      setState(() {
                        _baseTextColor = val;
                        _saveSettings();
                      });
                    },
                    onTajweedColorChanged: (rule, val) {
                      setState(() {
                        _tajweedColors[rule] = val;
                        _saveSettings();
                      });
                    },
                    onTajweedHighlightingChanged: (rule, val) {
                      setState(() {
                        _tajweedHighlighting[rule] = val;
                        _saveSettings();
                      });
                    },
                    onShowHelp: _showHelpDialog,
                    onReset: () {
                      setState(() {
                        _coverBackgroundColor = '#1a472a';
                        _baseTextColor = '#000000';
                        _tajweedColors = Map.from(defaultTajweedColors);
                        _tajweedHighlighting = {
                          for (var r in TajweedRule.values) r: true
                        };
                        _saveSettings();
                      });
                    },
                  ),
                  LocalizationTab(
                    customSurahNames: _customSurahNames,
                    onSurahNamesChanged: (val) {
                      setState(() {
                        _customSurahNames = val;
                        _saveSettings();
                      });
                    },
                    customLocalizedLabels: _customLocalizedLabels,
                    onLocalizedLabelsChanged: (val) {
                      setState(() {
                        _customLocalizedLabels = val;
                        _saveSettings();
                      });
                    },
                    onShowHelp: _showHelpDialog,
                    onReset: () {
                      setState(() {
                        _customSurahNames = {};
                        _customLocalizedLabels = {};
                        _saveSettings();
                      });
                    },
                  ),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          // Output Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Output Format:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
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
                    const VerticalDivider(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration Presets:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _buildPresetControls(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Instructions Card
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 20,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _outputFormat == 'HTML'
                              ? 'How to generate PDF'
                              : 'How to generate Images',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                        ),
                        Text(
                          _outputFormat == 'HTML'
                              ? 'Configure layout and click "Generate HTML". Use browser\'s "Print" -> "Save as PDF" (Enable "Background graphics". Tested with Firefox and Chrome browsers).'
                              : 'Configure resolution (DPI) and click "Generate". The folder containing PNGs and glyphs.db will open.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Range Controls
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    NumberInput(
                      label: 'Preview Page',
                      value: _previewPage,
                      onChanged: (v) => _previewPage = v.toInt(),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating
                            ? null
                            : () => _generateHtml(isPreview: true),
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text('Preview'),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: NumberInput(
                            label: 'Start Page',
                            value: _startPage,
                            onChanged: (v) => _startPage = v.toInt(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NumberInput(
                            label: 'End Page',
                            value: _endPage,
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateHtml,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.file_download),
                        label: Text(_isGenerating
                            ? 'Generating...'
                            : _outputFormat == 'HTML'
                                ? 'Generate HTML'
                                : 'Generate Images'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Preview & Generate
            ],
          ),
          if (_isGenerating || _statusMessage.isNotEmpty || _outputPath != null)
            const SizedBox(height: 16),
          // Progress and Status
          if (_isGenerating || _statusMessage.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isGenerating && _totalPages > 0) ...[
                  LinearProgressIndicator(
                    value: _currentPage / _totalPages,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(_statusMessage,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          // Output path
          if (_outputPath != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    'Saved: $_outputPath',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _openOutputFolder,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Open'),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateHtml({bool isPreview = false}) async {
    // Validate translation file selection for local sources
    if (_includeTranslation) {
      if (_translationSource == 'Tarteel' && _tarteelFilePath == null) {
        _showHelpDialog(
            'File Required', 'Please select a Tarteel SQLite database file.');
        return;
      }
      if (_translationSource == 'Tanzil' && _tanzilFilePath == null) {
        _showHelpDialog('File Required', 'Please select a Tanzil text file.');
        return;
      }
    }

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
        if (_includeTranslation) {
          if (_translationSource == 'QuranEnc' &&
              _selectedTranslationKey != null) {
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
          } else if (_translationSource == 'Tarteel' &&
              _tarteelFilePath != null) {
            translationName = p.basename(_tarteelFilePath!);
            translationLanguage = 'en';
          } else if (_translationSource == 'Tanzil' &&
              _tanzilFilePath != null) {
            translationName = p.basename(_tanzilFilePath!);
            translationLanguage = 'en';
          }
        }

        // Generate HTML using margins preset for selected PageSize
        final generator = MushafHtmlGenerator(
          dbReader,
          pageSize: _selectedPageSize,
          prefaceBlankPages: _prefaceBlankPages,
          startOnRightSide: _startOnRightSide,
          coverBackgroundColor: _coverBackgroundColor,
          baseTextColor: _baseTextColor,
          tajweedColors: _tajweedColors,
          tajweedHighlighting: _tajweedHighlighting,
          justifyTranslation: _justifyTranslation,
          customSurahNames: _customSurahNames,
          customLocalizedLabels: _customLocalizedLabels,
          includeTranslation: _includeTranslation,
          translationSource: _translationSource,
          tarteelFilePath: _tarteelFilePath,
          tanzilFilePath: _tanzilFilePath,
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
          tanzilTranslationService:
              _includeTranslation ? _tanzilTranslationService : null,
          // Labels & Content
          coverTitle: _coverTitle,
          coverSubtitle: _coverSubtitle,
          tocTitle: _tocTitle,
          blankPageText: _blankPageText,
          translationLabel: _translationLabel,
          wbwLabel: _wbwLabel,
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
            ? 'preview_page_$start'
            : 'mushaf_${_selectedPageSize.name}_pages_${start}_to_$end';
        final fileName = '${prefix}_$timestamp.html';
        final file = File('${mushafDir.path}/$fileName');
        await file.writeAsString(html);
        outputFile = file.path;
      } else {
        // Generate PNGs
        final prefix = isPreview
            ? 'preview_image_$start'
            : 'mushaf_${_selectedPageSize.name}_batch_${start}_to_$end';
        final batchFolderName = '${prefix}_$timestamp';
        final batchDir = Directory('${mushafDir.path}/$batchFolderName');

        final generator = MushafImageGenerator(
          dbReader,
          pageSize: _selectedPageSize,
          dpi: _dpi,
          includeWbw: _includeWbw,
          wbwLanguage: _includeWbw ? _selectedWbwLanguage : null,
          showDecorations: _showDecorations,
          startOnRightSide: _startOnRightSide,
          baseTextColor: _baseTextColor,
          tajweedColors: _tajweedColors,
          tajweedHighlighting: _tajweedHighlighting,
          customSurahNames: _customSurahNames,
          customLocalizedLabels: _customLocalizedLabels,
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

  Widget _buildPresetControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: _showSavePresetDialog,
          icon: const Icon(Icons.save_alt, size: 18),
          label: const Text('Save as Preset'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<PageSize>(
          onSelected: (preset) {
            setState(() {
              _selectedPageSize = preset;
              _saveSettings();
            });
          },
          itemBuilder: (context) => [
            ...PageSize.presets.map(
                (p) => PopupMenuItem(value: p, child: Text('Load ${p.name}'))),
            if (_customPresets.isNotEmpty) ...[
              const PopupMenuDivider(),
              ..._customPresets.map((p) => PopupMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Expanded(child: Text('Custom: ${p.name}')),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: Colors.red),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_backup_restore,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Load Preset',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSecondaryContainer),
              ],
            ),
          ),
        ),
      ],
    );
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
