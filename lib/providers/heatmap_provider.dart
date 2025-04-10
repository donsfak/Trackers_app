// lib/providers/heatmap_provider.dart ou autre fichier de providers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/data/repositories/repositories.dart'; // Pour taskRepositoryProvider

// Provider qui récupère les données formatées pour la heatmap
final heatmapDataProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  // Lire le repository (assurez-vous que taskRepositoryProvider est défini !)
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTasksCountByDate();
});

// Assurez-vous que taskRepositoryProvider est défini quelque part, par exemple :
// final taskRepositoryProvider = Provider<TaskRepository>((ref) {
//   final datasource = ref.watch(taskDatasourceProvider); // taskDatasourceProvider doit aussi exister
//   return TaskRepositoryImpl(datasource);
// });

// et taskDatasourceProvider
// final taskDatasourceProvider = Provider<TaskDatasource>((ref) => TaskDatasource());
