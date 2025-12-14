import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Cool Grey 100
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5), // Indigo 600
    brightness: Brightness.light,
    primary: const Color(0xFF4F46E5),
    secondary: const Color(0xFF0EA5E9), // Sky 500
    surface: const Color(0xFFF3F4F6), // Cool Grey 100 (Background)
    surfaceContainer: const Color(0xFFFFFFFF), // White (Cards/Bars)
    onSurface: const Color(0xFF111827), // Grey 900 (Text)
    error: const Color(0xFFEF4444),
  ),
  useMaterial3: true,
  /* cardTheme: CardTheme(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
    ),
  ), */
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFF3F4F6),
    foregroundColor: Color(0xFF111827),
    elevation: 0,
  ),
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).apply(
    bodyColor: const Color(0xFF111827),
    displayColor: const Color(0xFF111827),
  ),
);
