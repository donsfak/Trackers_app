// ignore_for_file: unused_local_variable, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/config/routes/routes.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/widgets/show_bottom_sheet.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final deviceSize = MediaQuery.of(context).size;
    final taskState = ref.watch(taskProvider);
    final selectDate = ref.watch(dateProvider);

    // Separate tasks into completed and incompleted
    final completedTasks = _completedTasks(taskState.tasks, selectDate);
    final incompletedTasks = _incompletedTasks(taskState.tasks, selectDate);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: deviceSize.height * 0.3,
                width: deviceSize.width,
                color: colors.primary,
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
                        mini: true, // Reduce button size
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
                            text: ' My Todo List ',
                            fontSize: 40,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 145,
            right: 0,
            left: 0,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // List of incompleted tasks
                    DisplayListOfTasks(
                      tasks: incompletedTasks,
                      onTaskToggle: (task) =>
                          _toggleTaskCompletion(ref, task, false),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    // List of completed tasks
                    DisplayListOfTasks(
                      tasks: completedTasks,
                      isCompletedTasks: true,
                      onTaskToggle: (task) =>
                          _toggleTaskCompletion(ref, task, true),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => context.push(RouteLocation.createTask),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Add Task',
                          style: TextStyle(fontSize: 20, color: Colors.purple),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to toggle the completion state of a task
  void _toggleTaskCompletion(
      WidgetRef ref, Task task, bool isCurrentlyCompleted) {
    final updatedTask = task.copyWith(isCompleted: !isCurrentlyCompleted);
    ref.read(taskProvider.notifier).updateTask(updatedTask).then((_) {
      AppAlert.displaysnackbar(
        ref.context,
        !isCurrentlyCompleted ? 'Task completed' : 'Task marked as incomplete',
      );
    });
  }

  // Filter completed tasks based on the selected date
  List<Task> _completedTasks(List<Task> tasks, DateTime selectedDate) {
    return tasks
        .where((task) =>
            task.isCompleted &&
            Helpers.isTaskFromSelectedDate(task, selectedDate))
        .toList();
  }

  // Filter incompleted tasks based on the selected date
  List<Task> _incompletedTasks(List<Task> tasks, DateTime selectedDate) {
    return tasks
        .where((task) =>
            !task.isCompleted &&
            Helpers.isTaskFromSelectedDate(task, selectedDate))
        .toList();
  }
}
