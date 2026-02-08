// ignore_for_file: avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:maid_ai_reader/features/smart_notes/data/models/note_model.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../domain/entities/note.dart' hide Note;
import '../data/repositories/notes_repository.dart';
import 'package:intl/intl.dart';

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
  late NotesRepository _notesRepository;
  bool _isRecording = false;
  String? _recordingPath;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      _notesRepository = NotesRepository();
      await _notesRepository.initialize();
      _loadNotesForCurrentPdf();
    } catch (e) {
      print('Error initializing notes repository: $e');
      _showErrorSnackbar('Failed to initialize notes storage');
    }
  }

  void _loadNotesForCurrentPdf() {
    try {
      final pdfNotes = _notesRepository.getNotesByPdf(widget.pdfPath);
      setState(() {
        _notes.clear();
        _notes.addAll(pdfNotes as Iterable<Note>);
      });
      print('✓ Loaded ${pdfNotes.length} notes for PDF');
    } catch (e) {
      print('Error loading notes: $e');
      setState(() {
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Voice recording would be implemented here
      // For now, this is a placeholder for future voice note integration
      setState(() {
        _isRecording = true;
      });
      // Simulate recording
      await Future.delayed(const Duration(seconds: 1));
      _showSuccessSnackbar('Voice recording started');
    } catch (e) {
      print('Error starting recording: $e');
      _showErrorSnackbar('Failed to start recording');
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Voice recording would be implemented here
      // For now, this is a placeholder for future voice note integration
      setState(() {
        _isRecording = false;
        _recordingPath = '/path/to/recording'; // Placeholder
      });
      _showSuccessSnackbar('Voice note recorded successfully');
    } catch (e) {
      print('Error stopping recording: $e');
      _showErrorSnackbar('Failed to stop recording');
    }
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _createNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.note_add_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Note',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            'Page ${widget.currentPage}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.grey600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title Input
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Note Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.grey100.withOpacity(0.5),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Content Input
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Note Content',
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.grey100.withOpacity(0.5),
                  ),
                  maxLines: 4,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Voice Note Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isRecording
                                ? Icons.fiber_manual_record
                                : Icons.mic_rounded,
                            color: _isRecording
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRecording ? 'Recording...' : 'Voice Note',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: _isRecording
                                      ? AppColors.error
                                      : AppColors.warning,
                                ),
                          ),
                          const Spacer(),
                          if (_recordingPath != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 16, color: AppColors.success),
                                  SizedBox(width: 4),
                                  Text('Recorded',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isRecording ? null : _startRecording,
                              icon: const Icon(Icons.mic_rounded),
                              label: const Text('Start'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRecording
                                    ? AppColors.grey400
                                    : AppColors.warning,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isRecording ? _stopRecording : null,
                              icon: const Icon(Icons.stop_rounded),
                              label: const Text('Stop'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRecording
                                    ? AppColors.error
                                    : AppColors.grey400,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tags Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.grey700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'Add tag',
                              prefixIcon: const Icon(Icons.label_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.grey100.withOpacity(0.5),
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                _addTag(value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _addTag(_tagController.text);
                              });
                            },
                            icon: const Icon(Icons.add_rounded,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tag, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _removeTag(tag);
                                    });
                                  },
                                  child: const Icon(Icons.close, size: 14),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _titleController.text.isEmpty
                            ? null
                            : () {
                                if (_titleController.text.isNotEmpty) {
                                  final newNote = Note(
                                    id: DateTime.now().toString(),
                                    title: _titleController.text,
                                    content: _contentController.text,
                                    pdfPath: widget.pdfPath,
                                    pageNumber: widget.currentPage,
                                    createdAt: DateTime.now(),
                                  );

                                  // Save to repository
                                  _notesRepository.addNote(newNote).then((_) {
                                    setState(() {
                                      _notes.add(newNote);
                                    });
                                    _titleController.clear();
                                    _contentController.clear();
                                    _selectedTags.clear();
                                    _recordingPath = null;
                                    Navigator.pop(context);
                                    _showSuccessSnackbar(
                                        'Note created successfully');
                                  }).catchError((e) {
                                    _showErrorSnackbar('Failed to save note');
                                    print('Error saving note: $e');
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Create Note'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pdfNotes =
        _notes.where((note) => note.pdfPath == widget.pdfPath).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Smart Notes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${pdfNotes.length} notes',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: pdfNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.note_add_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first note to organize\nyour thoughts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pdfNotes.length,
              itemBuilder: (context, index) {
                final note = pdfNotes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.grey800 : AppColors.grey200,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.05),
                                AppColors.secondary.withOpacity(0.02),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title and Delete
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM d, yyyy - hh:mm a')
                                              .format(note.createdAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.grey500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.delete_rounded,
                                          size: 20),
                                      color: AppColors.error,
                                      onPressed: () {
                                        setState(() {
                                          _notes.remove(note);
                                        });
                                        _showSuccessSnackbar('Note deleted');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Content Preview
                              if (note.content.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.grey900
                                        : AppColors.grey100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    note.content,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              const SizedBox(height: 12),

                              // Page Info
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.description_rounded,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Page ${note.pageNumber}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNote,
        elevation: 4,
        label: const Text('Add Note'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
