import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/ai/ai.dart';
import '../domain/entities/note_entity.dart';
import '../domain/usecases/summarize_content.dart';
import 'notes_viewmodel.dart';

/// State for summarization operations
enum SummarizeState { initial, loading, success, error }

/// Bottom sheet for summarizing content and saving to notes
class SummarizeSheet extends StatefulWidget {
  /// Text to summarize (selected text or page content)
  final String textToSummarize;

  /// Type of content being summarized
  final SummaryType summaryType;

  /// PDF path for note linking
  final String pdfPath;

  /// Page number for note linking
  final int pageNumber;

  /// Optional document title for context
  final String? documentTitle;

  /// Notes viewmodel for saving summaries
  final NotesViewModel? notesViewModel;

  const SummarizeSheet({
    super.key,
    required this.textToSummarize,
    required this.summaryType,
    required this.pdfPath,
    required this.pageNumber,
    this.documentTitle,
    this.notesViewModel,
  });

  /// Show the summarize sheet for selected text
  static Future<void> showForSelection(
    BuildContext context, {
    required String selectedText,
    required String pdfPath,
    required int pageNumber,
    String? documentTitle,
    NotesViewModel? notesViewModel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SummarizeSheet(
        textToSummarize: selectedText,
        summaryType: SummaryType.selection,
        pdfPath: pdfPath,
        pageNumber: pageNumber,
        documentTitle: documentTitle,
        notesViewModel: notesViewModel,
      ),
    );
  }

  /// Show the summarize sheet for a page
  static Future<void> showForPage(
    BuildContext context, {
    required String pageContent,
    required String pdfPath,
    required int pageNumber,
    String? documentTitle,
    NotesViewModel? notesViewModel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SummarizeSheet(
        textToSummarize: pageContent,
        summaryType: SummaryType.page,
        pdfPath: pdfPath,
        pageNumber: pageNumber,
        documentTitle: documentTitle,
        notesViewModel: notesViewModel,
      ),
    );
  }

  @override
  State<SummarizeSheet> createState() => _SummarizeSheetState();
}

class _SummarizeSheetState extends State<SummarizeSheet> {
  SummarizeState _state = SummarizeState.initial;
  String? _summary;
  String? _errorMessage;
  late SummarizeContentUseCase _summarizeUseCase;

  @override
  void initState() {
    super.initState();
    _initializeAndSummarize();
  }

  Future<void> _initializeAndSummarize() async {
    // Get AI service from factory
    final aiService = AIServiceFactory.create();
    _summarizeUseCase = SummarizeContentUseCase(aiService);

    await _generateSummary();
  }

  Future<void> _generateSummary() async {
    setState(() {
      _state = SummarizeState.loading;
      _errorMessage = null;
    });

    try {
      SummaryResult result;

      if (widget.summaryType == SummaryType.page) {
        result = await _summarizeUseCase.summarizePage(
          widget.textToSummarize,
          pageNumber: widget.pageNumber,
          documentTitle: widget.documentTitle,
        );
      } else {
        result = await _summarizeUseCase.summarizeSelection(
          widget.textToSummarize,
        );
      }

      if (mounted) {
        setState(() {
          if (result.isSuccess) {
            _summary = result.summary;
            _state = SummarizeState.success;
          } else {
            _errorMessage = result.errorMessage;
            _state = SummarizeState.error;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to summarize: $e';
          _state = SummarizeState.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Icon(
                    widget.summaryType == SummaryType.page
                        ? Icons.article
                        : Icons.text_fields,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.summaryType == SummaryType.page
                          ? 'Page Summary'
                          : 'Selection Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              // PDF & Page info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.pdfPath.split(RegExp(r'[/\\]')).last,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Page ${widget.pageNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [_buildContent(theme)],
                ),
              ),

              // Actions
              if (_state == SummarizeState.success) ...[
                const Divider(),
                _buildActions(theme),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (_state) {
      case SummarizeState.initial:
      case SummarizeState.loading:
        return _buildLoadingState(theme);
      case SummarizeState.success:
        return _buildSuccessState(theme);
      case SummarizeState.error:
        return _buildErrorState(theme);
    }
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text('Generating summary...', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            widget.summaryType == SummaryType.page
                ? 'Analyzing page content'
                : 'Analyzing selected text',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original text preview
        Text(
          'Original Text',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxHeight: 100),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: Text(
              widget.textToSummarize,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Summary
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Summary',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: SelectableText(
            _summary ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Failed to generate summary',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _generateSummary,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Copy button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _copySummary,
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy'),
            ),
          ),
          const SizedBox(width: 12),
          // Save to notes button
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: _saveToNotes,
              icon: const Icon(Icons.note_add, size: 18),
              label: const Text('Save to Notes'),
            ),
          ),
        ],
      ),
    );
  }

  void _copySummary() {
    if (_summary != null) {
      Clipboard.setData(ClipboardData(text: _summary!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveToNotes() async {
    if (_summary == null) return;

    // Use provided viewmodel or create new one
    final viewModel = widget.notesViewModel ?? NotesViewModel();

    if (widget.notesViewModel == null) {
      await viewModel.initialize();
    }

    final title = widget.summaryType == SummaryType.page
        ? 'Page ${widget.pageNumber} Summary'
        : 'Selection Summary';

    final note = await viewModel.addNote(
      content: _summary!,
      pdfPath: widget.pdfPath,
      pageNumber: widget.pageNumber,
      selectedText: widget.summaryType == SummaryType.selection
          ? widget.textToSummarize
          : null,
      title: title,
      tags: ['summary', 'ai-generated'],
    );

    if (note != null && mounted) {
      Navigator.pop(context, note);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary saved to notes'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save note'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
