import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  // Modern color schemes - Updated for better design
  static const Color primaryColor = Color(0xFF667EEA); // Modern Blue
  static const Color secondaryColor = Color(0xFF764BA2); // Purple Gradient
  static const Color accentColor = Color(0xFFF093FB); // Pink Accent
  static const Color successColor = Color(0xFF4ADE80); // Modern Green
  static const Color warningColor = Color(0xFFFBBF24); // Modern Amber
  static const Color errorColor = Color(0xFFF87171); // Modern Red

  // Light theme colors - Modern and clean
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark theme colors - Modern dark mode with better contrast
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkText = Color(0xFFFFFFFF); // Pure white for better visibility
  static const Color darkTextSecondary = Color(0xFFE2E8F0); // Lighter secondary text

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _isDarkMode = _themeMode == ThemeMode.dark;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  // Light theme
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: lightSurface,
        background: lightBackground,
        error: errorColor,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: lightSurface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightText),
        bodySmall: TextStyle(color: lightTextSecondary),
        labelLarge: TextStyle(color: lightText),
        labelMedium: TextStyle(color: lightTextSecondary),
        labelSmall: TextStyle(color: lightTextSecondary),
      ),
    );
  }

  // Dark theme
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkSurface,
        background: darkBackground,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: darkSurface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkText),
        bodyMedium: TextStyle(color: darkText),
        bodySmall: TextStyle(color: darkTextSecondary),
        labelLarge: TextStyle(color: darkText),
        labelMedium: TextStyle(color: darkTextSecondary),
        labelSmall: TextStyle(color: darkTextSecondary),
      ),
    );
  }
}
