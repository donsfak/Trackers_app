// lib/providers/task/task_notifier.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart'; // Pour @immutable si TaskState ici
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/task/task_state.dart';
// Importer les exceptions spécifiques
import 'package:trackers_app/data/repositories/repository_exception.dart';

// final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) { /* ... */ });

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;

  // Assurez-vous d'utiliser la version de TaskState avec isLoading et error
  TaskNotifier(this._repository) : super(const TaskState.initial()) {
    getTasks();
  }

  Future<void> createTask(Task task) async {
    // Début action, indiquer chargement, effacer erreur précédente
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.createTask(task);
      await getTasks(); // Recharge la liste (met à jour loading/success)
    } on RepositoryException catch (e) {
      // Erreur spécifique du Repository attrapée
      debugPrint("TaskNotifier createTask Repo Error: $e");
      state = state.copyWith(
          isLoading: false,
          error:
              e.message); // Met à jour l'état avec le message d'erreur du Repo
    } catch (e) {
      // Attraper toute autre erreur inattendue
      debugPrint("TaskNotifier createTask Unexpected Error: $e");
      state = state.copyWith(
          isLoading: false,
          error: "Impossible de créer la tâche."); // Message générique
    }
  }

  Future<void> updateTask(Task task) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateTask(task);
      await getTasks(); // Recharge
    } on RepositoryException catch (e) {
      debugPrint("TaskNotifier updateTask Repo Error: $e");
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      debugPrint("TaskNotifier updateTask Unexpected Error: $e");
      state = state.copyWith(
          isLoading: false, error: "Impossible de mettre à jour la tâche.");
    }
  }

  Future<void> deleteTask(Task task) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteTask(task);
      await getTasks(); // Recharge
    } on RepositoryException catch (e) {
      debugPrint("TaskNotifier deleteTask Repo Error: $e");
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      debugPrint("TaskNotifier deleteTask Unexpected Error: $e");
      state = state.copyWith(
          isLoading: false, error: "Impossible de supprimer la tâche.");
    }
  }

  Future<void> getTasks() async {
    // Début chargement, efface erreur précédente
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _repository.getAllTasks();
      state = state.copyWith(tasks: tasks, isLoading: false); // Succès
      print('Tâches chargées: ${tasks.length}');
    } on RepositoryException catch (e) {
      debugPrint("TaskNotifier getTasks Repo Error: $e");
      state = state.copyWith(
          isLoading: false, error: e.message); // Erreur spécifique
    } catch (e) {
      debugPrint("TaskNotifier getTasks Unexpected Error: $e");
      state = state.copyWith(
          isLoading: false,
          error: "Erreur chargement tâches."); // Erreur générique
    }
  }
}
