// lib/screens/heatmap_screen.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importer Riverpod
import 'package:go_router/go_router.dart';
import 'package:trackers_app/components/my_heatmap.dart';
// Importer le nouveau provider
import 'package:trackers_app/providers/heatmap_provider.dart'; // Ajustez le chemin si nécessaire

// Convertir en ConsumerWidget
class HeatmapScreen extends ConsumerWidget {
  static HeatmapScreen builder(BuildContext context, GoRouterState state) {
    return const HeatmapScreen(); // Mettre const si HeatmapScreen n'a pas de state interne
  }

  const HeatmapScreen({super.key});

  @override
  // Ajouter WidgetRef ref
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter l'état du FutureProvider
    final heatmapDataAsync = ref.watch(heatmapDataProvider);
    // Définir une date de début par défaut (peut être rendue configurable plus tard)
    final DateTime startDate =
        DateTime(DateTime.now().year, 1, 1); // Ex: Début de l'année

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches Complétées'), // Préciser ce qui est affiché
      ),
      // Utiliser .when pour gérer les états de AsyncValue (loading, error, data)
      body: heatmapDataAsync.when(
        data: (datasets) {
          // État succès: les données sont disponibles
          if (datasets.isEmpty) {
            return const Center(
                child: Text('Aucune donnée de tâche complétée à afficher.'));
          }
          return Padding(
            padding: const EdgeInsets.all(12.0), // Ajuster le padding
            child: SingleChildScrollView(
              // Permettre le défilement si la heatmap est grande
              child: MyHeatmap(
                startDate: startDate,
                datasets: datasets,
                onClick: (date, count) {
                  print('Clicked on $date with count $count');
                  // Ici, vous pourriez implémenter une logique plus riche,
                  // par exemple ouvrir une bottom sheet affichant les tâches
                  // complétées de ce jour spécifique, en utilisant ref.read pour
                  // accéder au TaskNotifier et filtrer les tâches.
                },
              ),
            ),
          );
        },
        loading: () {
          // État chargement
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          // État erreur
          print(
              "Erreur heatmapDataProvider: $error\n$stackTrace"); // Log pour débogage
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erreur lors du chargement des données de la heatmap.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
