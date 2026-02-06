import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:maid_ai_reader/core/constants/app_colors.dart';
import 'package:maid_ai_reader/core/constants/app_strings.dart';
import 'package:maid_ai_reader/core/widgets/error_states.dart';
import 'package:maid_ai_reader/features/library/data/models/reading_progress_model.dart';
import 'package:maid_ai_reader/features/pdf_reader/presentation/pdf_reader_page.dart';
import 'package:maid_ai_reader/l10n/app_localizations.dart';
import 'dart:io';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
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
          SnackBar(content: Text(AppLocalizations.of(context)!.fileNotFound)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade700
              : Colors.grey.shade400,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(icon: const Icon(Icons.history), text: AppLocalizations.of(context)!.recent),
            Tab(icon: const Icon(Icons.folder), text: AppLocalizations.of(context)!.allFiles),
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
        label: Text(_isLoading ? AppLocalizations.of(context)!.opening : AppLocalizations.of(context)!.openPdf),
      ),
    );
  }

  Widget _buildRecentTab() {
    if (_recentFiles.isEmpty) {
      return EmptyStateWidget(
        title: AppLocalizations.of(context)!.noRecentFiles,
        message: AppLocalizations.of(context)!.noRecentFilesMsg,
        icon: Icons.description_outlined,
        onAction: _pickFile,
        actionButtonText: AppLocalizations.of(context)!.openPdf,
        actionIcon: Icons.add,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentFiles.length,
      itemBuilder: (context, index) {
        final file = _recentFiles[index];
        final progress = _progressRepo.getProgress(file.path);
        final fileName = _getFileName(file);

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
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    file.path,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                )));
      },
    );
  }

  Widget _buildAllFilesTab() {
    return EmptyStateWidget(
      title: AppLocalizations.of(context)!.allFilesTitle,
      message: AppLocalizations.of(context)!.allFilesMsg,
      icon: Icons.folder_outlined,
      onAction: _pickFile,
      actionButtonText: AppLocalizations.of(context)!.openPdf,
      actionIcon: Icons.add,
    );
  }
}
