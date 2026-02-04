/// Types of AI queries for selected text
enum AIQueryType {
  /// General question about the text
  question,

  /// Explain the selected text
  explain,

  /// Summarize the selected text
  summarize,

  /// Define terms in the selected text
  define,

  /// Analyze the text (sentiment, style, etc.)
  analyze,

  /// Custom prompt with the text as context
  custom,
}

/// Extension for user-friendly display
extension AIQueryTypeExtension on AIQueryType {
  String get displayName {
    switch (this) {
      case AIQueryType.question:
        return 'Ask a Question';
      case AIQueryType.explain:
        return 'Explain This';
      case AIQueryType.summarize:
        return 'Summarize';
      case AIQueryType.define:
        return 'Define Terms';
      case AIQueryType.analyze:
        return 'Analyze';
      case AIQueryType.custom:
        return 'Custom Prompt';
    }
  }

  String get icon {
    switch (this) {
      case AIQueryType.question:
        return '❓';
      case AIQueryType.explain:
        return '💡';
      case AIQueryType.summarize:
        return '📝';
      case AIQueryType.define:
        return '📖';
      case AIQueryType.analyze:
        return '🔍';
      case AIQueryType.custom:
        return '✏️';
    }
  }

  String get description {
    switch (this) {
      case AIQueryType.question:
        return 'Ask any question about the selected text';
      case AIQueryType.explain:
        return 'Get a detailed explanation of the text';
      case AIQueryType.summarize:
        return 'Get a concise summary of the key points';
      case AIQueryType.define:
        return 'Define technical terms and concepts';
      case AIQueryType.analyze:
        return 'Analyze structure, tone, and meaning';
      case AIQueryType.custom:
        return 'Write your own prompt using the text';
    }
  }
}

/// Represents a query to the AI assistant
class AIQuery {
  /// The selected text from the PDF
  final String selectedText;

  /// Additional context (e.g., surrounding paragraphs, document title)
  final String? context;

  /// The type of query
  final AIQueryType queryType;

  /// Custom question or prompt (for question/custom types)
  final String? customPrompt;

  /// Document metadata for better context
  final DocumentContext? documentContext;

  /// Timestamp when the query was created
  final DateTime timestamp;

  AIQuery({
    required this.selectedText,
    this.context,
    this.queryType = AIQueryType.explain,
    this.customPrompt,
    this.documentContext,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create an explain query
  factory AIQuery.explain(
    String text, {
    String? context,
    DocumentContext? documentContext,
  }) {
    return AIQuery(
      selectedText: text,
      context: context,
      queryType: AIQueryType.explain,
      documentContext: documentContext,
    );
  }

  /// Create a question query
  factory AIQuery.question(
    String text,
    String question, {
    String? context,
    DocumentContext? documentContext,
  }) {
    return AIQuery(
      selectedText: text,
      context: context,
      queryType: AIQueryType.question,
      customPrompt: question,
      documentContext: documentContext,
    );
  }

  /// Create a summarize query
  factory AIQuery.summarize(
    String text, {
    String? context,
    DocumentContext? documentContext,
  }) {
    return AIQuery(
      selectedText: text,
      context: context,
      queryType: AIQueryType.summarize,
      documentContext: documentContext,
    );
  }

  /// Create a define query
  factory AIQuery.define(
    String text, {
    String? context,
    DocumentContext? documentContext,
  }) {
    return AIQuery(
      selectedText: text,
      context: context,
      queryType: AIQueryType.define,
      documentContext: documentContext,
    );
  }

  /// Create an analyze query
  factory AIQuery.analyze(
    String text, {
    String? context,
    DocumentContext? documentContext,
  }) {
    return AIQuery(
      selectedText: text,
      context: context,
      queryType: AIQueryType.analyze,
      documentContext: documentContext,
    );
  }

  /// Create a custom query
  factory AIQuery.custom(
    String text,
    String prompt, {
    String? context,
    DocumentContext? documentContext,
  }) {
    return AIQuery(
      selectedText: text,
      context: context,
      queryType: AIQueryType.custom,
      customPrompt: prompt,
      documentContext: documentContext,
    );
  }

  @override
  String toString() =>
      'AIQuery(type: $queryType, text: ${selectedText.length} chars)';
}

/// Document context for more relevant AI responses
class DocumentContext {
  /// Title of the document
  final String? title;

  /// Author of the document
  final String? author;

  /// Current page number
  final int? pageNumber;

  /// Total pages in document
  final int? totalPages;

  /// Document subject/category
  final String? subject;

  /// Language of the document
  final String? language;

  const DocumentContext({
    this.title,
    this.author,
    this.pageNumber,
    this.totalPages,
    this.subject,
    this.language,
  });

  String toContextString() {
    final parts = <String>[];
    if (title != null) parts.add('Document: $title');
    if (author != null) parts.add('Author: $author');
    if (pageNumber != null) {
      if (totalPages != null) {
        parts.add('Page $pageNumber of $totalPages');
      } else {
        parts.add('Page $pageNumber');
      }
    }
    if (subject != null) parts.add('Subject: $subject');
    return parts.join(' | ');
  }

  @override
  String toString() => toContextString();
}
