import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import '../../pdf_reader/presentation/pdf_reader_page.dart';

class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = false;
  final List<String> _commonPaths = [
    '/sdcard/Documents',
    '/sdcard/Downloads',
    '/sdcard/DCIM',
  ];

  @override
  void initState() {
    super.initState();
    _loadCommonDirectories();
  }

  Future<void> _loadCommonDirectories() async {
    setState(() => _isLoading = true);
    try {
      final List<FileSystemEntity> allFiles = [];

      // Try to load from common directories
      for (String path in _commonPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          try {
            final files = await dir.list().toList();
            allFiles.addAll(files.where((f) =>
                f.path.toLowerCase().endsWith('.pdf') ||
                f.path.toLowerCase().endsWith('.doc') ||
                f.path.toLowerCase().endsWith('.docx') ||
                f.path.toLowerCase().endsWith('.txt')));
          } catch (e) {
            print('Error reading directory $path: $e');
          }
        }
      }

      setState(() {
        _files = allFiles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading files: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDirectory() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        setState(() {
          _isLoading = true;
        });

        final dir = Directory(selectedDirectory);
        final files = await dir
            .list(recursive: false)
            .where((f) =>
                f.path.toLowerCase().endsWith('.pdf') ||
                f.path.toLowerCase().endsWith('.doc') ||
                f.path.toLowerCase().endsWith('.docx') ||
                f.path.toLowerCase().endsWith('.txt'))
            .toList();

        setState(() {
          _files = files;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error picking directory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _getFileSize(String path) {
    try {
      final file = File(path);
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getModificationTime(String path) {
    try {
      final file = File(path);
      final stat = file.statSync();
      final date = stat.modified;
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('All Files'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _files.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      final fileName = file.path.split('/').last;
                      final isSupported =
                          fileName.toLowerCase().endsWith('.pdf');

                      return Card(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.white,
                        child: ListTile(
                          leading: Icon(
                            fileName.toLowerCase().endsWith('.pdf')
                                ? Icons.picture_as_pdf
                                : Icons.insert_drive_file,
                            color:
                                isSupported ? AppColors.primary : Colors.grey,
                            size: 28,
                          ),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${_getFileSize(file.path)} • ${_getModificationTime(file.path)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSupported
                              ? Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white30
                                      : Colors.grey.shade400,
                                )
                              : Tooltip(
                                  message: 'Not supported yet',
                                  child: Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: Colors.red.shade300,
                                  ),
                                ),
                          onTap: () {
                            if (isSupported) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PdfReaderPage(filePath: file.path),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Only PDF files are supported for viewing',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickDirectory,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.folder_open),
        label: const Text('Browse Folder'),
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
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.folder_open,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No documents found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse your device to find documents',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickDirectory,
            icon: const Icon(Icons.folder_open),
            label: const Text('Browse Folder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
