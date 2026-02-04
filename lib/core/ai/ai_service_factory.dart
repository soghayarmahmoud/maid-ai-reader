/// AI Service Factory
///
/// Creates AI service instances based on configuration
/// without exposing implementation details.
library ai_service_factory;

import 'ai_config.dart';
import 'ai_service.dart';
import 'openai_service.dart';
import 'mock_ai_service.dart';

/// Factory for creating AI service instances
class AIServiceFactory {
  AIServiceFactory._();

  /// Create an AI service from configuration
  static AIService create(AIConfig config) {
    switch (config.provider) {
      case AIProvider.openAI:
      case AIProvider.azure:
      case AIProvider.custom:
        return OpenAIService(config: config);
      case AIProvider.anthropic:
        // For now, use OpenAI-compatible endpoint
        // Can be replaced with dedicated Anthropic implementation
        return OpenAIService(config: config);
    }
  }

  /// Create an AI service from environment variables
  ///
  /// Throws [AIConfigException] if required environment variables are missing
  static AIService createFromEnvironment() {
    final config = AIConfig.fromEnvironment();
    return create(config);
  }

  /// Create an AI service with explicit API key
  ///
  /// This is useful for mobile apps where the key comes from secure storage
  static AIService createWithApiKey(
    String apiKey, {
    AIProvider provider = AIProvider.openAI,
    String? model,
    String? baseUrl,
  }) {
    final config = AIConfig.custom(
      apiKey: apiKey,
      provider: provider,
      model: model,
      baseUrl: baseUrl,
    );
    return create(config);
  }

  /// Create a mock service for testing
  static AIService createMock({
    bool shouldFail = false,
    String? errorMessage,
    String Function(String prompt)? responseGenerator,
  }) {
    return MockAIService(
      shouldFail: shouldFail,
      errorMessage: errorMessage,
      responseGenerator: responseGenerator,
    );
  }

  /// Create a mock service optimized for translation testing
  static AIService createMockTranslation() {
    return MockAIService.translation();
  }
}

/// Service locator for AI services
///
/// Provides a global access point while allowing dependency injection
/// for testing.
class AIServiceLocator {
  static AIService? _instance;
  static AIService? _testInstance;

  AIServiceLocator._();

  /// Get the current AI service instance
  ///
  /// Throws [StateError] if no service has been initialized
  static AIService get instance {
    if (_testInstance != null) {
      return _testInstance!;
    }

    if (_instance == null) {
      throw StateError(
        'AIServiceLocator has not been initialized. '
        'Call initialize() or setTestInstance() first.',
      );
    }

    return _instance!;
  }

  /// Check if a service has been initialized
  static bool get isInitialized => _instance != null || _testInstance != null;

  /// Initialize with configuration
  static void initialize(AIConfig config) {
    _instance?.dispose();
    _instance = AIServiceFactory.create(config);
  }

  /// Initialize from environment variables
  static void initializeFromEnvironment() {
    _instance?.dispose();
    _instance = AIServiceFactory.createFromEnvironment();
  }

  /// Initialize with an API key
  static void initializeWithApiKey(
    String apiKey, {
    AIProvider provider = AIProvider.openAI,
    String? model,
  }) {
    _instance?.dispose();
    _instance = AIServiceFactory.createWithApiKey(
      apiKey,
      provider: provider,
      model: model,
    );
  }

  /// Set a test instance (overrides the main instance)
  ///
  /// Use this in tests to inject mock services
  static void setTestInstance(AIService service) {
    _testInstance = service;
  }

  /// Clear the test instance
  static void clearTestInstance() {
    _testInstance = null;
  }

  /// Reset the locator (for testing)
  static void reset() {
    _testInstance = null;
    _instance?.dispose();
    _instance = null;
  }
}
