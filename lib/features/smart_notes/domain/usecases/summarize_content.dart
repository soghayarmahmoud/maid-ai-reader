import '../../../core/ai/ai.dart';

/// Use case for AI-powered content summarization
/// Handles summarizing pages and selected text
class SummarizeContentUseCase {
  final AIService _aiService;

  SummarizeContentUseCase(this._aiService);

  /// Summarize selected text
  Future<SummaryResult> summarizeSelection(String selectedText) async {
    if (selectedText.trim().isEmpty) {
      return SummaryResult.failure('No text selected');
    }

    final response = await _aiService.prompt(
      '''Please provide a clear, concise summary of the following text. Focus on the key points and main ideas.

Text to summarize:
"$selectedText"

Provide only the summary, without any introduction or meta-commentary.''',
      systemPrompt:
          'You are a skilled summarizer. Create clear, concise summaries that capture the essential information. Use bullet points for multiple key points. Keep summaries readable and well-structured.',
      options: const AICompletionOptions(temperature: 0.3, maxTokens: 512),
    );

    if (response.isSuccess) {
      return SummaryResult.success(
        summary: response.content.trim(),
        originalText: selectedText,
        type: SummaryType.selection,
      );
    }

    return SummaryResult.failure(
      response.errorMessage ?? 'Failed to generate summary',
    );
  }

  /// Summarize a page's content
  Future<SummaryResult> summarizePage(
    String pageContent, {
    int? pageNumber,
    String? documentTitle,
  }) async {
    if (pageContent.trim().isEmpty) {
      return SummaryResult.failure('No page content to summarize');
    }

    final contextInfo = StringBuffer();
    if (documentTitle != null) {
      contextInfo.write('Document: $documentTitle\n');
    }
    if (pageNumber != null) {
      contextInfo.write('Page: $pageNumber\n');
    }

    final response = await _aiService.prompt(
      '''Please provide a clear, concise summary of the following page content. Identify the main topics, key points, and any important details.

${contextInfo.isNotEmpty ? '$contextInfo\n' : ''}Page content:
"$pageContent"

Provide a well-structured summary with:
- Main topic/theme
- Key points (as bullet points if multiple)
- Any notable details or conclusions''',
      systemPrompt:
          'You are a skilled document summarizer. Create clear, organized summaries that help readers understand page content quickly. Be concise but comprehensive.',
      options: const AICompletionOptions(temperature: 0.3, maxTokens: 768),
    );

    if (response.isSuccess) {
      return SummaryResult.success(
        summary: response.content.trim(),
        originalText: pageContent,
        type: SummaryType.page,
        pageNumber: pageNumber,
      );
    }

    return SummaryResult.failure(
      response.errorMessage ?? 'Failed to generate page summary',
    );
  }
}

/// Type of summary generated
enum SummaryType { selection, page }

/// Result of a summarization operation
class SummaryResult {
  final bool isSuccess;
  final String? summary;
  final String? originalText;
  final String? errorMessage;
  final SummaryType? type;
  final int? pageNumber;

  const SummaryResult._({
    required this.isSuccess,
    this.summary,
    this.originalText,
    this.errorMessage,
    this.type,
    this.pageNumber,
  });

  factory SummaryResult.success({
    required String summary,
    required String originalText,
    required SummaryType type,
    int? pageNumber,
  }) {
    return SummaryResult._(
      isSuccess: true,
      summary: summary,
      originalText: originalText,
      type: type,
      pageNumber: pageNumber,
    );
  }

  factory SummaryResult.failure(String errorMessage) {
    return SummaryResult._(isSuccess: false, errorMessage: errorMessage);
  }
}
