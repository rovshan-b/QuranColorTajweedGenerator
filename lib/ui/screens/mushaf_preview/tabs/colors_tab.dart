import 'package:flutter/material.dart';
import '../../../../tajweed_rule.dart';
import '../../../../tajweed_color_mapper.dart';
import '../../../widgets/custom_inputs.dart';

class ColorsTab extends StatelessWidget {
  final String coverBackgroundColor;
  final String baseTextColor;
  final Map<TajweedRule, String> tajweedColors;
  final Map<TajweedRule, bool> tajweedHighlighting;

  final Function(String) onCoverBackgroundColorChanged;
  final Function(String) onBaseTextColorChanged;
  final Function(TajweedRule, String) onTajweedColorChanged;
  final Function(TajweedRule, bool) onTajweedHighlightingChanged;
  final VoidCallback onReset;

  const ColorsTab({
    super.key,
    required this.coverBackgroundColor,
    required this.baseTextColor,
    required this.tajweedColors,
    required this.tajweedHighlighting,
    required this.onCoverBackgroundColorChanged,
    required this.onBaseTextColorChanged,
    required this.onTajweedColorChanged,
    required this.onTajweedHighlightingChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out 'none' as it's typically the base color
    final rules =
        TajweedRule.values.where((r) => r != TajweedRule.none).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Color Customization',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restore),
                label: const Text('Reset All Defaults'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor:
                      Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Global Layout Colors',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ColorInput(
                          label: 'Cover Background',
                          value: coverBackgroundColor,
                          onChanged: onCoverBackgroundColorChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ColorInput(
                          label: 'Base Text Color',
                          value: baseTextColor,
                          onChanged: onBaseTextColorChanged,
                        ),
                      ),
                    ],
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
                    'Tajweed Rules Highlighting',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customize colors for each rule or disable highlighting for specific rules.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rules.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final rule = rules[index];
                      final isHighlighted = tajweedHighlighting[rule] ?? true;
                      final currentColor = tajweedColors[rule] ?? '#000000';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rule.name
                                        .replaceAll(RegExp(r'(?=[A-Z])'), ' ')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: ColorInput(
                                label: 'Rule Color',
                                value: currentColor,
                                enabled: isHighlighted,
                                onChanged: (val) =>
                                    onTajweedColorChanged(rule, val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                Text(
                                  'Highlight',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Switch(
                                  value: isHighlighted,
                                  onChanged: (val) =>
                                      onTajweedHighlightingChanged(rule, val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
