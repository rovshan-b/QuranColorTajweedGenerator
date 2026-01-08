import 'tajweed_rule.dart';

/// Maps TajweedRule to CSS hex color strings for HTML generation.
/// Uses light theme colors by default.
String tajweedRuleToHex(TajweedRule rule) {
  return defaultTajweedColors[rule] ?? '#000000';
}

const Map<TajweedRule, String> defaultTajweedColors = {
  TajweedRule.LAFZATULLAH: '#4CAF50',
  TajweedRule.izhar: '#06B0B6',
  TajweedRule.ikhfaa: '#B71C1C',
  TajweedRule.idghamWithGhunna: '#F06292',
  TajweedRule.iqlab: '#2196F3',
  TajweedRule.qalqala: '#7B8F0A',
  TajweedRule.idghamWithoutGhunna: '#9E9E9E',
  TajweedRule.ghunna: '#FF9800',
  TajweedRule.prolonging: '#8E64D6',
  TajweedRule.alefTafreeq: '#9E9E9E',
  TajweedRule.hamzatulWasli: '#9E9E9E',
  TajweedRule.none: '#000000',
};

const String defaultCoverBackgroundColor = '#1a472a';
const String defaultBaseTextColor = '#000000';

/// Returns the default text color for non-tajweed text
String get defaultTextColorHex => '#000000';

/// Returns the color for aya number markers
String get ayaNumberColorHex => '#000000';
