// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Optionnel: pour la persistance
// import 'package:shared_preferences/shared_preferences.dart';

// Le Notifier qui contient la logique et l'état (le ThemeMode)
class ThemeNotifier extends StateNotifier<ThemeMode> {
  // Initialiser l'état (ex: ThemeMode.system)
  ThemeNotifier() : super(ThemeMode.system) {
    // Optionnel: Charger la préférence sauvegardée au démarrage
    // _loadThemeMode();
  }

  // Future<void> _loadThemeMode() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
  //     state = ThemeMode.values[themeIndex];
  //   } catch (e) {
  //     // Gérer l'erreur si SharedPreferences échoue
  //     print("Erreur chargement thème: $e");
  //     state = ThemeMode.system;
  //   }
  // }

  void setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode; // Met à jour l'état géré par StateNotifier

    // Optionnel: Sauvegarder la préférence
    // try {
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setInt('themeMode', mode.index);
    // } catch (e) {
    //   print("Erreur sauvegarde thème: $e");
    // }
  }
}

// Le Provider immuable qui expose le ThemeNotifier
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
