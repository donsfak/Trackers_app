// lib/widgets/display_list_of_tasks.dart

// ignore_for_file: use_build_context_synchronously, must_be_immutable, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // Import pour HapticFeedback

import '../config/routes/route_location.dart';
import '../providers/task/task_provider.dart'; // Pour appeler deleteTask et updateTask
import '../utils/utils.dart';
import '../data/data.dart';
// import 'common_container.dart'; // N'est plus utilisé
// import 'task_title.dart'; // N'est plus utilisé
import 'task_details.dart';

class DisplayListOfTasks extends ConsumerWidget {
  const DisplayListOfTasks({
    super.key,
    required this.tasks,
    this.isCompletedTasks = false,
  });

  final List<Task> tasks;
  final bool isCompletedTasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final deviceSize = context.devicesize; // N'est plus nécessaire ici
    final colors = Theme.of(context).colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      padding: EdgeInsets.zero,
      itemBuilder: (ctx, index) {
        final task = tasks[index];

        return Dismissible(
          key: Key(task.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red.shade700,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (direction) async {
            HapticFeedback.mediumImpact();
            try {
              await ref.read(taskProvider.notifier).deleteTask(task);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${task.title}" supprimée.')),
              );
            } catch (e) {
              print("Erreur Dismissible deleteTask: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur suppression: $e')),
              );
            }
          },
          // --- CORRECTION DANS InkWell ---
          child: InkWell(
            // Action principale: Afficher les détails
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => TaskDetails(task: task),
              );
            },
            // Action secondaire: Aller à la modification
            onLongPress: () {
              context.push(RouteLocation.modifyTask, extra: task);
            },
            // Suppression des doublons:
            // L'autre onTap a été supprimé.
            // L'autre onLongPress (qui appelait AppAlert) a été supprimé.
            // onDoubleTap: null, // Reste null ou peut être assigné à une autre action

            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 5),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (value) async {
                  HapticFeedback.lightImpact();
                  final updatedTask =
                      task.copyWith(isCompleted: value ?? false);
                  try {
                    await ref
                        .read(taskProvider.notifier)
                        .updateTask(updatedTask);
                    AppAlert.displaysnackbar(
                        context,
                        updatedTask.isCompleted
                            ? 'Tâche terminée'
                            : 'Tâche marquée comme incomplète');
                  } catch (e) {
                    print("Erreur Checkbox updateTask: $e");
                    AppAlert.displaysnackbar(context, 'Erreur mise à jour: $e');
                  }
                },
                activeColor: colors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              title: Text(
                task.title,
                style: task.isCompleted
                    ? TextStyle(
                        color: colors.onSurface.withOpacity(0.5),
                        decoration: TextDecoration.lineThrough,
                      )
                    : null,
              ),
              subtitle: task.note.isNotEmpty
                  ? Text(task.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(color: colors.onSurface.withOpacity(0.6)))
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.edit_note_outlined),
                iconSize: 20,
                color: colors.onSurface.withOpacity(0.4),
                tooltip: 'Modifier',
                onPressed: () {
                  // Redondant avec onLongPress, mais peut rester si préféré
                  context.push(RouteLocation.modifyTask, extra: task);
                },
              ),
            ),
          ),
          // --- FIN CORRECTION InkWell ---
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
            height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade300);
      },
    );
  }
}
