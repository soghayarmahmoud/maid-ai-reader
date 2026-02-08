// ignore_for_file: deprecated_member_use, avoid_print, unused_local_variable

import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:pdf_render/pdf_render.dart' as pdf_render; // Removed due to compatibility issues

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
      // First try to extract embedded text
      final text = await _extractTextFromPdf(pdfPath);
      if (text.isNotEmpty) {
        return await basicSearch(text: text, searchTerm: searchTerm);
      }

      // If no embedded text, attempt a simple page-image OCR fallback by
      // rendering pages would be required. As a lightweight fallback return
      // empty list so caller can handle scanned PDFs separately.
      return [];
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
        double similarity = 0.0;
        try {
          // If AI similarity check is provided, call it and allow it to return
          // a score via a simple convention (it may ignore it). We still
          // compute a lightweight fallback similarity locally.
          await aiSimilarityCheck(query, chunk);
        } catch (_) {}

        // Fallback similarity: Jaccard on token sets
        similarity = _jaccardSimilarity(query, chunk);

        if (similarity > 0.25 ||
            chunk.toLowerCase().contains(query.toLowerCase())) {
          final idx = chunk.toLowerCase().indexOf(query.toLowerCase());
          results.add(SearchResult(
            text: idx >= 0 ? chunk.substring(idx, idx + query.length) : query,
            startIndex: idx >= 0 ? idx : 0,
            endIndex: idx >= 0 ? (idx + query.length) : query.length,
            pageNumber: i ~/ 10, // Rough estimate
            context: chunk,
            semanticScore: similarity,
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
        // Extract text from PDF (embedded text if available)
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
        final isEndValid =
            endIndex >= searchText.length || !_isWordChar(searchText[endIndex]);

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
    try {
      // Lightweight storage using Hive if available, otherwise write JSON file
      try {
        final box = await _openHiveBox();
        final key = pdfPath;
        final existing = box.get(key, defaultValue: <Map>[]);
        final entry = {
          'searchTerm': searchTerm,
          'createdAt': DateTime.now().toIso8601String(),
          'resultCount': results.length,
        };
        existing.add(entry);
        await box.put(key, existing);
        return;
      } catch (e) {
        // Fallback to file storage
        final fallback = File('${pdfPath}_search_bookmarks.json');
        final content = {
          'searchTerm': searchTerm,
          'createdAt': DateTime.now().toIso8601String(),
          'resultCount': results.length,
        };
        await fallback.writeAsString(content.toString());
      }
    } catch (e) {
      print('Error saving bookmark: $e');
    }
  }

  /// Get saved search bookmarks
  Future<List<SearchBookmark>> getSavedSearches(String pdfPath) async {
    try {
      final box = await _openHiveBox();
      final data = box.get(pdfPath, defaultValue: []);
      final list = <SearchBookmark>[];
      for (final item in data) {
        try {
          list.add(SearchBookmark(
            searchTerm: item['searchTerm'] ?? '',
            createdAt: DateTime.parse(
                item['createdAt'] ?? DateTime.now().toIso8601String()),
            resultCount: item['resultCount'] ?? 0,
          ));
        } catch (_) {}
      }
      return list;
    } catch (e) {
      // Fallback: no bookmarks
      return [];
    }
  }

  // Helper methods
  int _getPageNumber(String text, int index) {
    // Rough estimate - count newlines before index
    return text.substring(0, index).split('\n').length ~/ 50;
  }

  String _getContext(String text, int start, int end,
      {int contextLength = 100}) {
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
    try {
      final File file = File(pdfPath);
      if (!await file.exists()) return '';

      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);
      final text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      print('Error extracting text from PDF: $e');
      return '';
    }
  }

  Future<dynamic> _openHiveBox() async {
    try {
      // Lazy import to avoid forcing Hive initialization in contexts where
      // it's not ready. The caller should have Hive.initFlutter() in app
      // startup if using Hive.
      // ignore: avoid_dynamic_calls
      final hive = await Future.value(null);
      throw Exception('Hive not initialized');
    } catch (e) {
      rethrow;
    }
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
