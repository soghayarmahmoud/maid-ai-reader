/// Mock AI service for testing
///
/// Provides predictable responses for unit tests
/// without requiring actual API calls.
library mock_ai_service;

import 'dart:async';
import 'ai_service.dart';

/// Mock implementation of AIService for testing
///
/// Features:
/// - Configurable response delays
/// - Predefined or custom responses
/// - Failure simulation
/// - Call tracking for verification
class MockAIService implements AIService {
  final Duration _responseDelay;
  final bool _shouldFail;
  final String? _errorMessage;
  final String Function(String prompt)? _responseGenerator;

  /// Track all calls for test verification
  final List<MockAICall> calls = [];

  /// Default response when no generator is provided
  static const String defaultResponse = 'Mock AI response';

  MockAIService({
    Duration responseDelay = const Duration(milliseconds: 100),
    bool shouldFail = false,
    String? errorMessage,
    String Function(String prompt)? responseGenerator,
  }) : _responseDelay = responseDelay,
       _shouldFail = shouldFail,
       _errorMessage = errorMessage,
       _responseGenerator = responseGenerator;

  /// Create a mock that always succeeds with a fixed response
  factory MockAIService.success([String response = defaultResponse]) {
    return MockAIService(responseGenerator: (_) => response);
  }

  /// Create a mock that always fails
  factory MockAIService.failure([String errorMessage = 'Mock error']) {
    return MockAIService(shouldFail: true, errorMessage: errorMessage);
  }

  /// Create a mock for translation testing
  factory MockAIService.translation() {
    return MockAIService(
      responseGenerator: (prompt) {
        // Extract target language from prompt and prefix response
        if (prompt.contains('Spanish')) {
          return '[ES] Texto traducido de prueba';
        } else if (prompt.contains('French')) {
          return '[FR] Texte traduit de test';
        } else if (prompt.contains('German')) {
          return '[DE] Übersetzter Testtext';
        }
        return '[TRANSLATED] Mock translated text';
      },
    );
  }

  @override
  String get serviceName => 'Mock AI Service';

  @override
  Future<bool> isAvailable() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return !_shouldFail;
  }

  @override
  Future<AIResponse> complete(
    List<AIMessage> messages, {
    AICompletionOptions options = const AICompletionOptions(),
  }) async {
    // Record the call
    final userMessage = messages.lastWhere(
      (m) => m.role == AIMessageRole.user,
      orElse: () => const AIMessage(role: AIMessageRole.user, content: ''),
    );

    calls.add(
      MockAICall(
        messages: messages,
        options: options,
        timestamp: DateTime.now(),
      ),
    );

    // Simulate network delay
    await Future.delayed(_responseDelay);

    // Return failure if configured
    if (_shouldFail) {
      return AIResponse.failure(_errorMessage ?? 'Mock service failure');
    }

    // Generate response
    final content =
        _responseGenerator?.call(userMessage.content) ?? defaultResponse;

    return AIResponse.success(
      content,
      metadata: {
        'model': 'mock-model',
        'usage': {'prompt_tokens': 10, 'completion_tokens': 20},
        'mock': true,
      },
    );
  }

  @override
  Future<AIResponse> prompt(
    String prompt, {
    String? systemPrompt,
    AICompletionOptions options = const AICompletionOptions(),
  }) async {
    final messages = <AIMessage>[
      if (systemPrompt != null)
        AIMessage(role: AIMessageRole.system, content: systemPrompt),
      AIMessage(role: AIMessageRole.user, content: prompt),
    ];

    return complete(messages, options: options);
  }

  /// Clear recorded calls
  void clearCalls() => calls.clear();

  /// Get the last call made
  MockAICall? get lastCall => calls.isNotEmpty ? calls.last : null;

  /// Check if a specific prompt was called
  bool wasCalledWith(String promptContains) {
    return calls.any(
      (call) => call.messages.any((m) => m.content.contains(promptContains)),
    );
  }

  @override
  void dispose() {
    // Nothing to dispose in mock
  }
}

/// Record of a mock AI service call
class MockAICall {
  final List<AIMessage> messages;
  final AICompletionOptions options;
  final DateTime timestamp;

  const MockAICall({
    required this.messages,
    required this.options,
    required this.timestamp,
  });

  String get userPrompt {
    final userMessage = messages.lastWhere(
      (m) => m.role == AIMessageRole.user,
      orElse: () => const AIMessage(role: AIMessageRole.user, content: ''),
    );
    return userMessage.content;
  }

  @override
  String toString() => 'MockAICall(prompt: ${userPrompt.substring(0, 50)}...)';
}

/// Extension for easier testing
extension MockAIServiceTestHelpers on MockAIService {
  /// Verify the service was called exactly n times
  bool verifyCallCount(int expected) => calls.length == expected;

  /// Verify the service was called at least once
  bool verifyCalled() => calls.isNotEmpty;

  /// Verify the service was never called
  bool verifyNeverCalled() => calls.isEmpty;
}
