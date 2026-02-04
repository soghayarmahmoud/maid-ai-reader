import '../entities/language.dart';
import '../entities/translation_result.dart';

/// Repository interface for translation operations
abstract class TranslationRepository {
  /// Translate text from source language to target language
  Future<TranslationResult> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  });

  /// Detect the language of the given text
  Future<Language?> detectLanguage(String text);

  /// Get list of supported languages
  List<Language> getSupportedLanguages();
}
