// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../pdf_reader/presentation/pdf_reader_page.dart';
import '../../ai_search/presentation/ai_chat_page.dart';
import '../../ai_search/services/voice_input_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Map<String, dynamic>> _allFiles = [];
  String _selectedFilter = 'All Files';
  bool _isLoading = true;
  final VoiceInputService _voiceService = VoiceInputService();
  bool _isListening = false;

  final List<String> _filters = [
    'All Files',
    'PDFs',
    'Recent',
    'Favorites',
  ];

  @override
  void initState() {
    super.initState();
    _loadFiles();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    try {
      await _voiceService.initialize();
    } catch (e) {
      print('Voice service error: $e');
    }
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _startVoiceSearch() async {
    if (!_voiceService.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice service not available')),
      );
      return;
    }

    setState(() => _isListening = true);

    try {
      _voiceService.startListening(
        onResult: (recognizedWords) {
          setState(() => _isListening = false);
          if (recognizedWords.isNotEmpty) {
            _showAiSearchDialog(recognizedWords);
          }
        },
      );
    } catch (e) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice error: $e')),
      );
    }
  }

  void _showAiSearchDialog(String initialText) {
    final TextEditingController controller =
        TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask MAID'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ask a question about your documents...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty && _allFiles.isNotEmpty) {
                // Navigate to AI chat with the first PDF
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AiChatPage(
                      pdfPath: _allFiles.first['path'],
                      selectedText: controller.text,
                    ),
                  ),
                );
              } else if (_allFiles.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please open a PDF first')),
                );
              }
            },
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final box = await Hive.openBox('recent_files');
      final List<Map<String, dynamic>> files = [];

      for (var key in box.keys) {
        final data = box.get(key);
        if (data is Map) {
          final path = data['path']?.toString() ?? '';
          if (path.isNotEmpty && File(path).existsSync()) {
            files.add({
              'path': path,
              'name': data['name']?.toString() ??
                  path.split('/').last.split('\\').last,
              'openedAt':
                  data['openedAt'] ?? DateTime.now().millisecondsSinceEpoch,
              'category': data['category']?.toString() ?? 'Document',
            });
          }
        }
      }

      // Sort by most recent
      files.sort(
          (a, b) => (b['openedAt'] as int).compareTo(a['openedAt'] as int));

      setState(() {
        _allFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading files: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFileToRecent(String path) async {
    final box = await Hive.openBox('recent_files');
    final name = path.split('/').last.split('\\').last;
    await box.put(path, {
      'path': path,
      'name': name,
      'openedAt': DateTime.now().millisecondsSinceEpoch,
      'category': 'Document',
    });
    await _loadFiles();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await _saveFileToRecent(path);
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfReaderPage(filePath: path),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _openFile(String path) async {
    await _saveFileToRecent(path);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfReaderPage(filePath: path),
        ),
      );
    }
  }

  String _timeAgo(int timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  List<Map<String, dynamic>> get _filteredFiles {
    switch (_selectedFilter) {
      case 'PDFs':
        return _allFiles
            .where((f) => f['path'].toString().endsWith('.pdf'))
            .toList();
      case 'Recent':
        return _allFiles.take(5).toList();
      case 'Favorites':
        return _allFiles.where((f) => f['favorite'] == true).toList();
      default:
        return _allFiles;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F3FF),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WELCOME BACK',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Color(0xFF6C3CE7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_getGreeting()} 👋',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF1A1A2E),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C3CE7), Color(0xFF9B59B6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('M',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Search Bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () => _showAiSearchDialog(''),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFEDE7F6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C3CE7).withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFF6C3CE7), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ask MAID about your documents...',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _startVoiceSearch,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? const Color(0xFFE53935).withOpacity(0.2)
                                  : const Color(0xFF6C3CE7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none_rounded,
                              color: _isListening
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF6C3CE7),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Filter Chips ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6C3CE7)
                                : isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6C3CE7)
                                  : isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : const Color(0xFFE8E0F0),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white60
                                      : const Color(0xFF757575),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ─── Section Header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      '${_filteredFiles.length} files',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Document Grid ───
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C3CE7))),
                  )
                : _filteredFiles.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(isDark),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final file = _filteredFiles[index];
                              return _buildDocumentCard(file, isDark);
                            },
                            childCount: _filteredFiles.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),

      // ─── FAB ───
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        backgroundColor: const Color(0xFF6C3CE7),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> file, bool isDark) {
    final name = file['name'] as String;
    final timestamp = file['openedAt'] as int;
    final category = file['category'] as String;
    final isPdf = name.toLowerCase().endsWith('.pdf');

    return GestureDetector(
      onTap: () => _openFile(file['path']),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFEDE7F6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF6C3CE7).withOpacity(0.08)
                      : const Color(0xFFF3EEFF),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C3CE7).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isPdf
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.insert_drive_file_rounded,
                              color: const Color(0xFF6C3CE7),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPdf
                                  ? const Color(0xFFE53935).withOpacity(0.12)
                                  : const Color(0xFF43A047).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPdf ? 'PDF' : 'FILE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isPdf
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF43A047),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C3CE7).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6C3CE7),
                          ),
                        ),
                      ),
                    ),
                    // More button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(
                        Icons.more_horiz,
                        size: 18,
                        color:
                            isDark ? Colors.white30 : const Color(0xFFBDBDBD),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // File info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white30 : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6C3CE7).withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              size: 56,
              color: Color(0xFF6C3CE7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No documents yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to open your first PDF',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Open PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C3CE7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
