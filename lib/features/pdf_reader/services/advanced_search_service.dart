import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:pdf_render/pdf_render.dart' as pdf_render;

/// Advanced Search Service
/// Handles all search operations including OCR, regex, semantic search
class AdvancedSearchService {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  /// Search with regex support
  Future<List<SearchResult>> regexSearch({
    required String pdfText,
    required String pattern,
    bool caseSensitive = false,
  }) async {
    try {
      final regex = RegExp(
        pattern,
        caseSensitive: caseSensitive,
        multiLine: true,
      );

      final matches = regex.allMatches(pdfText);
      final results = <SearchResult>[];

      for (final match in matches) {
        results.add(SearchResult(
          text: match.group(0) ?? '',
          startIndex: match.start,
          endIndex: match.end,
          pageNumber: _getPageNumber(pdfText, match.start),
          context: _getContext(pdfText, match.start, match.end),
        ));
      }

      return results;
    } catch (e) {
      print('Regex search error: $e');
      return [];
    }
  }

  /// OCR search for scanned PDFs
  Future<List<SearchResult>> ocrSearch({
    required String pdfPath,
    required String searchTerm,
  }) async {
    try {
      // TODO: Extract images from PDF pages
      // For each page:
      // 1. Render PDF page to image
      // 2. Run OCR on image
      // 3. Search in OCR text

      final document = await pdf_render.PdfDocument.openFile(pdfPath);
      final results = <SearchResult>[];

      for (int i = 0; i < document.pageCount; i++) {
        final page = await document.getPage(i + 1);
        final pageImage = await page.render();
        
        // Convert to input image for ML Kit
        final inputImage = InputImage.fromFilePath(pdfPath); // Simplified
        
        // Run OCR
        final recognizedText = await _textRecognizer.processImage(inputImage);
        
        // Search in OCR text
        final text = recognizedText.text.toLowerCase();
        final term = searchTerm.toLowerCase();
        
        if (text.contains(term)) {
          final index = text.indexOf(term);
          results.add(SearchResult(
            text: searchTerm,
            startIndex: index,
            endIndex: index + searchTerm.length,
            pageNumber: i + 1,
            context: _getContext(text, index, index + searchTerm.length),
            isOcrResult: true,
          ));
        }
      }

      await document.dispose();
      return results;
    } catch (e) {
      print('OCR search error: $e');
      return [];
    }
  }

  /// Semantic search using AI
  Future<List<SearchResult>> semanticSearch({
    required String pdfText,
    required String query,
    required Function(String, String) aiSimilarityCheck,
  }) async {
    try {
      // Split text into chunks
      final chunks = _splitIntoChunks(pdfText, chunkSize: 500);
      final results = <SearchResult>[];

      for (int i = 0; i < chunks.length; i++) {
        final chunk = chunks[i];
        
        // Use AI to check semantic similarity
        final similarity = await aiSimilarityCheck(query, chunk);
        
        // If similarity is high, add to results
        // TODO: Implement actual AI similarity check
        // For now, use simple keyword matching as placeholder
        if (chunk.toLowerCase().contains(query.toLowerCase())) {
          results.add(SearchResult(
            text: query,
            startIndex: chunk.toLowerCase().indexOf(query.toLowerCase()),
            endIndex: chunk.toLowerCase().indexOf(query.toLowerCase()) + query.length,
            pageNumber: i ~/ 10, // Rough estimate
            context: chunk,
            semanticScore: 0.8, // Placeholder
          ));
        }
      }

      return results;
    } catch (e) {
      print('Semantic search error: $e');
      return [];
    }
  }

  /// Search across multiple PDFs
  Future<Map<String, List<SearchResult>>> searchMultiplePdfs({
    required List<String> pdfPaths,
    required String searchTerm,
    bool caseSensitive = false,
    bool wholeWord = false,
  }) async {
    final results = <String, List<SearchResult>>{};

    for (String pdfPath in pdfPaths) {
      try {
        // TODO: Extract text from PDF
        final text = await _extractTextFromPdf(pdfPath);
        
        final pdfResults = await basicSearch(
          text: text,
          searchTerm: searchTerm,
          caseSensitive: caseSensitive,
          wholeWord: wholeWord,
        );

        if (pdfResults.isNotEmpty) {
          results[pdfPath] = pdfResults;
        }
      } catch (e) {
        print('Error searching $pdfPath: $e');
      }
    }

    return results;
  }

  /// Basic search with options
  Future<List<SearchResult>> basicSearch({
    required String text,
    required String searchTerm,
    bool caseSensitive = false,
    bool wholeWord = false,
  }) async {
    final results = <SearchResult>[];
    String searchText = caseSensitive ? text : text.toLowerCase();
    String term = caseSensitive ? searchTerm : searchTerm.toLowerCase();

    int index = 0;
    while ((index = searchText.indexOf(term, index)) != -1) {
      // Check whole word if needed
      if (wholeWord) {
        final isStartValid = index == 0 || !_isWordChar(searchText[index - 1]);
        final endIndex = index + term.length;
        final isEndValid = endIndex >= searchText.length || !_isWordChar(searchText[endIndex]);
        
        if (!isStartValid || !isEndValid) {
          index++;
          continue;
        }
      }

      results.add(SearchResult(
        text: text.substring(index, index + term.length),
        startIndex: index,
        endIndex: index + term.length,
        pageNumber: _getPageNumber(text, index),
        context: _getContext(text, index, index + term.length),
      ));

      index += term.length;
    }

    return results;
  }

  /// Save search bookmark
  Future<void> saveSearchBookmark({
    required String pdfPath,
    required String searchTerm,
    required List<SearchResult> results,
  }) async {
    // TODO: Save to Hive database
    print('Saving search bookmark for: $searchTerm');
  }

  /// Get saved search bookmarks
  Future<List<SearchBookmark>> getSavedSearches(String pdfPath) async {
    // TODO: Load from Hive database
    return [];
  }

  // Helper methods
  int _getPageNumber(String text, int index) {
    // Rough estimate - count newlines before index
    return text.substring(0, index).split('\n').length ~/ 50;
  }

  String _getContext(String text, int start, int end, {int contextLength = 100}) {
    final contextStart = (start - contextLength).clamp(0, text.length);
    final contextEnd = (end + contextLength).clamp(0, text.length);
    
    return text.substring(contextStart, contextEnd);
  }

  bool _isWordChar(String char) {
    return RegExp(r'[a-zA-Z0-9]').hasMatch(char);
  }

  List<String> _splitIntoChunks(String text, {int chunkSize = 500}) {
    final chunks = <String>[];
    for (int i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize).clamp(0, text.length);
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }

  Future<String> _extractTextFromPdf(String pdfPath) async {
    // TODO: Implement PDF text extraction
    // This is a placeholder
    return 'Extracted text from PDF';
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class SearchResult {
  final String text;
  final int startIndex;
  final int endIndex;
  final int pageNumber;
  final String context;
  final bool isOcrResult;
  final double? semanticScore;

  SearchResult({
    required this.text,
    required this.startIndex,
    required this.endIndex,
    required this.pageNumber,
    required this.context,
    this.isOcrResult = false,
    this.semanticScore,
  });
}

class SearchBookmark {
  final String searchTerm;
  final DateTime createdAt;
  final int resultCount;

  SearchBookmark({
    required this.searchTerm,
    required this.createdAt,
    required this.resultCount,
  });
}
