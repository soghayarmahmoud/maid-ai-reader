// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:maid_ai_reader/features/security/presentation/pin_setup_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/widgets/banner_ad_widget.dart';
import 'package:maid_ai_reader/l10n/app_localizations.dart';

const Color _kPrimary = Color(0xFF6C3CE7);
const Color _kPrimaryLight = Color(0xFF9B59B6);

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
      final info = await PackageInfo.fromPlatform();
      setState(() => _version = info.version);
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLockEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _enableBiometric = prefs.getBool('biometric_enabled') ?? false;
      final colorVal = prefs.getInt('highlight_color') ?? Colors.yellow.value;
      _defaultHighlightColor = Color(colorVal);
    });
  }

  Future<void> _saveBiometricSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF5F3FF),
      body: CustomScrollView(
        slivers: [
          // ─── Purple Gradient Header ───
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_kPrimary, _kPrimaryLight],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile / App card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text('M', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'MAID AI Reader',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Version $_version',
                                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('PRO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Settings Sections ───
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // APPEARANCE
                _sectionLabel(l10n.sectionAppearance, isDark),
                _card(isDark, children: [
                  _switchTile(
                    icon: Icons.dark_mode_rounded,
                    title: l10n.darkMode,
                    subtitle: l10n.darkModeDesc,
                    value: _isDarkMode,
                    onChanged: (v) {
                      setState(() => _isDarkMode = v);
                      widget.onToggleTheme();
                    },
                    isDark: isDark,
                  ),
                  _divider(isDark),
                  _tile(
                    icon: Icons.color_lens_rounded,
                    title: l10n.defaultHighlightColor,
                    isDark: isDark,
                    trailing: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _defaultHighlightColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                    ),
                  ),
                ]),

                // READING
                _sectionLabel(l10n.sectionReadingPreferences, isDark),
                _card(isDark, children: [
                  _tile(
                    icon: Icons.zoom_in_rounded,
                    title: l10n.defaultZoom,
                    subtitle: _defaultZoom,
                    isDark: isDark,
                    onTap: _showZoomDialog,
                    showArrow: true,
                  ),
                  _divider(isDark),
                  _switchTile(
                    icon: Icons.save_rounded,
                    title: l10n.autoSave,
                    subtitle: l10n.autoSaveDesc,
                    value: _autoSave,
                    onChanged: (v) => setState(() => _autoSave = v),
                    isDark: isDark,
                  ),
                  _divider(isDark),
                  _switchTile(
                    icon: Icons.image_rounded,
                    title: l10n.showThumbnails,
                    subtitle: l10n.showThumbnailsDesc,
                    value: _showThumbnails,
                    onChanged: (v) => setState(() => _showThumbnails = v),
                    isDark: isDark,
                  ),
                ]),

                // LANGUAGE
                _sectionLabel(l10n.sectionLanguage, isDark),
                _card(isDark, children: [
                  _tile(
                    icon: Icons.language_rounded,
                    title: l10n.language,
                    subtitle: _language,
                    isDark: isDark,
                    onTap: _showLanguageDialog,
                    showArrow: true,
                  ),
                ]),

                // SECURITY
                _sectionLabel(l10n.sectionSecurity, isDark),
                _card(isDark, children: [
                  _switchTile(
                    icon: Icons.lock_rounded,
                    title: l10n.appLock,
                    subtitle: l10n.appLockDesc,
                    value: _appLockEnabled,
                    onChanged: (v) async {
                      if (v) {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => const PinSetupPage()),
                        );
                        if (result == true) setState(() => _appLockEnabled = true);
                      } else {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('app_lock_enabled', false);
                        setState(() {
                          _appLockEnabled = false;
                          _enableBiometric = false;
                        });
                        await _saveBiometricSetting(false);
                      }
                    },
                    isDark: isDark,
                  ),
                  _divider(isDark),
                  _switchTile(
                    icon: Icons.fingerprint_rounded,
                    title: l10n.biometric,
                    subtitle: l10n.biometricDesc,
                    value: _enableBiometric,
                    onChanged: _appLockEnabled
                        ? (v) {
                            setState(() => _enableBiometric = v);
                            _saveBiometricSetting(v);
                          }
                        : null,
                    isDark: isDark,
                  ),
                ]),

                // STORAGE
                _sectionLabel(l10n.sectionStorage, isDark),
                _card(isDark, children: [
                  _tile(
                    icon: Icons.delete_sweep_rounded,
                    title: l10n.clearCache,
                    subtitle: l10n.clearCacheDesc,
                    isDark: isDark,
                    onTap: _showClearCacheDialog,
                    showArrow: true,
                  ),
                  _divider(isDark),
                  _tile(
                    icon: Icons.backup_rounded,
                    title: l10n.backupRestore,
                    subtitle: l10n.backupRestoreDesc,
                    isDark: isDark,
                    showArrow: true,
                  ),
                ]),

                // ABOUT
                _sectionLabel(l10n.sectionAbout, isDark),
                _card(isDark, children: [
                  _tile(icon: Icons.help_outline_rounded, title: l10n.helpShortcuts, isDark: isDark, onTap: _showHelpDialog, showArrow: true),
                  _divider(isDark),
                  _tile(icon: Icons.privacy_tip_outlined, title: l10n.privacyPolicy, isDark: isDark, showArrow: true),
                  _divider(isDark),
                  _tile(icon: Icons.description_outlined, title: l10n.termsOfService, isDark: isDark, showArrow: true),
                  _divider(isDark),
                  _tile(
                    icon: Icons.code_rounded,
                    title: l10n.openSourceLicenses,
                    isDark: isDark,
                    showArrow: true,
                    onTap: () => showLicensePage(context: context),
                  ),
                ]),

                const SizedBox(height: 16),
                const BannerAdWidget(isTest: false),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  REUSABLE WIDGETS
  // ═══════════════════════════════════════════

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: _kPrimary.withOpacity(isDark ? 0.7 : 1),
        ),
      ),
    );
  }

  Widget _card(bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEDE7F6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(height: 1, indent: 56, color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF0ECF8));
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kPrimary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)))
          : null,
      trailing: trailing ?? (showArrow ? Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? Colors.white24 : const Color(0xFFBDBDBD)) : null),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    ValueChanged<bool>? onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _kPrimary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1A1A2E))),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E))),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: _kPrimary,
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  DIALOGS
  // ═══════════════════════════════════════════

  void _showZoomDialog() {
    final l10n = AppLocalizations.of(context)!;
    final opts = [l10n.fitWidth, l10n.fitPage, l10n.actualSize, l10n.zoom50, l10n.zoom75, l10n.zoom100, l10n.zoom150, l10n.zoom200];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.defaultZoom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: opts.map((z) => RadioListTile(
            title: Text(z),
            value: z,
            groupValue: _defaultZoom,
            activeColor: _kPrimary,
            onChanged: (v) {
              setState(() => _defaultZoom = v as String);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;
    final langMap = {
      l10n.english: 'en', l10n.arabic: 'ar', l10n.spanish: 'es',
      l10n.french: 'fr', l10n.german: 'de', l10n.chinese: 'zh',
    };
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: langMap.keys.map((lang) => RadioListTile(
            title: Text(lang),
            value: lang,
            groupValue: _language,
            activeColor: _kPrimary,
            onChanged: (v) {
              setState(() => _language = v as String);
              widget.onLanguageChanged(Locale(langMap[v] ?? 'en'));
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.cacheCleared),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.helpShortcuts),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.keyboardShortcuts, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _shortcut(l10n.ctrlF, l10n.searchInPdf),
              _shortcut(l10n.ctrlH, l10n.highlightText),
              _shortcut(l10n.ctrlU, l10n.underlineText),
              _shortcut(l10n.ctrlS, l10n.strikeoutText),
              _shortcut(l10n.ctrlD, l10n.freeDrawing),
              _shortcut(l10n.ctrlT, l10n.toggleToolbar),
              _shortcut(l10n.ctrlB, l10n.addBookmark),
              _shortcut(l10n.arrowKeys, l10n.navigatePages),
              const SizedBox(height: 16),
              Text(l10n.pdfFeatures, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
    );
  }

  Widget _shortcut(String key, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(key, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: _kPrimary, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
