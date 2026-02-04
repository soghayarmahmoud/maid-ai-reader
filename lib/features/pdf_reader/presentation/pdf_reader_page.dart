// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSearching = false;
  bool _showToolbar = false;
  String? _selectedText;
  AnnotationMode _annotationMode = AnnotationMode.none;
  final List<int> _bookmarks = [];
  bool _showBookmarks = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _searchController.dispose();
    _commentController.dispose();
    _focusNode.dispose();
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
    try {
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
    } finally {
      controller.dispose();
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

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  void _setAnnotationMode(AnnotationMode mode) {
    setState(() {
      _annotationMode = mode;
    });
  }

  void _addAnnotation() {
    // Placeholder for annotation functionality
    // Syncfusion PDF viewer annotations would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Annotation feature: $_annotationMode')),
    );
  }

  void _toggleBookmarks() {
    setState(() {
      _showBookmarks = !_showBookmarks;
    });
  }

  void _addBookmark() {
    if (!_bookmarks.contains(_currentPage)) {
      setState(() {
        _bookmarks.add(_currentPage);
        _bookmarks.sort();
      });
    }
  }

  void _removeBookmark(int page) {
    setState(() {
      _bookmarks.remove(page);
    });
  }

  void _jumpToBookmark(int page) {
    _pdfViewerController.jumpToPage(page);
    setState(() {
      _showBookmarks = false;
    });
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

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isControlPressed) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.keyF:
            _toggleSearch();
            break;
          case LogicalKeyboardKey.keyH:
            _setAnnotationMode(AnnotationMode.highlight);
            break;
          case LogicalKeyboardKey.keyU:
            _setAnnotationMode(AnnotationMode.underline);
            break;
          case LogicalKeyboardKey.keyS:
            _setAnnotationMode(AnnotationMode.strikeout);
            break;
          case LogicalKeyboardKey.keyC:
            _setAnnotationMode(AnnotationMode.comment);
            break;
          case LogicalKeyboardKey.keyT:
            _toggleToolbar();
            break;
          case LogicalKeyboardKey.keyB:
            _addBookmark();
            break;
        }
      } else {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowLeft:
            _previousPage();
            break;
          case LogicalKeyboardKey.arrowRight:
            _nextPage();
            break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(fileName),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _toggleSearch,
              tooltip: 'Search (Ctrl+F)',
            ),
            IconButton(
              icon: const Icon(Icons.build),
              onPressed: _toggleToolbar,
              tooltip: 'Tools (Ctrl+T)',
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: _addBookmark,
              tooltip: 'Add Bookmark (Ctrl+B)',
            ),
            IconButton(
              icon: const Icon(Icons.bookmarks),
              onPressed: _toggleBookmarks,
              tooltip: 'Show Bookmarks',
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
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            if (_showToolbar)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).cardColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAnnotationButton(AnnotationMode.highlight,
                        Icons.highlight, 'Highlight (Ctrl+H)'),
                    _buildAnnotationButton(AnnotationMode.underline,
                        Icons.format_underlined, 'Underline (Ctrl+U)'),
                    _buildAnnotationButton(AnnotationMode.strikeout,
                        Icons.strikethrough_s, 'Strikeout (Ctrl+S)'),
                    _buildAnnotationButton(AnnotationMode.comment,
                        Icons.comment, 'Comment (Ctrl+C)'),
                  ],
                ),
              ),
            if (_showBookmarks)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Theme.of(context).cardColor,
                height: 100,
                child: _bookmarks.isEmpty
                    ? const Center(child: Text('No bookmarks yet'))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _bookmarks.length,
                        itemBuilder: (context, index) {
                          final page = _bookmarks[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Card(
                              child: InkWell(
                                onTap: () => _jumpToBookmark(page),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Page $page'),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 16),
                                      onPressed: () => _removeBookmark(page),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            Expanded(
              child: RepaintBoundary(
                child: SfPdfViewer.file(
                  File(widget.filePath),
                  controller: _pdfViewerController,
                  onPageChanged: _onPageChanged,
                  onDocumentLoaded: _onDocumentLoaded,
                  onTextSelectionChanged:
                      (PdfTextSelectionChangedDetails details) {
                    setState(() {
                      _selectedText = details.selectedText;
                    });
                    if (_annotationMode != AnnotationMode.none &&
                        details.selectedText != null) {
                      _addAnnotation();
                    }
                  },
                  enableTextSelection: true,
                  enableDoubleTapZooming: true,
                ),
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
      ),
    );
  }

  Widget _buildAnnotationButton(
      AnnotationMode mode, IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon,
          color:
              _annotationMode == mode ? Theme.of(context).primaryColor : null),
      onPressed: () => _setAnnotationMode(mode),
      tooltip: tooltip,
    );
  }
}

enum AnnotationMode {
  none,
  highlight,
  underline,
  strikeout,
  comment,
}
