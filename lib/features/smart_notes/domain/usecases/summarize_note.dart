import '../../../core/ai/ai.dart';
import '../entities/note_entity.dart';
import '../repositories/notes_repository.dart';

/// Use case for AI-powered note summarization
class SummarizeNoteUseCase {
  final NotesRepository _repository;
  final AIService _aiService;

  SummarizeNoteUseCase(this._repository, this._aiService);

  /// Summarize a note's content using AI
  Future<String> execute(String noteId) async {
    final note = await _repository.getNoteById(noteId);
    if (note == null) {
      throw StateError('Note not found: $noteId');
    }

    final textToSummarize = note.selectedText ?? note.content;
    if (textToSummarize.isEmpty) {
      return note.content;
    }

    final response = await _aiService.prompt(
      'Please provide a brief summary of the following text:\n\n"$textToSummarize"',
      systemPrompt: 'You are a helpful assistant that creates concise summaries.',
      options: const AICompletionOptions(
        temperature: 0.3,
        maxTokens: 256,
      ),
    );

    if (response.isSuccess) {
      return response.content;
    }

    return textToSummarize;
  }

  /// Summarize multiple notes
  Future<String> executeForMultiple(List<String> noteIds) async {
    final contents = <String>[];

    for (final id in noteIds) {
      final note = await _repository.getNoteById(id);
      if (note != null) {
        contents.add(note.selectedText ?? note.content);
      }
    }

    if (contents.isEmpty) {
      return '';
    }

    final combinedText = contents.join('\n\n---\n\n');
    final response = await _aiService.prompt(
      'Please provide a comprehensive summary of the following notes:\n\n$combinedText',
      systemPrompt: 'You are a helpful assistant that creates concise summaries from multiple notes.',
      options: const AICompletionOptions(
        temperature: 0.3,
        maxTokens: 512,
      ),
    );

    if (response.isSuccess) {
      return response.content;
    }

    return combinedText;
  }
}
