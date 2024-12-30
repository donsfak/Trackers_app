import 'package:flutter/material.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';

class TaskTitle extends StatelessWidget {
  const TaskTitle({super.key, required this.task, this.onCompleted});
  final Task task;
  final Function(bool?)? onCompleted;
  @override
  Widget build(BuildContext context) {
    final style = context.textTheme;
    final double iconOpacity = task.isCompleted ? 0.3 : 0.5;
    final backgroundOpacity = task.isCompleted ? 0.1 : 0.3;
    final TextDecoration textDecoration =
        task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none;
    final fontWeight = textDecoration == TextDecoration.lineThrough
        ? FontWeight.normal
        : FontWeight.bold;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleContainer(
            // ignore: deprecated_member_use
            color: task.category.color.withOpacity(backgroundOpacity),

            child: Center(
              child: Icon(
                task.category.icon,
                // ignore: deprecated_member_use
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
                      fontWeight: fontWeight),
                ),
                Text(
                  task.title,
                  style: style.titleMedium?.copyWith(
                    decoration: textDecoration,
                  ),
                )
              ],
            ),
          ),
          Checkbox(value: task.isCompleted, onChanged: onCompleted),
        ],
      ),
    );
  }
}
