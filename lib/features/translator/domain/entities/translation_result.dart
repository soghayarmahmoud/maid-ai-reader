import 'language.dart';

/// Result of a translation operation
class TranslationResult {
  final String originalText;
  final String translatedText;
  final Language sourceLanguage;
  final Language targetLanguage;
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory TranslationResult.success({
    required String originalText,
    required String translatedText,
    required Language sourceLanguage,
    required Language targetLanguage,
  }) {
    return TranslationResult(
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
      isSuccess: true,
    );
  }

  factory TranslationResult.failure({
    required String originalText,
    required Language sourceLanguage,
    required Language targetLanguage,
    required String errorMessage,
  }) {
    return TranslationResult(
      originalText: originalText,
      translatedText: '',
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() =>
      'TranslationResult(from: ${sourceLanguage.code}, to: ${targetLanguage.code}, success: $isSuccess)';
}
