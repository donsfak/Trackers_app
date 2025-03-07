// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  TaskNotifier(this._repository) : super(const TaskState.initial()) {
    //chargement de toutes les tâches
    getTasks();
  }

  Future<void> createTask(Task task) async {
    try {
      await _repository.createTask(task);
      getTasks();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      // Mise à jour de la tâche avec la nouvelle valeur d'achèvement
      await _repository.updateTask(task);

      // Recharger la liste des tâches après la mise à jour
      final updatedTasks = await _repository.getAllTasks();
      state = state.copyWith(tasks: updatedTasks);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la tâche : ${e.toString()}');
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      await _repository.deleteTask(task);
      getTasks();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getTasks() async {
    try {
      final tasks = await _repository.getAllTasks();
      state = state.copyWith(tasks: tasks);
      print('Tâches chargées: ${tasks.length}'); // Log pour déboguer
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
