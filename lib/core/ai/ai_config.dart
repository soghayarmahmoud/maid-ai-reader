/// AI Service configuration and environment management
///
/// API keys should be provided via:
/// 1. Environment variables (recommended for production)
/// 2. Secure storage (for mobile apps)
/// 3. Runtime configuration (for testing)
///
/// NEVER hardcode API keys in source code.
library ai_config;

import 'dart:io';

/// Environment variable names for AI service configuration
class AIEnvironmentKeys {
  static const String openAiApiKey = 'OPENAI_API_KEY';
  static const String openAiBaseUrl = 'OPENAI_BASE_URL';
  static const String aiProvider = 'AI_PROVIDER';
  static const String aiModel = 'AI_MODEL';

  AIEnvironmentKeys._();
}

/// Supported AI providers
enum AIProvider { openAI, azure, anthropic, custom }

/// Configuration for AI services
class AIConfig {
  /// The API key for authentication
  final String apiKey;

  /// The base URL for the AI service
  final String baseUrl;

  /// The AI provider being used
  final AIProvider provider;

  /// The model to use for requests
  final String model;

  /// Request timeout duration
  final Duration timeout;

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Delay between retry attempts
  final Duration retryDelay;

  /// Whether to use exponential backoff for retries
  final bool useExponentialBackoff;

  const AIConfig({
    required this.apiKey,
    required this.baseUrl,
    this.provider = AIProvider.openAI,
    this.model = 'gpt-4o-mini',
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.useExponentialBackoff = true,
  });

  /// Create configuration from environment variables
  ///
  /// Throws [AIConfigException] if required environment variables are missing
  factory AIConfig.fromEnvironment() {
    final apiKey = Platform.environment[AIEnvironmentKeys.openAiApiKey];

    if (apiKey == null || apiKey.isEmpty) {
      throw AIConfigException(
        'Missing required environment variable: ${AIEnvironmentKeys.openAiApiKey}',
      );
    }

    final baseUrl =
        Platform.environment[AIEnvironmentKeys.openAiBaseUrl] ??
        'https://api.openai.com/v1';

    final model =
        Platform.environment[AIEnvironmentKeys.aiModel] ?? 'gpt-4o-mini';

    final providerStr = Platform.environment[AIEnvironmentKeys.aiProvider];
    final provider = _parseProvider(providerStr);

    return AIConfig(
      apiKey: apiKey,
      baseUrl: baseUrl,
      provider: provider,
      model: model,
    );
  }

  /// Create configuration with custom values
  /// Useful for testing or runtime configuration
  factory AIConfig.custom({
    required String apiKey,
    String? baseUrl,
    AIProvider provider = AIProvider.openAI,
    String? model,
    Duration? timeout,
    int? maxRetries,
  }) {
    return AIConfig(
      apiKey: apiKey,
      baseUrl: baseUrl ?? _defaultBaseUrl(provider),
      provider: provider,
      model: model ?? _defaultModel(provider),
      timeout: timeout ?? const Duration(seconds: 30),
      maxRetries: maxRetries ?? 3,
    );
  }

  /// Check if configuration is valid
  bool get isValid => apiKey.isNotEmpty && baseUrl.isNotEmpty;

  /// Create a copy with modified values
  AIConfig copyWith({
    String? apiKey,
    String? baseUrl,
    AIProvider? provider,
    String? model,
    Duration? timeout,
    int? maxRetries,
    Duration? retryDelay,
    bool? useExponentialBackoff,
  }) {
    return AIConfig(
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      provider: provider ?? this.provider,
      model: model ?? this.model,
      timeout: timeout ?? this.timeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      useExponentialBackoff:
          useExponentialBackoff ?? this.useExponentialBackoff,
    );
  }

  static AIProvider _parseProvider(String? providerStr) {
    switch (providerStr?.toLowerCase()) {
      case 'azure':
        return AIProvider.azure;
      case 'anthropic':
        return AIProvider.anthropic;
      case 'custom':
        return AIProvider.custom;
      default:
        return AIProvider.openAI;
    }
  }

  static String _defaultBaseUrl(AIProvider provider) {
    switch (provider) {
      case AIProvider.openAI:
        return 'https://api.openai.com/v1';
      case AIProvider.azure:
        return 'https://YOUR_RESOURCE.openai.azure.com';
      case AIProvider.anthropic:
        return 'https://api.anthropic.com/v1';
      case AIProvider.custom:
        return '';
    }
  }

  static String _defaultModel(AIProvider provider) {
    switch (provider) {
      case AIProvider.openAI:
        return 'gpt-4o-mini';
      case AIProvider.azure:
        return 'gpt-4o-mini';
      case AIProvider.anthropic:
        return 'claude-3-haiku-20240307';
      case AIProvider.custom:
        return '';
    }
  }

  @override
  String toString() =>
      'AIConfig(provider: $provider, model: $model, baseUrl: $baseUrl)';
}

/// Exception thrown when AI configuration is invalid or missing
class AIConfigException implements Exception {
  final String message;

  const AIConfigException(this.message);

  @override
  String toString() => 'AIConfigException: $message';
}

/// Secure configuration provider interface
/// Implement this for platform-specific secure storage
abstract class AIConfigProvider {
  /// Get the current AI configuration
  Future<AIConfig?> getConfig();

  /// Save AI configuration securely
  Future<void> saveConfig(AIConfig config);

  /// Clear stored configuration
  Future<void> clearConfig();

  /// Check if configuration exists
  Future<bool> hasConfig();
}
