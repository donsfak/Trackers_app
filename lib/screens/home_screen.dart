// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/config/routes/routes.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/widgets/show_Bottom_Sheet.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';

class HomeScreen extends ConsumerWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final deviceSize = context.devicesize;
    final taskState = ref.watch(taskProvider);
    final completedTasks = _completedTasks(taskState.tasks, ref);
    final incompletedTasks = _incompletedTasks(taskState.tasks, ref);
    final selectDate = ref.watch(dateProvider);

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
                      left: 05,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,

                        onPressed: () {
                          // Action du bouton flottant
                          showCustomBottomSheet(context);
                          print("Bouton flottant cliqué");
                        },
                        mini: true, // Réduit la taille du bouton
                        child: Icon(
                          Icons.menu, // Icône du bouton
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
                    DisplayListOfTasks(
                      tasks: incompletedTasks,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Completed',
                      style: context.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    DisplayListOfTasks(
                      tasks: completedTasks,
                      isCompletedTasks: true,
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

  // Lister toutes les tâches complétées
  List<Task> _completedTasks(List<Task> tasks, WidgetRef ref) {
    final selectedDate = ref.watch(dateProvider);
    final List<Task> filteredTasks = [];
    for (var task in tasks) {
      final isTaskDay = Helpers.isTaskFromSelectedDate(task, selectedDate);

      if (task.isCompleted && isTaskDay) {
        filteredTasks.add(task);
      }
    }
    return filteredTasks;
  }

  // Lister toutes les tâches non terminées
  List<Task> _incompletedTasks(List<Task> tasks, WidgetRef ref) {
    final selectedDate = ref.watch(dateProvider);
    final List<Task> filteredTasks = [];
    for (var task in tasks) {
      final isTaskDay = Helpers.isTaskFromSelectedDate(task, selectedDate);

      if (!task.isCompleted && isTaskDay) {
        filteredTasks.add(task);
      }
    }
    return filteredTasks;
  }
}
