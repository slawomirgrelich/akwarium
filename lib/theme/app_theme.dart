import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _lightScaffold = Color(0xFFF2F8F6);
  static const _darkScaffold = Color(0xFF0F172A);
  static const _darkSurface = Color(0xFF1E293B);
  static const _darkPrimary = Color(0xFF2DD4BF);
  static const _darkOnSurface = Color(0xFFF8FAFC);
  static const _darkOnSurfaceVariant = Color(0xFFCBD5E1);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightScaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF9FBFB),
        foregroundColor: Color(0xFF0F2D2A),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Color(0x180F2D2A),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x240F2D2A)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x180F2D2A), space: 1),
      filledButtonTheme: _buttonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(dark: false),
    );
  }

  static ThemeData get dark {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _darkPrimary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _darkPrimary,
          onPrimary: const Color(0xFF042F2E),
          surface: _darkSurface,
          onSurface: _darkOnSurface,
          onSurfaceVariant: _darkOnSurfaceVariant,
          outline: const Color(0xFF475569),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkScaffold,
      canvasColor: _darkScaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkScaffold,
        foregroundColor: _darkOnSurface,
        elevation: 0,
      ),
      cardColor: _darkSurface,
      cardTheme: CardThemeData(
        color: _darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0x33475569)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x33475569), space: 1),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkOnSurface),
        bodyMedium: TextStyle(color: _darkOnSurfaceVariant),
        bodySmall: TextStyle(color: _darkOnSurfaceVariant),
        titleLarge: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: TextStyle(
          color: _darkOnSurface,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: TextStyle(color: _darkOnSurface),
      ),
      iconTheme: const IconThemeData(color: _darkOnSurfaceVariant),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      filledButtonTheme: _buttonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(dark: true),
    );
  }

  static FilledButtonThemeData _buttonTheme() => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme() =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme({required bool dark}) {
    final borderColor = dark ? const Color(0xFF475569) : Colors.white24;
    final fillColor = dark ? _darkSurface : Colors.white;
    final labelColor = dark ? _darkOnSurfaceVariant : const Color(0xFF49635E);
    final focusedColor = dark ? _darkPrimary : Colors.teal;
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: labelColor),
      floatingLabelStyle: TextStyle(color: focusedColor),
      hintStyle: TextStyle(color: labelColor),
      prefixIconColor: labelColor,
      suffixStyle: TextStyle(color: labelColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedColor, width: 2),
      ),
    );
  }
}
