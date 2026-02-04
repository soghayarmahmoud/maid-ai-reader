/// Core AI services module
///
/// Provides a clean, isolated AI layer with:
/// - Abstract service interface for easy mocking
/// - Environment-based configuration (no hardcoded keys)
/// - Timeout and retry logic
/// - Multiple provider support
///
/// Usage:
/// ```dart
/// // Initialize from environment
/// AIServiceLocator.initializeFromEnvironment();
///
/// // Or with explicit API key (from secure storage)
/// AIServiceLocator.initializeWithApiKey(apiKey);
///
/// // Use the service
/// final service = AIServiceLocator.instance;
/// final response = await service.prompt('Hello!');
///
/// // For testing
/// AIServiceLocator.setTestInstance(MockAIService.success());
/// ```
library ai;

export 'ai_config.dart';
export 'ai_service.dart';
export 'ai_service_factory.dart';
export 'mock_ai_service.dart';
export 'openai_service.dart';
