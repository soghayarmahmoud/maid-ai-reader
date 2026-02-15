import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Safe getter for AppLocalizations that provides default strings if context is invalid
extension AppLocalizationsHelper on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      throw FlutterError('AppLocalizations.of(context) returned null.\n'
          'Make sure AppLocalizations.delegate is in localizationsDelegates.');
    }
    return localizations;
  }
}

/// Fallback strings if localization fails
class FallbackStrings {
  static const String appName = 'Maid AI Reader';
  static const String home = 'Home';
  static const String settings = 'Settings';
  static const String help = 'Help';
  static const String recent = 'Recent';
  static const String allFiles = 'All Files';
  static const String openPdf = 'Open PDF';
  static const String opening = 'Opening...';
  static const String noRecentFiles = 'No Recent Files';
  static const String noRecentFilesMsg =
      'No recent files found. Start by opening a PDF.';
  static const String fileNotFound = 'File not found';
  static const String allFilesTitle = 'All Files';
  static const String allFilesMsg = 'Browse all files on your device';
}
