import 'package:flutter/material.dart';
import '../../domain/entities/pdf_search_result.dart';
import '../../services/pdf_text_search_service.dart';

/// Overlay widget to show search result indicators
/// Shows a floating indicator with result count and navigation
class PdfSearchResultsOverlay extends StatelessWidget {
  final PdfTextSearchService searchService;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback? onShowResults;

  const PdfSearchResultsOverlay({
    super.key,
    required this.searchService,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    this.onShowResults,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PdfSearchSession>(
      stream: searchService.searchState,
      initialData: searchService.currentSession,
      builder: (context, snapshot) {
        final session = snapshot.data ?? const PdfSearchSession(query: '');

        if (!session.hasResults && !session.isSearching) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 80,
          right: 16,
          child: _SearchResultIndicator(
            session: session,
            onPrevious: onPrevious,
            onNext: onNext,
            onClose: onClose,
            onShowResults: onShowResults,
          ),
        );
      },
    );
  }
}

class _SearchResultIndicator extends StatelessWidget {
  final PdfSearchSession session;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;
  final VoidCallback? onShowResults;

  const _SearchResultIndicator({
    required this.session,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
    this.onShowResults,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: session.isSearching
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                  : Text(
                      session.hasResults
                          ? '${session.currentResultIndex + 1} of ${session.totalResults}'
                          : 'No results',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
            ),

            if (session.hasResults) ...[
              // Previous button
              IconButton(
                icon: Icon(
                  Icons.arrow_upward,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                onPressed: onPrevious,
                tooltip: 'Previous result (Shift+F3)',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),

              // Next button
              IconButton(
                icon: Icon(
                  Icons.arrow_downward,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                onPressed: onNext,
                tooltip: 'Next result (F3)',
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),

              // Show all results
              if (onShowResults != null)
                IconButton(
                  icon: Icon(
                    Icons.list,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                  onPressed: onShowResults,
                  tooltip: 'Show all results',
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
            ],

            // Close button
            IconButton(
              icon: Icon(
                Icons.close,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
              onPressed: onClose,
              tooltip: 'Close search (Esc)',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

/// Page indicator showing which pages have search results
class SearchPageIndicator extends StatelessWidget {
  final PdfSearchSession session;
  final int currentPage;
  final int totalPages;
  final Function(int page) onPageTap;

  const SearchPageIndicator({
    super.key,
    required this.session,
    required this.currentPage,
    required this.totalPages,
    required this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!session.hasResults) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pagesWithResults = session.pagesWithResults;

    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(2),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: pagesWithResults.map((page) {
              final position = (page - 1) / totalPages;
              final hasResultOnCurrentPage = page == currentPage;

              return Positioned(
                left: constraints.maxWidth * position,
                child: GestureDetector(
                  onTap: () => onPageTap(page),
                  child: Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: hasResultOnCurrentPage
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

/// Results summary panel that shows grouped results by page
class SearchResultsSummaryPanel extends StatelessWidget {
  final PdfSearchSession session;
  final Function(int resultIndex) onResultTap;
  final VoidCallback onClose;

  const SearchResultsSummaryPanel({
    super.key,
    required this.session,
    required this.onResultTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resultsByPage = session.resultsByPage;

    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${session.totalResults} results for "${session.query}"',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Results by page
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: resultsByPage.length,
                itemBuilder: (context, index) {
                  final page = resultsByPage.keys.elementAt(index);
                  final pageResults = resultsByPage[page]!;
                  final resultsOnPage = pageResults.length;

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        '$page',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      'Page $page',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$resultsOnPage ${resultsOnPage == 1 ? 'result' : 'results'}',
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () => onResultTap(pageResults.first.resultIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact inline search result indicator
class InlineSearchResultIndicator extends StatelessWidget {
  final int currentResult;
  final int totalResults;
  final bool isSearching;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const InlineSearchResultIndicator({
    super.key,
    required this.currentResult,
    required this.totalResults,
    required this.isSearching,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSearching)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          )
        else if (totalResults > 0)
          Text(
            '${currentResult + 1}/$totalResults',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            'No results',
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 13,
            ),
          ),
        if (totalResults > 0) ...[
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.arrow_upward, size: 18),
            onPressed: onPrevious,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, size: 18),
            onPressed: onNext,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ],
    );
  }
}
