import 'package:flutter_test/flutter_test.dart';
import 'package:maid_ai_reader/features/smart_notes/domain/entities/note.dart';

void main() {
  group('Note Entity', () {
    test('should create a Note with all required fields', () {
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'This is a test note',
        pdfPath: '/path/to/pdf',
        pageNumber: 5,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'This is a test note');
      expect(note.pdfPath, '/path/to/pdf');
      expect(note.pageNumber, 5);
      expect(note.createdAt, DateTime(2024, 1, 1));
    });
  });
}
