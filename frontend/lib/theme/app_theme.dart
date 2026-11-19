import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Anti-“AI Look” Design Tokens
  // Primary: deep teal #0F766E, used sparingly (primary buttons, active nav, header, key accents only).
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color primaryTealDark = Color(0xFF115E59);
  static const Color primaryTealLight = Color(0xFFCCFBF1);

  // Surfaces & Backgrounds
  // Neutral off-white background #F7F8F8, white surfaces, hairline borders #E4E7E7.
  static const Color background = Color(0xFFF7F8F8);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFFAFAFA);
  static const Color hairlineBorder = Color(0xFFE4E7E7);

  // Status Indicators (shown with small dots or plain text, not large pills)
  static const Color statusPending = Color(0xFFD97706); // Amber
  static const Color statusApproved = Color(0xFF0F766E); // Deep Teal
  static const Color statusRejected = Color(0xFFDC2626); // Red
  static const Color statusCompleted = Color(0xFF16A34A); // Green
  static const Color statusInfo = Color(0xFF2563EB); // Blue

  // Single Standard Radius: 8.0
  static const double radius = 8.0;

  // Single Standard Subtle Elevation / Shadow
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: primaryTealLight,
      onPrimaryContainer: const Color(0xFF042F29),
      surface: surface,
      onSurface: const Color(0xFF0F172A),
      background: background,
      onBackground: const Color(0xFF0F172A),
      outline: hairlineBorder,
      outlineVariant: const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A), size: 20),
        shape: const Border(
          bottom: BorderSide(color: hairlineBorder, width: 1.0),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: primaryTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: statusRejected, width: 1.0),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF64748B)),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF94A3B8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(color: hairlineBorder, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: hairlineBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Backwards compatibility aliases
  static const Color primaryEmerald = primaryTeal;
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightBorder = hairlineBorder;

  static ThemeData darkTheme() {
    return lightTheme(); // Focus on light mode first per design principles
  }
}
