// lib/config/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'light_mode.dart';
import 'dark_mode.dart';

// Option 1: Export simple (suffisant pour ce cas)
// (Pas besoin de classe, juste exporter depuis theme.dart)

// OU Option 2: Classe d'accès statique
class AppThemes {
  static final ThemeData light = lightMode;
  static final ThemeData dark = darkMode;
}

// Mettez à jour theme.dart pour exporter correctement
// lib/config/theme/theme.dart
// Exportez aussi le provider
