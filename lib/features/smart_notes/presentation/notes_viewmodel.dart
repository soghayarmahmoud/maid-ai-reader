import 'package:flutter/foundation.dart';
import '../data/notes_repository_impl.dart';
import '../domain/entities/note_entity.dart';
import '../domain/usecases/add_note.dart';
import '../domain/usecases/get_notes_by_pdf.dart';

/// State for notes operations
enum NotesState { initial, loading, loaded, error }

/// ViewModel for managing smart notes
class NotesViewModel extends ChangeNotifier {
  final NotesRepositoryImpl _repository;
  late final AddNoteUseCase _addNoteUseCase;
  late final UpdateNoteUseCase _updateNoteUseCase;
  late final DeleteNoteUseCase _deleteNoteUseCase;
  late final GetNotesByPdfUseCase _getNotesByPdfUseCase;
  late final GetNotesByPageUseCase _getNotesByPageUseCase;
  late final GetAllNotesUseCase _getAllNotesUseCase;
  late final SearchNotesUseCase _searchNotesUseCase;

  NotesState _state = NotesState.initial;
  List<NoteEntity> _notes = [];
  List<NoteEntity> _filteredNotes = [];
  String? _currentPdfPath;
  int? _currentPage;
  String? _errorMessage;
  String _searchQuery = '';
  NoteSortOrder _sortOrder = NoteSortOrder.recentFirst;
  bool _isInitialized = false;

  NotesViewModel({NotesRepositoryImpl? repository})
    : _repository = repository ?? NotesRepositoryImpl() {
    _addNoteUseCase = AddNoteUseCase(_repository);
    _updateNoteUseCase = UpdateNoteUseCase(_repository);
    _deleteNoteUseCase = DeleteNoteUseCase(_repository);
    _getNotesByPdfUseCase = GetNotesByPdfUseCase(_repository);
    _getNotesByPageUseCase = GetNotesByPageUseCase(_repository);
    _getAllNotesUseCase = GetAllNotesUseCase(_repository);
    _searchNotesUseCase = SearchNotesUseCase(_repository);
  }

  // Getters
  NotesState get state => _state;
  List<NoteEntity> get notes => _filteredNotes;
  List<NoteEntity> get allNotes => _notes;
  String? get currentPdfPath => _currentPdfPath;
  int? get currentPage => _currentPage;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  NoteSortOrder get sortOrder => _sortOrder;
  bool get isLoading => _state == NotesState.loading;
  bool get hasNotes => _notes.isNotEmpty;
  int get noteCount => _notes.length;

  /// Initialize the repository
  Future<void> initialize() async {
    if (_isInitialized) return;

    _state = NotesState.loading;
    notifyListeners();

    try {
      await _repository.initialize();
      _isInitialized = true;
      await loadAllNotes();
    } catch (e) {
      _state = NotesState.error;
      _errorMessage = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  /// Load all notes
  Future<void> loadAllNotes() async {
    _state = NotesState.loading;
    notifyListeners();

    try {
      _notes = await _getAllNotesUseCase.execute(sortOrder: _sortOrder);
      _currentPdfPath = null;
      _currentPage = null;
      _applyFilters();
      _state = NotesState.loaded;
    } catch (e) {
      _state = NotesState.error;
      _errorMessage = 'Failed to load notes: $e';
    }

    notifyListeners();
  }

  /// Load notes for a specific PDF
  Future<void> loadNotesForPdf(String pdfPath) async {
    _state = NotesState.loading;
    notifyListeners();

    try {
      _notes = await _getNotesByPdfUseCase.execute(pdfPath);
      _currentPdfPath = pdfPath;
      _currentPage = null;
      _applyFilters();
      _state = NotesState.loaded;
    } catch (e) {
      _state = NotesState.error;
      _errorMessage = 'Failed to load notes: $e';
    }

    notifyListeners();
  }

  /// Load notes for a specific page
  Future<void> loadNotesForPage(String pdfPath, int pageNumber) async {
    _state = NotesState.loading;
    notifyListeners();

    try {
      _notes = await _getNotesByPageUseCase.execute(pdfPath, pageNumber);
      _currentPdfPath = pdfPath;
      _currentPage = pageNumber;
      _applyFilters();
      _state = NotesState.loaded;
    } catch (e) {
      _state = NotesState.error;
      _errorMessage = 'Failed to load notes: $e';
    }

    notifyListeners();
  }

  /// Add a new note
  Future<NoteEntity?> addNote({
    required String content,
    required String pdfPath,
    required int pageNumber,
    String? selectedText,
    NotePosition? position,
    String? title,
    List<String> tags = const [],
    String? highlightColor,
  }) async {
    try {
      final note = await _addNoteUseCase.execute(
        content: content,
        pdfPath: pdfPath,
        pageNumber: pageNumber,
        selectedText: selectedText,
        position: position,
        title: title,
        tags: tags,
        highlightColor: highlightColor,
      );

      _notes.insert(0, note);
      _applyFilters();
      notifyListeners();
      return note;
    } catch (e) {
      _errorMessage = 'Failed to add note: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update a note
  Future<bool> updateNote({
    required String noteId,
    String? content,
    String? title,
    List<String>? tags,
    String? highlightColor,
    bool? isPinned,
  }) async {
    try {
      final updatedNote = await _updateNoteUseCase.execute(
        noteId: noteId,
        content: content,
        title: title,
        tags: tags,
        highlightColor: highlightColor,
        isPinned: isPinned,
      );

      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = updatedNote;
        _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update note: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a note
  Future<bool> deleteNote(String noteId) async {
    try {
      final success = await _deleteNoteUseCase.execute(noteId);
      if (success) {
        _notes.removeWhere((n) => n.id == noteId);
        _applyFilters();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete note: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search notes
  Future<void> search(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _applyFilters();
      notifyListeners();
      return;
    }

    try {
      _filteredNotes = await _searchNotesUseCase.execute(query);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      notifyListeners();
    }
  }

  /// Set sort order
  void setSortOrder(NoteSortOrder order) {
    if (_sortOrder != order) {
      _sortOrder = order;
      _applyFilters();
      notifyListeners();
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  /// Get notes count for a specific PDF
  int getNotesCountForPdf(String pdfPath) {
    return _notes.where((n) => n.pdfPath == pdfPath).length;
  }

  /// Get notes count for a specific page
  int getNotesCountForPage(String pdfPath, int pageNumber) {
    return _notes
        .where((n) => n.pdfPath == pdfPath && n.pageNumber == pageNumber)
        .length;
  }

  void _applyFilters() {
    var filtered = List<NoteEntity>.from(_notes);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((note) {
        return note.content.toLowerCase().contains(query) ||
            (note.title?.toLowerCase().contains(query) ?? false) ||
            (note.selectedText?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply sort
    switch (_sortOrder) {
      case NoteSortOrder.recentFirst:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOrder.oldestFirst:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOrder.byPdf:
        filtered.sort((a, b) {
          final pdfCompare = a.pdfFileName.compareTo(b.pdfFileName);
          if (pdfCompare != 0) return pdfCompare;
          return a.pageNumber.compareTo(b.pageNumber);
        });
        break;
      case NoteSortOrder.byPage:
        filtered.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
        break;
      case NoteSortOrder.pinnedFirst:
        filtered.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }

    _filteredNotes = filtered;
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
