import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/error_states.dart';
import '../../pdf_reader/presentation/pdf_reader_page.dart';
import '../data/models/reading_progress_model.dart';
import '../services/pdf_import_service.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final PdfImportService _importService = PdfImportService();
  List<ImportedPdfInfo> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _importService.initialize();
      _loadRecentFiles();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  void _loadRecentFiles() {
    setState(() {
      _recentFiles = _importService.getRecentFiles(limit: 20);
    });
  }

  Future<void> _importPdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _importService.importPdf();

      if (!mounted) return;

      if (result.isSuccess) {
        _loadRecentFiles();
        _openPdf(result.file!.path, result.fileName!);
      } else {
        _showError(result.error!, result.message!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(PdfImportError error, String message) {
    if (!mounted) return;

    final snackBar = SnackBar(
      content: Text(message),
      action: error == PdfImportError.permissionDenied
          ? SnackBarAction(
              label: 'Settings',
              onPressed: () {
                // Open app settings
                // openAppSettings(); // from permission_handler
              },
            )
          : null,
      duration: const Duration(seconds: 4),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _openPdf(String filePath, String fileName) async {
    final file = File(filePath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found')),
        );
        // Remove from history if file no longer exists
        await _importService.removeFromHistory(filePath);
        _loadRecentFiles();
      }
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfReaderPage(filePath: filePath),
        ),
      ).then((_) => _loadRecentFiles());
    }
  }

  Future<void> _removeFromHistory(ImportedPdfInfo file) async {
    await _importService.removeFromHistory(file.filePath);
    _loadRecentFiles();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${file.fileName}" from history'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              // Re-import the file to restore it
              final pdfFile = File(file.filePath);
              if (await pdfFile.exists()) {
                final result = await _importService.importPdf();
                if (result.isSuccess) {
                  _loadRecentFiles();
                }
              }
            },
          ),
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        onPressed: _isLoading ? null : _importPdf,
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
        label: Text(_isLoading ? 'Importing...' : 'Import PDF'),
      ),
    );
  }

  Widget _buildRecentTab() {
    if (_recentFiles.isEmpty) {
      return EmptyStateWidget(
        title: 'No Recent Files',
        message:
            'Import a PDF to get started.\nYour recently viewed files will appear here.',
        icon: Icons.description_outlined,
        onAction: _importPdf,
        actionButtonText: 'Import PDF',
        actionIcon: Icons.add,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadRecentFiles();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recentFiles.length,
        itemBuilder: (context, index) {
          final file = _recentFiles[index];
          return _buildFileCard(file);
        },
      ),
    );
  }

  Widget _buildAllFilesTab() {
    if (_recentFiles.isEmpty) {
      return EmptyStateWidget(
        title: 'No Files',
        message: 'Import PDF files to see them here.',
        icon: Icons.folder_open_outlined,
        onAction: _importPdf,
        actionButtonText: 'Import PDF',
        actionIcon: Icons.add,
      );
    }

    // Sort by file name for the all files tab
    final sortedFiles = List<ImportedPdfInfo>.from(_recentFiles)
      ..sort((a, b) =>
          a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));

    return RefreshIndicator(
      onRefresh: () async {
        _loadRecentFiles();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedFiles.length,
        itemBuilder: (context, index) {
          final file = sortedFiles[index];
          return _buildFileCard(file, showProgress: false);
        },
      ),
    );
  }

  Widget _buildFileCard(ImportedPdfInfo file, {bool showProgress = true}) {
    return Dismissible(
      key: Key(file.filePath),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove from history?'),
            content: Text('Remove "${file.fileName}" from your library?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _removeFromHistory(file),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _openPdf(file.filePath, file.fileName),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        file.lastOpenedText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (showProgress && file.totalPages > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: file.progressPercentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    file.progressPercentage >= 100
                                        ? Colors.green
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${file.currentPage}/${file.totalPages}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'remove':
                        _removeFromHistory(file);
                        break;
                      case 'open':
                        _openPdf(file.filePath, file.fileName);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'open',
                      child: ListTile(
                        leading: Icon(Icons.open_in_new),
                        title: Text('Open'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title:
                            Text('Remove', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
