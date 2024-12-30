import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define light and dark themes
final ThemeData lightMode = ThemeData.light().copyWith(
  primaryColor: Colors.purple,
  colorScheme: const ColorScheme.light(primary: Colors.purple),
);

final ThemeData darkMode = ThemeData.dark().copyWith(
  primaryColor: Colors.deepPurple,
  colorScheme: const ColorScheme.dark(primary: Colors.deepPurple),
);

// StateNotifier to manage theme state
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightMode);

  bool get isDarkMode => state == darkMode;

  void toggleTheme() {
    state = isDarkMode ? lightMode : darkMode;
  }
}

// Define a provider for the theme
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
