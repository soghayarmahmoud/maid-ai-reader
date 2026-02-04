import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

/// Use case for getting notes by PDF
class GetNotesByPdfUseCase {
  final NotesRepository _repository;

  GetNotesByPdfUseCase(this._repository);

  /// Get all notes for a specific PDF, sorted by page number
  Future<List<NoteEntity>> execute(String pdfPath) async {
    if (pdfPath.isEmpty) {
      return [];
    }
    return await _repository.getNotesByPdf(pdfPath);
  }
}

/// Use case for getting notes by page
class GetNotesByPageUseCase {
  final NotesRepository _repository;

  GetNotesByPageUseCase(this._repository);

  /// Get all notes for a specific page in a PDF
  Future<List<NoteEntity>> execute(String pdfPath, int pageNumber) async {
    if (pdfPath.isEmpty || pageNumber < 1) {
      return [];
    }
    return await _repository.getNotesByPage(pdfPath, pageNumber);
  }
}

/// Use case for getting all notes
class GetAllNotesUseCase {
  final NotesRepository _repository;

  GetAllNotesUseCase(this._repository);

  /// Get all notes, optionally sorted
  Future<List<NoteEntity>> execute({NoteSortOrder sortOrder = NoteSortOrder.recentFirst}) async {
    final notes = await _repository.getAllNotes();
    return _sortNotes(notes, sortOrder);
  }

  List<NoteEntity> _sortNotes(List<NoteEntity> notes, NoteSortOrder sortOrder) {
    final sorted = List<NoteEntity>.from(notes);
    switch (sortOrder) {
      case NoteSortOrder.recentFirst:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSortOrder.oldestFirst:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOrder.byPdf:
        sorted.sort((a, b) {
          final pdfCompare = a.pdfFileName.compareTo(b.pdfFileName);
          if (pdfCompare != 0) return pdfCompare;
          return a.pageNumber.compareTo(b.pageNumber);
        });
        break;
      case NoteSortOrder.byPage:
        sorted.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
        break;
      case NoteSortOrder.pinnedFirst:
        sorted.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }
    return sorted;
  }
}

/// Use case for searching notes
class SearchNotesUseCase {
  final NotesRepository _repository;

  SearchNotesUseCase(this._repository);

  /// Search notes by query string
  Future<List<NoteEntity>> execute(String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getAllNotes();
    }
    return await _repository.searchNotes(query.trim());
  }
}

/// Sort order options for notes
enum NoteSortOrder {
  recentFirst,
  oldestFirst,
  byPdf,
  byPage,
  pinnedFirst,
}
