import '../domain/ai_service.dart';

/// Mock AI Service implementation
/// Replace this with actual AI service integration (OpenAI, Gemini, etc.)
class MockAiService implements AiService {
  @override
  Future<String> query(String prompt, {String? context}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    return 'This is a mock response. Please integrate with a real AI service like OpenAI or Google Gemini.';
  }

  @override
  Future<String> summarize(String text) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return 'This is a mock summary of the provided text. Please integrate with a real AI service.';
  }

  @override
  Future<String> translate(String text, String targetLanguage) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return 'This is a mock translation to $targetLanguage. Please integrate with a real translation service.';
  }
}
