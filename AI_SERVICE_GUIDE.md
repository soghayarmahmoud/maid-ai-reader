# AI Service Architecture

This document explains the AI service architecture in MAID AI Reader.

## Overview

The AI service is abstracted through the `AiService` interface, allowing easy swapping between different AI providers (OpenAI, Google Gemini, etc.).

## Interface Definition

```dart
abstract class AiService {
  /// Send a query to the AI service
  Future<String> query(String prompt, {String? context});

  /// Summarize the given text
  Future<String> summarize(String text);

  /// Translate text to the target language
  Future<String> translate(String text, String targetLanguage);
}
```

## Current Implementation

### MockAiService

The app currently uses a mock implementation for development:

```dart
lib/features/ai_search/data/mock_ai_service.dart
```

This mock service:
- Returns simulated responses
- Has artificial delays to simulate network calls
- Allows testing UI without API costs
- Is useful for development and demonstrations

## Integration Steps

### 1. Choose Your AI Provider

**Option A: OpenAI (GPT-3.5/GPT-4)**
- Best for: General purpose, high quality responses
- Cost: Pay per token
- Setup: Easy with `dart_openai` package

**Option B: Google Gemini**
- Best for: Cost-effective, good quality
- Cost: Generous free tier
- Setup: Easy with `google_generative_ai` package

**Option C: Custom/Local AI**
- Best for: Privacy, offline support
- Cost: Infrastructure costs
- Setup: More complex

### 2. Implement the Interface

Create a new file for your AI service:

```dart
lib/features/ai_search/data/openai_service.dart
// or
lib/features/ai_search/data/gemini_service.dart
```

Implement the `AiService` interface:

```dart
class OpenAiService implements AiService {
  // Implementation here
}
```

### 3. Register in Dependency Injection

Update `lib/di/service_locator.dart`:

```dart
// Import your service
import '../features/ai_search/data/openai_service.dart';

Future<void> initializeDependencies() async {
  // ... existing code ...
  
  // Register AI Service
  sl.registerLazySingleton<AiService>(
    () => OpenAiService(
      apiKey: 'YOUR_API_KEY', // Better: load from environment
    ),
  );
}
```

### 4. Use in Features

Update features to use the registered service:

```dart
// In AI Chat Page
final aiService = sl<AiService>();
final response = await aiService.query(message, context: pdfContext);

// In Notes Page
final aiService = sl<AiService>();
final summary = await aiService.summarize(selectedText);

// In Translator
final aiService = sl<AiService>();
final translation = await aiService.translate(text, targetLanguage);
```

## Best Practices

### 1. Error Handling

Always wrap AI calls in try-catch:

```dart
try {
  final response = await aiService.query(prompt);
  // Handle success
} on NetworkException catch (e) {
  // Handle network error
} on ApiException catch (e) {
  // Handle API error
} catch (e) {
  // Handle unknown error
}
```

### 2. Context Management

For PDF questions, provide relevant context:

```dart
final context = extractRelevantText(pdfDocument, currentPage);
final response = await aiService.query(
  userQuestion,
  context: context,
);
```

### 3. Rate Limiting

Implement rate limiting to avoid API abuse:

```dart
class RateLimitedAiService implements AiService {
  final AiService _service;
  final RateLimiter _limiter;

  // Wrap calls with rate limiting
  @override
  Future<String> query(String prompt, {String? context}) async {
    await _limiter.acquire();
    return _service.query(prompt, context: context);
  }
}
```

### 4. Caching

Cache responses for repeated queries:

```dart
class CachedAiService implements AiService {
  final AiService _service;
  final Map<String, String> _cache = {};

  @override
  Future<String> query(String prompt, {String? context}) async {
    final key = '$prompt:$context';
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    final response = await _service.query(prompt, context: context);
    _cache[key] = response;
    return response;
  }
}
```

### 5. Streaming Responses

For better UX, consider streaming responses:

```dart
abstract class AiService {
  Stream<String> queryStream(String prompt, {String? context});
}
```

## Testing

### Unit Testing

Mock the AI service in tests:

```dart
class MockAiService extends Mock implements AiService {}

void main() {
  late MockAiService mockAiService;

  setUp(() {
    mockAiService = MockAiService();
  });

  test('should get AI response', () async {
    when(mockAiService.query(any, context: anyNamed('context')))
        .thenAnswer((_) async => 'Test response');

    final response = await mockAiService.query('test');
    expect(response, 'Test response');
  });
}
```

### Integration Testing

Test with the mock service first, then with real API:

```dart
// Use MockAiService for CI/CD
// Use real service for manual testing
```

## Performance Considerations

1. **Reduce API Calls:** Cache responses, debounce user input
2. **Optimize Context:** Send only relevant text, not entire documents
3. **Handle Timeouts:** Set reasonable timeout limits
4. **Background Processing:** Use isolates for heavy processing
5. **Monitor Costs:** Track API usage and implement limits

## Security

1. **Protect API Keys:** Never commit to version control
2. **Use Environment Variables:** Load keys from `.env` files
3. **Validate Input:** Sanitize user input before sending to AI
4. **Rate Limiting:** Prevent abuse and control costs
5. **Error Messages:** Don't expose sensitive info in errors

## Future Enhancements

- [ ] Support for multiple AI providers simultaneously
- [ ] User preference for AI provider
- [ ] Local AI model support (e.g., TensorFlow Lite)
- [ ] Streaming responses for better UX
- [ ] Voice input/output with AI
- [ ] Multi-modal AI (text + images from PDFs)
