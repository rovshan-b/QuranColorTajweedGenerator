// Simple debug script - just print raw cached token data
// Run with: dart run test/debug_tokens.dart
import '../lib/tajweed_rule.dart';
import '../lib/tajweed_subrule.dart';
import '../lib/tajweed_token.dart';
import '../lib/tajweed_word.dart';
import '../lib/cached_tajweed_tokens.dart';
import '../lib/tajweed.dart';

void main() {
  // Check surah 61 (index 60), aya 1 (index 0)
  final surahIndex = 60;
  final ayahIndex = 0;

  print('Surah ${surahIndex + 1}, Aya ${ayahIndex + 1}:');
  print('---');

  final ayaTokens = CachedTajweedTokens.suraTokens[surahIndex][ayahIndex];
  print('Number of tokens: ${ayaTokens.length}');

  // Print each token
  print('\nTokens:');
  for (var i = 0; i < ayaTokens.length; i++) {
    print('  [$i] "${ayaTokens[i].text}" (rule: ${ayaTokens[i].rule})');
  }

  // Convert to words
  final words = Tajweed.tokensToWords(ayaTokens);
  print('\nNumber of words: ${words.length}');

  // Print each word
  print('\nWords:');
  for (var i = 0; i < words.length; i++) {
    final wordText = words[i].tokens.map((t) => t.text).join('');
    print('  [$i] "$wordText"');
  }

  // Compare with database expected count (11 words + 1 aya number = 12)
  print('\n---');
  print('Expected database words: 11 (plus aya number marker)');
  print('Actual tajweed words: ${words.length}');
  if (words.length != 11) {
    print('MISMATCH! Difference: ${11 - words.length}');
  }
}
