// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/providers/task/task_provider.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';

class TaskTitle extends ConsumerWidget {
  const TaskTitle({super.key, required this.task, this.onCompleted});

  final Task task;
  final Function(bool?)? onCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = context.textTheme;
    final double iconOpacity = task.isCompleted ? 0.3 : 0.5;
    final double backgroundOpacity = task.isCompleted ? 0.1 : 0.3;
    final TextDecoration textDecoration =
        task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none;
    final FontWeight fontWeight =
        task.isCompleted ? FontWeight.normal : FontWeight.bold;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleContainer(
            color: task.category.color.withOpacity(backgroundOpacity),
            child: Center(
              child: Icon(
                task.category.icon,
                color: task.category.color.withOpacity(iconOpacity),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.time,
                  style: style.titleMedium?.copyWith(
                    decoration: textDecoration,
                    fontSize: 20,
                    fontWeight: fontWeight,
                  ),
                ),
                Text(
                  task.title,
                  style: style.titleMedium?.copyWith(
                    decoration: textDecoration,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              if (value != null) {
                final updatedTask = task.copyWith(isCompleted: value);
                ref
                    .read(taskProvider.notifier)
                    .updateTask(updatedTask)
                    .then((_) {
                  AppAlert.displaysnackbar(context,
                      value ? 'Task completed' : 'Task marked as incomplete');
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
