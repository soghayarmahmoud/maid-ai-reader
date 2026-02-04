/// OpenAI implementation of the AI service interface
/// with timeout and retry logic
library openai_service;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_config.dart';
import 'ai_service.dart';

/// OpenAI-compatible AI service implementation
///
/// Supports:
/// - OpenAI API
/// - Azure OpenAI
/// - Any OpenAI-compatible API endpoint
class OpenAIService implements AIService {
  final AIConfig _config;
  final http.Client _httpClient;
  bool _isDisposed = false;

  OpenAIService({required AIConfig config, http.Client? httpClient})
    : _config = config,
      _httpClient = httpClient ?? http.Client();

  /// Create service from environment variables
  factory OpenAIService.fromEnvironment({http.Client? httpClient}) {
    return OpenAIService(
      config: AIConfig.fromEnvironment(),
      httpClient: httpClient,
    );
  }

  @override
  String get serviceName => 'OpenAI (${_config.model})';

  @override
  Future<bool> isAvailable() async {
    if (_isDisposed) return false;
    if (!_config.isValid) return false;

    try {
      // Simple health check - list models endpoint
      final uri = Uri.parse('${_config.baseUrl}/models');
      final response = await _httpClient
          .get(uri, headers: {'Authorization': 'Bearer ${_config.apiKey}'})
          .timeout(_config.timeout);

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AIResponse> complete(
    List<AIMessage> messages, {
    AICompletionOptions options = const AICompletionOptions(),
  }) async {
    if (_isDisposed) {
      return AIResponse.failure('Service has been disposed');
    }

    return _executeWithRetry(() => _doComplete(messages, options));
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

  Future<AIResponse> _doComplete(
    List<AIMessage> messages,
    AICompletionOptions options,
  ) async {
    final uri = Uri.parse('${_config.baseUrl}/chat/completions');

    final body = jsonEncode({
      'model': _config.model,
      'messages': messages.map((m) => m.toJson()).toList(),
      ...options.toJson(),
    });

    final response = await _httpClient
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_config.apiKey}',
          },
          body: body,
        )
        .timeout(_config.timeout);

    return _parseResponse(response);
  }

  AIResponse _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List?;

        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'];
          final content = message['content'] as String? ?? '';

          return AIResponse.success(
            content.trim(),
            metadata: {
              'model': data['model'],
              'usage': data['usage'],
              'finish_reason': choices[0]['finish_reason'],
            },
          );
        }

        return AIResponse.failure(
          'No content in response',
          statusCode: response.statusCode,
        );
      } catch (e) {
        return AIResponse.failure(
          'Failed to parse response: $e',
          statusCode: response.statusCode,
        );
      }
    }

    // Handle error responses
    String errorMessage = 'Request failed';
    try {
      final data = jsonDecode(response.body);
      errorMessage = data['error']?['message'] ?? errorMessage;
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
    }

    return AIResponse.failure(errorMessage, statusCode: response.statusCode);
  }

  /// Execute request with retry logic
  Future<AIResponse> _executeWithRetry(
    Future<AIResponse> Function() operation,
  ) async {
    int attempt = 0;
    AIResponse? lastResponse;

    while (attempt < _config.maxRetries) {
      attempt++;

      try {
        lastResponse = await operation();

        // Success - return immediately
        if (lastResponse.isSuccess) {
          return lastResponse;
        }

        // Check if error is retryable
        if (!_isRetryableError(lastResponse.statusCode)) {
          return lastResponse;
        }
      } on TimeoutException {
        lastResponse = AIResponse.failure(
          'Request timed out after ${_config.timeout.inSeconds} seconds',
        );
      } on http.ClientException catch (e) {
        lastResponse = AIResponse.failure('Network error: ${e.message}');
      } catch (e) {
        lastResponse = AIResponse.failure('Unexpected error: $e');
        // Don't retry unexpected errors
        return lastResponse;
      }

      // Wait before retry (with exponential backoff if enabled)
      if (attempt < _config.maxRetries) {
        final delay = _config.useExponentialBackoff
            ? _config.retryDelay * (1 << (attempt - 1))
            : _config.retryDelay;

        await Future.delayed(delay);
      }
    }

    return lastResponse ??
        AIResponse.failure('Request failed after $_config.maxRetries attempts');
  }

  bool _isRetryableError(int? statusCode) {
    if (statusCode == null) return true;

    // Retry on rate limiting, server errors, and gateway errors
    return statusCode == 429 || // Rate limited
        statusCode == 500 || // Internal server error
        statusCode == 502 || // Bad gateway
        statusCode == 503 || // Service unavailable
        statusCode == 504; // Gateway timeout
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _httpClient.close();
      _isDisposed = true;
    }
  }
}
