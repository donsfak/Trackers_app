import 'package:trackers_app/data/models/task.dart';

abstract class TaskRepository {
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(Task task);
  Future<List<Task>> getAllTasks();
  Future<Map<DateTime, int>> getTasksCountByDate();
}
