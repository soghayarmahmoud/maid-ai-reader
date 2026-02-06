import 'package:flutter/material.dart';
import 'package:maid_ai_reader/features/security/presentation/pin_setup_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import 'package:maid_ai_reader/l10n/app_localizations.dart';

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
    _loadSettings();
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

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final pinEnabled = prefs.getBool('app_lock_enabled') ?? false;
    final biometricAvailable = false;

    setState(() {
      _appLockEnabled = pinEnabled;
      _enableBiometric = prefs.getBool('biometric_enabled') ?? false;

      // Load highlight color
      final colorValue = prefs.getInt('highlight_color') ?? Colors.yellow.value;
      _defaultHighlightColor = Color(colorValue);
    });
  }

  Future<void> _saveBiometricSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(AppLocalizations.of(context)!.sectionAppearance),
          _buildCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: Text(AppLocalizations.of(context)!.darkMode),
                subtitle: Text(AppLocalizations.of(context)!.darkModeDesc),
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
                title: Text(AppLocalizations.of(context)!.defaultHighlightColor),
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
          _buildSectionHeader(AppLocalizations.of(context)!.sectionReadingPreferences),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.zoom_in),
                title: Text(AppLocalizations.of(context)!.defaultZoom),
                subtitle: Text(_defaultZoom),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showZoomDialog,
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.save),
                title: Text(AppLocalizations.of(context)!.autoSave),
                subtitle: Text(AppLocalizations.of(context)!.autoSaveDesc),
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
                title: Text(AppLocalizations.of(context)!.showThumbnails),
                subtitle: Text(AppLocalizations.of(context)!.showThumbnailsDesc),
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
          _buildSectionHeader(AppLocalizations.of(context)!.sectionLanguage),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.language),
                subtitle: Text(_language),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showLanguageDialog,
              ),
            ],
          ),

          // Security Section
          _buildSectionHeader(AppLocalizations.of(context)!.sectionSecurity),
          _buildCard(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.lock),
                title: Text(AppLocalizations.of(context)!.appLock),
                subtitle: Text(AppLocalizations.of(context)!.appLockDesc),
                value: _appLockEnabled,
                onChanged: (value) async {
                  if (value) {
                    // Show PIN setup
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PinSetupPage(),
                      ),
                    );
                    if (result == true) {
                      setState(() {
                        _appLockEnabled = true;
                      });
                    }
                  } else {
                    // Disable PIN
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('app_lock_enabled', false);
                    setState(() {
                      _appLockEnabled = false;
                      _enableBiometric = false;
                    });
                    await _saveBiometricSetting(false);
                  }
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: Text(AppLocalizations.of(context)!.biometric),
                subtitle: Text(AppLocalizations.of(context)!.biometricDesc),
                value: _enableBiometric,
                onChanged: _appLockEnabled
                    ? (value) {
                        setState(() {
                          _enableBiometric = value;
                        });
                      }
                    : null,
              ),
            ],
          ),

          // Storage Section
          _buildSectionHeader(AppLocalizations.of(context)!.sectionStorage),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: Text(AppLocalizations.of(context)!.cacheSize),
                subtitle: Text(AppLocalizations.of(context)!.calculating),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show cache details
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: Text(AppLocalizations.of(context)!.clearCache),
                subtitle: Text(AppLocalizations.of(context)!.clearCacheDesc),
                onTap: _showClearCacheDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.backup),
                title: Text(AppLocalizations.of(context)!.backupRestore),
                subtitle: Text(AppLocalizations.of(context)!.backupRestoreDesc),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Show backup options
                },
              ),
            ],
          ),

          // About Section
          _buildSectionHeader(AppLocalizations.of(context)!.sectionAbout),
          _buildCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(AppLocalizations.of(context)!.version),
                subtitle: Text(_version),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text(AppLocalizations.of(context)!.helpShortcuts),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showHelpDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: Text(AppLocalizations.of(context)!.privacyPolicy),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(AppLocalizations.of(context)!.termsOfService),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () {
                  // TODO: Open terms
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(AppLocalizations.of(context)!.openSourceLicenses),
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
    final l10n = AppLocalizations.of(context)!;
    final zoomOptions = [
      l10n.fitWidth,
      l10n.fitPage,
      l10n.actualSize,
      l10n.zoom50,
      l10n.zoom75,
      l10n.zoom100,
      l10n.zoom150,
      l10n.zoom200,
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.defaultZoom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: zoomOptions.map((zoom) {
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
    final l10n = AppLocalizations.of(context)!;
    final languageMap = {
      l10n.english: 'en',
      l10n.arabic: 'ar',
      l10n.spanish: 'es',
      l10n.french: 'fr',
      l10n.german: 'de',
      l10n.chinese: 'zh',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageMap.keys.map((lang) {
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cacheCleared)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.helpShortcuts),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.keyboardShortcuts,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildShortcutItem(l10n.ctrlF, l10n.searchInPdf),
              _buildShortcutItem(l10n.ctrlH, l10n.highlightText),
              _buildShortcutItem(l10n.ctrlU, l10n.underlineText),
              _buildShortcutItem(l10n.ctrlS, l10n.strikeoutText),
              _buildShortcutItem(l10n.ctrlD, l10n.freeDrawing),
              _buildShortcutItem(l10n.ctrlT, l10n.toggleToolbar),
              _buildShortcutItem(l10n.ctrlB, l10n.addBookmark),
              _buildShortcutItem(l10n.arrowKeys, l10n.navigatePages),
              const SizedBox(height: 16),
              Text(
                l10n.pdfFeatures,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text('• ${l10n.annotationsMultipleColors}'),
              Text('• ${l10n.aiPoweredChat}'),
              Text('• ${l10n.smartNotes}'),
              Text('• ${l10n.textTranslation}'),
              Text('• ${l10n.googleSearch}'),
              Text('• ${l10n.exportConversations}'),
              Text('• ${l10n.advancedSearch}'),
              Text('• ${l10n.bookmarksNavigation}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
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
          Expanded(
              child: Text(description, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
