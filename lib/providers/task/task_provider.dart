import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository);
});
