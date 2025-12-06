import 'package:flutter/material.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';
import 'package:trackers_app/widgets/circle_container.dart';

class TaskDetails extends StatelessWidget {
  const TaskDetails({super.key, required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme;
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          CircleContainer(
            // ignore: deprecated_member_use
            color: task.category.color.withOpacity(0.3),
            child: Icon(
              task.category.icon,
              // ignore: deprecated_member_use
              color: task.category.color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            task.title,
            style: style.titleMedium
                ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            task.time,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          Visibility(
            visible: !task.isCompleted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'task to be completed on ${task.date} ',
                ),
                Icon(
                  Icons.check_box,
                  color: task.category.color,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            thickness: 1.5,
            color: task.category.color,
          ),
          const SizedBox(height: 20),
          Text(task.note.isEmpty ? 'no note' : task.note),
          const SizedBox(height: 20),
          Visibility(
            visible: task.isCompleted,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'task completed ',
                ),
                Icon(
                  Icons.check_box,
                  color: Colors.green,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
