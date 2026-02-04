import '../entities/ai_query.dart';
import '../entities/ai_assistant_response.dart';
import '../repositories/ai_assistant_repository.dart';

/// Use case for asking AI about selected text
class AskAIUseCase {
  final AIAssistantRepository _repository;

  AskAIUseCase(this._repository);

  /// Execute the AI query
  Future<AIAssistantResponse> execute(AIQuery query) async {
    // Validate input
    if (query.selectedText.trim().isEmpty) {
      return AIAssistantResponse.failure(
        query: query,
        errorMessage: 'Selected text cannot be empty',
      );
    }

    // For question type, validate that a question was provided
    if (query.queryType == AIQueryType.question &&
        (query.customPrompt == null || query.customPrompt!.trim().isEmpty)) {
      return AIAssistantResponse.failure(
        query: query,
        errorMessage: 'Please enter a question',
      );
    }

    // For custom type, validate that a prompt was provided
    if (query.queryType == AIQueryType.custom &&
        (query.customPrompt == null || query.customPrompt!.trim().isEmpty)) {
      return AIAssistantResponse.failure(
        query: query,
        errorMessage: 'Please enter a custom prompt',
      );
    }

    try {
      return await _repository.askAI(query);
    } catch (e) {
      return AIAssistantResponse.failure(
        query: query,
        errorMessage: 'Failed to get AI response: ${e.toString()}',
      );
    }
  }

  /// Check if AI service is available
  Future<bool> isServiceAvailable() async {
    try {
      return await _repository.isAvailable();
    } catch (_) {
      return false;
    }
  }
}
