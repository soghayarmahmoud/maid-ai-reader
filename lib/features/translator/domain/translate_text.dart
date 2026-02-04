import 'entities/language.dart';
import 'entities/translation_result.dart';
import 'repositories/translation_repository.dart';

/// Use case for translating selected PDF text
class TranslateTextUseCase {
  final TranslationRepository _repository;

  TranslateTextUseCase(this._repository);

  /// Execute translation of the given text
  Future<TranslationResult> execute({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  }) async {
    // Validate input
    if (text.trim().isEmpty) {
      return TranslationResult.failure(
        originalText: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        errorMessage: 'Text cannot be empty',
      );
    }

    // Validate languages are different
    if (sourceLanguage.code == targetLanguage.code) {
      return TranslationResult.failure(
        originalText: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        errorMessage: 'Source and target languages must be different',
      );
    }

    try {
      return await _repository.translate(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );
    } catch (e) {
      return TranslationResult.failure(
        originalText: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        errorMessage: 'Translation failed: ${e.toString()}',
      );
    }
  }

  /// Get supported languages
  List<Language> getSupportedLanguages() {
    return _repository.getSupportedLanguages();
  }

  /// Detect language of text
  Future<Language?> detectLanguage(String text) async {
    if (text.trim().isEmpty) return null;
    return await _repository.detectLanguage(text);
  }
}
