import 'package:tajweed/cached_tajweed_tokens.dart';
import 'package:tajweed/mushaf_db_reader.dart';
import 'package:tajweed/tajweed.dart';
import 'package:tajweed/tajweed_token.dart';
import 'package:tajweed/tajweed_word.dart';

/// Maps words from the database to their corresponding Tajweed-colored tokens.
class MushafWordMapper {
  /// Cache for aya words to avoid repeated tokenization
  final Map<String, List<TajweedWord>> _ayaWordsCache = {};

  /// Track mapping failures for debugging
  final List<String> mappingWarnings = [];

  /// Hizb/Rub markers that appear in tajweed tokens but not in database
  static final _hizbMarkerPattern = RegExp(r'^[۞۩]+$');

  /// Maps a MushafWord to its corresponding TajweedWord with colored tokens.
  ///
  /// Returns null if:
  /// - The word is an aya number marker
  /// - The surah/aya combination is out of bounds
  /// - The word index is out of bounds for the aya
  TajweedWord? mapWordToTokens(MushafWord mushafWord) {
    // Skip aya number markers - they need special handling
    if (mushafWord.isAyaNumber) {
      return null;
    }

    // Convert from 1-based (database) to 0-based (CachedTajweedTokens)
    final surahIndex = mushafWord.surah - 1;
    final ayahIndex = mushafWord.ayah - 1;
    final wordIndex = mushafWord.word - 1;

    // Check bounds for surah
    if (surahIndex < 0 || surahIndex >= CachedTajweedTokens.suraTokens.length) {
      final warning =
          'WARNING: Surah ${mushafWord.surah} out of bounds (max: ${CachedTajweedTokens.suraTokens.length}) for word "${mushafWord.text}"';
      mappingWarnings.add(warning);
      print(warning);
      return null;
    }

    // Check bounds for ayah
    final surahTokens = CachedTajweedTokens.suraTokens[surahIndex];
    if (ayahIndex < 0 || ayahIndex >= surahTokens.length) {
      final warning =
          'WARNING: Ayah ${mushafWord.ayah} out of bounds (max: ${surahTokens.length}) in Surah ${mushafWord.surah} for word "${mushafWord.text}"';
      mappingWarnings.add(warning);
      print(warning);
      return null;
    }

    // Get cached words or compute them
    final cacheKey = '$surahIndex:$ayahIndex';
    List<TajweedWord> words;

    if (_ayaWordsCache.containsKey(cacheKey)) {
      words = _ayaWordsCache[cacheKey]!;
    } else {
      final ayaTokens = surahTokens[ayahIndex];
      words = _processAyaWords(Tajweed.tokensToWords(ayaTokens));
      _ayaWordsCache[cacheKey] = words;
    }

    // Check bounds for word
    if (wordIndex < 0 || wordIndex >= words.length) {
      final warning =
          'WARNING: Word ${mushafWord.word} out of bounds (tajweed has ${words.length} words) in Surah ${mushafWord.surah} Ayah ${mushafWord.ayah} for word "${mushafWord.text}"';
      mappingWarnings.add(warning);
      print(warning);
      return null;
    }

    return words[wordIndex];
  }

  /// Process aya words to handle hizb markers:
  /// - If a word is ONLY a hizb marker, prepend it to the next word
  /// - This preserves the hizb for rendering but doesn't affect word count
  List<TajweedWord> _processAyaWords(List<TajweedWord> rawWords) {
    final result = <TajweedWord>[];
    TajweedWord? pendingHizb;

    for (final word in rawWords) {
      final wordText = word.tokens.map((t) => t.text).join('').trim();

      // Skip empty words
      if (wordText.isEmpty) continue;

      // Check if this is a hizb-only word
      if (_hizbMarkerPattern.hasMatch(wordText)) {
        // Store it to prepend to next word
        pendingHizb = word;
        continue;
      }

      // If we have a pending hizb, prepend its tokens to this word
      if (pendingHizb != null) {
        final combinedWord = TajweedWord();
        // Add hizb tokens
        for (final token in pendingHizb.tokens) {
          combinedWord.tokens.add(token);
        }
        // Add a space token between hizb and word
        combinedWord.tokens.add(TajweedToken(
          word.tokens.first.rule,
          null,
          null,
          ' ',
          0,
          1,
          null,
        ));
        // Add word tokens
        for (final token in word.tokens) {
          combinedWord.tokens.add(token);
        }
        result.add(combinedWord);
        pendingHizb = null;
      } else {
        result.add(word);
      }
    }

    return result;
  }

  /// Clears the internal cache.
  void clearCache() {
    _ayaWordsCache.clear();
    mappingWarnings.clear();
  }
}
