import 'package:flutter/material.dart';
import '../domain/entities/note_entity.dart';
import '../domain/usecases/get_notes_by_pdf.dart';
import 'notes_viewmodel.dart';
import 'widgets/note_card.dart';
import 'widgets/note_editor_sheet.dart';

/// Page displaying all notes or notes for a specific PDF
class NotesPage extends StatefulWidget {
  /// Optional: Filter to show notes only for this PDF
  final String? pdfPath;

  /// Optional: Filter to show notes only for this page
  final int? pageNumber;

  const NotesPage({super.key, this.pdfPath, this.pageNumber});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late NotesViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = NotesViewModel();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    await _viewModel.initialize();
    if (widget.pdfPath != null && widget.pageNumber != null) {
      await _viewModel.loadNotesForPage(widget.pdfPath!, widget.pageNumber!);
    } else if (widget.pdfPath != null) {
      await _viewModel.loadNotesForPdf(widget.pdfPath!);
    } else {
      await _viewModel.loadAllNotes();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          PopupMenuButton<NoteSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort notes',
            onSelected: (order) {
              _viewModel.setSortOrder(order);
              setState(() {});
            },
            itemBuilder: (context) => [
              _buildSortMenuItem(NoteSortOrder.recentFirst, 'Most Recent'),
              _buildSortMenuItem(NoteSortOrder.oldestFirst, 'Oldest First'),
              _buildSortMenuItem(NoteSortOrder.byPdf, 'By Document'),
              _buildSortMenuItem(NoteSortOrder.byPage, 'By Page'),
              _buildSortMenuItem(NoteSortOrder.pinnedFirst, 'Pinned First'),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _viewModel.clearSearch();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                _viewModel.search(value);
                setState(() {});
              },
            ),
          ),

          // Notes list
          Expanded(child: _buildContent(theme)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
    );
  }

  String _getTitle() {
    if (widget.pdfPath != null && widget.pageNumber != null) {
      final fileName = widget.pdfPath!.split(RegExp(r'[/\\]')).last;
      return 'Notes - Page ${widget.pageNumber}';
    } else if (widget.pdfPath != null) {
      final fileName = widget.pdfPath!.split(RegExp(r'[/\\]')).last;
      return 'Notes - $fileName';
    }
    return 'All Notes';
  }

  PopupMenuItem<NoteSortOrder> _buildSortMenuItem(
    NoteSortOrder order,
    String label,
  ) {
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          if (_viewModel.sortOrder == order)
            const Icon(Icons.check, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_viewModel.errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeAndLoad,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_viewModel.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No notes match your search'
                  : 'No notes yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first note by selecting text in a PDF',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initializeAndLoad,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _viewModel.notes.length,
        itemBuilder: (context, index) {
          final note = _viewModel.notes[index];
          return NoteCard(
            note: note,
            onTap: () => _showNoteDetails(context, note),
            onEdit: () => _showEditNoteSheet(context, note),
            onDelete: () => _confirmDeleteNote(context, note),
            onPin: () => _togglePin(note),
          );
        },
      ),
    );
  }

  void _showAddNoteSheet(BuildContext context) {
    NoteEditorSheet.show(
      context,
      pdfPath: widget.pdfPath ?? '',
      pageNumber: widget.pageNumber ?? 1,
      onSave: (content, title, tags) async {
        final note = await _viewModel.addNote(
          content: content,
          pdfPath: widget.pdfPath ?? 'unknown',
          pageNumber: widget.pageNumber ?? 1,
          title: title,
          tags: tags,
        );
        if (note != null && mounted) {
          setState(() {});
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note added')));
        }
      },
    );
  }

  void _showEditNoteSheet(BuildContext context, NoteEntity note) {
    NoteEditorSheet.show(
      context,
      note: note,
      pdfPath: note.pdfPath,
      pageNumber: note.pageNumber,
      onSave: (content, title, tags) async {
        final success = await _viewModel.updateNote(
          noteId: note.id,
          content: content,
          title: title,
          tags: tags,
        );
        if (success && mounted) {
          setState(() {});
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Note updated')));
        }
      },
    );
  }

  void _showNoteDetails(BuildContext context, NoteEntity note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NoteDetailsSheet(note: note),
    );
  }

  Future<void> _confirmDeleteNote(BuildContext context, NoteEntity note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _viewModel.deleteNote(note.id);
      if (success && mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note deleted')));
      }
    }
  }

  Future<void> _togglePin(NoteEntity note) async {
    await _viewModel.updateNote(noteId: note.id, isPinned: !note.isPinned);
    setState(() {});
  }
}

/// Bottom sheet showing note details
class NoteDetailsSheet extends StatelessWidget {
  final NoteEntity note;

  const NoteDetailsSheet({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
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

              // Title
              if (note.title != null) ...[
                Text(
                  note.title!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // PDF & Page info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                        note.pdfFileName,
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
                        'Page ${note.pageNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selected text
              if (note.selectedText != null) ...[
                Text(
                  'Selected Text',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: SelectableText(
                    note.selectedText!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Note content
              Text(
                'Note',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(note.content, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),

              // Tags
              if (note.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: note.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Timestamps
              Text(
                'Created: ${_formatDate(note.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Updated: ${_formatDate(note.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
