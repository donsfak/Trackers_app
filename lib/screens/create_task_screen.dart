import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/config/routes/routes.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/widgets/widgets.dart';

import '../data/data.dart';
import '../providers/providers.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  static CreateTaskScreen builder(BuildContext context, GoRouterState state) =>
      const CreateTaskScreen();
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

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
          text: 'Add Task',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextField(
                title: 'TaskTitle',
                hintText: 'TaskTitle',
                controller: _titleController,
              ),
              SizedBox(height: 10),
              const SelectCategory(),
              SizedBox(height: 10),
              SelectDateTime(),
              SizedBox(height: 10),
              CommonTextField(
                title: 'Note',
                hintText: 'Task Note',
                maxLines: 6,
                controller: _noteController,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                  onPressed: _createTask,
                  child: const DisplayWhiteText(
                    text: 'Save ',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _createTask() async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final date = ref.watch(dateProvider);
    final time = ref.watch(timeProvider);
    final category = ref.watch(categoryProvider);

    if (title.isNotEmpty) {
      final task = Task(
        title: title,
        note: note,
        date: DateFormat.yMMMd().format(date),
        time: Helpers.timeToString(time),
        category: category,
        isCompleted: false,
      );

      await ref.read(taskProvider.notifier).createTask(task).then((value) {
        // ignore: use_build_context_synchronously
        AppAlert.displaysnackbar(context, 'Task created successfully');
        // ignore: use_build_context_synchronously
        context.go(RouteLocation.home);
      });
    } else {
      AppAlert.displaysnackbar(context, 'Task title cannot be empty');
    }
  }
}
