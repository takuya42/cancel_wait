import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _primary = Color(0xFF2563EB);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      fontFamily: 'sans-serif',
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x182563EB),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE1E8E5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAF9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD9E2DF)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
    );
  }
}
