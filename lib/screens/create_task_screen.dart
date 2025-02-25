// ignore_for_file: use_build_context_synchronously

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
  bool _isSaving = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Réinitialiser la catégorie à la valeur par défaut
    Future.microtask(() {
      ref.read(categoryProvider.notifier).state =
          TaskCategories.home; // Valeur par défaut
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
    final colors = Theme.of(context).colorScheme;
    final category = ref.watch(categoryProvider);
    final categoryColor = getCategoryColor(category.name);

    return Scaffold(
      appBar: AppBar(
        title: const DisplayWhiteText(
          text: 'Add Task',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Carte pour le titre de la tâche
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
                            Icons.title,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Task',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHovered = true),
                        onExit: (_) => setState(() => _isHovered = false),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _isHovered ? Colors.grey[200] : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: CommonTextField(
                            title: 'Task',
                            hintText: 'Enter task title',
                            controller: _titleController,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Carte pour la catégorie
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: categoryColor,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Category',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const SelectCategory(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Carte pour la date et l'heure
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
                            Icons.calendar_today,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Date & Time',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const SelectDateTime(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Carte pour la note
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
                            Icons.notes,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Note',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CommonTextField(
                        title: 'Note',
                        hintText: 'Enter task note',
                        maxLines: 6,
                        controller: _noteController,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Bouton "Save"
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _createTask,
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving ? Colors.grey : colors.primary,
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
    );
  }

  void _createTask() async {
    setState(() => _isSaving = true); // Début de l'animation
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final date = ref.watch(dateProvider);
    final time = ref.watch(timeProvider);
    final category = ref.watch(categoryProvider);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSaving = false); // Fin de l'animation
      return;
    }

    final task = Task(
      title: title,
      note: note,
      date: DateFormat.yMMMd().format(date),
      time: Helpers.timeToString(time),
      category: category,
      isCompleted: false,
    );

    await ref.read(taskProvider.notifier).createTask(task).then((_) {
      AppAlert.displaysnackbar(context, 'Task created successfully');
      context.go(RouteLocation.home);
    });
    Navigator.of(context).pop(); // Ferme l'écran actuel
    setState(() => _isSaving = false); // Fin de l'animation
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.blue;
      case 'shopping':
        return Colors.yellow;
      case 'travel':
        return Colors.purple;
      case 'home':
        return Colors.grey;
      case 'sport':
        return Colors.redAccent;
      case 'work':
        return Colors.purple;
      default:
        return Colors.cyanAccent;
    }
  }
}
