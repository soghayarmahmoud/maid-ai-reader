import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/note_entity.dart';
import '../domain/repositories/notes_repository.dart';

/// Local storage implementation of NotesRepository using SharedPreferences
class NotesRepositoryImpl implements NotesRepository {
  static const String _notesKey = 'smart_notes_data';
  static const String _notesIndexKey = 'smart_notes_index';

  SharedPreferences? _prefs;
  List<NoteEntity>? _cachedNotes;

  /// Initialize the repository
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _loadNotes();
  }

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _loadNotes() async {
    final prefs = await _preferences;
    final notesJson = prefs.getString(_notesKey);

    if (notesJson != null && notesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(notesJson);
        _cachedNotes = decoded
            .map((e) => NoteEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _cachedNotes = [];
      }
    } else {
      _cachedNotes = [];
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await _preferences;
    final notesJson = jsonEncode(_cachedNotes!.map((n) => n.toJson()).toList());
    await prefs.setString(_notesKey, notesJson);

    // Also save an index for quick lookups
    final index = <String, List<String>>{};
    for (final note in _cachedNotes!) {
      index.putIfAbsent(note.pdfPath, () => []).add(note.id);
    }
    await prefs.setString(_notesIndexKey, jsonEncode(index));
  }

  @override
  Future<List<NoteEntity>> getAllNotes() async {
    if (_cachedNotes == null) await _loadNotes();
    return List.unmodifiable(_cachedNotes!);
  }

  @override
  Future<List<NoteEntity>> getNotesByPdf(String pdfPath) async {
    if (_cachedNotes == null) await _loadNotes();
    return _cachedNotes!.where((n) => n.pdfPath == pdfPath).toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  @override
  Future<List<NoteEntity>> getNotesByPage(String pdfPath, int pageNumber) async {
    if (_cachedNotes == null) await _loadNotes();
    return _cachedNotes!
        .where((n) => n.pdfPath == pdfPath && n.pageNumber == pageNumber)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<NoteEntity?> getNoteById(String id) async {
    if (_cachedNotes == null) await _loadNotes();
    try {
      return _cachedNotes!.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<NoteEntity> addNote(NoteEntity note) async {
    if (_cachedNotes == null) await _loadNotes();
    _cachedNotes!.add(note);
    await _saveNotes();
    return note;
  }

  @override
  Future<NoteEntity> updateNote(NoteEntity note) async {
    if (_cachedNotes == null) await _loadNotes();

    final index = _cachedNotes!.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _cachedNotes![index] = note;
      await _saveNotes();
    }
    return note;
  }

  @override
  Future<bool> deleteNote(String id) async {
    if (_cachedNotes == null) await _loadNotes();

    final lengthBefore = _cachedNotes!.length;
    _cachedNotes!.removeWhere((n) => n.id == id);

    if (_cachedNotes!.length != lengthBefore) {
      await _saveNotes();
      return true;
    }
    return false;
  }

  @override
  Future<int> deleteNotesByPdf(String pdfPath) async {
    if (_cachedNotes == null) await _loadNotes();

    final lengthBefore = _cachedNotes!.length;
    _cachedNotes!.removeWhere((n) => n.pdfPath == pdfPath);

    final deleted = lengthBefore - _cachedNotes!.length;
    if (deleted > 0) {
      await _saveNotes();
    }
    return deleted;
  }

  @override
  Future<List<NoteEntity>> searchNotes(String query) async {
    if (_cachedNotes == null) await _loadNotes();

    final lowerQuery = query.toLowerCase();
    return _cachedNotes!.where((note) {
      return note.content.toLowerCase().contains(lowerQuery) ||
          (note.title?.toLowerCase().contains(lowerQuery) ?? false) ||
          (note.selectedText?.toLowerCase().contains(lowerQuery) ?? false) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  @override
  Future<List<NoteEntity>> getNotesByTag(String tag) async {
    if (_cachedNotes == null) await _loadNotes();
    return _cachedNotes!.where((n) => n.tags.contains(tag)).toList();
  }

  @override
  Future<List<String>> getAllTags() async {
    if (_cachedNotes == null) await _loadNotes();

    final tags = <String>{};
    for (final note in _cachedNotes!) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  @override
  Future<String> exportNotes(List<String>? noteIds) async {
    if (_cachedNotes == null) await _loadNotes();

    List<NoteEntity> notesToExport;
    if (noteIds != null) {
      notesToExport = _cachedNotes!.where((n) => noteIds.contains(n.id)).toList();
    } else {
      notesToExport = _cachedNotes!;
    }

    return jsonEncode({
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notes': notesToExport.map((n) => n.toJson()).toList(),
    });
  }

  @override
  Future<int> importNotes(String jsonData) async {
    if (_cachedNotes == null) await _loadNotes();

    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final notesList = data['notes'] as List<dynamic>;
      
      int imported = 0;
      for (final noteJson in notesList) {
        final note = NoteEntity.fromJson(noteJson as Map<String, dynamic>);
        // Check if note already exists
        final exists = _cachedNotes!.any((n) => n.id == note.id);
        if (!exists) {
          _cachedNotes!.add(note);
          imported++;
        }
      }

      if (imported > 0) {
        await _saveNotes();
      }
      return imported;
    } catch (e) {
      throw FormatException('Invalid notes data: $e');
    }
  }

  /// Clear all notes (for testing)
  Future<void> clearAll() async {
    _cachedNotes = [];
    await _saveNotes();
  }
}
