import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SettingsPage({super.key, required this.onToggleTheme});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  String _language = 'English';
  bool _autoSave = true;
  bool _showThumbnails = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle between light and dark themes'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              widget.onToggleTheme();
            },
          ),
          _buildSectionHeader('Language'),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showLanguageDialog,
          ),
          _buildSectionHeader('Reading'),
          SwitchListTile(
            title: const Text('Auto Save'),
            subtitle: const Text('Automatically save reading progress'),
            value: _autoSave,
            onChanged: (value) {
              setState(() {
                _autoSave = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Thumbnails'),
            subtitle: const Text('Display file thumbnails in library'),
            value: _showThumbnails,
            onChanged: (value) {
              setState(() {
                _showThumbnails = value;
              });
            },
          ),
          _buildSectionHeader('About'),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Help & Shortcuts'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _showHelpDialog,
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Open terms
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value as String;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value as String;
                });
                Navigator.pop(context);
              },
            ),
            // Add more languages as needed
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutItem('Ctrl + F', 'Search in PDF'),
              _buildShortcutItem('Ctrl + H', 'Highlight selected text'),
              _buildShortcutItem('Ctrl + U', 'Underline selected text'),
              _buildShortcutItem('Ctrl + S', 'Strikeout selected text'),
              _buildShortcutItem('Ctrl + C', 'Add comment to selected text'),
              _buildShortcutItem('Ctrl + T', 'Toggle tools toolbar'),
              _buildShortcutItem('← →', 'Navigate pages'),
              const SizedBox(height: 16),
              const Text(
                'PDF Reading Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Highlight, underline, and strikeout text'),
              const Text('• Add comments and notes'),
              const Text('• AI-powered search and chat'),
              const Text('• Text translation'),
              const Text('• Smart notes taking'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
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
