import 'package:flutter/material.dart';

/// App Theme Configuration
/// Mengikuti konsep Single Responsibility Principle
/// Semua konfigurasi theme aplikasi berada di satu tempat
class AppTheme {
  /// Palet utama bertema oranye-putih yang sporty
  static const Color primaryColor = Color(0xFFFC4C02); // Strava orange
  static const Color secondaryColor = Color(0xFFFF8F4B); // Warm amber
  static const Color neutralDark = Color(0xFF111827);
  static const Color neutralBody = Color(0xFF4B5563);
  static const Color errorColor = Color(0xFFE45858);
  static const Color successColor = Color(0xFF16A34A);

  /// Method untuk mendapatkan light theme
  /// Mengembalikan ThemeData untuk light mode
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: Colors.white,
        onSurface: neutralDark,
        onPrimary: Colors.white,
        surfaceTint: Colors.transparent,
        primaryContainer: const Color(0xFFFFE1D1),
        onPrimaryContainer: neutralDark,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: neutralDark),
        displayMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: neutralDark),
        displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: neutralDark),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: neutralDark),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: neutralDark),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: neutralDark),
        bodyLarge: TextStyle(fontSize: 16, color: neutralDark),
        bodyMedium: TextStyle(fontSize: 14, color: neutralBody),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: neutralDark),
      ),
    );
  }

  /// Method untuk mendapatkan dark theme (opsional)
  /// Mengembalikan ThemeData untuk dark mode
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: const Color(0xFF1F2937),
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF111827),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}

