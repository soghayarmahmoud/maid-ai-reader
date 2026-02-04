import 'package:flutter/foundation.dart';
import '../data/translation_service.dart';
import '../domain/entities/language.dart';
import '../domain/entities/translation_result.dart';
import '../domain/translate_text.dart';
import '../domain/repositories/translation_repository.dart';

/// State for translation operations
enum TranslationState { idle, detectingLanguage, translating, success, error }

/// ViewModel for managing translation state
class TranslationViewModel extends ChangeNotifier {
  final TranslateTextUseCase _translateUseCase;
  final TranslationRepository _repository;

  Language _sourceLanguage = SupportedLanguages.defaultSourceLanguage;
  Language _targetLanguage = SupportedLanguages.defaultTargetLanguage;
  TranslationState _state = TranslationState.idle;
  TranslationResult? _lastResult;
  String? _errorMessage;
  List<TranslationResult> _history = [];

  TranslationViewModel({required TranslationRepository repository})
    : _repository = repository,
      _translateUseCase = TranslateTextUseCase(repository);

  /// Factory constructor using API key
  factory TranslationViewModel.withApiKey(String apiKey) {
    final repository = TranslationService(apiKey: apiKey);
    return TranslationViewModel(repository: repository);
  }

  /// Factory constructor using mock service (for testing/demo)
  factory TranslationViewModel.mock() {
    final repository = MockTranslationService();
    return TranslationViewModel(repository: repository);
  }

  // Getters
  Language get sourceLanguage => _sourceLanguage;
  Language get targetLanguage => _targetLanguage;
  TranslationState get state => _state;
  TranslationResult? get lastResult => _lastResult;
  String? get errorMessage => _errorMessage;
  List<TranslationResult> get history => List.unmodifiable(_history);
  bool get isLoading =>
      _state == TranslationState.translating ||
      _state == TranslationState.detectingLanguage;
  List<Language> get supportedLanguages =>
      _translateUseCase.getSupportedLanguages();

  /// Set source language
  void setSourceLanguage(Language language) {
    if (_sourceLanguage != language) {
      _sourceLanguage = language;
      // Ensure target is different
      if (_targetLanguage.code == language.code) {
        _targetLanguage = SupportedLanguages.all.firstWhere(
          (lang) => lang.code != language.code,
          orElse: () => SupportedLanguages.defaultTargetLanguage,
        );
      }
      notifyListeners();
    }
  }

  /// Set target language
  void setTargetLanguage(Language language) {
    if (_targetLanguage != language) {
      _targetLanguage = language;
      // Ensure source is different
      if (_sourceLanguage.code == language.code) {
        _sourceLanguage = SupportedLanguages.all.firstWhere(
          (lang) => lang.code != language.code,
          orElse: () => SupportedLanguages.defaultSourceLanguage,
        );
      }
      notifyListeners();
    }
  }

  /// Swap source and target languages
  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }

  /// Detect language of text
  Future<void> detectLanguage(String text) async {
    if (text.trim().isEmpty) return;

    _state = TranslationState.detectingLanguage;
    notifyListeners();

    try {
      final detected = await _translateUseCase.detectLanguage(text);
      if (detected != null) {
        _sourceLanguage = detected;
        // Ensure target is different
        if (_targetLanguage.code == detected.code) {
          _targetLanguage = SupportedLanguages.all.firstWhere(
            (lang) => lang.code != detected.code,
            orElse: () => SupportedLanguages.defaultTargetLanguage,
          );
        }
      }
      _state = TranslationState.idle;
    } catch (e) {
      _state = TranslationState.idle;
    }

    notifyListeners();
  }

  /// Translate text
  Future<TranslationResult> translate(String text) async {
    if (text.trim().isEmpty) {
      final errorResult = TranslationResult.failure(
        originalText: text,
        sourceLanguage: _sourceLanguage,
        targetLanguage: _targetLanguage,
        errorMessage: 'Text cannot be empty',
      );
      _lastResult = errorResult;
      _errorMessage = errorResult.errorMessage;
      _state = TranslationState.error;
      notifyListeners();
      return errorResult;
    }

    _state = TranslationState.translating;
    _errorMessage = null;
    notifyListeners();

    final result = await _translateUseCase.execute(
      text: text,
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
    );

    _lastResult = result;

    if (result.isSuccess) {
      _state = TranslationState.success;
      _history.insert(0, result);
      // Keep only last 50 translations in history
      if (_history.length > 50) {
        _history = _history.sublist(0, 50);
      }
    } else {
      _state = TranslationState.error;
      _errorMessage = result.errorMessage;
    }

    notifyListeners();
    return result;
  }

  /// Clear translation result
  void clearResult() {
    _lastResult = null;
    _errorMessage = null;
    _state = TranslationState.idle;
    notifyListeners();
  }

  /// Clear translation history
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  /// Reset to initial state
  void reset() {
    _sourceLanguage = SupportedLanguages.defaultSourceLanguage;
    _targetLanguage = SupportedLanguages.defaultTargetLanguage;
    _state = TranslationState.idle;
    _lastResult = null;
    _errorMessage = null;
    notifyListeners();
  }
}
