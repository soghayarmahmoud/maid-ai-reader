import '../entities/ai_query.dart';
import '../entities/ai_assistant_response.dart';

/// Repository interface for AI assistant operations
abstract class AIAssistantRepository {
  /// Send a query to the AI and get a response
  Future<AIAssistantResponse> askAI(AIQuery query);

  /// Check if the service is available
  Future<bool> isAvailable();
}
