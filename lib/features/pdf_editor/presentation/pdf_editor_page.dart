import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
                      icon: Icons.watermark,
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
            _buildInfoRow('File Size', '${(_pdfInfo!.fileSize / 1024 / 1024).toStringAsFixed(2)} MB'),
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
      // TODO: Show page selector and position picker
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insert Image'),
          content: const Text('Select page and position for image'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Insert image at position
                await _editorService.insertImage(
                  pdfPath: widget.pdfPath,
                  imagePath: result.files.single.path!,
                  pageNumber: 0,
                  x: 50,
                  y: 50,
                );
                Navigator.pop(context);
                _showSuccessSnackbar('Image inserted successfully');
              },
              child: const Text('Insert'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showRotatePageDialog() async {
    // TODO: Show page selector and rotation angle
    _showSuccessSnackbar('Rotate page feature - Select page and angle');
  }

  Future<void> _showDeletePageDialog() async {
    // TODO: Show page selector
    _showSuccessSnackbar('Delete page feature - Select pages to delete');
  }

  Future<void> _showReorderPagesDialog() async {
    // TODO: Show drag-and-drop page reorder interface
    _showSuccessSnackbar('Reorder pages feature - Drag to reorder');
  }

  Future<void> _showCropPageDialog() async {
    // TODO: Show page selector and crop area picker
    _showSuccessSnackbar('Crop page feature - Select area to crop');
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
      // TODO: Show page and position selector
      _showSuccessSnackbar('Signature feature - Select position');
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
      
      // TODO: Show merge preview and output path selector
      _showSuccessSnackbar('Merge ${paths.length} PDFs');
    }
  }

  Future<void> _showSplitPdfDialog() async {
    // TODO: Show page range selector
    _showSuccessSnackbar('Split PDF feature - Select split points');
  }

  Future<void> _showFormFillingDialog() async {
    // TODO: Show form fields editor
    _showSuccessSnackbar('Form filling feature - Fill form fields');
  }

  Future<void> _exportPdf() async {
    final outputPath = '${widget.pdfPath.replaceAll('.pdf', '_edited.pdf')}';
    
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
