import '../../../core/ai/ai.dart';
import '../domain/entities/language.dart';
import '../domain/entities/translation_result.dart';
import '../domain/repositories/translation_repository.dart';

/// AI-powered translation service implementation
///
/// Uses the core AI service abstraction for all AI operations.
/// API keys are managed through environment variables or secure storage,
/// never hardcoded.
class TranslationService implements TranslationRepository {
  final AIService _aiService;

  /// Create translation service with an AI service instance
  TranslationService({required AIService aiService}) : _aiService = aiService;

  /// Create from environment variables
  ///
  /// Requires OPENAI_API_KEY environment variable to be set
  factory TranslationService.fromEnvironment() {
    return TranslationService(
      aiService: AIServiceFactory.createFromEnvironment(),
    );
  }

  /// Create with explicit API key (for mobile apps with secure storage)
  factory TranslationService.withApiKey(String apiKey) {
    return TranslationService(
      aiService: AIServiceFactory.createWithApiKey(apiKey),
    );
  }

  /// Create with mock service for testing
  factory TranslationService.mock() {
    return TranslationService(
      aiService: AIServiceFactory.createMockTranslation(),
    );
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  }) async {
    try {
      final prompt = _buildTranslationPrompt(
        text: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
      );

      final response = await _aiService.prompt(
        prompt,
        systemPrompt:
            'You are a professional translator. Provide accurate, natural translations.',
        options: AICompletionOptions.translation,
      );

      if (response.isSuccess && response.content.isNotEmpty) {
        return TranslationResult.success(
          originalText: text,
          translatedText: response.content.trim(),
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        );
      }

      return TranslationResult.failure(
        originalText: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        errorMessage:
            response.errorMessage ??
            'Failed to get translation from AI service',
      );
    } catch (e) {
      return TranslationResult.failure(
        originalText: text,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        errorMessage: 'Translation error: ${e.toString()}',
      );
    }
  }

  @override
  Future<Language?> detectLanguage(String text) async {
    try {
      final prompt = '''Detect the language of the following text. 
Respond with ONLY the ISO 639-1 two-letter language code (e.g., "en" for English, "es" for Spanish).
Do not include any other text or explanation.

Text: "$text"''';

      final response = await _aiService.prompt(
        prompt,
        options: AICompletionOptions.precise,
      );

      if (response.isSuccess && response.content.isNotEmpty) {
        final code = response.content.trim().toLowerCase();
        return SupportedLanguages.findByCode(code);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  List<Language> getSupportedLanguages() {
    return SupportedLanguages.all;
  }

  String _buildTranslationPrompt({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  }) {
    return '''Translate the following text from ${sourceLanguage.name} to ${targetLanguage.name}.

Rules:
1. Preserve the original meaning and tone
2. Maintain any formatting, punctuation, and paragraph structure
3. Use natural, fluent ${targetLanguage.name} expressions
4. If there are technical terms, translate them appropriately for the context
5. Do not add explanations or notes - provide only the translation

Text to translate:
"""
$text
"""

Translation:''';
  }

  void dispose() {
    _aiService.dispose();
  }
}

/// Mock translation service for testing (legacy compatibility)
///
/// Prefer using TranslationService.mock() for new code
class MockTranslationService implements TranslationRepository {
  @override
  Future<TranslationResult> translate({
    required String text,
    required Language sourceLanguage,
    required Language targetLanguage,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simple mock translation (adds prefix for demo)
    final mockTranslation = '[${targetLanguage.code.toUpperCase()}] $text';

    return TranslationResult.success(
      originalText: text,
      translatedText: mockTranslation,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  @override
  Future<Language?> detectLanguage(String text) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Default to English for mock
    return SupportedLanguages.defaultSourceLanguage;
  }

  @override
  List<Language> getSupportedLanguages() {
    return SupportedLanguages.all;
  }
}
