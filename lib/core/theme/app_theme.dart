import 'package:flutter/material.dart';

class AppTheme {
  // Theme Colors - Customizable
  static Color primaryColor = const Color(0xFF6366F1); // Indigo
  static Color secondaryColor = const Color(0xFF8B5CF6); // Purple
  static Color accentColor = const Color(0xFFEC4899); // Pink
  static Color backgroundColor = const Color(0xFFF8FAFC);
  static Color surfaceColor = Colors.white;
  static Color errorColor = const Color(0xFFEF4444);
  static Color successColor = const Color(0xFF10B981);
  static Color warningColor = const Color(0xFFF59E0B);

  // Dark Theme Colors
  static Color darkPrimaryColor = const Color(0xFF818CF8);
  static Color darkBackgroundColor = const Color(0xFF0F172A);
  static Color darkSurfaceColor = const Color(0xFF1E293B);
  static Color darkCardColor = const Color(0xFF334155);

  // Night Mode Warmth (0.0 = cool, 1.0 = warm)
  static double nightModeWarmth = 0.5;

  // Glassmorphism
  static BoxDecoration glassDecoration({
    Color? color,
    double blur = 10,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Animated Gradient Background
  static BoxDecoration gradientBackground({bool isDark = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                darkBackgroundColor,
                darkBackgroundColor.withBlue(40),
                darkBackgroundColor.withBlue(60),
              ]
            : [
                backgroundColor,
                backgroundColor.withBlue(255),
                backgroundColor.withGreen(250),
              ],
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: backgroundColor,
      surface: surfaceColor,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surfaceColor,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(color: primaryColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: darkBackgroundColor,
      surface: darkSurfaceColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: darkCardColor,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkPrimaryColor, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkPrimaryColor.withOpacity(0.2),
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // Night Mode Theme (with warmth)
  static ThemeData nightTheme({double warmth = 0.5}) {
    final warmColor = Color.lerp(
      const Color(0xFF1E293B), // Cool blue-gray
      const Color(0xFF292524), // Warm brown-gray
      warmth,
    )!;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: warmColor,
        surface: warmColor.withOpacity(0.9),
      ),
      scaffoldBackgroundColor: warmColor,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: warmColor.withOpacity(0.8),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white.withOpacity(0.9),
        centerTitle: true,
      ),
    );
  }

  // Preset Theme Colors
  static final List<ThemePreset> presets = [
    ThemePreset(
      name: 'Indigo Dream',
      primary: const Color(0xFF6366F1),
      secondary: const Color(0xFF8B5CF6),
      accent: const Color(0xFFEC4899),
    ),
    ThemePreset(
      name: 'Ocean Blue',
      primary: const Color(0xFF0EA5E9),
      secondary: const Color(0xFF06B6D4),
      accent: const Color(0xFF3B82F6),
    ),
    ThemePreset(
      name: 'Emerald Forest',
      primary: const Color(0xFF10B981),
      secondary: const Color(0xFF059669),
      accent: const Color(0xFF14B8A6),
    ),
    ThemePreset(
      name: 'Sunset Orange',
      primary: const Color(0xFFF97316),
      secondary: const Color(0xFFEF4444),
      accent: const Color(0xFFF59E0B),
    ),
    ThemePreset(
      name: 'Royal Purple',
      primary: const Color(0xFF9333EA),
      secondary: const Color(0xFFA855F7),
      accent: const Color(0xFFD946EF),
    ),
    ThemePreset(
      name: 'Rose Gold',
      primary: const Color(0xFFF43F5E),
      secondary: const Color(0xFFEC4899),
      accent: const Color(0xFFFBBF24),
    ),
  ];

  // Apply theme preset
  static void applyPreset(ThemePreset preset) {
    primaryColor = preset.primary;
    secondaryColor = preset.secondary;
    accentColor = preset.accent;
  }

  // Page transition
  static PageRouteBuilder<T> createRoute<T>({
    required Widget page,
    TransitionType type = TransitionType.slide,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          
          case TransitionType.slide:
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          
          case TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            );
          
          case TransitionType.rotation:
            return RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

class ThemePreset {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;

  ThemePreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
  });
}

enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
}
