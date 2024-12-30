// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:trackers_app/data/data.dart';

class TaskState extends Equatable {
  final List<Task> tasks;

  const TaskState(this.tasks);
  const TaskState.initial({this.tasks = const <Task>[]});

  TaskState copyWith({
    List<Task>? tasks,
  }) {
    return TaskState(
      tasks ?? this.tasks,
    );
  }

  @override
  List<Object> get props => [tasks];
}
