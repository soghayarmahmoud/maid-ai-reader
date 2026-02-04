import 'package:flutter_test/flutter_test.dart';
import 'package:maid_ai_reader/features/smart_notes/data/models/note_model.dart';

void main() {
  group('Note Model Tests', () {
    test('Note model should create from entity correctly', () {
      // Arrange
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'This is a test note',
        pdfPath: '/path/to/pdf.pdf',
        pageNumber: 5,
        createdAt: DateTime.now(),
        tags: ['test', 'important'],
        summary: 'Test summary',
      );

      // Act
      final model = NoteModel.fromEntity(note);

      // Assert
      expect(model.id, note.id);
      expect(model.title, note.title);
      expect(model.content, note.content);
      expect(model.pdfPath, note.pdfPath);
      expect(model.pageNumber, note.pageNumber);
      expect(model.tags, note.tags);
      expect(model.summary, note.summary);
    });

    test('Note model should convert to entity correctly', () {
      // Arrange
      final model = NoteModel(
        id: '1',
        title: 'Test Note',
        content: 'This is a test note',
        pdfPath: '/path/to/pdf.pdf',
        pageNumber: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['test', 'important'],
        summary: 'Test summary',
      );

      // Act
      final note = model.toEntity();

      // Assert
      expect(note.id, model.id);
      expect(note.title, model.title);
      expect(note.content, model.content);
      expect(note.pdfPath, model.pdfPath);
      expect(note.pageNumber, model.pageNumber);
      expect(note.tags, model.tags);
      expect(note.summary, model.summary);
    });
  });
}
