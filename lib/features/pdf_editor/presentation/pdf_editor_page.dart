// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/pdf_editor_service.dart';
import 'dart:io';

/// PDF Editor Page - Main editing interface
class PdfEditorPage extends StatefulWidget {
  final String pdfPath;

  const PdfEditorPage({
    super.key,
    required this.pdfPath,
  });

  @override
  State<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends State<PdfEditorPage> {
  final PdfEditorService _editorService = PdfEditorService();
  PdfInfo? _pdfInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPdfInfo();
  }

  Future<void> _loadPdfInfo() async {
    setState(() {
      _isLoading = true;
    });

    final info = await _editorService.getPdfInfo(widget.pdfPath);

    setState(() {
      _pdfInfo = info;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _exportPdf,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // PDF Info Card
                if (_pdfInfo != null) _buildInfoCard(),
                const SizedBox(height: 16),

                // Page Operations
                _buildSectionCard(
                  title: 'Page Operations',
                  icon: Icons.pages,
                  children: [
                    _buildActionTile(
                      icon: Icons.rotate_right,
                      title: 'Rotate Pages',
                      subtitle: 'Rotate individual pages',
                      onTap: _showRotatePageDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.delete,
                      title: 'Delete Pages',
                      subtitle: 'Remove unwanted pages',
                      onTap: _showDeletePageDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.reorder,
                      title: 'Reorder Pages',
                      subtitle: 'Change page order',
                      onTap: _showReorderPagesDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.crop,
                      title: 'Crop Pages',
                      subtitle: 'Trim page margins',
                      onTap: _showCropPageDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Content Operations
                _buildSectionCard(
                  title: 'Add Content',
                  icon: Icons.add_circle_outline,
                  children: [
                    _buildActionTile(
                      icon: Icons.image,
                      title: 'Insert Image',
                      subtitle: 'Add images to pages',
                      onTap: _showInsertImageDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.waterfall_chart,
                      title: 'Add Watermark',
                      subtitle: 'Add text watermark',
                      onTap: _showWatermarkDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.draw,
                      title: 'Add Signature',
                      subtitle: 'Insert digital signature',
                      onTap: _showSignatureDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Document Operations
                _buildSectionCard(
                  title: 'Document Operations',
                  icon: Icons.description,
                  children: [
                    _buildActionTile(
                      icon: Icons.merge,
                      title: 'Merge PDFs',
                      subtitle: 'Combine multiple PDFs',
                      onTap: _showMergePdfsDialog,
                    ),
                    _buildActionTile(
                      icon: Icons.call_split,
                      title: 'Split PDF',
                      subtitle: 'Split into multiple files',
                      onTap: _showSplitPdfDialog,
                    ),
                    if (_pdfInfo?.hasForm ?? false)
                      _buildActionTile(
                        icon: Icons.edit_document,
                        title: 'Fill Forms',
                        subtitle: 'Fill PDF form fields',
                        onTap: _showFormFillingDialog,
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Info',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Pages', '${_pdfInfo!.pageCount}'),
            _buildInfoRow('File Size',
                '${(_pdfInfo!.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
            if (_pdfInfo!.title.isNotEmpty)
              _buildInfoRow('Title', _pdfInfo!.title),
            if (_pdfInfo!.author.isNotEmpty)
              _buildInfoRow('Author', _pdfInfo!.author),
            _buildInfoRow('Has Forms', _pdfInfo!.hasForm ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // Action dialogs
  Future<void> _showInsertImageDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      // Ask for target page and position (simple inputs)
      final pageController = TextEditingController(text: '0');
      final xController = TextEditingController(text: '50');
      final yController = TextEditingController(text: '50');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insert Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: pageController,
                  decoration:
                      const InputDecoration(labelText: 'Page (0-based)')),
              TextField(
                  controller: xController,
                  decoration: const InputDecoration(labelText: 'X position')),
              TextField(
                  controller: yController,
                  decoration: const InputDecoration(labelText: 'Y position')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final page = int.tryParse(pageController.text) ?? 0;
                final x = double.tryParse(xController.text) ?? 50;
                final y = double.tryParse(yController.text) ?? 50;
                final success = await _editorService.insertImage(
                  pdfPath: widget.pdfPath,
                  imagePath: result.files.single.path!,
                  pageNumber: page,
                  x: x,
                  y: y,
                );
                Navigator.pop(context);
                if (success) {
                  _showSuccessSnackbar('Image inserted successfully');
                }
              },
              child: const Text('Insert'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showRotatePageDialog() async {
    final pageController = TextEditingController(text: '0');
    int angleIndex = 0;
    final angles = ['90', '180', '270'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rotate Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: pageController,
                decoration: const InputDecoration(labelText: 'Page (0-based)')),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: angleIndex,
              items: List.generate(
                  angles.length,
                  (i) =>
                      DropdownMenuItem(value: i, child: Text('${angles[i]}°'))),
              onChanged: (v) => angleIndex = v ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final page = int.tryParse(pageController.text) ?? 0;
              final angle = angleIndex == 0
                  ? PdfPageRotateAngle.rotateAngle90
                  : angleIndex == 1
                      ? PdfPageRotateAngle.rotateAngle180
                      : PdfPageRotateAngle.rotateAngle270;
              final success = await _editorService.rotatePage(
                  pdfPath: widget.pdfPath, pageNumber: page, angle: angle);
              Navigator.pop(context);
              if (success) _showSuccessSnackbar('Page rotated');
            },
            child: const Text('Rotate'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeletePageDialog() async {
    final pagesController = TextEditingController(text: '0');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pages'),
        content: TextField(
            controller: pagesController,
            decoration: const InputDecoration(
                labelText: 'Pages (comma-separated, 0-based)')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final raw = pagesController.text
                  .split(',')
                  .map((s) => int.tryParse(s.trim()))
                  .whereType<int>()
                  .toList();
              raw.sort();
              for (int i = raw.length - 1; i >= 0; i--) {
                await _editorService.deletePage(
                    pdfPath: widget.pdfPath, pageNumber: raw[i]);
              }
              Navigator.pop(context);
              _showSuccessSnackbar('Selected pages deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReorderPagesDialog() async {
    final orderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reorder Pages'),
        content: TextField(
            controller: orderController,
            decoration: const InputDecoration(
                labelText: 'New order (comma-separated indexes)')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final order = orderController.text
                  .split(',')
                  .map((s) => int.tryParse(s.trim()))
                  .whereType<int>()
                  .toList();
              if (order.isNotEmpty) {
                await _editorService.reorderPages(
                    pdfPath: widget.pdfPath, newOrder: order);
                Navigator.pop(context);
                _showSuccessSnackbar('Pages reordered');
              }
            },
            child: const Text('Reorder'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCropPageDialog() async {
    final pageController = TextEditingController(text: '0');
    final lController = TextEditingController(text: '0');
    final tController = TextEditingController(text: '0');
    final wController = TextEditingController(text: '300');
    final hController = TextEditingController(text: '400');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crop Page'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: pageController,
                  decoration:
                      const InputDecoration(labelText: 'Page (0-based)')),
              TextField(
                  controller: lController,
                  decoration: const InputDecoration(labelText: 'Left')),
              TextField(
                  controller: tController,
                  decoration: const InputDecoration(labelText: 'Top')),
              TextField(
                  controller: wController,
                  decoration: const InputDecoration(labelText: 'Width')),
              TextField(
                  controller: hController,
                  decoration: const InputDecoration(labelText: 'Height')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final page = int.tryParse(pageController.text) ?? 0;
              final left = double.tryParse(lController.text) ?? 0.0;
              final top = double.tryParse(tController.text) ?? 0.0;
              final width = double.tryParse(wController.text) ?? 300.0;
              final height = double.tryParse(hController.text) ?? 400.0;
              final rect = Rect.fromLTWH(left, top, width, height);
              final success = await _editorService.cropPage(
                  pdfPath: widget.pdfPath, pageNumber: page, cropBox: rect);
              Navigator.pop(context);
              if (success) _showSuccessSnackbar('Page cropped');
            },
            child: const Text('Crop'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWatermarkDialog() async {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Watermark'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Watermark Text',
            hintText: 'Enter watermark text',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text;
              if (text.isNotEmpty) {
                final success = await _editorService.addWatermark(
                  pdfPath: widget.pdfPath,
                  watermarkText: text,
                );
                Navigator.pop(context);
                if (success) {
                  _showSuccessSnackbar('Watermark added successfully');
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignatureDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      final pageController = TextEditingController(text: '0');
      final lController = TextEditingController(text: '50');
      final tController = TextEditingController(text: '50');
      final wController = TextEditingController(text: '150');
      final hController = TextEditingController(text: '60');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Add Signature'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: pageController,
                  decoration:
                      const InputDecoration(labelText: 'Page (0-based)')),
              TextField(
                  controller: lController,
                  decoration: const InputDecoration(labelText: 'Left')),
              TextField(
                  controller: tController,
                  decoration: const InputDecoration(labelText: 'Top')),
              TextField(
                  controller: wController,
                  decoration: const InputDecoration(labelText: 'Width')),
              TextField(
                  controller: hController,
                  decoration: const InputDecoration(labelText: 'Height')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final page = int.tryParse(pageController.text) ?? 0;
                final left = double.tryParse(lController.text) ?? 50.0;
                final top = double.tryParse(tController.text) ?? 50.0;
                final width = double.tryParse(wController.text) ?? 150.0;
                final height = double.tryParse(hController.text) ?? 60.0;
                final bounds = Rect.fromLTWH(left, top, width, height);
                final success = await _editorService.addSignature(
                  pdfPath: widget.pdfPath,
                  signatureImagePath: result.files.single.path!,
                  pageNumber: page,
                  bounds: bounds,
                );
                Navigator.pop(context);
                if (success) _showSuccessSnackbar('Signature added');
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showMergePdfsDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final paths = result.files.map((f) => f.path!).toList();
      paths.insert(0, widget.pdfPath);

      final outputDir = File(widget.pdfPath).parent.path;
      final outputPath =
          '$outputDir/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final resultPath = await _editorService.mergePdfs(
          pdfPaths: paths, outputPath: outputPath);
      if (resultPath != null) {
        _showSuccessSnackbar('Merged PDFs to $resultPath');
      }
    }
  }

  Future<void> _showSplitPdfDialog() async {
    final splitsController = TextEditingController();
    final outputDir = File(widget.pdfPath).parent.path;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split PDF'),
        content: TextField(
            controller: splitsController,
            decoration: const InputDecoration(
                labelText: 'Split points (comma separated page indexes)')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final points = splitsController.text
                  .split(',')
                  .map((s) => int.tryParse(s.trim()))
                  .whereType<int>()
                  .toList();
              final outputs = await _editorService.splitPdf(
                  pdfPath: widget.pdfPath,
                  outputDir: outputDir,
                  splitPoints: points);
              Navigator.pop(context);
              if (outputs.isNotEmpty) {
                _showSuccessSnackbar('Split into ${outputs.length} files');
              }
            },
            child: const Text('Split'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFormFillingDialog() async {
    final fieldController = TextEditingController();
    final valueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fill Form Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: fieldController,
                decoration: const InputDecoration(labelText: 'Field name')),
            TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final field = fieldController.text.trim();
              final value = valueController.text;
              if (field.isNotEmpty) {
                final success = await _editorService.fillFormField(
                    pdfPath: widget.pdfPath, fieldName: field, value: value);
                Navigator.pop(context);
                if (success) _showSuccessSnackbar('Form field updated');
              }
            },
            child: const Text('Fill'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    final outputPath = widget.pdfPath.replaceAll('.pdf', '_edited.pdf');

    final success = await _editorService.exportPdf(
      sourcePath: widget.pdfPath,
      destinationPath: outputPath,
      flatten: true,
    );

    if (success != null) {
      _showSuccessSnackbar('PDF exported to: $outputPath');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
