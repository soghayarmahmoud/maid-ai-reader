import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_states.dart';
import '../pdf_reader/presentation/pdf_reader_page.dart';
import 'data/models/reading_progress_model.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin {
  final List<File> _recentFiles = [];
  late TabController _tabController;
  bool _isLoading = false;
  final ReadingProgressRepository _progressRepo = ReadingProgressRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeProgress();
  }

  Future<void> _initializeProgress() async {
    try {
      await _progressRepo.initialize();
      _loadRecentFiles();
    } catch (e) {
      print('Error initializing progress: $e');
    }
  }

  void _loadRecentFiles() {
    final recentProgress = _progressRepo.getRecentFiles(limit: 20);
    setState(() {
      _recentFiles.clear();
      for (var progress in recentProgress) {
        if (File(progress.pdfPath).existsSync()) {
          _recentFiles.add(File(progress.pdfPath));
        }
      }
    });
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await _openPdf(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openPdf(File file) async {
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found')),
        );
      }
      return;
    }

    // Save to recent files
    if (!_recentFiles.contains(file)) {
      setState(() {
        _recentFiles.insert(0, file);
        if (_recentFiles.length > 20) {
          _recentFiles.removeLast();
        }
      });
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfReaderPage(filePath: file.path),
        ),
      ).then((_) => _loadRecentFiles());
    }
  }

  String _getFileName(File file) {
    return file.path.split(Platform.pathSeparator).last;
  }

  String _getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'Recent'),
            Tab(icon: Icon(Icons.folder), text: 'All Files'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecentTab(),
          _buildAllFilesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _pickFile,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add),
        label: Text(_isLoading ? 'Opening...' : 'Open PDF'),
      ),
    );
  }

  Widget _buildRecentTab() {
    if (_recentFiles.isEmpty) {
      return EmptyStateWidget(
        title: 'No Recent Files',
        message: 'Open a PDF to get started.\nYour recently viewed files will appear here.',
        icon: Icons.description_outlined,
        onAction: _pickFile,
        actionButtonText: 'Open PDF',
        actionIcon: Icons.add,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentFiles.length,
      itemBuilder: (context, index) {
        final file = _recentFiles[index];
        final progress = _progressRepo.getProgress(file.path);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _openPdf(file),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.picture_as_pdf,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              file,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
