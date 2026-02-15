import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NotesRepository {
  static const String _boxName = 'notes';
  late Box<NoteModel> _notesBox;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    
    _notesBox = await Hive.openBox<NoteModel>(_boxName);
  }

  // Create a new note
  Future<void> addNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    await _notesBox.put(note.id, model);
  }

  // Get all notes
  List<Note> getAllNotes() {
    return _notesBox.values.map((model) => model.toEntity()).toList();
  }

  // Get notes for a specific PDF
  List<Note> getNotesByPdf(String pdfPath) {
    return _notesBox.values
        .where((model) => model.pdfPath == pdfPath)
        .map((model) => model.toEntity())
        .toList();
  }

  // Get notes for a specific page
  List<Note> getNotesByPage(String pdfPath, int pageNumber) {
    return _notesBox.values
        .where((model) => 
            model.pdfPath == pdfPath && model.pageNumber == pageNumber)
        .map((model) => model.toEntity())
        .toList();
  }

  // Update a note
  Future<void> updateNote(Note note) async {
    final model = NoteModel.fromEntity(note);
    model.updatedAt = DateTime.now();
    await _notesBox.put(note.id, model);
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    await _notesBox.delete(noteId);
  }

  // Search notes
  List<Note> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _notesBox.values
        .where((model) =>
            model.title.toLowerCase().contains(lowerQuery) ||
            model.content.toLowerCase().contains(lowerQuery) ||
            (model.tags?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ?? false))
        .map((model) => model.toEntity())
        .toList();
  }

  // Get notes by tag
  List<Note> getNotesByTag(String tag) {
    return _notesBox.values
        .where((model) => model.tags?.contains(tag) ?? false)
        .map((model) => model.toEntity())
        .toList();
  }

  // Clear all notes
  Future<void> clearAll() async {
    await _notesBox.clear();
  }

  void dispose() {
    _notesBox.close();
  }
}
