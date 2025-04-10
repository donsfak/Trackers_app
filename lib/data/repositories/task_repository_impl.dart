// lib/data/repositories/task_repository_impl.dart
import '../data.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource
      _datasource; // Assurez-vous que TaskDatasource est injecté

  TaskRepositoryImpl(this._datasource); // Constructeur recevant la datasource

  @override
  Future<void> createTask(Task task) async {
    await _datasource.addTask(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _datasource.updateTask(task);
  }

  @override
  Future<void> deleteTask(Task task) async {
    await _datasource.deleteTask(task);
  }

  @override
  Future<List<Task>> getAllTasks() async {
    return await _datasource.getAllTasks();
  }

  @override
  Future<Map<DateTime, int>> getTasksCountByDate() async {
    return await _datasource.getTasksCountByDate();
  }
}
