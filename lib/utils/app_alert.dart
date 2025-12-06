// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/task/task_provider.dart';
import 'package:trackers_app/utils/utils.dart';

class AppAlert {
  AppAlert._();

  static void displaysnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.surface,
          ),
        ),
        backgroundColor: context.colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> showDeleteAlertDialog(
      BuildContext context, WidgetRef ref, Task task) async {
    Widget cancelButton = TextButton(
      onPressed: () => context.pop(),
      child: Text("NO"),
    );
    Widget deleteButton = TextButton(
      onPressed: () async {
        ref.read(taskProvider.notifier).deleteTask(task).then((value) {
          displaysnackbar(context, 'Task deleted successfully');
          //pour fermer le modal
          context.pop();
        });
      },
      child: Text("YES"),
    );
    AlertDialog alert = AlertDialog(
      title: const Text('Are you sure you want to delete this task?'),
      actions: [deleteButton, cancelButton],
    );

    await showDialog(
      context: context,
      builder: (ctx) {
        return alert;
      },
    );
  }
}
