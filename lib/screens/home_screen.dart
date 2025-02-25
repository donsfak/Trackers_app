// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/screens/create_task_screen.dart';
import 'package:trackers_app/widgets/show_bottom_sheet.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final colors = Theme.of(context).colorScheme;
          final deviceSize = MediaQuery.of(context).size;
          final taskState = ref.watch(taskProvider);
          final selectDate = ref.watch(dateProvider);

          final completedTasks = _completedTasks(taskState.tasks, selectDate);
          final incompletedTasks =
              _incompletedTasks(taskState.tasks, selectDate);

          return Column(
            children: [
              // Section supérieure colorée
              Container(
                height: deviceSize.height * 0.3,
                width: deviceSize.width,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 55,
                      left: 5,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () {
                          showCustomBottomSheet(context);
                          print("Floating button clicked");
                        },
                        mini: true,
                        child: Icon(
                          Icons.menu,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => Helpers.selectDate(context, ref),
                            child: DisplayWhiteText(
                              text: DateFormat.yMMMd().format(selectDate),
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const DisplayWhiteText(
                            text: 'My Todo List',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Section des tâches
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tâches incomplètes
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.assignment,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tâches à faire',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              DisplayListOfTasks(
                                tasks: incompletedTasks,
                                onTaskToggle: (task) =>
                                    _toggleTaskCompletion(ref, task, false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tâches complètes
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tâches terminées',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              DisplayListOfTasks(
                                tasks: completedTasks,
                                isCompletedTasks: true,
                                onTaskToggle: (task) =>
                                    _toggleTaskCompletion(ref, task, true),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Bouton "Ajouter une tâche" avec transition
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (
                                BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation,
                              ) =>
                                  CreateTaskScreen(),
                              transitionsBuilder: (
                                BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation,
                                Widget child,
                              ) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Ajouter une tâche',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleTaskCompletion(
      WidgetRef ref, Task task, bool isCurrentlyCompleted) {
    try {
      final updatedTask = task.copyWith(isCompleted: !isCurrentlyCompleted);
      ref.read(taskProvider.notifier).updateTask(updatedTask).then((_) {
        AppAlert.displaysnackbar(
          ref.context,
          !isCurrentlyCompleted
              ? 'Tâche terminée'
              : 'Tâche marquée comme incomplète',
        );
      });
    } catch (e) {
      AppAlert.displaysnackbar(
          ref.context, 'Échec de la mise à jour de la tâche');
    }
  }

  List<Task> _completedTasks(List<Task> tasks, DateTime selectedDate) {
    return tasks
        .where((task) =>
            task.isCompleted &&
            Helpers.isTaskFromSelectedDate(task, selectedDate))
        .toList();
  }

  List<Task> _incompletedTasks(List<Task> tasks, DateTime selectedDate) {
    return tasks
        .where((task) =>
            !task.isCompleted &&
            Helpers.isTaskFromSelectedDate(task, selectedDate))
        .toList();
  }
}
