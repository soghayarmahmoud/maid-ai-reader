import 'package:flutter_test/flutter_test.dart';
import 'package:maid_ai_reader/features/library/data/models/reading_progress_model.dart';

void main() {
  group('Reading Progress Model Tests', () {
    test('Progress percentage calculation should be correct', () {
      // Arrange
      final progress = ReadingProgressModel(
        pdfPath: '/path/to/test.pdf',
        currentPage: 50,
        totalPages: 100,
        lastOpened: DateTime.now(),
      );

      // Act
      final percentage = progress.progressPercentage;

      // Assert
      expect(percentage, 50.0);
    });

    test('isFinished should return true when on last page', () {
      // Arrange
      final progress = ReadingProgressModel(
        pdfPath: '/path/to/test.pdf',
        currentPage: 100,
        totalPages: 100,
        lastOpened: DateTime.now(),
      );

      // Act & Assert
      expect(progress.isFinished, true);
    });

    test('isFinished should return false when not on last page', () {
      // Arrange
      final progress = ReadingProgressModel(
        pdfPath: '/path/to/test.pdf',
        currentPage: 50,
        totalPages: 100,
        lastOpened: DateTime.now(),
      );

      // Act & Assert
      expect(progress.isFinished, false);
    });

    test('updateProgress should update page and timestamp', () async {
      // Arrange
      final initialTime = DateTime.now();
      await Future.delayed(const Duration(milliseconds: 10));
      
      final progress = ReadingProgressModel(
        pdfPath: '/path/to/test.pdf',
        currentPage: 50,
        totalPages: 100,
        lastOpened: initialTime,
      );

      // Act
      progress.updateProgress(page: 75);

      // Assert
      expect(progress.currentPage, 75);
      expect(progress.lastOpened.isAfter(initialTime), true);
    });

    test('Zero total pages should return 0% progress', () {
      // Arrange
      final progress = ReadingProgressModel(
        pdfPath: '/path/to/test.pdf',
        currentPage: 0,
        totalPages: 0,
        lastOpened: DateTime.now(),
      );

      // Act & Assert
      expect(progress.progressPercentage, 0.0);
    });
  });
}
