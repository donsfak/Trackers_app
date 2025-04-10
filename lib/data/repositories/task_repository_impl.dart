// lib/data/repositories/task_repository_impl.dart
// ignore_for_file: deprecated_member_use

import 'package:logger/logger.dart'; // Importer logger
import 'package:trackers_app/data/repositories/repository_exception.dart';
import '../data.dart'; // Importe Task, TaskRepository, TaskDatasource
// Importer les exceptions personnalisées
import '../datasource/datasource_exception.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _datasource;
  final Logger _logger = Logger(
    // Initialiser le logger avec une configuration simple
    printer: PrettyPrinter(
        methodCount:
            1, // Affiche seulement 1 niveau de la stack trace dans le log
        errorMethodCount: 8, // Affiche plus de détails pour les erreurs
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true // Ajoute l'heure au log
        ),
  );

  TaskRepositoryImpl(this._datasource);

  @override
  Future<void> createTask(Task task) async {
    try {
      await _datasource.addTask(task);
      _logger.i("Task created successfully: ${task.title}"); // Log de succès
    } on DataSourceException catch (e, stackTrace) {
      _logger.e("Repository Error createTask: DataSource failed",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Impossible de créer la tâche.", e);
    } catch (e, stackTrace) {
      _logger.e("Unexpected Repository Error createTask",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Erreur inattendue lors de la création.", e);
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _datasource.updateTask(task);
      _logger.i("Task updated successfully: ID ${task.id}"); // Log de succès
    } on DataSourceException catch (e, stackTrace) {
      _logger.e("Repository Error updateTask: DataSource failed",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Impossible de mettre à jour la tâche.", e);
    } catch (e, stackTrace) {
      _logger.e("Unexpected Repository Error updateTask",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Erreur inattendue lors de la mise à jour.", e);
    }
  }

  @override
  Future<void> deleteTask(Task task) async {
    try {
      await _datasource.deleteTask(task);
      _logger.w(
          "Task deleted successfully: ID ${task.id}"); // Log de succès (warning pour attirer l'oeil)
    } on DataSourceException catch (e, stackTrace) {
      _logger.e("Repository Error deleteTask: DataSource failed",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Impossible de supprimer la tâche.", e);
    } catch (e, stackTrace) {
      _logger.e("Unexpected Repository Error deleteTask",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Erreur inattendue lors de la suppression.", e);
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final tasks = await _datasource.getAllTasks();
      _logger.i("Fetched ${tasks.length} tasks successfully."); // Log de succès
      return tasks;
    } on DataSourceException catch (e, stackTrace) {
      _logger.e("Repository Error getAllTasks: DataSource failed",
          error: e, stackTrace: stackTrace);
      throw RepositoryException("Impossible de récupérer les tâches.", e);
    } catch (e, stackTrace) {
      _logger.e("Unexpected Repository Error getAllTasks",
          error: e, stackTrace: stackTrace);
      throw RepositoryException(
          "Erreur inattendue lors de la récupération des tâches.", e);
    }
  }

  @override
  Future<Map<DateTime, int>> getTasksCountByDate() async {
    try {
      final data = await _datasource.getTasksCountByDate();
      _logger.i(
          "Fetched heatmap data successfully (${data.length} entries)."); // Log de succès
      return data;
    } on DataSourceException catch (e, stackTrace) {
      _logger.e("Repository Error getTasksCountByDate: DataSource failed",
          error: e, stackTrace: stackTrace);
      throw RepositoryException(
          "Impossible de récupérer les données pour la heatmap.", e);
    } catch (e, stackTrace) {
      _logger.e("Unexpected Repository Error getTasksCountByDate",
          error: e, stackTrace: stackTrace);
      throw RepositoryException(
          "Erreur inattendue lors de la récupération pour la heatmap.", e);
    }
  }
}
