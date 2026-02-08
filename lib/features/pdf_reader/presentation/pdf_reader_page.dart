// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
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

  // Color customization
  Color _highlightColor = Colors.yellow;
  Color _underlineColor = Colors.red;
  final List<Color> _colorPalette = [
    Colors.yellow,
    Colors.yellow.shade700,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.amber,
  ];

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

  void _showColorPickerMenu(BuildContext context, AnnotationMode mode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose ${mode == AnnotationMode.highlight ? 'Highlight' : 'Underline'} Color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colorPalette.map((color) {
                final isSelected = mode == AnnotationMode.highlight
                    ? color == _highlightColor
                    : color == _underlineColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (mode == AnnotationMode.highlight) {
                        _highlightColor = color;
                      } else {
                        _underlineColor = color;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.black,
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Page $_currentPage of $_totalPages',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _toggleSearch,
              tooltip: 'Search (Ctrl+F)',
            ),
            IconButton(
              icon: const Icon(Icons.construction_rounded),
              onPressed: _toggleToolbar,
              tooltip: 'Tools (Ctrl+T)',
            ),
            IconButton(
              icon: Icon(
                _bookmarks.contains(_currentPage)
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
              ),
              onPressed: _addBookmark,
              tooltip: 'Bookmark (Ctrl+B)',
            ),
            IconButton(
              icon: const Icon(Icons.bookmarks_rounded),
              onPressed: _toggleBookmarks,
              tooltip: 'View Bookmarks',
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: _showAiChat,
                  child:  const Row(
                    children: [
                      Icon(Icons.chat_bubble_rounded),
                      SizedBox(width: 12),
                      Text('AI Chat'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: _showNotes,
                  child: const Row(
                    children: [
                      Icon(Icons.note_add_rounded),
                      SizedBox(width: 12),
                      Text('Smart Notes'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: _showTranslator,
                  child: const Row(
                    children: [
                      Icon(Icons.translate_rounded),
                      SizedBox(width: 12),
                      Text('Translate'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Modern Search Bar
            if (_isSearching)
              Container(
                padding: const EdgeInsets.all(12.0),
                color: isDark ? AppColors.surfaceDark : AppColors.grey100,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search in PDF',
                            border: InputBorder.none,
                            prefixIcon:  Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                            ),
                            contentPadding:  EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search_rounded,
                            color: Colors.white),
                        onPressed: _performSearch,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.grey800 : AppColors.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: _toggleSearch,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Modern Toolbar
            if (_showToolbar)
              Container(
                padding: const EdgeInsets.all(12.0),
                color: isDark ? AppColors.surfaceDark : AppColors.grey100,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModernAnnotationButton(
                          AnnotationMode.highlight,
                          Icons.highlight_rounded,
                          'Highlight',
                        ),
                        _buildModernAnnotationButton(
                          AnnotationMode.underline,
                          Icons.format_underlined,
                          'Underline',
                        ),
                        _buildModernAnnotationButton(
                          AnnotationMode.strikeout,
                          Icons.strikethrough_s,
                          'Strikeout',
                        ),
                        _buildModernAnnotationButton(
                          AnnotationMode.comment,
                          Icons.comment_rounded,
                          'Comment',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Modern Bookmarks Section
            if (_showBookmarks && _bookmarks.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: isDark ? AppColors.surfaceDark : AppColors.grey100,
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _bookmarks.length,
                    itemBuilder: (context, index) {
                      final page = _bookmarks[index];
                      return GestureDetector(
                        onTap: () => _jumpToBookmark(page),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: _currentPage == page
                                ? AppColors.primary
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _currentPage == page
                                  ? AppColors.primary
                                  : AppColors.grey300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pg $page',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _currentPage == page
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _removeBookmark(page),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: _currentPage == page
                                      ? Colors.white
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            // PDF Viewer
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
            // Modern Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: AppColors.primary),
                      onPressed: _currentPage > 1 ? _previousPage : null,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _jumpToPage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_currentPage / $_totalPages',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            'tap to jump',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right_rounded,
                          color: AppColors.primary),
                      onPressed: _currentPage < _totalPages ? _nextPage : null,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Banner Ad
            const BannerAdWidget(isTest: false),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAnnotationButton(
    AnnotationMode mode,
    IconData icon,
    String label,
  ) {
    final isActive = _annotationMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(
                  icon,
                  color: isActive ? Colors.white : AppColors.primary,
                ),
                onPressed: () => _setAnnotationMode(mode),
                constraints: const BoxConstraints(
                  minWidth: 50,
                  minHeight: 50,
                ),
              ),
            ),
            // Color picker button for highlight and underline
            if ((mode == AnnotationMode.highlight ||
                    mode == AnnotationMode.underline) &&
                isActive)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: mode == AnnotationMode.highlight
                        ? _highlightColor
                        : _underlineColor,
                    border: Border.all(
                      color: isDark ? AppColors.grey700 : AppColors.grey300,
                      width: 2,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () => _showColorPickerMenu(context, mode),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.palette_rounded,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
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
