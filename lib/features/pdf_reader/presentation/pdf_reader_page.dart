// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdf_lib;
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../ai_search/presentation/ai_chat_page.dart';
import '../../ai_search/data/gemini_ai_service.dart';
import '../../smart_notes/presentation/notes_page.dart';
import '../../translator/presentation/translate_sheet.dart';

const Color _kPrimary = Color(0xFF6C3CE7);

class PdfReaderPage extends StatefulWidget {
  final String filePath;
  const PdfReaderPage({super.key, required this.filePath});

  @override
  State<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends State<PdfReaderPage>
    with SingleTickerProviderStateMixin {
  final PdfViewerController _pdfCtrl = PdfViewerController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSearching = false;
  bool _showToolbar = false;
  bool _showBookmarks = false;
  String? _selectedText;
  AnnotationMode _annotationMode = AnnotationMode.none;
  final List<int> _bookmarks = [];

  // AI
  final GeminiAiService _aiService = GeminiAiService();
  String? _aiInsight;
  bool _loadingAi = false;
  String? _pdfFullText;

  late AnimationController _fabAnimCtrl;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _initAi();
  }

  Future<void> _initAi() async {
    try {
      await _aiService.initialize();
    } catch (_) {}
  }

  @override
  void dispose() {
    _pdfCtrl.dispose();
    _searchCtrl.dispose();
    _focusNode.dispose();
    _fabAnimCtrl.dispose();
    _aiService.dispose();
    super.dispose();
  }

  // ─── PDF callbacks ───
  void _onPageChanged(PdfPageChangedDetails d) {
    setState(() => _currentPage = d.newPageNumber);
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails d) {
    setState(() => _totalPages = d.document.pages.count);
    _extractPdfText();
  }

  Future<void> _extractPdfText() async {
    try {
      final bytes = await File(widget.filePath).readAsBytes();
      final doc = pdf_lib.PdfDocument(inputBytes: bytes);
      final extractor = pdf_lib.PdfTextExtractor(doc);
      final buffer = StringBuffer();
      for (int i = 0; i < doc.pages.count && i < 20; i++) {
        buffer.writeln(extractor.extractText(startPageIndex: i));
      }
      doc.dispose();
      _pdfFullText = buffer.toString();
    } catch (e) {
      print('PDF text extraction error: $e');
    }
  }

  // ─── Navigation ───
  void _previousPage() {
    if (_currentPage > 1) _pdfCtrl.jumpToPage(_currentPage - 1);
  }

  void _nextPage() {
    if (_currentPage < _totalPages) _pdfCtrl.jumpToPage(_currentPage + 1);
  }

  void _jumpToPage() async {
    final ctrl = TextEditingController(text: _currentPage.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.jumpToPage),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Page (1-$_totalPages)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final p = int.tryParse(ctrl.text);
              if (p != null && p >= 1 && p <= _totalPages)
                Navigator.pop(context, p);
            },
            style: FilledButton.styleFrom(backgroundColor: _kPrimary),
            child: const Text('Go'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null) _pdfCtrl.jumpToPage(result);
  }

  // ─── Search ───
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchCtrl.clear();
        _pdfCtrl.clearSelection();
      }
    });
  }

  void _performSearch() {
    if (_searchCtrl.text.isNotEmpty) _pdfCtrl.searchText(_searchCtrl.text);
  }

  // ─── Toolbar & Annotations ───
  void _toggleToolbar() => setState(() => _showToolbar = !_showToolbar);

  void _setAnnotationMode(AnnotationMode m) =>
      setState(() => _annotationMode = m);

  void _applyAnnotation(String selectedText) {
    final modeName = _annotationMode.name;
    final displayName = modeName[0].toUpperCase() + modeName.substring(1);
    final preview = selectedText.length > 30
        ? '${selectedText.substring(0, 30)}...'
        : selectedText;
    _showSnack('✓ Applied $displayName to: "$preview"');
  }

  void _toggleBookmarks() => setState(() => _showBookmarks = !_showBookmarks);

  void _addBookmark() {
    if (!_bookmarks.contains(_currentPage)) {
      setState(() {
        _bookmarks.add(_currentPage);
        _bookmarks.sort();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmarked page $_currentPage'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: _kPrimary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _removeBookmark(int page) => setState(() => _bookmarks.remove(page));
  void _jumpToBookmark(int page) {
    _pdfCtrl.jumpToPage(page);
    setState(() => _showBookmarks = false);
  }

  // ─── AI Features ───
  void _showAiChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiChatPage(
          pdfPath: widget.filePath,
          selectedText: _selectedText,
        ),
      ),
    );
  }

  Future<void> _summarizeDocument() async {
    if (_pdfFullText == null || _pdfFullText!.isEmpty) {
      _showSnack('No text extracted from PDF');
      return;
    }
    setState(() => _loadingAi = true);
    final result = await _aiService.analyzePdf(_pdfFullText!);
    if (mounted) {
      setState(() {
        _loadingAi = false;
        _aiInsight = result;
      });
    }
  }

  Future<void> _extractKeyPoints() async {
    if (_pdfFullText == null || _pdfFullText!.isEmpty) {
      _showSnack('No text extracted from PDF');
      return;
    }
    setState(() => _loadingAi = true);
    final result = await _aiService.extractKeyPoints(_pdfFullText!);
    if (mounted) {
      setState(() {
        _loadingAi = false;
        _aiInsight = result;
      });
    }
  }

  void _showNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NotesPage(pdfPath: widget.filePath, currentPage: _currentPage),
      ),
    );
  }

  void _showTranslator() {
    if (_selectedText != null && _selectedText!.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => TranslateSheet(text: _selectedText!),
      );
    } else {
      _showSnack('Please select text to translate');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Keyboard shortcuts ───
  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
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
        case LogicalKeyboardKey.keyT:
          _toggleToolbar();
          break;
        case LogicalKeyboardKey.keyB:
          _addBookmark();
          break;
        default:
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
        default:
          break;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = widget.filePath.split('/').last.split('\\').last;
    final fileNameShort =
        fileName.length > 28 ? '${fileName.substring(0, 25)}...' : fileName;

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFAF9FE),
        // ─── AppBar ───
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileNameShort,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              if (_totalPages > 0)
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_rounded,
                  color: isDark ? Colors.white70 : const Color(0xFF1A1A2E)),
              onPressed: _toggleSearch,
              tooltip: 'Search (Ctrl+F)',
            ),
            _buildPopupMenu(isDark),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // ─── Reading progress bar ───
                if (_totalPages > 0)
                  LinearProgressIndicator(
                    value: _currentPage / _totalPages,
                    minHeight: 2.5,
                    backgroundColor:
                        isDark ? Colors.white10 : const Color(0xFFEDE7F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
                  ),

                // ─── Search bar ───
                if (_isSearching) _buildSearchBar(isDark),

                // ─── Toolbar ───
                if (_showToolbar) _buildToolbar(isDark),

                // ─── Bookmarks panel ───
                if (_showBookmarks) _buildBookmarksPanel(isDark),

                // ─── PDF viewer ───
                Expanded(
                  child: RepaintBoundary(
                    child: SfPdfViewer.file(
                      File(widget.filePath),
                      controller: _pdfCtrl,
                      onPageChanged: _onPageChanged,
                      onDocumentLoaded: _onDocumentLoaded,
                      onTextSelectionChanged: (d) {
                        setState(() => _selectedText = d.selectedText);
                        if (_annotationMode != AnnotationMode.none &&
                            d.selectedText != null) {
                          _applyAnnotation(d.selectedText!);
                        }
                      },
                      enableTextSelection: true,
                      enableDoubleTapZooming: true,
                    ),
                  ),
                ),

                // ─── Banner Ad ───
                const BannerAdWidget(isTest: false),
              ],
            ),

            // ─── AI Insight bubble ───
            if (_aiInsight != null) _buildAiInsightBubble(isDark),

            // ─── Loading overlay ───
            if (_loadingAi) _buildLoadingOverlay(),

            // ─── Floating Bottom Action Bar ───
            Positioned(
              bottom: 56,
              left: 20,
              right: 20,
              child: _buildFloatingActionBar(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Popup menu (more options) ───
  Widget _buildPopupMenu(bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          color: isDark ? Colors.white70 : const Color(0xFF1A1A2E)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        switch (v) {
          case 'toolbar':
            _toggleToolbar();
            break;
          case 'bookmark':
            _addBookmark();
            break;
          case 'bookmarks':
            _toggleBookmarks();
            break;
          case 'ai':
            _showAiChat();
            break;
          case 'notes':
            _showNotes();
            break;
          case 'translate':
            _showTranslator();
            break;
          case 'jump':
            _jumpToPage();
            break;
        }
      },
      itemBuilder: (_) => [
        _popMenuItem('toolbar', Icons.build_circle_outlined, 'Tools'),
        _popMenuItem('bookmark', Icons.bookmark_add_outlined, 'Add Bookmark'),
        _popMenuItem('bookmarks', Icons.bookmarks_outlined, 'Bookmarks'),
        const PopupMenuDivider(),
        _popMenuItem('ai', Icons.auto_awesome, 'AI Chat'),
        _popMenuItem('notes', Icons.note_add_outlined, 'Notes'),
        _popMenuItem('translate', Icons.translate_rounded, 'Translate'),
        const PopupMenuDivider(),
        _popMenuItem('jump', Icons.pin_outlined, 'Jump to Page'),
      ],
    );
  }

  PopupMenuItem<String> _popMenuItem(
      String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: _kPrimary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  // ─── Search bar ───
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search in document...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFF5F3FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: _toggleSearch,
          ),
        ],
      ),
    );
  }

  // ─── Annotation toolbar ───
  Widget _buildToolbar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolBtn(AnnotationMode.highlight, Icons.highlight_rounded,
              'Highlight', Colors.amber),
          _buildToolBtn(AnnotationMode.underline,
              Icons.format_underlined_rounded, 'Underline', Colors.blue),
          _buildToolBtn(AnnotationMode.strikeout, Icons.strikethrough_s_rounded,
              'Strikeout', Colors.red),
          _buildToolBtn(AnnotationMode.comment,
              Icons.chat_bubble_outline_rounded, 'Comment', _kPrimary),
        ],
      ),
    );
  }

  Widget _buildToolBtn(
      AnnotationMode mode, IconData icon, String label, Color color) {
    final selected = _annotationMode == mode;
    return GestureDetector(
      onTap: () => _setAnnotationMode(selected ? AnnotationMode.none : mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: selected ? color : Colors.grey,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  // ─── Bookmarks panel ───
  Widget _buildBookmarksPanel(bool isDark) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: _bookmarks.isEmpty
          ? Center(
              child: Text(
                'No bookmarks yet — tap ⋮ → Add Bookmark',
                style: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                    fontSize: 13),
              ),
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final page = _bookmarks[i];
                return GestureDetector(
                  onTap: () => _jumpToBookmark(page),
                  child: Container(
                    width: 64,
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kPrimary.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_rounded,
                            color: _kPrimary, size: 20),
                        const SizedBox(height: 2),
                        Text('P. $page',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kPrimary)),
                        GestureDetector(
                          onTap: () => _removeBookmark(page),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ─── Floating Action Bar (Summarize / Extract / Mark) ───
  Widget _buildFloatingActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E).withOpacity(0.95)
            : Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6)),
          BoxShadow(
              color: _kPrimary.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 10)),
        ],
        border: Border.all(
          color:
              isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEDE7F6),
        ),
      ),
      child: Row(
        children: [
          _buildFabAction(Icons.auto_awesome_outlined, 'Summarize',
              _summarizeDocument, isDark),
          _buildFabDivider(isDark),
          _buildFabAction(Icons.format_list_bulleted_rounded, 'Extract',
              _extractKeyPoints, isDark,
              isCenter: true),
          _buildFabDivider(isDark),
          _buildFabAction(Icons.brush_outlined, 'Mark', _toggleToolbar, isDark),
        ],
      ),
    );
  }

  Widget _buildFabAction(
      IconData icon, String label, VoidCallback onTap, bool isDark,
      {bool isCenter = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: isCenter
              ? BoxDecoration(
                  color: _kPrimary,
                  borderRadius: BorderRadius.circular(14),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 22,
                  color: isCenter
                      ? Colors.white
                      : (isDark ? Colors.white60 : const Color(0xFF616161))),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCenter ? FontWeight.w600 : FontWeight.w500,
                  color: isCenter
                      ? Colors.white
                      : (isDark ? Colors.white60 : const Color(0xFF616161)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEDE7F6),
    );
  }

  // ─── AI Insight Bubble ───
  Widget _buildAiInsightBubble(bool isDark) {
    return Positioned(
      bottom: 130,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        shadowColor: _kPrimary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kPrimary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: _kPrimary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI INSIGHT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: _kPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _aiInsight = null),
                    child:
                        const Icon(Icons.close, size: 18, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _aiInsight ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white70 : const Color(0xFF424242),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Loading overlay ───
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black26,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: _kPrimary),
                SizedBox(height: 16),
                Text('AI is thinking...',
                    style: TextStyle(color: Color(0xFF757575), fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
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
