import '../../../core/ai/ai.dart';
import '../domain/entities/ai_query.dart';
import '../domain/entities/ai_assistant_response.dart';
import '../domain/repositories/ai_assistant_repository.dart';

/// AI Assistant service implementation using the core AI layer
class AIAssistantService implements AIAssistantRepository {
  final AIService _aiService;

  AIAssistantService({required AIService aiService}) : _aiService = aiService;

  /// Create from environment variables
  factory AIAssistantService.fromEnvironment() {
    return AIAssistantService(
      aiService: AIServiceFactory.createFromEnvironment(),
    );
  }

  /// Create with explicit API key
  factory AIAssistantService.withApiKey(String apiKey) {
    return AIAssistantService(
      aiService: AIServiceFactory.createWithApiKey(apiKey),
    );
  }

  /// Create mock service for testing
  factory AIAssistantService.mock() {
    return AIAssistantService(
      aiService: MockAIService(
        responseGenerator: (prompt) {
          if (prompt.contains('explain')) {
            return 'This text discusses an important concept. Here\'s a detailed explanation:\n\n'
                '1. **Key Point**: The main idea revolves around...\n'
                '2. **Context**: In the broader context, this relates to...\n'
                '3. **Significance**: This is important because...\n\n'
                'In summary, the selected text highlights a fundamental aspect of the topic.';
          } else if (prompt.contains('summarize')) {
            return '**Summary:**\n\n'
                'The selected text covers the following key points:\n'
                '• Main concept and its definition\n'
                '• Supporting details and examples\n'
                '• Implications and conclusions';
          } else if (prompt.contains('define')) {
            return '**Definitions:**\n\n'
                '• **Term 1**: A concept referring to...\n'
                '• **Term 2**: This describes the process of...\n'
                '• **Term 3**: A technical term meaning...';
          }
          return 'Based on the selected text, here is my analysis and response to your query. '
              'The content discusses important concepts that are relevant to the broader topic.';
        },
      ),
    );
  }

  @override
  Future<AIAssistantResponse> askAI(AIQuery query) async {
    final stopwatch = Stopwatch()..start();

    try {
      final systemPrompt = _buildSystemPrompt(query);
      final userPrompt = _buildUserPrompt(query);

      final response = await _aiService.prompt(
        userPrompt,
        systemPrompt: systemPrompt,
        options: _getCompletionOptions(query.queryType),
      );

      stopwatch.stop();

      if (response.isSuccess) {
        return AIAssistantResponse.success(
          query: query,
          content: response.content,
          responseTime: stopwatch.elapsed,
          metadata: response.metadata,
        );
      }

      return AIAssistantResponse.failure(
        query: query,
        errorMessage: response.errorMessage ?? 'Failed to get AI response',
      );
    } catch (e) {
      stopwatch.stop();
      return AIAssistantResponse.failure(
        query: query,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    return await _aiService.isAvailable();
  }

  String _buildSystemPrompt(AIQuery query) {
    final basePrompt =
        '''You are a helpful AI assistant integrated into a PDF reader application. 
Your role is to help users understand and analyze text they've selected from documents.

Guidelines:
- Provide clear, accurate, and helpful responses
- Use markdown formatting for better readability
- Be concise but thorough
- If the text is unclear or ambiguous, acknowledge this
- Stay focused on the selected text and user's query''';

    // Add document context if available
    if (query.documentContext != null) {
      final docContext = query.documentContext!.toContextString();
      if (docContext.isNotEmpty) {
        return '$basePrompt\n\nDocument context: $docContext';
      }
    }

    return basePrompt;
  }

  String _buildUserPrompt(AIQuery query) {
    final selectedText = query.selectedText;
    final additionalContext = query.context;

    String prompt;

    switch (query.queryType) {
      case AIQueryType.explain:
        prompt =
            '''Please explain the following text in detail. Break down any complex concepts and provide clarity.

Selected text:
"""
$selectedText
"""''';
        break;

      case AIQueryType.summarize:
        prompt =
            '''Please provide a concise summary of the following text. Highlight the key points and main ideas.

Selected text:
"""
$selectedText
"""''';
        break;

      case AIQueryType.define:
        prompt =
            '''Please identify and define any technical terms, jargon, or key concepts in the following text.

Selected text:
"""
$selectedText
"""''';
        break;

      case AIQueryType.analyze:
        prompt =
            '''Please analyze the following text. Consider its structure, tone, main arguments, and any notable aspects.

Selected text:
"""
$selectedText
"""''';
        break;

      case AIQueryType.question:
        prompt =
            '''Based on the following text, please answer this question: ${query.customPrompt}

Selected text:
"""
$selectedText
"""''';
        break;

      case AIQueryType.custom:
        prompt =
            '''${query.customPrompt}

Selected text:
"""
$selectedText
"""''';
        break;
    }

    // Add additional context if available
    if (additionalContext != null && additionalContext.isNotEmpty) {
      prompt +=
          '\n\nAdditional context from surrounding text:\n"""$additionalContext"""';
    }

    return prompt;
  }

  AICompletionOptions _getCompletionOptions(AIQueryType queryType) {
    switch (queryType) {
      case AIQueryType.summarize:
        // More focused for summaries
        return const AICompletionOptions(temperature: 0.3, maxTokens: 1024);
      case AIQueryType.define:
        // Precise for definitions
        return const AICompletionOptions(temperature: 0.2, maxTokens: 2048);
      case AIQueryType.analyze:
        // Slightly more creative for analysis
        return const AICompletionOptions(temperature: 0.5, maxTokens: 2048);
      case AIQueryType.explain:
      case AIQueryType.question:
      case AIQueryType.custom:
      default:
        return const AICompletionOptions(temperature: 0.4, maxTokens: 2048);
    }
  }

  void dispose() {
    _aiService.dispose();
  }
}
