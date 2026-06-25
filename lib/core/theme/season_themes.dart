import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SeasonThemeMode {
  spring,
  summer,
  fall,
  winter,
  dark,
}

class SeasonThemes {
  static ThemeData getTheme(SeasonThemeMode mode) {
    ColorScheme colorScheme;

    switch (mode) {
      case SeasonThemeMode.spring:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFFD6336C),
          secondary: Color(0xFFFF4081),
          surface: Color(0xFFFFF0F3),
          error: Color(0xFFEF4444),
        );
        break;
      case SeasonThemeMode.summer:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFF0D9488),
          secondary: Color(0xFF06B6D4),
          surface: Color(0xFFFAF9F6),
          error: Color(0xFFEF4444),
        );
        break;
      case SeasonThemeMode.fall:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFFD97706),
          secondary: Color(0xFFEA580C),
          surface: Color(0xFFFAF8F5),
          error: Color(0xFFEF4444),
        );
        break;
      case SeasonThemeMode.winter:
        colorScheme = const ColorScheme.light(
          primary: Color(0xFF2563EB),
          secondary: Color(0xFF4F46E5),
          surface: Color(0xFFF5FAFF),
          error: Color(0xFFEF4444),
        );
        break;
      case SeasonThemeMode.dark:
        colorScheme = const ColorScheme.dark(
          primary: Color(0xFFD6336C),
          secondary: Color(0xFFFF4081),
          surface: Color(0xFF0B0F19),
          error: Color(0xFFEF4444),
        );
        break;
    }

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: mode == SeasonThemeMode.dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: GoogleFonts.beVietnamProTextTheme(
        mode == SeasonThemeMode.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
    );

    return baseTheme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.baloo2(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: mode == SeasonThemeMode.dark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 2,
        shadowColor: colorScheme.shadow.withAlpha((0.08 * 255).round()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.beVietnamPro(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// Extends ColorScheme to support gradients
extension ColorSchemeGradient on ColorScheme {
  List<Color> get seasonGradient {
    if (primary == const Color(0xFFD6336C)) {
      return const [Color(0xFFD6336C), Color(0xFFFF4081), Color(0xFFFFB6C1)];
    } else if (primary == const Color(0xFF0D9488)) {
      return const [Color(0xFF0D9488), Color(0xFF06B6D4), Color(0xFF38BDF8)];
    } else if (primary == const Color(0xFFD97706)) {
      return const [Color(0xFFD97706), Color(0xFFEA580C), Color(0xFFFCD34D)];
    } else if (primary == const Color(0xFF2563EB)) {
      return const [Color(0xFF2563EB), Color(0xFF4F46E5), Color(0xFFA5B4FC)];
    }
    return const [Color(0xFFD6336C), Color(0xFFFF4081), Color(0xFFFFB6C1)];
  }
}
