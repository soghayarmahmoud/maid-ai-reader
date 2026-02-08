// ignore_for_file: avoid_print

import '../../ai_search/data/gemini_ai_service.dart';

/// Document Comparison Service
/// AI-powered comparison of two PDF documents
class DocumentComparisonService {
  final GeminiAiService _aiService = GeminiAiService();

  /// Compare two documents using AI
  Future<ComparisonResult> compareDoccuments({
    required String doc1Path,
    required String doc2Path,
    required String doc1Text,
    required String doc2Text,
  }) async {
    try {
      await _aiService.initialize();

      // Create comparison prompt
      final prompt = '''
Compare these two documents and highlight:
1. Key differences
2. Similarities
3. Added content in document 2
4. Removed content from document 1
5. Overall summary of changes

Document 1:
${doc1Text.substring(0, doc1Text.length.clamp(0, 2000))}...

Document 2:
${doc2Text.substring(0, doc2Text.length.clamp(0, 2000))}...

Provide a structured comparison.
''';

      final response = await _aiService.sendChatMessage(prompt);

      return ComparisonResult(
        summary: response,
        differences: _extractDifferences(response),
        similarities: _extractSimilarities(response),
        addedContent: [],
        removedContent: [],
        changePercentage: _calculateChangePercentage(doc1Text, doc2Text),
      );
    } catch (e) {
      print('Error comparing documents: $e');
      return ComparisonResult.error(e.toString());
    }
  }

  /// Context-aware scrolling suggestions
  Future<List<ScrollSuggestion>> getScrollSuggestions({
    required String currentPageText,
    required int currentPage,
    required int totalPages,
  }) async {
    try {
      await _aiService.initialize();

      final prompt = '''
Based on this page content, suggest what the reader might want to explore next:

Current page ($currentPage of $totalPages):
$currentPageText

Provide 3-5 suggestions for:
1. Related sections to jump to
2. Important topics to review
3. Summary sections

Format: Brief description | suggested page number
''';

      final response = await _aiService.sendChatMessage(prompt);

      return _parseScrollSuggestions(response);
    } catch (e) {
      print('Error getting scroll suggestions: $e');
      return [];
    }
  }

  /// Find similar sections across documents
  Future<List<SimilarSection>> findSimilarSections({
    required String sourceText,
    required List<String> targetTexts,
  }) async {
    final sections = <SimilarSection>[];
    // Simple semantic similarity fallback: compute token overlap score
    for (int i = 0; i < targetTexts.length; i++) {
      final t = targetTexts[i];
      final score = _jaccardSimilarity(sourceText, t);
      if (score > 0.2) {
        sections.add(
            SimilarSection(text: t, pageNumber: i + 1, similarityScore: score));
      }
    }

    return sections;
  }

  // Helper methods
  List<String> _extractDifferences(String aiResponse) {
    // Try to extract numbered lines or bullet points as differences
    final lines = aiResponse.split('\n');
    final diffs = <String>[];
    for (final l in lines) {
      final trimmed = l.trim();
      if (trimmed.startsWith('1.') ||
          trimmed.startsWith('-') ||
          trimmed.toLowerCase().contains('difference')) {
        diffs.add(trimmed.replaceAll(RegExp(r'^\d+\.|^-'), '').trim());
      }
    }
    if (diffs.isEmpty) {
      // fallback: take first two sentences
      final sentences = aiResponse.split(RegExp(r'[\.!?]\s'));
      for (int i = 0; i < sentences.length && i < 2; i++) {
        diffs.add(sentences[i].trim());
      }
    }
    return diffs;
  }

  List<String> _extractSimilarities(String aiResponse) {
    final lines = aiResponse.split('\n');
    final sims = <String>[];
    for (final l in lines) {
      final trimmed = l.trim();
      if (trimmed.toLowerCase().contains('similar') ||
          trimmed.startsWith('*') ||
          trimmed.startsWith('-')) {
        sims.add(trimmed.replaceAll(RegExp(r'^\*|^-'), '').trim());
      }
    }
    if (sims.isEmpty) {
      // fallback: pick one short sentence
      final sentences = aiResponse.split(RegExp(r'[\.!?]\s'));
      if (sentences.isNotEmpty) sims.add(sentences.first.trim());
    }
    return sims;
  }

  double _calculateChangePercentage(String text1, String text2) {
    // Simple character-based difference
    final length = text1.length > text2.length ? text1.length : text2.length;
    final diff = (text1.length - text2.length).abs();
    return (diff / length) * 100;
  }

  List<ScrollSuggestion> _parseScrollSuggestions(String aiResponse) {
    final suggestions = <ScrollSuggestion>[];
    final lines = aiResponse.split('\n');
    for (final l in lines) {
      final parts = l.split('|');
      if (parts.length >= 2) {
        final desc = parts[0].trim();
        final page = int.tryParse(parts[1].trim()) ?? 1;
        suggestions.add(ScrollSuggestion(
            description: desc, targetPage: page, relevanceScore: 0.7));
      }
    }
    if (suggestions.isEmpty) {
      suggestions.add(ScrollSuggestion(
          description: 'Continue to next section',
          targetPage: 1,
          relevanceScore: 0.6));
    }
    return suggestions;
  }

  double _jaccardSimilarity(String a, String b) {
    final setA = a
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((s) => s.isNotEmpty)
        .toSet();
    final setB = b
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((s) => s.isNotEmpty)
        .toSet();
    if (setA.isEmpty || setB.isEmpty) return 0.0;
    final intersection = setA.intersection(setB).length.toDouble();
    final union = setA.union(setB).length.toDouble();
    return intersection / union;
  }
}

class ComparisonResult {
  final String summary;
  final List<String> differences;
  final List<String> similarities;
  final List<String> addedContent;
  final List<String> removedContent;
  final double changePercentage;
  final String? error;

  ComparisonResult({
    required this.summary,
    required this.differences,
    required this.similarities,
    required this.addedContent,
    required this.removedContent,
    required this.changePercentage,
    this.error,
  });

  factory ComparisonResult.error(String error) {
    return ComparisonResult(
      summary: '',
      differences: [],
      similarities: [],
      addedContent: [],
      removedContent: [],
      changePercentage: 0,
      error: error,
    );
  }

  bool get hasError => error != null;
}

class ScrollSuggestion {
  final String description;
  final int targetPage;
  final double relevanceScore;

  ScrollSuggestion({
    required this.description,
    required this.targetPage,
    required this.relevanceScore,
  });
}

class SimilarSection {
  final String text;
  final int pageNumber;
  final double similarityScore;

  SimilarSection({
    required this.text,
    required this.pageNumber,
    required this.similarityScore,
  });
}
