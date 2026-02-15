// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_theme.dart';
import 'features/library/presentation/library_page.dart';
import 'features/settings/settings_page.dart';
import 'features/pdf_reader/presentation/pdf_reader_page.dart';
import 'features/search/presentation/search_page.dart';
import 'features/files/presentation/files_page.dart';
import 'l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  final String? initialFilePath;

  const MyApp({super.key, this.initialFilePath});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Handle shared file intent from native Android
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check for initial file path passed from security wrapper
      if (widget.initialFilePath != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _openPdfPage(widget.initialFilePath!);
        }
        return;
      }

      // Check for shared file from native intent
      const platform = MethodChannel('com.maid/file_intent');
      try {
        final shared = await platform.invokeMethod<String>('getSharedFile');
        if (shared != null && shared.isNotEmpty && mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _openPdfPage(shared);
          }
        }
      } catch (e) {
        debugPrint('No shared file available: $e');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openPdfPage(String filePath) {
    // Set the index to 0 (home) first, then navigate to PDF reader
    setState(() => _currentIndex = 0);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PdfReaderPage(filePath: filePath),
        ));
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const LibraryPage(),
      const SearchPage(),
      const FilesPage(),
      SettingsPage(
        onToggleTheme: _toggleTheme,
        onLanguageChanged: _changeLanguage,
      ),
    ];

    return MaterialApp(
      title: 'MAID AI Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('es'),
        Locale('fr'),
        Locale('de'),
        Locale('zh'),
      ],
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFF6C3CE7).withOpacity(0.12),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: Color(0xFF6C3CE7)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search, color: Color(0xFF6C3CE7)),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder, color: Color(0xFF6C3CE7)),
                label: 'Files',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings, color: Color(0xFF6C3CE7)),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
