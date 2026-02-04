import 'ai_query.dart';

/// Response from the AI assistant
class AIAssistantResponse {
  /// The original query
  final AIQuery query;

  /// The AI's response content
  final String content;

  /// Whether the response was successful
  final bool isSuccess;

  /// Error message if failed
  final String? errorMessage;

  /// Response timestamp
  final DateTime timestamp;

  /// Time taken to generate response
  final Duration? responseTime;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const AIAssistantResponse({
    required this.query,
    required this.content,
    required this.isSuccess,
    this.errorMessage,
    required this.timestamp,
    this.responseTime,
    this.metadata,
  });

  factory AIAssistantResponse.success({
    required AIQuery query,
    required String content,
    Duration? responseTime,
    Map<String, dynamic>? metadata,
  }) {
    return AIAssistantResponse(
      query: query,
      content: content,
      isSuccess: true,
      timestamp: DateTime.now(),
      responseTime: responseTime,
      metadata: metadata,
    );
  }

  factory AIAssistantResponse.failure({
    required AIQuery query,
    required String errorMessage,
  }) {
    return AIAssistantResponse(
      query: query,
      content: '',
      isSuccess: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  /// Check if this is a cached response
  bool get isCached => metadata?['cached'] == true;

  @override
  String toString() => isSuccess
      ? 'AIAssistantResponse.success(${content.length} chars)'
      : 'AIAssistantResponse.failure($errorMessage)';
}

/// State for AI assistant operations
enum AIAssistantState {
  /// Initial state, ready for input
  idle,

  /// Processing the query
  loading,

  /// Successfully received response
  success,

  /// An error occurred
  error,
}
