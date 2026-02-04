import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maid_ai_reader/l10n/app_localizations.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/library/presentation/library_page.dart';
import 'features/settings/settings_page.dart';
import 'features/help/help_page.dart';
import 'package:flutter/services.dart';
import 'features/pdf_reader/presentation/pdf_reader_page.dart';

class MyApp extends StatefulWidget {
  final String? initialFilePath;

  const MyApp({super.key, this.initialFilePath});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  int _selectedIndex = 0;
  Locale _locale = const Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    // Handle file from intent if present
    if (widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty) {
      print('📄 File opened from external app: ${widget.initialFilePath}');
    }

    // After first frame, ask native for any shared file (avoids MissingPluginException)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      const platform = MethodChannel('com.maid/file_intent');
      try {
        final shared = await platform.invokeMethod<String>('getSharedFile');
        if (shared != null && mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PdfReaderPage(filePath: shared),
          ));
        }
      } catch (e) {
        // Safe to ignore; native side may not implement the channel on some platforms
        debugPrint(
            'No shared file available or platform channel not implemented: $e');
      }
    });
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const LibraryPage(),
      SettingsPage(
        onToggleTheme: _toggleTheme,
        onLanguageChanged: _changeLanguage,
      ),
      const HelpPage(),
    ];

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      // Builder to handle RTL based on locale
      builder: (context, child) {
        return Directionality(
          textDirection: _locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                activeIcon: Icon(Icons.help),
                label: 'Help',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedFontSize: 12,
            unselectedFontSize: 11,
          ),
        ),
      ),
    );
  }
}
