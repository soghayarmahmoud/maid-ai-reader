import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final Function(Locale) onLanguageChanged;

  const SettingsPage({
    super.key,
    required this.onToggleTheme,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Settings state
  bool _isDarkMode = false;
  String _language = 'English';
  bool _autoSave = true;
  bool _showThumbnails = true;
  String _defaultZoom = 'Fit Width';
  Color _defaultHighlightColor = Colors.yellow;
  bool _enableBiometric = false;
  bool _appLockEnabled = false;
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
      });
    } catch (e) {
      print('Error loading version: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('🎨 Appearance'),
          _buildCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
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
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Default Highlight Color'),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _defaultHighlightColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () {
                  // TODO: Show color picker
                },
              ),
            ],
          ),

          // Reading Preferences Section
          _buildSectionHeader('📖 Reading Preferences'),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.zoom_in),
                title: const Text('Default Zoom'),
                subtitle: Text(_defaultZoom),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showZoomDialog,
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.save),
                title: const Text('Auto Save'),
                subtitle: const Text('Automatically save reading progress'),
                value: _autoSave,
                onChanged: (value) {
                  setState(() {
                    _autoSave = value;
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.image),
                title: const Text('Show Thumbnails'),
                subtitle: const Text('Display file thumbnails in library'),
                value: _showThumbnails,
                onChanged: (value) {
                  setState(() {
                    _showThumbnails = value;
                  });
                },
              ),
            ],
          ),

          // Language Section
          _buildSectionHeader('🌍 Language'),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(_language),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showLanguageDialog,
              ),
            ],
          ),

          // Security Section
          _buildSectionHeader('🔒 Security & Privacy'),
          _buildCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.lock),
                title: const Text('App Lock'),
                subtitle: const Text('Require PIN to open app'),
                value: _appLockEnabled,
                onChanged: (value) {
                  setState(() {
                    _appLockEnabled = value;
                  });
                  // TODO: Show PIN setup dialog
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometric Authentication'),
                subtitle: const Text('Use fingerprint or face ID'),
                value: _enableBiometric,
                onChanged: _appLockEnabled ? (value) {
                  setState(() {
                    _enableBiometric = value;
                  });
                } : null,
              ),
            ],
          ),

          // Storage Section
          _buildSectionHeader('💾 Storage'),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Cache Size'),
                subtitle: const Text('Calculating...'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show cache details
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up storage space'),
                onTap: _showClearCacheDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Backup notes and annotations'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show backup options
                },
              ),
            ],
          ),

          // About Section
          _buildSectionHeader('ℹ️ About'),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Version'),
                subtitle: Text(_version),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Shortcuts'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showHelpDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {
                  // TODO: Open terms
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Open Source Licenses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }





  void _showZoomDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Zoom'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'Fit Width',
            'Fit Page',
            'Actual Size',
            '50%',
            '75%',
            '100%',
            '150%',
            '200%',
          ].map((zoom) {
            return RadioListTile(
              title: Text(zoom),
              value: zoom,
              groupValue: _defaultZoom,
              onChanged: (value) {
                setState(() {
                  _defaultZoom = value as String;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languageMap = {
      'English': 'en',
      'Arabic': 'ar',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Arabic'].map((lang) {
            return RadioListTile(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value as String;
                });
                final languageCode = languageMap[value] ?? 'en';
                widget.onLanguageChanged(Locale(languageCode));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will delete all cached PDF pages and thumbnails. '
          'Your annotations and notes will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
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
              const Text(
                'Keyboard Shortcuts:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildShortcutItem('Ctrl + F', 'Search in PDF'),
              _buildShortcutItem('Ctrl + H', 'Highlight selected text'),
              _buildShortcutItem('Ctrl + U', 'Underline selected text'),
              _buildShortcutItem('Ctrl + S', 'Strikeout selected text'),
              _buildShortcutItem('Ctrl + D', 'Free drawing mode'),
              _buildShortcutItem('Ctrl + T', 'Toggle annotation toolbar'),
              _buildShortcutItem('Ctrl + B', 'Add bookmark'),
              _buildShortcutItem('← →', 'Navigate pages'),
              const SizedBox(height: 16),
              const Text(
                'PDF Features:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('• Annotations with multiple colors'),
              const Text('• AI-powered chat and analysis'),
              const Text('• Smart notes with AI summarization'),
              const Text('• Text translation'),
              const Text('• Google search integration'),
              const Text('• Export conversations and notes'),
              const Text('• Advanced search with filters'),
              const Text('• Bookmarks and navigation'),
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
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
