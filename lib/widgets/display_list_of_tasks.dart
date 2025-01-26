// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/config/routes/route_location.dart';
import 'package:trackers_app/providers/task/task_provider.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data.dart';
import 'common_container.dart';
import 'task_title.dart';
import 'task_details.dart'; // Import the TaskDetails widget

class DisplayListOfTasks extends ConsumerWidget {
  const DisplayListOfTasks(
      {super.key,
      required this.tasks,
      this.isCompletedTasks = false,
      required void Function(dynamic task) onTaskToggle});
  final List<Task> tasks;
  final bool isCompletedTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceSize = context.devicesize;
    final height =
        isCompletedTasks ? deviceSize.height * 0.25 : deviceSize.height * 0.3;
    final emptyTasksMessage = isCompletedTasks
        ? 'there is no completed task yet '
        : 'there is no task todo!';

    return CommonContainer(
      height: height,
      child: tasks.isEmpty
          ? Center(
              child: Text(
                emptyTasksMessage,
                style: context.textTheme.headlineSmall,
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: tasks.length,
              padding: EdgeInsets.zero,
              itemBuilder: (ctx, index) {
                final task = tasks[index];
                return InkWell(
                    onLongPress: () {
                      //delete task
                      AppAlert.showDeleteAlertDialog(
                        context,
                        ref,
                        task,
                      );
                    },
                    onTap: () async {
                      //show task details
                      await showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return TaskDetails(task: task);
                        },
                      );
                    },
                    onDoubleTap: () async {
                      context.push(
                        RouteLocation.modifyTask,
                        extra: task, // Passer la tâche actuelle
                      );
                    },
                    child: TaskTitle(
                      task: task,
                      onCompleted: (value) async {
                        ref
                            .read(taskProvider.notifier)
                            .updateTask(task)
                            .then((value) {
                          AppAlert.displaysnackbar(
                              context,
                              task.isCompleted
                                  ? 'Task uncompleted'
                                  : 'Task completed');
                        });
                      },
                    ));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
            ),
    );
  }
}
