import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System & Palette Google Stitch pour AtelierPro (Niger).
class AtelierProColors {
  static const primary = Color(0xFF442A22); // Deep Terracotta / Brown
  static const primaryContainer = Color(0xFF5D4037);
  static const secondary = Color(0xFF745B20); // Warm Bronze / Gold
  static const secondaryContainer = Color(0xFFFFDB94);
  
  static const background = Color(0xFFFFF8F6);
  static const surface = Color(0xFFFFF8F6);
  static const surfaceTan = Color(0xFFFDFBF7);
  static const surfaceContainerHigh = Color(0xFFEFE6E4);
  static const surfaceContainerLowest = Colors.white;

  static const onPrimary = Colors.white;
  static const onSurface = Color(0xFF1E1B1A);
  static const onSurfaceVariant = Color(0xFF504441);
  static const outline = Color(0xFF827470);
  static const outlineVariant = Color(0xFFD4C3BE);

  // Couleurs de statut
  static const statusPending = Color(0xFFF59E0B);
  static const statusProgress = Color(0xFF3B82F6);
  static const statusDone = Color(0xFF10B981);
  static const statusDelivered = Color(0xFF6366F1);

  // Rétrocompatibilité des noms
  static const terracotta = primary;
  static const sable = background;
  static const encre = onSurface;
  static const vertSucces = statusDone;
  static const orangeAttente = statusPending;
  static const rougeAlerte = Color(0xFFBA1A1A);
}

class AtelierProTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AtelierProColors.primary,
        onPrimary: AtelierProColors.onPrimary,
        primaryContainer: AtelierProColors.primaryContainer,
        secondary: AtelierProColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AtelierProColors.secondaryContainer,
        surface: AtelierProColors.surface,
        onSurface: AtelierProColors.onSurface,
        surfaceContainerHigh: AtelierProColors.surfaceContainerHigh,
        outline: AtelierProColors.outline,
        outlineVariant: AtelierProColors.outlineVariant,
        error: AtelierProColors.rougeAlerte,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AtelierProColors.surfaceTan,
    );

    final textTheme = GoogleFonts.sourceSans3TextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.hankenGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AtelierProColors.primary,
      ),
      headlineMedium: GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AtelierProColors.onSurface,
      ),
      titleMedium: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AtelierProColors.onSurface,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AtelierProColors.onSurface,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AtelierProColors.onSurface,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AtelierProColors.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AtelierProColors.surfaceTan,
        foregroundColor: AtelierProColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AtelierProColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AtelierProColors.outlineVariant, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AtelierProColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AtelierProColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AtelierProColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AtelierProColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AtelierProColors.primary, width: 2),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AtelierProColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
