import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MAID AI Reader'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @darkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle between light and dark themes'**
  String get darkModeDesc;

  /// No description provided for @defaultHighlightColor.
  ///
  /// In en, this message translates to:
  /// **'Default Highlight Color'**
  String get defaultHighlightColor;

  /// No description provided for @readingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Reading Preferences'**
  String get readingPreferences;

  /// No description provided for @defaultZoom.
  ///
  /// In en, this message translates to:
  /// **'Default Zoom'**
  String get defaultZoom;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// No description provided for @autoSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically save reading progress'**
  String get autoSaveDesc;

  /// No description provided for @showThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Show Thumbnails'**
  String get showThumbnails;

  /// No description provided for @showThumbnailsDesc.
  ///
  /// In en, this message translates to:
  /// **'Display file thumbnails in library'**
  String get showThumbnailsDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @securityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security & Privacy'**
  String get securityPrivacy;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockDesc.
  ///
  /// In en, this message translates to:
  /// **'Require PIN to open app'**
  String get appLockDesc;

  /// No description provided for @biometric.
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometric;

  /// No description provided for @biometricDesc.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID'**
  String get biometricDesc;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @cacheSize.
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get cacheSize;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get clearCacheDesc;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup notes and annotations'**
  String get backupRestoreDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @helpShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Help & Shortcuts'**
  String get helpShortcuts;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all cached PDF pages and thumbnails. Your annotations and notes will not be affected.'**
  String get clearCacheMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared!'**
  String get cacheCleared;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts:'**
  String get keyboardShortcuts;

  /// No description provided for @searchInPdf.
  ///
  /// In en, this message translates to:
  /// **'Search in PDF'**
  String get searchInPdf;

  /// No description provided for @highlightText.
  ///
  /// In en, this message translates to:
  /// **'Highlight selected text'**
  String get highlightText;

  /// No description provided for @underlineText.
  ///
  /// In en, this message translates to:
  /// **'Underline selected text'**
  String get underlineText;

  /// No description provided for @strikeoutText.
  ///
  /// In en, this message translates to:
  /// **'Strikeout selected text'**
  String get strikeoutText;

  /// No description provided for @freeDrawing.
  ///
  /// In en, this message translates to:
  /// **'Free drawing mode'**
  String get freeDrawing;

  /// No description provided for @toggleToolbar.
  ///
  /// In en, this message translates to:
  /// **'Toggle annotation toolbar'**
  String get toggleToolbar;

  /// No description provided for @addBookmark.
  ///
  /// In en, this message translates to:
  /// **'Add bookmark'**
  String get addBookmark;

  /// No description provided for @navigatePages.
  ///
  /// In en, this message translates to:
  /// **'Navigate pages'**
  String get navigatePages;

  /// No description provided for @pdfFeatures.
  ///
  /// In en, this message translates to:
  /// **'PDF Features:'**
  String get pdfFeatures;

  /// No description provided for @pdfFeaturesDesc.
  ///
  /// In en, this message translates to:
  /// **'• Annotations with multiple colors\n• AI-powered chat and analysis\n• Smart notes with AI summarization\n• Text translation\n• Google search integration\n• Export conversations and notes\n• Advanced search with filters\n• Bookmarks and navigation'**
  String get pdfFeaturesDesc;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibrary;

  /// No description provided for @recentFiles.
  ///
  /// In en, this message translates to:
  /// **'Recent Files'**
  String get recentFiles;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @allDocuments.
  ///
  /// In en, this message translates to:
  /// **'All Documents'**
  String get allDocuments;

  /// No description provided for @importPdf.
  ///
  /// In en, this message translates to:
  /// **'Import PDF'**
  String get importPdf;

  /// No description provided for @searchDocuments.
  ///
  /// In en, this message translates to:
  /// **'Search documents...'**
  String get searchDocuments;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @tapPlusToImport.
  ///
  /// In en, this message translates to:
  /// **'Tap + to import your first PDF'**
  String get tapPlusToImport;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @askQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a question...'**
  String get askQuestion;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @simplify.
  ///
  /// In en, this message translates to:
  /// **'Simplify'**
  String get simplify;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @fitWidth.
  ///
  /// In en, this message translates to:
  /// **'Fit Width'**
  String get fitWidth;

  /// No description provided for @fitPage.
  ///
  /// In en, this message translates to:
  /// **'Fit Page'**
  String get fitPage;

  /// No description provided for @actualSize.
  ///
  /// In en, this message translates to:
  /// **'Actual Size'**
  String get actualSize;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
