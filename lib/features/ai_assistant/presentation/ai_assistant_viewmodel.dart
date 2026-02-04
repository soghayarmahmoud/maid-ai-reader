import 'package:flutter/foundation.dart';
import '../data/ai_assistant_service.dart';
import '../domain/entities/ai_query.dart';
import '../domain/entities/ai_assistant_response.dart';
import '../domain/usecases/ask_ai_usecase.dart';

/// ViewModel for AI Assistant feature
class AIAssistantViewModel extends ChangeNotifier {
  final AskAIUseCase _askAIUseCase;
  final AIAssistantService _service;

  AIAssistantState _state = AIAssistantState.idle;
  AIAssistantResponse? _currentResponse;
  AIQueryType _selectedQueryType = AIQueryType.explain;
  String? _errorMessage;
  List<AIAssistantResponse> _history = [];

  AIAssistantViewModel({required AIAssistantService service})
    : _service = service,
      _askAIUseCase = AskAIUseCase(service);

  /// Create with API key
  factory AIAssistantViewModel.withApiKey(String apiKey) {
    return AIAssistantViewModel(service: AIAssistantService.withApiKey(apiKey));
  }

  /// Create mock for testing
  factory AIAssistantViewModel.mock() {
    return AIAssistantViewModel(service: AIAssistantService.mock());
  }

  // Getters
  AIAssistantState get state => _state;
  AIAssistantResponse? get currentResponse => _currentResponse;
  AIQueryType get selectedQueryType => _selectedQueryType;
  String? get errorMessage => _errorMessage;
  List<AIAssistantResponse> get history => List.unmodifiable(_history);
  bool get isLoading => _state == AIAssistantState.loading;
  bool get hasResponse =>
      _currentResponse != null && _currentResponse!.isSuccess;

  /// Set the query type
  void setQueryType(AIQueryType type) {
    if (_selectedQueryType != type) {
      _selectedQueryType = type;
      notifyListeners();
    }
  }

  /// Ask AI about selected text
  Future<AIAssistantResponse> askAboutText({
    required String selectedText,
    String? context,
    String? customPrompt,
    DocumentContext? documentContext,
  }) async {
    _state = AIAssistantState.loading;
    _errorMessage = null;
    notifyListeners();

    final query = AIQuery(
      selectedText: selectedText,
      context: context,
      queryType: _selectedQueryType,
      customPrompt: customPrompt,
      documentContext: documentContext,
    );

    final response = await _askAIUseCase.execute(query);

    _currentResponse = response;

    if (response.isSuccess) {
      _state = AIAssistantState.success;
      _history.insert(0, response);
      // Keep only last 20 responses
      if (_history.length > 20) {
        _history = _history.sublist(0, 20);
      }
    } else {
      _state = AIAssistantState.error;
      _errorMessage = response.errorMessage;
    }

    notifyListeners();
    return response;
  }

  /// Quick actions
  Future<AIAssistantResponse> explain(
    String text, {
    DocumentContext? documentContext,
  }) async {
    _selectedQueryType = AIQueryType.explain;
    return askAboutText(selectedText: text, documentContext: documentContext);
  }

  Future<AIAssistantResponse> summarize(
    String text, {
    DocumentContext? documentContext,
  }) async {
    _selectedQueryType = AIQueryType.summarize;
    return askAboutText(selectedText: text, documentContext: documentContext);
  }

  Future<AIAssistantResponse> define(
    String text, {
    DocumentContext? documentContext,
  }) async {
    _selectedQueryType = AIQueryType.define;
    return askAboutText(selectedText: text, documentContext: documentContext);
  }

  Future<AIAssistantResponse> analyze(
    String text, {
    DocumentContext? documentContext,
  }) async {
    _selectedQueryType = AIQueryType.analyze;
    return askAboutText(selectedText: text, documentContext: documentContext);
  }

  Future<AIAssistantResponse> askQuestion(
    String text,
    String question, {
    DocumentContext? documentContext,
  }) async {
    _selectedQueryType = AIQueryType.question;
    return askAboutText(
      selectedText: text,
      customPrompt: question,
      documentContext: documentContext,
    );
  }

  /// Clear current response
  void clearResponse() {
    _currentResponse = null;
    _errorMessage = null;
    _state = AIAssistantState.idle;
    notifyListeners();
  }

  /// Clear history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _state = AIAssistantState.idle;
    _currentResponse = null;
    _errorMessage = null;
    _selectedQueryType = AIQueryType.explain;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
