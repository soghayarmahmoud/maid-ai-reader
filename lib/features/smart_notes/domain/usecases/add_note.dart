import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

/// Use case for adding a new note
class AddNoteUseCase {
  final NotesRepository _repository;

  AddNoteUseCase(this._repository);

  /// Create and save a new note from selected text
  Future<NoteEntity> execute({
    required String content,
    required String pdfPath,
    required int pageNumber,
    String? selectedText,
    NotePosition? position,
    String? title,
    List<String> tags = const [],
    String? highlightColor,
  }) async {
    // Validate input
    if (content.trim().isEmpty) {
      throw ArgumentError('Note content cannot be empty');
    }

    if (pdfPath.trim().isEmpty) {
      throw ArgumentError('PDF path cannot be empty');
    }

    if (pageNumber < 1) {
      throw ArgumentError('Page number must be at least 1');
    }

    // Create the note
    final note = NoteEntity.create(
      content: content.trim(),
      selectedText: selectedText?.trim(),
      pdfPath: pdfPath,
      pageNumber: pageNumber,
      position: position,
      title: title?.trim(),
      tags: tags.where((t) => t.isNotEmpty).toList(),
      highlightColor: highlightColor,
    );

    // Save and return
    return await _repository.addNote(note);
  }
}

/// Use case for updating an existing note
class UpdateNoteUseCase {
  final NotesRepository _repository;

  UpdateNoteUseCase(this._repository);

  /// Update a note's content and metadata
  Future<NoteEntity> execute({
    required String noteId,
    String? content,
    String? title,
    List<String>? tags,
    String? highlightColor,
    bool? isPinned,
  }) async {
    final existingNote = await _repository.getNoteById(noteId);
    if (existingNote == null) {
      throw StateError('Note not found: $noteId');
    }

    final updatedNote = existingNote.copyWith(
      content: content?.trim() ?? existingNote.content,
      title: title?.trim(),
      tags: tags?.where((t) => t.isNotEmpty).toList(),
      highlightColor: highlightColor,
      isPinned: isPinned,
    );

    return await _repository.updateNote(updatedNote);
  }
}

/// Use case for deleting a note
class DeleteNoteUseCase {
  final NotesRepository _repository;

  DeleteNoteUseCase(this._repository);

  /// Delete a note by ID
  Future<bool> execute(String noteId) async {
    if (noteId.isEmpty) {
      throw ArgumentError('Note ID cannot be empty');
    }
    return await _repository.deleteNote(noteId);
  }

  /// Delete all notes for a PDF
  Future<int> executeForPdf(String pdfPath) async {
    if (pdfPath.isEmpty) {
      throw ArgumentError('PDF path cannot be empty');
    }
    return await _repository.deleteNotesByPdf(pdfPath);
  }
}
