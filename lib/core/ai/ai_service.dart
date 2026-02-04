/// Abstract AI service interface
///
/// This provides a clean abstraction for AI operations,
/// allowing easy mocking for tests and swapping implementations.
library ai_service;

/// Result of an AI service request
class AIResponse {
  final String content;
  final bool isSuccess;
  final String? errorMessage;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  const AIResponse({
    required this.content,
    required this.isSuccess,
    this.errorMessage,
    this.statusCode,
    this.metadata,
  });

  factory AIResponse.success(String content, {Map<String, dynamic>? metadata}) {
    return AIResponse(content: content, isSuccess: true, metadata: metadata);
  }

  factory AIResponse.failure(String errorMessage, {int? statusCode}) {
    return AIResponse(
      content: '',
      isSuccess: false,
      errorMessage: errorMessage,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => isSuccess
      ? 'AIResponse.success(content: ${content.length} chars)'
      : 'AIResponse.failure($errorMessage)';
}

/// Message role for chat-based AI requests
enum AIMessageRole { system, user, assistant }

/// A message in a chat conversation
class AIMessage {
  final AIMessageRole role;
  final String content;

  const AIMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role.name, 'content': content};
}

/// Options for AI completion requests
class AICompletionOptions {
  /// Temperature for response randomness (0.0 - 2.0)
  final double temperature;

  /// Maximum tokens in the response
  final int maxTokens;

  /// Top-p sampling parameter
  final double? topP;

  /// Frequency penalty (-2.0 - 2.0)
  final double? frequencyPenalty;

  /// Presence penalty (-2.0 - 2.0)
  final double? presencePenalty;

  /// Stop sequences
  final List<String>? stopSequences;

  const AICompletionOptions({
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.topP,
    this.frequencyPenalty,
    this.presencePenalty,
    this.stopSequences,
  });

  /// Options optimized for translation tasks
  static const translation = AICompletionOptions(
    temperature: 0.3,
    maxTokens: 4096,
  );

  /// Options optimized for creative tasks
  static const creative = AICompletionOptions(
    temperature: 0.9,
    maxTokens: 4096,
  );

  /// Options optimized for factual/precise tasks
  static const precise = AICompletionOptions(temperature: 0.1, maxTokens: 4096);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'temperature': temperature,
      'max_tokens': maxTokens,
    };

    if (topP != null) json['top_p'] = topP;
    if (frequencyPenalty != null) json['frequency_penalty'] = frequencyPenalty;
    if (presencePenalty != null) json['presence_penalty'] = presencePenalty;
    if (stopSequences != null) json['stop'] = stopSequences;

    return json;
  }
}

/// Abstract interface for AI services
///
/// Implement this interface to create different AI service backends
/// (OpenAI, Azure, local models, mock services, etc.)
abstract class AIService {
  /// Complete a chat conversation
  ///
  /// [messages] - List of messages in the conversation
  /// [options] - Optional completion parameters
  ///
  /// Returns [AIResponse] with the assistant's reply
  Future<AIResponse> complete(
    List<AIMessage> messages, {
    AICompletionOptions options = const AICompletionOptions(),
  });

  /// Simple prompt completion (convenience method)
  ///
  /// [prompt] - The user prompt
  /// [systemPrompt] - Optional system instructions
  /// [options] - Optional completion parameters
  Future<AIResponse> prompt(
    String prompt, {
    String? systemPrompt,
    AICompletionOptions options = const AICompletionOptions(),
  });

  /// Check if the service is available and configured
  Future<bool> isAvailable();

  /// Get the name/identifier of this service
  String get serviceName;

  /// Dispose of any resources
  void dispose();
}

/// Exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;
  final bool isRetryable;

  const AIServiceException(
    this.message, {
    this.statusCode,
    this.details,
    this.isRetryable = false,
  });

  @override
  String toString() =>
      'AIServiceException: $message'
      '${statusCode != null ? ' (status: $statusCode)' : ''}'
      '${details != null ? '\nDetails: $details' : ''}';
}
