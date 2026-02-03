import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../ai_search/presentation/ai_chat_page.dart';
import '../../smart_notes/presentation/notes_page.dart';
import '../../translator/presentation/translate_sheet.dart';

class PdfReaderPage extends StatefulWidget {
  final String filePath;

  const PdfReaderPage({super.key, required this.filePath});

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSearching = false;
  String? _selectedText;

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    setState(() {
      _currentPage = details.newPageNumber;
    });
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    setState(() {
      _totalPages = details.document.pages.count;
    });
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _pdfViewerController.jumpToPage(_currentPage - 1);
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _pdfViewerController.jumpToPage(_currentPage + 1);
    }
  }

  Future<void> _jumpToPage() async {
    final controller = TextEditingController(text: _currentPage.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.jumpToPage),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '${AppStrings.page} (1-$_totalPages)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                Navigator.pop(context, page);
              }
            },
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );

    if (result != null) {
      _pdfViewerController.jumpToPage(result);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _pdfViewerController.clearSelection();
      }
    });
  }

  void _performSearch() {
    if (_searchController.text.isNotEmpty) {
      _pdfViewerController.searchText(_searchController.text);
    }
  }

  void _showAiChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiChatPage(
          pdfPath: widget.filePath,
          selectedText: _selectedText,
        ),
      ),
    );
  }

  void _showNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotesPage(
          pdfPath: widget.filePath,
          currentPage: _currentPage,
        ),
      ),
    );
  }

  void _showTranslator() {
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => TranslateSheet(text: _selectedText!),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select text to translate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
            tooltip: AppStrings.searchInPdf,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: _showAiChat,
            tooltip: AppStrings.aiSearch,
          ),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: _showNotes,
            tooltip: AppStrings.smartNotes,
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _showTranslator,
            tooltip: AppStrings.translator,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: AppColors.grey200,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: AppStrings.searchInPdf,
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _performSearch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearch,
                  ),
                ],
              ),
            ),
          Expanded(
            child: SfPdfViewer.file(
              widget.filePath as File,
              controller: _pdfViewerController,
              onPageChanged: _onPageChanged,
              onDocumentLoaded: _onDocumentLoaded,
              onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                setState(() {
                  _selectedText = details.selectedText;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1 ? _previousPage : null,
                ),
                GestureDetector(
                  onTap: _jumpToPage,
                  child: Text(
                    '${AppStrings.page} $_currentPage ${AppStrings.of} $_totalPages',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _currentPage < _totalPages ? _nextPage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
