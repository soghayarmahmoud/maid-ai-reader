abstract class AiService {
  /// Send a query to the AI service
  Future<String> query(String prompt, {String? context});

  /// Summarize the given text
  Future<String> summarize(String text);

  /// Translate text to the target language
  Future<String> translate(String text, String targetLanguage);
}
