import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/pdf_search_result.dart';
import '../../services/pdf_text_search_service.dart';

/// A comprehensive PDF search widget with text input, result navigation,
/// and highlighting support
class PdfSearchWidget extends StatefulWidget {
  /// The search service instance
  final PdfTextSearchService searchService;

  /// Callback when search is toggled off
  final VoidCallback? onClose;

  /// Callback when navigating to a result
  final Function(PdfSearchResult result)? onNavigateToResult;

  /// Whether to show the result list panel
  final bool showResultsList;

  const PdfSearchWidget({
    super.key,
    required this.searchService,
    this.onClose,
    this.onNavigateToResult,
    this.showResultsList = true,
  });

  @override
  State<PdfSearchWidget> createState() => _PdfSearchWidgetState();
}

class _PdfSearchWidgetState extends State<PdfSearchWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _showOptions = false;
  bool _showResultsPanel = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    await widget.searchService.search(
      query,
      caseSensitive: _caseSensitive,
      wholeWord: _wholeWord,
    );
  }

  void _nextResult() async {
    await widget.searchService.nextResult();
    final session = widget.searchService.currentSession;
    if (session.hasCurrentResult && widget.onNavigateToResult != null) {
      widget.onNavigateToResult!(session.currentResult!);
    }
  }

  void _previousResult() async {
    await widget.searchService.previousResult();
    final session = widget.searchService.currentSession;
    if (session.hasCurrentResult && widget.onNavigateToResult != null) {
      widget.onNavigateToResult!(session.currentResult!);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    widget.searchService.clearSearch();
    setState(() {
      _showResultsPanel = false;
    });
  }

  void _close() async {
    await _animationController.reverse();
    widget.searchService.clearSearch();
    widget.onClose?.call();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
  }

  void _toggleResultsPanel() {
    setState(() {
      _showResultsPanel = !_showResultsPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: StreamBuilder<PdfSearchSession>(
        stream: widget.searchService.searchState,
        initialData: widget.searchService.currentSession,
        builder: (context, snapshot) {
          final session = snapshot.data ?? const PdfSearchSession(query: '');

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main search bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search input row
                    Row(
                      children: [
                        // Search field
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Search in PDF...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                        colorScheme.outline.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: colorScheme.primary, width: 2),
                              ),
                              prefixIcon: session.isSearching
                                  ? Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.search,
                                      color: colorScheme.onSurfaceVariant),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear,
                                          color: colorScheme.onSurfaceVariant),
                                      onPressed: _clearSearch,
                                      tooltip: 'Clear search',
                                    )
                                  : null,
                              isDense: true,
                            ),
                            onSubmitted: (_) => _performSearch(),
                            onChanged: (_) => setState(() {}),
                            textInputAction: TextInputAction.search,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Result counter and navigation
                        if (session.hasResults) ...[
                          // Result counter
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${session.currentResultIndex + 1}/${session.totalResults}',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          // Navigation buttons
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up),
                            onPressed: _previousResult,
                            tooltip: 'Previous result',
                            iconSize: 24,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: _nextResult,
                            tooltip: 'Next result',
                            iconSize: 24,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ] else if (!session.isSearching &&
                            _searchController.text.isNotEmpty &&
                            session.query.isNotEmpty) ...[
                          // No results indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No results',
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],

                        // Options toggle
                        IconButton(
                          icon: Icon(
                            _showOptions ? Icons.tune : Icons.tune_outlined,
                            color: _showOptions
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          onPressed: _toggleOptions,
                          tooltip: 'Search options',
                        ),

                        // Results list toggle
                        if (session.hasResults && widget.showResultsList)
                          IconButton(
                            icon: Icon(
                              _showResultsPanel
                                  ? Icons.list
                                  : Icons.list_outlined,
                              color: _showResultsPanel
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _toggleResultsPanel,
                            tooltip: 'Show results list',
                          ),

                        // Close button
                        IconButton(
                          icon: Icon(Icons.close,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: _close,
                          tooltip: 'Close search',
                        ),
                      ],
                    ),

                    // Search options
                    if (_showOptions)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            _buildOptionChip(
                              label: 'Case sensitive',
                              value: _caseSensitive,
                              onChanged: (value) {
                                setState(() {
                                  _caseSensitive = value;
                                });
                                if (_searchController.text.isNotEmpty) {
                                  _performSearch();
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildOptionChip(
                              label: 'Whole word',
                              value: _wholeWord,
                              onChanged: (value) {
                                setState(() {
                                  _wholeWord = value;
                                });
                                if (_searchController.text.isNotEmpty) {
                                  _performSearch();
                                }
                              },
                            ),
                            const Spacer(),
                            // Keyboard shortcuts hint
                            Text(
                              'Enter to search • ↑↓ to navigate',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Results panel
              if (_showResultsPanel && session.hasResults)
                _buildResultsPanel(session, colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: value,
      onSelected: onChanged,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildResultsPanel(PdfSearchSession session, ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: session.results.length,
        itemBuilder: (context, index) {
          final result = session.results[index];
          final isSelected = index == session.currentResultIndex;

          return ListTile(
            dense: true,
            selected: isSelected,
            selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
            leading: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${result.pageNumber}',
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            title: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: result.matchedText,
                    style: TextStyle(
                      backgroundColor: colorScheme.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (result.contextText.isNotEmpty)
                    TextSpan(
                      text: ' ${result.contextText}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            subtitle: Text(
              'Page ${result.pageNumber} • Result ${result.resultIndex + 1}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
            onTap: () async {
              await widget.searchService.navigateToResult(index);
              if (widget.onNavigateToResult != null) {
                widget.onNavigateToResult!(result);
              }
            },
          );
        },
      ),
    );
  }
}

/// A floating search bar that can be positioned anywhere
class FloatingPdfSearchBar extends StatelessWidget {
  final PdfTextSearchService searchService;
  final VoidCallback? onClose;
  final Function(PdfSearchResult result)? onNavigateToResult;

  const FloatingPdfSearchBar({
    super.key,
    required this.searchService,
    this.onClose,
    this.onNavigateToResult,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PdfSearchWidget(
          searchService: searchService,
          onClose: onClose,
          onNavigateToResult: onNavigateToResult,
          showResultsList: false,
        ),
      ),
    );
  }
}

/// Keyboard shortcuts handler for search
class PdfSearchKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback onToggleSearch;
  final VoidCallback? onNextResult;
  final VoidCallback? onPreviousResult;
  final VoidCallback? onCloseSearch;

  const PdfSearchKeyboardShortcuts({
    super.key,
    required this.child,
    required this.onToggleSearch,
    this.onNextResult,
    this.onPreviousResult,
    this.onCloseSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        // Ctrl+F to open search
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
            const _ToggleSearchIntent(),
        // F3 or Enter for next result
        const SingleActivator(LogicalKeyboardKey.f3): const _NextResultIntent(),
        // Shift+F3 for previous result
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.f3):
            const _PreviousResultIntent(),
        // Escape to close
        const SingleActivator(LogicalKeyboardKey.escape):
            const _CloseSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ToggleSearchIntent: CallbackAction<_ToggleSearchIntent>(
            onInvoke: (_) {
              onToggleSearch();
              return null;
            },
          ),
          _NextResultIntent: CallbackAction<_NextResultIntent>(
            onInvoke: (_) {
              onNextResult?.call();
              return null;
            },
          ),
          _PreviousResultIntent: CallbackAction<_PreviousResultIntent>(
            onInvoke: (_) {
              onPreviousResult?.call();
              return null;
            },
          ),
          _CloseSearchIntent: CallbackAction<_CloseSearchIntent>(
            onInvoke: (_) {
              onCloseSearch?.call();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _ToggleSearchIntent extends Intent {
  const _ToggleSearchIntent();
}

class _NextResultIntent extends Intent {
  const _NextResultIntent();
}

class _PreviousResultIntent extends Intent {
  const _PreviousResultIntent();
}

class _CloseSearchIntent extends Intent {
  const _CloseSearchIntent();
}
