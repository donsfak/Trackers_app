import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black, // Vrai noir
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6B4CF2), // Deep Purple Premium
    brightness: Brightness.dark,
    primary: const Color(0xFF6B4CF2),
    secondary: const Color(0xFF00D1FF), // Cyan Accent
    surface: const Color(0xFF121212), // Slightly lighter black for cards
    onSurface: Colors.white,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);
