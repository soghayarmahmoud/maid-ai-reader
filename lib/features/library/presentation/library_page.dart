// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:maid_ai_reader/core/constants/app_colors.dart';
import 'package:maid_ai_reader/core/constants/app_strings.dart';
import 'package:maid_ai_reader/core/widgets/error_states.dart';
import 'package:maid_ai_reader/core/widgets/banner_ad_widget.dart';
import 'package:maid_ai_reader/core/widgets/interstitial_ad_manager.dart';
import 'package:maid_ai_reader/features/library/data/models/reading_progress_model.dart';
import 'package:maid_ai_reader/features/pdf_reader/presentation/pdf_reader_page.dart';
import 'package:maid_ai_reader/l10n/app_localizations.dart';
import 'package:maid_ai_reader/l10n/l10n_helper.dart';
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
  late ReadingProgressRepository _progressRepo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _progressRepo = ReadingProgressRepository();
    _initializeProgress();

    // Load interstitial ad in background
    Future.delayed(const Duration(seconds: 2), () {
      final interstitialAdManager = InterstitialAdManager();
      if (!interstitialAdManager.isAdLoaded) {
        interstitialAdManager.loadInterstitialAd(isTest: false);
        print('✓ Preloading interstitial ad for next use');
      }
    });
  }

  Future<void> _initializeProgress() async {
    try {
      // Initialize repository if not already done
      if (!_progressRepo.isInitialized) {
        await _progressRepo.initialize();
      }
      _loadRecentFiles();
      print('✓ Reading progress repository initialized');
    } catch (e, stackTrace) {
      print('✗ Error initializing progress repository: $e');
      print('Stack trace: $stackTrace');
      // Show snackbar with error but let app continue - delayed to avoid inherited widget error
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Library loading: ${e.toString()}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        });
      }
    }
  }

  void _loadRecentFiles() {
    if (!_progressRepo.isInitialized) {
      setState(() {
        _recentFiles.clear();
      });
      return;
    }

    try {
      final recentProgress = _progressRepo.getRecentFiles(limit: 20);
      setState(() {
        _recentFiles.clear();
        for (var progress in recentProgress) {
          if (File(progress.pdfPath).existsSync()) {
            _recentFiles.add(File(progress.pdfPath));
          }
        }
      });
    } catch (e) {
      print('Error loading recent files: $e');
    }
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
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      print('Error in _pickFile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openPdf(File file) async {
    if (!await file.exists()) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n?.fileNotFound ?? FallbackStrings.fileNotFound),
              backgroundColor: AppColors.error),
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

    // Show interstitial ad before opening PDF
    print('📢 Preparing to show interstitial ad...');
    final interstitialAdManager = InterstitialAdManager();
    if (interstitialAdManager.isAdLoaded) {
      await interstitialAdManager.showInterstitialAd();
    } else {
      print('⚠️ Interstitial ad not ready yet, loading in background...');
      // Load ad for next time
      interstitialAdManager.loadInterstitialAd(isTest: false);
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
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 4,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? Colors.grey.shade500 : Colors.grey.shade700,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          splashFactory: NoSplash.splashFactory,
          tabs: [
            Tab(
              icon: Icon(Icons.history_rounded,
                  color: _tabController.index == 0
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade700)),
              text: l10n?.recent ?? FallbackStrings.recent,
            ),
            Tab(
              icon: Icon(Icons.folder_rounded,
                  color: _tabController.index == 1
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade500 : Colors.grey.shade700)),
              text: l10n?.allFiles ?? FallbackStrings.allFiles,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecentTab(),
                _buildAllFilesTab(),
              ],
            ),
          ),
          // Banner Ad
          const BannerAdWidget(isTest: false),
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
            : const Icon(Icons.add_rounded),
        label: Text(_isLoading
            ? (l10n?.opening ?? FallbackStrings.opening)
            : (l10n?.openPdf ?? FallbackStrings.openPdf)),
      ),
    );
  }

  Widget _buildRecentTab() {
    final l10n = AppLocalizations.of(context);
    if (_recentFiles.isEmpty) {
      return EmptyStateWidget(
        title: l10n?.noRecentFiles ?? FallbackStrings.noRecentFiles,
        message: l10n?.noRecentFilesMsg ?? FallbackStrings.noRecentFilesMsg,
        icon: Icons.description_outlined,
        onAction: _pickFile,
        actionButtonText: l10n?.openPdf ?? FallbackStrings.openPdf,
        actionIcon: Icons.add_rounded,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentFiles.length,
      itemBuilder: (context, index) {
        final file = _recentFiles[index];
        final progress = _progressRepo.isInitialized
            ? _progressRepo.getProgress(file.path)
            : null;
        final fileName = _getFileName(file);
        final fileSize = _getFileSize(file);
        final progressPercent = progress?.progressPercentage ?? 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _openPdf(file),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // PDF Icon with background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // File info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              fileSize,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            if (progress != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${progressPercent.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Progress bar
                        if (progress != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progressPercent / 100,
                              minHeight: 3,
                              backgroundColor: AppColors.grey300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.secondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Action icon
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: AppColors.grey500,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllFilesTab() {
    final l10n = AppLocalizations.of(context);
    return EmptyStateWidget(
      title: l10n?.allFilesTitle ?? FallbackStrings.allFilesTitle,
      message: l10n?.allFilesMsg ?? FallbackStrings.allFilesMsg,
      icon: Icons.folder_open_rounded,
      onAction: _pickFile,
      actionButtonText: l10n?.openPdf ?? FallbackStrings.openPdf,
      actionIcon: Icons.add_rounded,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
