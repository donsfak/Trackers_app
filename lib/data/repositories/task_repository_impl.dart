// ignore_for_file: avoid_print

import 'package:trackers_app/data/data.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<void> createTask(Task task) async {
    try {
      await _datasource.addTask(task);
    } catch (e) {
      throw '$e';
    }
  }

  @override
  Future<void> deleteTask(Task task) async {
    try {
      await _datasource.deleteTask(task);
    } catch (e) {
      throw '$e';
    }
  }

  @override
  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final tasks = await _datasource.getAllTasks();
      print(
          'Tâches récupérées depuis la base de données: ${tasks.length}'); // Log pour déboguer
      return tasks;
    } catch (e) {
      throw '$e';
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _datasource.updateTask(task);
    } catch (e) {
      throw '$e';
    }
  }
}
