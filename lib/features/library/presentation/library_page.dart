import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../pdf_reader/presentation/pdf_reader_page.dart';

class LibraryPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const LibraryPage({super.key, required this.onToggleTheme});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final List<String> _recentFiles = [];

  Future<void> _openPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (mounted) {
          setState(() {
            if (!_recentFiles.contains(filePath)) {
              _recentFiles.insert(0, filePath);
              if (_recentFiles.length > 10) {
                _recentFiles.removeLast();
              }
            }
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfReaderPage(filePath: filePath),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appFullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to ${AppStrings.appName}',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.appFullName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openPdfFile,
              icon: const Icon(Icons.file_open),
              label: const Text(AppStrings.openPdf),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            if (_recentFiles.isNotEmpty) ...[
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Files',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _recentFiles.length,
                      itemBuilder: (context, index) {
                        final file = _recentFiles[index];
                        final fileName = file.split('/').last;
                        return RepaintBoundary(
                          child: ListTile(
                            leading: const Icon(Icons.picture_as_pdf),
                            title: Text(fileName),
                            subtitle: Text(file),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfReaderPage(filePath: file),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
