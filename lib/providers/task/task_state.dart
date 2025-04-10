// lib/providers/task/task_state.dart (Version AMÉLIORÉE RECOMMANDÉE)

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // Importer pour @immutable

import 'package:trackers_app/data/data.dart';

@immutable // Bonne pratique pour les états
class TaskState extends Equatable {
  final List<Task> tasks;
  final bool isLoading; // <- AJOUTÉ
  final String? error; // <- AJOUTÉ (nullable pour indiquer l'absence d'erreur)

  const TaskState({
    required this.tasks,
    this.isLoading = false, // Valeur par défaut
    this.error,
  });

  // État initial
  const TaskState.initial()
      : tasks = const <Task>[],
        isLoading = false,
        error = null;

  // Méthode copyWith MISE À JOUR pour accepter les nouveaux champs
  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    bool clearError = false, // Option pour effacer l'erreur explicitement
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError
          ? null
          : error ?? this.error, // Gérer l'effacement de l'erreur
    );
  }

  @override
  // Inclure les nouveaux champs dans props pour Equatable
  List<Object?> get props => [tasks, isLoading, error];
}
