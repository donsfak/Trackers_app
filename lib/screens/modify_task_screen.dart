import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/config/routes/route_location.dart';
import 'package:trackers_app/data/models/task.dart';
import 'package:trackers_app/providers/category_provider.dart';
import 'package:trackers_app/providers/date_provider.dart';
import 'package:trackers_app/providers/task/task_provider.dart';
import 'package:trackers_app/providers/time_provider.dart';
import 'package:trackers_app/utils/utils.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _noteController.text = widget.task.note;
    Future.microtask(() {
      ref.read(dateProvider.notifier).state = widget.task.date;
      ref.read(timeProvider.notifier).state =
          Helpers.stringToTimeOfDay(widget.task.time);
      ref.read(categoryProvider.notifier).state = widget.task.category;
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
    // Force Premium Dark Aesthetics
    final bgColor = Colors.black;
    final cardColor = Colors.grey[900];

    // Watch Providers for State
    final selectedCategory = ref.watch(categoryProvider);
    final selectedDate = ref.watch(dateProvider);
    final selectedTime = ref.watch(timeProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Input
              TextField(
                controller: _titleController,
                style: GoogleFonts.poppins(
                  textStyle:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                ),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
              const SizedBox(height: 24),

              // 2. Category Chips
              Text('Category',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TaskCategories.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = TaskCategories.values[index];
                    final isSelected = selectedCategory == cat;
                    final color =
                        cat.color; // Using extension getter from TaskCategories

                    return ChoiceChip(
                      label: Text(
                        cat.name.capitalize(),
                        style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.grey),
                      ),
                      selected: isSelected,
                      selectedColor: color,
                      backgroundColor: Colors.grey[900],
                      shape: StadiumBorder(
                          side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : Colors.grey[800]!)),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(categoryProvider.notifier).state = cat;
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 3. Details Grid
              Text('Details',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.calendar_today,
                      title: DateFormat.yMMMd().format(selectedDate),
                      subtitle: 'Date',
                      onTap: () => Helpers.selectDate(context, ref),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      icon: Icons.access_time,
                      title: Helpers.timeToString(selectedTime),
                      subtitle: 'Time',
                      onTap: () async {
                        final picked = await showTimePicker(
                            context: context, initialTime: selectedTime);
                        if (picked != null) {
                          ref.read(timeProvider.notifier).state = picked;
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // 4. Note Input
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _noteController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add a note...',
                    icon: Icon(Icons.notes, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
              const SizedBox(height: 32),

              // 4.5 Focus Action
              GestureDetector(
                onTap: () =>
                    context.push(RouteLocation.focus, extra: widget.task),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.purpleAccent]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, color: Colors.white),
                      const SizedBox(width: 12),
                      Text("Start Focus Session",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 5. Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: _deleteTask,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _updateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Update Task',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey[400], size: 20),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle,
                style:
                    GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _updateTask() async {
    setState(() => _isSaving = true);
    try {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        date: ref.read(dateProvider),
        time: Helpers.timeToString(ref.read(timeProvider)),
        category: ref.read(categoryProvider),
      );
      await ref.read(taskProvider.notifier).updateTask(updatedTask);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task Updated')));
        context.pop();
      }
    } catch (e) {
      debugPrint("Error updating: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _deleteTask() {
    // Show confirmation dialog if needed, for now straight delete
    ref.read(taskProvider.notifier).deleteTask(widget.task);
    context.pop();
  }
}
