// lib/app/trackers_app.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importer les thèmes définis et le nouveau provider
import '../config/theme/theme.dart';
// Importer le provider des routes
import '../config/routes/routes_providers.dart';

class TrackersApp extends ConsumerWidget {
  const TrackersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lire la configuration des routes via Riverpod
    final routeConfig = ref.watch(routesProviders);
    // Lire le mode de thème actuel via Riverpod
    final themeMode = ref.watch(themeNotifierProvider); // <- AJOUTÉ ICI

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Trackers App', // Ajoutez un titre si vous voulez

      // --- Configuration du Thème ---
      themeMode: themeMode, // Utiliser le mode du provider Riverpod
      theme: lightMode, // Le thème clair défini précédemment
      darkTheme: darkMode, // Le thème sombre défini précédemment
      // --- Fin Configuration du Thème ---

      // Configuration des routes avec GoRouter (fourni par routesProviders)
      routerConfig: routeConfig,
    );
  }
}
