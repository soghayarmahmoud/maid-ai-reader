import 'package:google_generative_ai/google_generative_ai.dart';

/// Google Gemini AI Service Implementation
///
/// Uses systemInstruction on GenerativeModel for proper context injection.
/// Gemini 1.5 Flash free tier: 15 requests/min, 1500/day.
class GeminiAiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _initialized = false;

  /// Gemini API Key
  static const String _apiKey = 'AIzaSyBePZxVvjM96UB24s9SwbCyQxEWpQ7MyeQ';

  bool get isInitialized => _initialized;

  /// Initialize the AI service (no system instruction — general purpose)
  Future<void> initialize() async {
    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
      _initialized = true;
      print('✅ Gemini AI Service initialized');
    } catch (e) {
      print('❌ Error initializing Gemini AI: $e');
      _initialized = false;
      rethrow;
    }
  }

  /// Create a model instance with a specific system instruction for PDF context
  GenerativeModel _createModelWithContext(String systemPrompt) {
    return GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// Start a new chat session with optional PDF context
  void startChatSession({String? pdfContext}) {
    if (!_initialized && _model == null) {
      throw Exception('AI Service not initialized. Call initialize() first.');
    }

    if (pdfContext != null && pdfContext.isNotEmpty) {
      // Create a dedicated model with PDF context as system instruction
      final contextModel = _createModelWithContext(
        'You are MAID, an intelligent AI assistant for PDF documents. '
        'You help users understand, analyze, and extract insights from their documents. '
        'Here is the content of the PDF the user is reading:\n\n'
        '$pdfContext\n\n'
        'Answer questions about this document accurately and helpfully. '
        'If asked about something not in the document, say so clearly.',
      );
      _chatSession = contextModel.startChat();
    } else {
      _chatSession = _model!.startChat();
    }
  }

  /// Send a message in the current chat session
  Future<String> sendChatMessage(String message) async {
    if (_chatSession == null) {
      startChatSession();
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'No response from AI';
    } catch (e) {
      print('❌ Chat error: $e');
      return _formatError(e);
    }
  }

  /// Ask a one-time question (no chat history)
  Future<String> askQuestion(String question, {String? pdfContext}) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      GenerativeModel model;
      if (pdfContext != null && pdfContext.isNotEmpty) {
        model = _createModelWithContext(
          'You are MAID, an AI assistant. Answer based on this PDF content:\n\n$pdfContext',
        );
      } else {
        model = _model!;
      }

      final response = await model.generateContent([Content.text(question)]);
      return response.text ?? 'No response from AI';
    } catch (e) {
      print('❌ Question error: $e');
      return _formatError(e);
    }
  }

  /// Analyze and summarize PDF content
  Future<String> analyzePdf(String pdfText, {int maxLength = 500}) async {
    if (!_initialized) await initialize();

    try {
      // Truncate to avoid token limits
      String text = pdfText;
      if (text.length > 8000) {
        text = '${text.substring(0, 8000)}...';
      }

      final model = _createModelWithContext(
        'You are a document analyzer. Provide structured, clear analysis.',
      );

      final prompt = '''
Analyze this document and provide:
1. **Summary** (2-3 sentences)
2. **Main Topics** covered
3. **Key Takeaways**

Document:
$text
''';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to analyze PDF';
    } catch (e) {
      print('❌ Analysis error: $e');
      return _formatError(e);
    }
  }

  /// Summarize selected text
  Future<String> summarizeText(String text) async {
    if (!_initialized) await initialize();

    try {
      final response = await _model!.generateContent([
        Content.text('Summarize this text concisely:\n\n$text'),
      ]);
      return response.text ?? 'Unable to summarize';
    } catch (e) {
      print('❌ Summarize error: $e');
      return _formatError(e);
    }
  }

  /// Explain text in simpler terms
  Future<String> simplifyText(String text) async {
    if (!_initialized) await initialize();

    try {
      final response = await _model!.generateContent([
        Content.text('Explain this text in simple, easy-to-understand language:\n\n$text'),
      ]);
      return response.text ?? 'Unable to simplify';
    } catch (e) {
      print('❌ Simplify error: $e');
      return _formatError(e);
    }
  }

  /// Extract key points from text
  Future<String> extractKeyPoints(String text) async {
    if (!_initialized) await initialize();

    try {
      final response = await _model!.generateContent([
        Content.text('Extract the key points from this text as a clear bulleted list:\n\n$text'),
      ]);
      return response.text ?? 'Unable to extract key points';
    } catch (e) {
      print('❌ Extract error: $e');
      return _formatError(e);
    }
  }

  /// Generate study questions about the text
  Future<List<String>> generateQuestions(String text, {int count = 5}) async {
    if (!_initialized) await initialize();

    try {
      final response = await _model!.generateContent([
        Content.text(
          'Generate $count thought-provoking questions about this text. '
          'Return only the questions, one per line, numbered.\n\n$text',
        ),
      ]);

      final questionText = response.text ?? '';
      return questionText.split('\n').where((q) => q.trim().isNotEmpty).toList();
    } catch (e) {
      print('❌ Question generation error: $e');
      return ['Error generating questions: ${e.toString()}'];
    }
  }

  /// End the current chat session
  void endChatSession() {
    _chatSession = null;
  }

  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
    _initialized = false;
  }

  /// Format error messages for the user
  String _formatError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('api key') || msg.contains('permission')) {
      return '⚠️ API key error. Please check your Gemini API key configuration.';
    } else if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return '⚠️ Network error. Please check your internet connection and try again.';
    } else if (msg.contains('quota') || msg.contains('rate')) {
      return '⚠️ Rate limit reached. Please wait a moment and try again.';
    } else if (msg.contains('safety')) {
      return '⚠️ The content was flagged by safety filters. Please try a different query.';
    }
    return '⚠️ AI error: ${e.toString()}';
  }
}
