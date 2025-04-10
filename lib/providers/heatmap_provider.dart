// lib/providers/heatmap_provider.dart

// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/data/repositories/repositories.dart';
// Importer le provider des tâches pour créer la dépendance
import 'package:trackers_app/providers/task/task_provider.dart';

// Provider qui récupère les données formatées pour la heatmap
// Gardons .autoDispose si l'état peut être perdu quand l'écran n'est pas visible
final heatmapDataProvider =
    FutureProvider.autoDispose<Map<DateTime, int>>((ref) async {
  // --- AJOUT DE CETTE LIGNE ---
  // On "écoute" l'état des tâches. Quand taskProvider notifie un changement,
  // ce heatmapDataProvider sera automatiquement ré-exécuté.
  final taskState = ref.watch(taskProvider);
  // --- FIN AJOUT ---
  // Note: On n'utilise pas directement 'taskState' ici, mais le 'watch' crée la dépendance.

  print(
      "Heatmap Provider: Fetching data (déclenché par watch initial ou changement taskProvider)...");
  final repository =
      ref.watch(taskRepositoryProvider); // Lire le repo (ne change pas souvent)
  try {
    // L'appel à la base de données reste le même
    final data = await repository.getTasksCountByDate();
    print("Heatmap Provider: Data fetched (${data.length} entries)");
    return data;
  } catch (e, stack) {
    print("Heatmap Provider: Error fetching data: $e\n$stack");
    rethrow; // Important pour que .when(error:...) fonctionne
  }
});

// Rappel: Assurez-vous que taskRepositoryProvider et taskDatasourceProvider sont définis ailleurs
// final taskRepositoryProvider = Provider<TaskRepository>((ref) { /* ... */ });
// final taskDatasourceProvider = Provider<TaskDatasource>((ref) => TaskDatasource());
// final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) { /* ... */ });
