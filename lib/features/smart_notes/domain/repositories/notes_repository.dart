import '../entities/note_entity.dart';

/// Repository interface for note operations
abstract class NotesRepository {
  /// Get all notes
  Future<List<NoteEntity>> getAllNotes();

  /// Get notes for a specific PDF
  Future<List<NoteEntity>> getNotesByPdf(String pdfPath);

  /// Get notes for a specific page in a PDF
  Future<List<NoteEntity>> getNotesByPage(String pdfPath, int pageNumber);

  /// Get a single note by ID
  Future<NoteEntity?> getNoteById(String id);

  /// Add a new note
  Future<NoteEntity> addNote(NoteEntity note);

  /// Update an existing note
  Future<NoteEntity> updateNote(NoteEntity note);

  /// Delete a note
  Future<bool> deleteNote(String id);

  /// Delete all notes for a PDF
  Future<int> deleteNotesByPdf(String pdfPath);

  /// Search notes by content
  Future<List<NoteEntity>> searchNotes(String query);

  /// Get notes by tag
  Future<List<NoteEntity>> getNotesByTag(String tag);

  /// Get all unique tags
  Future<List<String>> getAllTags();

  /// Export notes to JSON
  Future<String> exportNotes(List<String>? noteIds);

  /// Import notes from JSON
  Future<int> importNotes(String jsonData);
}
