import 'package:tajweed/tajweed_rule.dart';

/// Maps TajweedRule to CSS hex color strings for HTML generation.
/// Uses light theme colors by default.
String tajweedRuleToHex(TajweedRule rule) {
  switch (rule) {
    case TajweedRule.LAFZATULLAH:
      return '#4CAF50'; // Green
    case TajweedRule.izhar:
      return '#06B0B6'; // Cyan
    case TajweedRule.ikhfaa:
      return '#B71C1C'; // Dark Red
    case TajweedRule.idghamWithGhunna:
      return '#F06292'; // Pink
    case TajweedRule.iqlab:
      return '#2196F3'; // Blue
    case TajweedRule.qalqala:
      return '#7B8F0A'; // Olive/Yellow-Green
    case TajweedRule.idghamWithoutGhunna:
      return '#9E9E9E'; // Grey
    case TajweedRule.ghunna:
      return '#FF9800'; // Orange
    case TajweedRule.prolonging:
      return '#8E64D6'; // Purple
    case TajweedRule.alefTafreeq:
      return '#9E9E9E'; // Grey
    case TajweedRule.hamzatulWasli:
      return '#9E9E9E'; // Grey
    case TajweedRule.none:
      return '#000000'; // Black (default text)
  }
}

/// Returns the default text color for non-tajweed text
String get defaultTextColorHex => '#000000';

/// Returns the color for aya number markers
String get ayaNumberColorHex => '#000000';
