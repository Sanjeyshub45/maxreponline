// lib/theme/app_theme.dart
// Reference design: very dark bg, golden-yellow primary, minimal borders

import 'package:flutter/material.dart';

class AppTheme {
  // ─── Color palette ─────────────────────────────────────────────────────────
  static const Color background     = Color(0xFF0F0F0F);
  static const Color surface        = Color(0xFF1C1C1E);
  static const Color cardBg         = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2E);
  static const Color border         = Color(0xFF2C2C2E);

  // Golden yellow — matches reference exactly
  static const Color primary        = Color(0xFFFFD60A);
  static const Color primaryDark    = Color(0xFFC8A800);

  // Secondaries
  static const Color accent         = Color(0xFF8E8E93); // gray
  static const Color accentAlt      = Color(0xFF48484A);
  static const Color vitality       = Color(0xFF34C759); // green for vitality

  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFF8E8E93);
  static const Color textTertiary   = Color(0xFF48484A);

  // ─── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onPrimary: Color(0xFF000000),
        onSurface: textPrimary,
      ),

      // Text
      fontFamily: 'SF Pro Display',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 34),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 17),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 15),
        bodySmall: TextStyle(color: textSecondary, fontSize: 13),
      ),

      // Elevated button (golden pill)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        iconColor: textSecondary,
      ),

      // Divider
      dividerTheme: const DividerThemeData(color: border, thickness: 0.5),

      // Bottom nav
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
        ),
      ),
    );
  }
}
