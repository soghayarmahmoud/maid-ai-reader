import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/entities/note.dart';

class NotesPage extends StatefulWidget {
  final String pdfPath;
  final int currentPage;

  const NotesPage({
    super.key,
    required this.pdfPath,
    required this.currentPage,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final List<Note> _notes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.createNote),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: AppStrings.noteTitle,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: AppStrings.noteContent,
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                setState(() {
                  _notes.add(Note(
                    id: DateTime.now().toString(),
                    title: _titleController.text,
                    content: _contentController.text,
                    pdfPath: widget.pdfPath,
                    pageNumber: widget.currentPage,
                    createdAt: DateTime.now(),
                  ));
                });
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _summarizeText() {
    // This would integrate with AI service to summarize selected text
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Summarization - Please integrate with AI service'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfNotes = _notes.where((note) => note.pdfPath == widget.pdfPath).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.smartNotes),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _summarizeText,
            tooltip: AppStrings.summarizeText,
          ),
        ],
      ),
      body: pdfNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add_outlined,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first note',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey500,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pdfNotes.length,
              itemBuilder: (context, index) {
                final note = pdfNotes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Page ${note.pageNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        setState(() {
                          _notes.remove(note);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
