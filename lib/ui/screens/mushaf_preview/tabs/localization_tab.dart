import 'package:flutter/material.dart';
import '../../../../quran_metadata.dart';

class LocalizationTab extends StatefulWidget {
  final Map<int, String> customSurahNames;
  final ValueChanged<Map<int, String>> onSurahNamesChanged;
  final Map<String, String> customLocalizedLabels;
  final ValueChanged<Map<String, String>> onLocalizedLabelsChanged;
  final Function(String, String) onShowHelp;
  final VoidCallback onReset;

  const LocalizationTab({
    super.key,
    required this.customSurahNames,
    required this.onSurahNamesChanged,
    required this.customLocalizedLabels,
    required this.onLocalizedLabelsChanged,
    required this.onShowHelp,
    required this.onReset,
  });

  @override
  State<LocalizationTab> createState() => _LocalizationTabState();
}

class _LocalizationTabState extends State<LocalizationTab> {
  late Map<int, TextEditingController> _surahControllers;
  late Map<String, TextEditingController> _labelControllers;

  Widget _buildHelpIcon(String title, String helpText) {
    return IconButton(
      icon: const Icon(Icons.help_outline, size: 18),
      onPressed: () => widget.onShowHelp(title, helpText),
      tooltip: 'Help',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  // Known tajweed keys to expose
  static const List<Map<String, String>> _ruleKeys = [
    {'key': 'rule_lafzatullah', 'label': 'Lafzatullah'},
    {'key': 'rule_izhar', 'label': 'Izhar'},
    {'key': 'rule_ikhfaa', 'label': 'Ikhfaa'},
    {'key': 'rule_idgham_ghunna', 'label': 'Idgham + Ghunna'},
    {'key': 'rule_idgham', 'label': 'Idgham'},
    {'key': 'rule_iqlab', 'label': 'Iqlab'},
    {'key': 'rule_qalqala', 'label': 'Qalqala'},
    {'key': 'rule_ghunna', 'label': 'Ghunna'},
    {'key': 'rule_madd', 'label': 'Madd (Prolonging)'},
  ];

  @override
  void initState() {
    super.initState();
    _surahControllers = {};
    _labelControllers = {};
    _initControllers();
  }

  @override
  void didUpdateWidget(LocalizationTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the maps changed externally (e.g. reset), update controllers
    if (widget.customSurahNames != oldWidget.customSurahNames) {
      _updateSurahControllers();
    }
    if (widget.customLocalizedLabels != oldWidget.customLocalizedLabels) {
      _updateLabelControllers();
    }
  }

  void _initControllers() {
    // Surahs 1-114
    for (int i = 1; i <= 114; i++) {
      final val = widget.customSurahNames[i] ?? getTranslatedSurahName(i, 'en');
      _surahControllers[i] = TextEditingController(text: val);
    }
    // Rules
    for (final rule in _ruleKeys) {
      final key = rule['key']!;
      final val =
          widget.customLocalizedLabels[key] ?? getLocalizedText(key, 'en');
      _labelControllers[key] = TextEditingController(text: val);
    }
  }

  void _updateSurahControllers() {
    for (int i = 1; i <= 114; i++) {
      final val = widget.customSurahNames[i] ?? getTranslatedSurahName(i, 'en');
      if (_surahControllers[i]?.text != val) {
        _surahControllers[i]?.text = val;
      }
    }
  }

  void _updateLabelControllers() {
    for (final rule in _ruleKeys) {
      final key = rule['key']!;
      final val =
          widget.customLocalizedLabels[key] ?? getLocalizedText(key, 'en');
      if (_labelControllers[key]?.text != val) {
        _labelControllers[key]?.text = val;
      }
    }
  }

  @override
  void dispose() {
    for (var c in _surahControllers.values) c.dispose();
    for (var c in _labelControllers.values) c.dispose();
    super.dispose();
  }

  void _onSurahChanged(int surah, String value) {
    final newMap = Map<int, String>.from(widget.customSurahNames);
    newMap[surah] = value;
    widget.onSurahNamesChanged(newMap);
  }

  void _onLabelChanged(String key, String value) {
    final newMap = Map<String, String>.from(widget.customLocalizedLabels);
    newMap[key] = value;
    widget.onLocalizedLabelsChanged(newMap);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader(
          'Tajweed Rule Names',
          _buildHelpIcon('Tajweed Localization',
              'Customize the labels used for each Tajweed rule in the legend at the bottom of the page. This is useful for translating into other languages.'),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: _ruleKeys
                  .map((r) => _buildLabelField(r['key']!, r['label']!))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(
          'Surah Translation Names',
          _buildHelpIcon('Surah Localization',
              'Customize how Surah names appear in the Table of Contents and Page Headers. By default, these are shown in English transliteration / translation.'),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 114,
            separatorBuilder: (c, i) => const Divider(height: 1),
            itemBuilder: (c, i) {
              final surahNum = i + 1;
              return _buildSurahField(surahNum);
            },
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            onPressed: widget.onReset,
            icon: const Icon(Icons.restore),
            label: const Text('Reset to English Defaults'),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSectionHeader(String title, [Widget? trailing]) {
    return Row(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
        const Expanded(child: Divider(indent: 12)),
      ],
    );
  }

  Widget _buildLabelField(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _labelControllers[key],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => _onLabelChanged(key, val),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahField(int surahNum) {
    final arabicName = surahNames[surahNum - 1];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('$surahNum.',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SizedBox(
            width: 80,
            child: Text(arabicName,
                style: const TextStyle(fontFamily: 'Amiri', fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _surahControllers[surahNum],
              decoration: InputDecoration(
                hintText: getTranslatedSurahName(surahNum, 'en'),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => _onSurahChanged(surahNum, val),
            ),
          ),
        ],
      ),
    );
  }
}
