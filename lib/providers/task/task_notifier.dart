// lib/providers/task/task_notifier.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/task/task_state.dart'; // Importer TaskState

// Assurez-vous que taskProvider est défini (probablement dans task_provider.dart)
// final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
//   final repository = ref.watch(taskRepositoryProvider);
//   return TaskNotifier(repository);
// });

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  TaskNotifier(this._repository) : super(const TaskState.initial()) {
    //chargement initial des tâches pour la liste principale
    getTasks();
  }

  Future<void> createTask(Task task) async {
    state = state.copyWith(isLoading: true); // Optionnel: indiquer chargement
    try {
      await _repository.createTask(task);
      await getTasks(); // Recharge toutes les tâches après création
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(
          isLoading: false, error: e.toString()); // Gérer l'erreur
    }
  }

  Future<void> updateTask(Task task) async {
    state = state.copyWith(isLoading: true); // Optionnel: indiquer chargement
    try {
      await _repository.updateTask(task);
      // Recharger la liste des tâches après la mise à jour (plus simple que de modifier localement)
      await getTasks();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la tâche : ${e.toString()}');
      state = state.copyWith(
          isLoading: false, error: e.toString()); // Gérer l'erreur
    }
  }

  Future<void> deleteTask(Task task) async {
    state = state.copyWith(isLoading: true); // Optionnel: indiquer chargement
    try {
      await _repository.deleteTask(task);
      await getTasks(); // Recharge toutes les tâches après suppression
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(
          isLoading: false, error: e.toString()); // Gérer l'erreur
    }
  }

  Future<void> getTasks() async {
    state = state.copyWith(isLoading: true, error: null); // Début chargement
    try {
      final tasks = await _repository.getAllTasks();
      state = state.copyWith(
          tasks: tasks, isLoading: false); // Fin chargement succès
      print('Tâches chargées: ${tasks.length}');
    } catch (e) {
      debugPrint(e.toString());
      state = state.copyWith(
          isLoading: false, error: e.toString()); // Fin chargement erreur
    }
  }

  // Le getter taskHeatmapData a été retiré car nous utilisons heatmapDataProvider
}

// Assurez-vous que TaskState a les champs nécessaires (tasks, isLoading, error)
// Exemple dans lib/providers/task/task_state.dart
// @immutable
// class TaskState {
//   final List<Task> tasks;
//   final bool isLoading;
//   final String? error;

//   const TaskState({required this.tasks, this.isLoading = false, this.error});

//   const TaskState.initial() : tasks = const [], isLoading = false, error = null;

//   TaskState copyWith({List<Task>? tasks, bool? isLoading, String? error}) {
//     return TaskState(
//       tasks: tasks ?? this.tasks,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//     );
//   }
// }
