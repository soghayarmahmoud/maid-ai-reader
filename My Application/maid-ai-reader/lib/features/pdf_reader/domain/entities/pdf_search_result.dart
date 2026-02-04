import 'package:equatable/equatable.dart';

/// Represents a single search result in a PDF document
class PdfSearchResult extends Equatable {
  /// The matched text
  final String matchedText;

  /// The page number where the match was found (1-indexed)
  final int pageNumber;

  /// The index of this result in the list of all results
  final int resultIndex;

  /// Context text around the match for preview
  final String contextText;

  /// Start position of the match in the context
  final int matchStartInContext;

  /// Whether this result is currently selected/focused
  final bool isSelected;

  const PdfSearchResult({
    required this.matchedText,
    required this.pageNumber,
    required this.resultIndex,
    this.contextText = '',
    this.matchStartInContext = 0,
    this.isSelected = false,
  });

  /// Create a copy with updated selection state
  PdfSearchResult copyWith({
    String? matchedText,
    int? pageNumber,
    int? resultIndex,
    String? contextText,
    int? matchStartInContext,
    bool? isSelected,
  }) {
    return PdfSearchResult(
      matchedText: matchedText ?? this.matchedText,
      pageNumber: pageNumber ?? this.pageNumber,
      resultIndex: resultIndex ?? this.resultIndex,
      contextText: contextText ?? this.contextText,
      matchStartInContext: matchStartInContext ?? this.matchStartInContext,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
        matchedText,
        pageNumber,
        resultIndex,
        contextText,
        matchStartInContext,
        isSelected,
      ];

  @override
  String toString() =>
      'PdfSearchResult(page: $pageNumber, text: "$matchedText", index: $resultIndex)';
}

/// Represents a complete search session with all results
class PdfSearchSession extends Equatable {
  /// The search query
  final String query;

  /// All search results
  final List<PdfSearchResult> results;

  /// Index of the currently focused result (-1 if none)
  final int currentResultIndex;

  /// Whether the search is case sensitive
  final bool caseSensitive;

  /// Whether to match whole words only
  final bool wholeWord;

  /// Whether the search is in progress
  final bool isSearching;

  /// Error message if search failed
  final String? errorMessage;

  const PdfSearchSession({
    required this.query,
    this.results = const [],
    this.currentResultIndex = -1,
    this.caseSensitive = false,
    this.wholeWord = false,
    this.isSearching = false,
    this.errorMessage,
  });

  /// Total number of results found
  int get totalResults => results.length;

  /// Whether there are any results
  bool get hasResults => results.isNotEmpty;

  /// Whether there's a current result selected
  bool get hasCurrentResult =>
      currentResultIndex >= 0 && currentResultIndex < results.length;

  /// Get the current result, or null if none
  PdfSearchResult? get currentResult =>
      hasCurrentResult ? results[currentResultIndex] : null;

  /// Get results grouped by page number
  Map<int, List<PdfSearchResult>> get resultsByPage {
    final grouped = <int, List<PdfSearchResult>>{};
    for (final result in results) {
      grouped.putIfAbsent(result.pageNumber, () => []).add(result);
    }
    return grouped;
  }

  /// Get the list of pages that have results
  List<int> get pagesWithResults => resultsByPage.keys.toList()..sort();

  /// Create a copy with updated values
  PdfSearchSession copyWith({
    String? query,
    List<PdfSearchResult>? results,
    int? currentResultIndex,
    bool? caseSensitive,
    bool? wholeWord,
    bool? isSearching,
    String? errorMessage,
  }) {
    return PdfSearchSession(
      query: query ?? this.query,
      results: results ?? this.results,
      currentResultIndex: currentResultIndex ?? this.currentResultIndex,
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: errorMessage,
    );
  }

  /// Clear the search session
  PdfSearchSession clear() {
    return const PdfSearchSession(query: '');
  }

  @override
  List<Object?> get props => [
        query,
        results,
        currentResultIndex,
        caseSensitive,
        wholeWord,
        isSearching,
        errorMessage,
      ];
}
