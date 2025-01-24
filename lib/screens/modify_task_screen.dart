// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/config/routes/route_location.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/providers/category_provider.dart';
import 'package:trackers_app/providers/date_provider.dart';
import 'package:trackers_app/providers/task/task_provider.dart';
import 'package:trackers_app/providers/time_provider.dart';
import 'package:trackers_app/utils/app_alert.dart';
import 'package:trackers_app/utils/helpers.dart';
import 'package:trackers_app/widgets/common_text_field.dart';
import 'package:trackers_app/widgets/display_white_text.dart';
import 'package:trackers_app/widgets/select_category.dart';
import 'package:trackers_app/widgets/select_date_time.dart'; // Ensure this import is correct

class ModifyTaskScreen extends ConsumerStatefulWidget {
  final Task task;

  const ModifyTaskScreen({super.key, required this.task});

  static ModifyTaskScreen builder(BuildContext context, GoRouterState state) {
    final task = state.extra as Task?;
    if (task == null) {
      throw Exception('No task provided to ModifyTaskScreen');
    }
    return ModifyTaskScreen(task: task);
  }

  @override
  ConsumerState<ModifyTaskScreen> createState() => _ModifyTaskScreenState();
}

class _ModifyTaskScreenState extends ConsumerState<ModifyTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize fields with the values of the received task
    _titleController.text = widget.task.title;
    _noteController.text = widget.task.note;

    // Delay the state updates to avoid modifying providers during widget lifecycle
    Future.microtask(() {
      ref.read(dateProvider.notifier).state =
          DateFormat.yMMMd().parse(widget.task.date);
      ref.read(timeProvider.notifier).state =
          Helpers.stringToTimeOfDay(widget.task.time);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const DisplayWhiteText(
          text: 'Modify Task',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextField(
                title: 'Task Title',
                hintText: 'Task Title',
                controller: _titleController,
              ),
              const SizedBox(height: 10),
              const SelectCategory(),
              const SizedBox(height: 10),
              SelectDateTime(),
              const SizedBox(height: 10),
              CommonTextField(
                title: 'Note',
                hintText: 'Task Note',
                maxLines: 6,
                controller: _noteController,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _updateTask,
                child: const Text(
                  'Update',
                  style: TextStyle(fontSize: 20, color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTask() async {
    final updatedTask = widget.task.copyWith(
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      date: DateFormat.yMMMd().format(ref.read(dateProvider)),
      time: Helpers.timeToString(ref.read(timeProvider)),
      isCompleted: widget.task.isCompleted,
      category: ref.read(categoryProvider),
    );

    await ref.read(taskProvider.notifier).updateTask(updatedTask).then((_) {
      AppAlert.displaysnackbar(context, 'Task updated successfully');
      context.go(RouteLocation.home);
    });
  }
}
