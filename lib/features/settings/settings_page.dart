// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:maid_ai_reader/features/security/presentation/pin_setup_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/banner_ad_widget.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.defaultZoom,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: zoomOptions.map((zoom) {
            return RadioListTile<String>(
              title: Text(zoom),
              value: zoom,
              groupValue: _defaultZoom,
              onChanged: (value) {
                setState(() {
                  _defaultZoom = value as String;
                });
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.selectLanguage,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languageMap.keys.map((lang) {
            return RadioListTile<String>(
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
              activeColor: AppColors.primary,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.cacheCleared),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.helpShortcuts,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.keyboardShortcuts,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSectionHeader(String title, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildModernSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildModernSwitch(bool value, Function(bool)? onChanged) {
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
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
          _buildModernSectionHeader(
            AppLocalizations.of(context)!.sectionAppearance,
            icon: Icons.palette_rounded,
          ),
          _buildModernCard(
            children: [
              _buildModernSettingTile(
                icon: Icons.dark_mode_rounded,
                title: AppLocalizations.of(context)!.darkMode,
                subtitle: AppLocalizations.of(context)!.darkModeDesc,
                trailing: _buildModernSwitch(_isDarkMode, (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  widget.onToggleTheme();
                }),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.color_lens_rounded,
                title: AppLocalizations.of(context)!.defaultHighlightColor,
                subtitle: 'Choose highlight color',
                trailing: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _defaultHighlightColor,
                      border: Border.all(
                        color: AppColors.grey300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _defaultHighlightColor.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Reading Preferences Section
          _buildModernSectionHeader(
            AppLocalizations.of(context)!.sectionReadingPreferences,
            icon: Icons.menu_book_rounded,
          ),
          _buildModernCard(
            children: [
              _buildModernSettingTile(
                icon: Icons.zoom_in_rounded,
                title: AppLocalizations.of(context)!.defaultZoom,
                subtitle: _defaultZoom,
                onTap: _showZoomDialog,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.save_rounded,
                title: AppLocalizations.of(context)!.autoSave,
                subtitle: AppLocalizations.of(context)!.autoSaveDesc,
                trailing: _buildModernSwitch(_autoSave, (value) {
                  setState(() {
                    _autoSave = value;
                  });
                }),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.image_rounded,
                title: AppLocalizations.of(context)!.showThumbnails,
                subtitle: AppLocalizations.of(context)!.showThumbnailsDesc,
                trailing: _buildModernSwitch(_showThumbnails, (value) {
                  setState(() {
                    _showThumbnails = value;
                  });
                }),
              ),
            ],
          ),

          // Language Section
          _buildModernSectionHeader(
            AppLocalizations.of(context)!.sectionLanguage,
            icon: Icons.language_rounded,
          ),
          _buildModernCard(
            children: [
              _buildModernSettingTile(
                icon: Icons.language_rounded,
                title: AppLocalizations.of(context)!.language,
                subtitle: _language,
                onTap: _showLanguageDialog,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            ],
          ),

          // Security Section
          _buildModernSectionHeader(
            AppLocalizations.of(context)!.sectionSecurity,
            icon: Icons.security_rounded,
          ),
          _buildModernCard(
            children: [
              _buildModernSettingTile(
                icon: Icons.lock_rounded,
                title: AppLocalizations.of(context)!.appLock,
                subtitle: AppLocalizations.of(context)!.appLockDesc,
                trailing: _buildModernSwitch(_appLockEnabled, (value) async {
                  if (value) {
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
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('app_lock_enabled', false);
                    setState(() {
                      _appLockEnabled = false;
                      _enableBiometric = false;
                    });
                    await _saveBiometricSetting(false);
                  }
                }),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.fingerprint_rounded,
                title: AppLocalizations.of(context)!.biometric,
                subtitle: AppLocalizations.of(context)!.biometricDesc,
                trailing: _buildModernSwitch(
                    _enableBiometric,
                    _appLockEnabled
                        ? (value) {
                            setState(() {
                              _enableBiometric = value;
                            });
                          }
                        : null),
              ),
            ],
          ),

          // Storage Section
          _buildModernSectionHeader(
            AppLocalizations.of(context)!.sectionStorage,
            icon: Icons.storage_rounded,
          ),
          _buildModernCard(
            children: [
              _buildModernSettingTile(
                icon: Icons.storage_rounded,
                title: AppLocalizations.of(context)!.cacheSize,
                subtitle: AppLocalizations.of(context)!.calculating,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.delete_sweep_rounded,
                title: AppLocalizations.of(context)!.clearCache,
                subtitle: AppLocalizations.of(context)!.clearCacheDesc,
                onTap: _showClearCacheDialog,
                trailing: const SizedBox.shrink(),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.backup_rounded,
                title: AppLocalizations.of(context)!.backupRestore,
                subtitle: AppLocalizations.of(context)!.backupRestoreDesc,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            ],
          ),

          // About Section
          _buildModernSectionHeader(
            AppLocalizations.of(context)!.sectionAbout,
            icon: Icons.info_rounded,
          ),
          _buildModernCard(
            children: [
              _buildModernSettingTile(
                icon: Icons.info_rounded,
                title: AppLocalizations.of(context)!.version,
                subtitle: _version,
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.help_rounded,
                title: AppLocalizations.of(context)!.helpShortcuts,
                onTap: _showHelpDialog,
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.privacy_tip_rounded,
                title: AppLocalizations.of(context)!.privacyPolicy,
                trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.description_rounded,
                title: AppLocalizations.of(context)!.termsOfService,
                trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              ),
              const Divider(height: 1),
              _buildModernSettingTile(
                icon: Icons.code_rounded,
                title: AppLocalizations.of(context)!.openSourceLicenses,
                onTap: () {
                  showLicensePage(context: context);
                },
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const BannerAdWidget(isTest: false),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
