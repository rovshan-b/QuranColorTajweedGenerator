import 'package:flutter/material.dart';
import 'package:mushaf_generator/ui/widgets/custom_inputs.dart';

class GeneralLabelsTab extends StatelessWidget {
  final String coverTitle;
  final ValueChanged<String> onCoverTitleChanged;
  final String coverSubtitle;
  final ValueChanged<String> onCoverSubtitleChanged;
  final String tocTitle;
  final ValueChanged<String> onTocTitleChanged;
  final String blankPageText;
  final ValueChanged<String> onBlankPageTextChanged;
  final String translationLabel;
  final ValueChanged<String> onTranslationLabelChanged;
  final String wbwLabel;
  final ValueChanged<String> onWbwLabelChanged;
  final Function(String, String) onShowHelp;

  const GeneralLabelsTab({
    super.key,
    required this.coverTitle,
    required this.onCoverTitleChanged,
    required this.coverSubtitle,
    required this.onCoverSubtitleChanged,
    required this.tocTitle,
    required this.onTocTitleChanged,
    required this.blankPageText,
    required this.onBlankPageTextChanged,
    required this.translationLabel,
    required this.onTranslationLabelChanged,
    required this.wbwLabel,
    required this.onWbwLabelChanged,
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
                    'Mushaf Labels & Titles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextInput(
                          label: 'Cover Title',
                          value: coverTitle,
                          suffix: _buildHelpIcon(
                              'Cover Title', 'Main title on the cover page.'),
                          onChanged: onCoverTitleChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextInput(
                          label: 'Cover Subtitle',
                          value: coverSubtitle,
                          suffix: _buildHelpIcon(
                              'Cover Subtitle', 'Subtitle on the cover page.'),
                          onChanged: onCoverSubtitleChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextInput(
                          label: 'TOC Title',
                          value: tocTitle,
                          suffix: _buildHelpIcon('TOC Title',
                              'Title for the Table of Contents section.'),
                          onChanged: onTocTitleChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextInput(
                          label: 'Blank Page Text',
                          value: blankPageText,
                          suffix: _buildHelpIcon('Blank Page Text',
                              'Description text for empty preface pages.'),
                          onChanged: onBlankPageTextChanged,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextInput(
                          label: 'Translation Label',
                          value: translationLabel,
                          suffix: _buildHelpIcon('Translation Label',
                              'How "Translation" is displayed on the cover/headers.'),
                          onChanged: onTranslationLabelChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextInput(
                          label: 'WBW Label',
                          value: wbwLabel,
                          suffix: _buildHelpIcon('WBW Label',
                              'How "Word by Word" is displayed on the cover/headers.'),
                          onChanged: onWbwLabelChanged,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These labels are used throughout the generated PDF and cover page.',
                          style:
                              TextStyle(fontSize: 13, color: Colors.blueGrey),
                        ),
                      ),
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
