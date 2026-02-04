import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../domain/entities/pdf_search_result.dart';

/// Service to handle PDF text search operations
/// Optimized for large documents with result tracking and navigation
class PdfTextSearchService {
  /// The PDF viewer controller
  final PdfViewerController pdfController;

  /// Current search session
  PdfSearchSession _currentSession = const PdfSearchSession(query: '');

  /// Search text instance from Syncfusion
  PdfTextSearchResult? _syncfusionSearchResult;

  /// Stream controller for search state updates
  final _searchStateController = StreamController<PdfSearchSession>.broadcast();

  /// Stream of search state updates
  Stream<PdfSearchSession> get searchState => _searchStateController.stream;

  /// Get current search session
  PdfSearchSession get currentSession => _currentSession;

  /// Total count of search instances found
  int _totalInstanceCount = 0;

  /// Current instance index
  int _currentInstanceIndex = 0;

  PdfTextSearchService({required this.pdfController});

  /// Perform a text search in the PDF
  /// Returns the search session with results
  Future<PdfSearchSession> search(
    String query, {
    bool caseSensitive = false,
    bool wholeWord = false,
  }) async {
    if (query.isEmpty) {
      clearSearch();
      return _currentSession;
    }

    // Clear previous search
    if (_syncfusionSearchResult != null) {
      _syncfusionSearchResult!.clear();
      _syncfusionSearchResult = null;
    }

    // Start new search - mark as searching
    _updateSession(PdfSearchSession(
      query: query,
      caseSensitive: caseSensitive,
      wholeWord: wholeWord,
      isSearching: true,
    ));

    try {
      // Get search option
      TextSearchOption? searchOption;
      if (caseSensitive && wholeWord) {
        searchOption = TextSearchOption.both;
      } else if (caseSensitive) {
        searchOption = TextSearchOption.caseSensitive;
      } else if (wholeWord) {
        searchOption = TextSearchOption.wholeWords;
      }

      // Perform search with Syncfusion
      _syncfusionSearchResult = pdfController.searchText(
        query,
        searchOption: searchOption,
      );

      // Reset counters
      _totalInstanceCount = 0;
      _currentInstanceIndex = 0;

      // Listen for search completion
      if (_syncfusionSearchResult != null) {
        // Give time for search to process
        await Future.delayed(const Duration(milliseconds: 100));

        // Count total instances
        if (_syncfusionSearchResult!.hasResult) {
          _totalInstanceCount = _syncfusionSearchResult!.totalInstanceCount;
          _currentInstanceIndex = 0;

          // Build results list
          final results = _buildResultsList(query);

          _updateSession(PdfSearchSession(
            query: query,
            results: results,
            currentResultIndex: results.isNotEmpty ? 0 : -1,
            caseSensitive: caseSensitive,
            wholeWord: wholeWord,
            isSearching: false,
          ));
        } else {
          // No results found
          _updateSession(PdfSearchSession(
            query: query,
            results: const [],
            currentResultIndex: -1,
            caseSensitive: caseSensitive,
            wholeWord: wholeWord,
            isSearching: false,
          ));
        }
      }

      return _currentSession;
    } catch (e) {
      debugPrint('Search error: $e');
      _updateSession(_currentSession.copyWith(
        isSearching: false,
        errorMessage: 'Search failed: $e',
      ));
      return _currentSession;
    }
  }

  /// Build a list of search results from the total count
  List<PdfSearchResult> _buildResultsList(String query) {
    final results = <PdfSearchResult>[];

    for (int i = 0; i < _totalInstanceCount && i < 10000; i++) {
      results.add(PdfSearchResult(
        matchedText: query,
        pageNumber: 0, // Will be updated when navigating
        resultIndex: i,
        isSelected: i == 0,
      ));
    }

    return results;
  }

  /// Navigate to a specific result by index
  Future<void> navigateToResult(int index) async {
    if (_syncfusionSearchResult == null ||
        index < 0 ||
        index >= _totalInstanceCount) {
      return;
    }

    // Navigate to the specific instance
    if (index > _currentInstanceIndex) {
      // Move forward
      while (_currentInstanceIndex < index) {
        _syncfusionSearchResult!.nextInstance();
        _currentInstanceIndex++;
      }
    } else if (index < _currentInstanceIndex) {
      // Move backward
      while (_currentInstanceIndex > index) {
        _syncfusionSearchResult!.previousInstance();
        _currentInstanceIndex--;
      }
    }

    // Update session with new current index
    _updateSession(_currentSession.copyWith(currentResultIndex: index));
  }

  /// Navigate to next search result
  Future<void> nextResult() async {
    if (_syncfusionSearchResult == null ||
        !_syncfusionSearchResult!.hasResult) {
      return;
    }

    _syncfusionSearchResult!.nextInstance();
    _currentInstanceIndex++;

    // Wrap around
    if (_currentInstanceIndex >= _totalInstanceCount) {
      _currentInstanceIndex = 0;
    }

    _updateSession(_currentSession.copyWith(
      currentResultIndex: _currentInstanceIndex,
    ));
  }

  /// Navigate to previous search result
  Future<void> previousResult() async {
    if (_syncfusionSearchResult == null ||
        !_syncfusionSearchResult!.hasResult) {
      return;
    }

    _syncfusionSearchResult!.previousInstance();
    _currentInstanceIndex--;

    // Wrap around
    if (_currentInstanceIndex < 0) {
      _currentInstanceIndex = _totalInstanceCount - 1;
    }

    _updateSession(_currentSession.copyWith(
      currentResultIndex: _currentInstanceIndex,
    ));
  }

  /// Navigate to first result on a specific page
  Future<void> navigateToPage(int pageNumber) async {
    // Jump to page and search will highlight automatically
    pdfController.jumpToPage(pageNumber);
  }

  /// Clear the current search
  void clearSearch() {
    if (_syncfusionSearchResult != null) {
      _syncfusionSearchResult!.clear();
      _syncfusionSearchResult = null;
    }
    _totalInstanceCount = 0;
    _currentInstanceIndex = 0;
    _updateSession(const PdfSearchSession(query: ''));
  }

  /// Update the current session and notify listeners
  void _updateSession(PdfSearchSession session) {
    _currentSession = session;
    if (!_searchStateController.isClosed) {
      _searchStateController.add(session);
    }
  }

  /// Dispose resources
  void dispose() {
    clearSearch();
    _searchStateController.close();
  }
}
