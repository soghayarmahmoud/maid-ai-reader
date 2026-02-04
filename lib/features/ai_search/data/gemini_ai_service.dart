import 'package:google_generative_ai/google_generative_ai.dart';

/// Google Gemini AI Service Implementation
/// 
/// This service provides AI-powered features for PDF analysis, chat, and summarization.
/// Uses Google's Gemini API (FREE tier available: 15 requests/min, 1500/day)
class GeminiAiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  
  /// TODO: Add your Gemini API key here
  /// Get your free API key from: https://makersuite.google.com/app/apikey
  /// 
  /// IMPORTANT: For production, store this in flutter_secure_storage
  /// or environment variables, NOT hardcoded!
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // TODO: Replace with your API key
  
  /// Initialize the AI service
  Future<void> initialize() async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      print('⚠️ WARNING: Gemini API key not configured!');
      print('📝 Add your API key in lib/features/ai_search/data/gemini_ai_service.dart');
      print('🔗 Get free API key: https://makersuite.google.com/app/apikey');
      return;
    }
    
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Free tier model
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );
      
      print('✅ Gemini AI Service initialized successfully!');
    } catch (e) {
      print('❌ Error initializing Gemini AI: $e');
      rethrow;
    }
  }
  
  /// Start a new chat session
  void startChatSession({String? pdfContext}) {
    if (_model == null) {
      throw Exception('AI Service not initialized. Call initialize() first.');
    }
    
    final systemInstruction = pdfContext != null
        ? 'You are an AI assistant helping users understand a PDF document. '
            'Here is some context from the document:\n\n$pdfContext\n\n'
            'Answer questions based on this context and provide helpful insights.'
        : 'You are an AI assistant helping users with their PDF documents. '
            'Provide clear, concise, and helpful answers.';
    
    _chatSession = _model!.startChat(
      history: [
        Content.text(systemInstruction),
      ],
    );
  }
  
  /// Send a message in the current chat session
  Future<String> sendChatMessage(String message) async {
    if (_chatSession == null) {
      startChatSession();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return '⚠️ API key not configured. Please add your Gemini API key to use AI features.\n\n'
          'Get your free API key from: https://makersuite.google.com/app/apikey\n\n'
          'The free tier includes:\n'
          '• 15 requests per minute\n'
          '• 1500 requests per day\n'
          '• No credit card required';
    }
    
    try {
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'No response from AI';
    } catch (e) {
      print('❌ Error sending chat message: $e');
      return 'Error: Unable to get AI response. Please check your API key and internet connection.';
    }
  }
  
  /// Ask a question about PDF content (one-time query, no chat history)
  Future<String> askQuestion(String question, {String? pdfContext}) async {
    if (_model == null) {
      await initialize();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return '⚠️ API key not configured. Please add your Gemini API key to use AI features.';
    }
    
    try {
      final prompt = pdfContext != null
          ? 'Based on this PDF content:\n\n$pdfContext\n\nQuestion: $question'
          : question;
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'No response from AI';
    } catch (e) {
      print('❌ Error asking question: $e');
      return 'Error: Unable to get AI response. Please check your API key and internet connection.';
    }
  }
  
  /// Analyze and summarize PDF content
  Future<String> analyzePdf(String pdfText, {int maxLength = 500}) async {
    if (_model == null) {
      await initialize();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return '⚠️ API key not configured.';
    }
    
    try {
      // Truncate PDF text if too long (to avoid token limits)
      String textToAnalyze = pdfText;
      if (textToAnalyze.length > 8000) {
        textToAnalyze = textToAnalyze.substring(0, 8000) + '...';
      }
      
      final prompt = '''
Analyze this PDF document and provide:
1. A concise summary (2-3 sentences)
2. Main topics covered
3. Key takeaways

PDF Content:
$textToAnalyze

Please provide the analysis in a clear, structured format.
''';
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'Unable to analyze PDF';
    } catch (e) {
      print('❌ Error analyzing PDF: $e');
      return 'Error analyzing PDF: $e';
    }
  }
  
  /// Summarize selected text
  Future<String> summarizeText(String text) async {
    if (_model == null) {
      await initialize();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return '⚠️ API key not configured.';
    }
    
    try {
      final prompt = 'Summarize this text concisely:\n\n$text';
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'Unable to summarize';
    } catch (e) {
      print('❌ Error summarizing text: $e');
      return 'Error: $e';
    }
  }
  
  /// Explain text in simpler terms
  Future<String> simplifyText(String text) async {
    if (_model == null) {
      await initialize();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return '⚠️ API key not configured.';
    }
    
    try {
      final prompt = 'Explain this text in simple, easy-to-understand language:\n\n$text';
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      return response.text ?? 'Unable to simplify';
    } catch (e) {
      print('❌ Error simplifying text: $e');
      return 'Error: $e';
    }
  }
  
  /// Generate questions about the text (for studying)
  Future<List<String>> generateQuestions(String text, {int count = 5}) async {
    if (_model == null) {
      await initialize();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return ['⚠️ API key not configured.'];
    }
    
    try {
      final prompt = '''
Generate $count thought-provoking questions about this text that would help someone better understand it:

$text

Return only the questions, one per line, numbered.
''';
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final questionText = response.text ?? '';
      return questionText.split('\n').where((q) => q.trim().isNotEmpty).toList();
    } catch (e) {
      print('❌ Error generating questions: $e');
      return ['Error generating questions'];
    }
  }
  
  /// Extract key points from text
  Future<List<String>> extractKeyPoints(String text) async {
    if (_model == null) {
      await initialize();
    }
    
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return ['⚠️ API key not configured.'];
    }
    
    try {
      final prompt = '''
Extract the key points from this text. Return only the key points as a bulleted list:

$text
''';
      
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      final keyPointsText = response.text ?? '';
      return keyPointsText.split('\n').where((p) => p.trim().isNotEmpty).toList();
    } catch (e) {
      print('❌ Error extracting key points: $e');
      return ['Error extracting key points'];
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
  }
}
