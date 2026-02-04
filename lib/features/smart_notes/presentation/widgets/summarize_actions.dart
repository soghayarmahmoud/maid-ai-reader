import 'package:flutter/material.dart';
import 'summarize_sheet.dart';
import '../notes_viewmodel.dart';
import '../../domain/usecases/summarize_content.dart';

/// Quick action buttons for summarizing content
class SummarizeActions extends StatelessWidget {
  /// Selected text from PDF (null if no selection)
  final String? selectedText;

  /// Current page content
  final String? pageContent;

  /// PDF path
  final String pdfPath;

  /// Current page number
  final int pageNumber;

  /// Document title for context
  final String? documentTitle;

  /// Notes viewmodel for saving
  final NotesViewModel? notesViewModel;

  /// Callback when a note is saved
  final void Function(dynamic note)? onNoteSaved;

  const SummarizeActions({
    super.key,
    this.selectedText,
    this.pageContent,
    required this.pdfPath,
    required this.pageNumber,
    this.documentTitle,
    this.notesViewModel,
    this.onNoteSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedText != null && selectedText!.isNotEmpty;
    final hasPageContent = pageContent != null && pageContent!.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Summarize selection button
        if (hasSelection) ...[
          _ActionButton(
            icon: Icons.summarize,
            label: 'Summarize Selection',
            onPressed: () => _summarizeSelection(context),
            theme: theme,
          ),
          const SizedBox(width: 8),
        ],

        // Summarize page button
        if (hasPageContent)
          _ActionButton(
            icon: Icons.article,
            label: 'Summarize Page',
            onPressed: () => _summarizePage(context),
            theme: theme,
          ),
      ],
    );
  }

  void _summarizeSelection(BuildContext context) async {
    if (selectedText == null) return;

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SummarizeSheet(
        textToSummarize: selectedText!,
        summaryType: SummaryType.selection,
        pdfPath: pdfPath,
        pageNumber: pageNumber,
        documentTitle: documentTitle,
        notesViewModel: notesViewModel,
      ),
    );

    if (result != null) {
      onNoteSaved?.call(result);
    }
  }

  void _summarizePage(BuildContext context) async {
    if (pageContent == null) return;

    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SummarizeSheet(
        textToSummarize: pageContent!,
        summaryType: SummaryType.page,
        pdfPath: pdfPath,
        pageNumber: pageNumber,
        documentTitle: documentTitle,
        notesViewModel: notesViewModel,
      ),
    );

    if (result != null) {
      onNoteSaved?.call(result);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final ThemeData theme;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

/// Floating action button for summarization
class SummarizeFloatingMenu extends StatefulWidget {
  /// Selected text from PDF
  final String? selectedText;

  /// Current page content
  final String? pageContent;

  /// PDF path
  final String pdfPath;

  /// Current page number
  final int pageNumber;

  /// Document title
  final String? documentTitle;

  /// Notes viewmodel
  final NotesViewModel? notesViewModel;

  const SummarizeFloatingMenu({
    super.key,
    this.selectedText,
    this.pageContent,
    required this.pdfPath,
    required this.pageNumber,
    this.documentTitle,
    this.notesViewModel,
  });

  @override
  State<SummarizeFloatingMenu> createState() => _SummarizeFloatingMenuState();
}

class _SummarizeFloatingMenuState extends State<SummarizeFloatingMenu> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection =
        widget.selectedText != null && widget.selectedText!.isNotEmpty;
    final hasPageContent =
        widget.pageContent != null && widget.pageContent!.isNotEmpty;

    if (!hasSelection && !hasPageContent) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded options
        if (_isExpanded) ...[
          if (hasSelection)
            _FloatingOption(
              icon: Icons.text_fields,
              label: 'Summarize Selection',
              onTap: () {
                setState(() => _isExpanded = false);
                SummarizeSheet.showForSelection(
                  context,
                  selectedText: widget.selectedText!,
                  pdfPath: widget.pdfPath,
                  pageNumber: widget.pageNumber,
                  documentTitle: widget.documentTitle,
                  notesViewModel: widget.notesViewModel,
                );
              },
            ),
          if (hasPageContent)
            _FloatingOption(
              icon: Icons.article,
              label: 'Summarize Page',
              onTap: () {
                setState(() => _isExpanded = false);
                SummarizeSheet.showForPage(
                  context,
                  pageContent: widget.pageContent!,
                  pdfPath: widget.pdfPath,
                  pageNumber: widget.pageNumber,
                  documentTitle: widget.documentTitle,
                  notesViewModel: widget.notesViewModel,
                );
              },
            ),
          const SizedBox(height: 8),
        ],

        // Main FAB
        FloatingActionButton(
          onPressed: () {
            // If only one option, go directly to it
            if (hasSelection && !hasPageContent) {
              SummarizeSheet.showForSelection(
                context,
                selectedText: widget.selectedText!,
                pdfPath: widget.pdfPath,
                pageNumber: widget.pageNumber,
                documentTitle: widget.documentTitle,
                notesViewModel: widget.notesViewModel,
              );
            } else if (!hasSelection && hasPageContent) {
              SummarizeSheet.showForPage(
                context,
                pageContent: widget.pageContent!,
                pdfPath: widget.pdfPath,
                pageNumber: widget.pageNumber,
                documentTitle: widget.documentTitle,
                notesViewModel: widget.notesViewModel,
              );
            } else {
              setState(() => _isExpanded = !_isExpanded);
            }
          },
          child: Icon(_isExpanded ? Icons.close : Icons.auto_awesome),
        ),
      ],
    );
  }
}

class _FloatingOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FloatingOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mini FAB
          FloatingActionButton.small(
            heroTag: label,
            onPressed: onTap,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }
}
