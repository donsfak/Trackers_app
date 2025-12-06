import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Choisissez votre couleur principale
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
);
