import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Shortcuts'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Keyboard Shortcuts', [
            _buildShortcut('Ctrl + F', 'Search in PDF'),
            _buildShortcut('Ctrl + H', 'Highlight selected text'),
            _buildShortcut('Ctrl + U', 'Underline selected text'),
            _buildShortcut('Ctrl + S', 'Strikeout selected text'),
            _buildShortcut('Ctrl + C', 'Add comment to selected text'),
            _buildShortcut('Ctrl + T', 'Toggle tools toolbar'),
            _buildShortcut('← →', 'Navigate pages'),
          ]),
          const SizedBox(height: 24),
          _buildSection('PDF Reading Features', [
            const Text('• Highlight, underline, and strikeout text'),
            const Text('• Add comments and notes'),
            const Text('• AI-powered search and chat'),
            const Text('• Text translation'),
            const Text('• Smart notes taking'),
            const Text('• Zoom and pan'),
            const Text('• Page navigation'),
          ]),
          const SizedBox(height: 24),
          _buildSection('Getting Started', [
            const Text('1. Open a PDF file from the home screen'),
            const Text('2. Use the toolbar to access reading tools'),
            const Text('3. Select text to highlight or add notes'),
            const Text('4. Use AI chat for questions about the content'),
            const Text('5. Access settings to customize your experience'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: item,
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildShortcut(String key, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
