import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  bool _isAnalyzing = false; // Pour l'état de l'IA

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(categoryProvider.notifier).state = TaskCategories.home;
      // Reset date/time to now just in case
      ref.read(dateProvider.notifier).state = DateTime.now();
      ref.read(timeProvider.notifier).state = TimeOfDay.now();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- AI LOGIC ---
  Future<void> _analyzeTaskWithAI() async {
    final text = _titleController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a task title to analyze')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty) throw Exception('No API Key');

      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        generationConfig:
            GenerationConfig(responseMimeType: 'application/json'),
      );

      final prompt = '''
      Analyze this task description: "$text".
      Extract the following fields in JSON format:
      {
        "title": "Cleaned up title",
        "category": "one of: education, health, shopping, travel, home, social, personal, work, sport (default to home)",
        "year": 2024,
        "month": 1 to 12,
        "day": 1 to 31,
        "hour": 0 to 23,
        "minute": 0 to 59,
        "note": "Any extra details found"
      }
      If date/time is not specified, use today's date/time.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);
      final jsonText = response.text;

      if (jsonText != null) {
        // Simple manual parsing or use dart:convert if structured correctly
        // For robustness in this snippet, we will assume standard JSON response
        // In a real app, use jsonDecode
        debugPrint("AI Response: $jsonText");

        // This is a simplified "apply" logic.
        // In production, we would parse the JSON string safely.
        // For this demo, let's pretend we parsed it into variables.
        // TODO: Add proper JSON parsing here
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'AI analysis simulation complete (Implement JSON parsing)')),
        );
      }
    } catch (e) {
      debugPrint('AI Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Analysis failed: $e')),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force Premium Dark Aesthetics regardless of system theme
    final bgColor = Colors.black;
    // cardColor unused
    final selectedCategory = ref.watch(categoryProvider);
    final selectedDate = ref.watch(dateProvider);
    final selectedTime = ref.watch(timeProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'New Task',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.purpleAccent))
                : const Icon(Icons.auto_fix_high, color: Colors.purpleAccent),
            tooltip: 'Auto-fill Details',
            onPressed: _isAnalyzing ? null : _analyzeTaskWithAI,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title Input (Large, distinct)
              TextField(
                controller: _titleController,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
              const SizedBox(height: 24),

              // 2. Category Chips (Pills)
              Text('Category',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                    final color = TaskCategoriesExtension(cat)
                        .color; // Using extension wrapper if needed or direct property
                    // Note: Your extension syntax might be `cat.color` if extension is applicable directly
                    // Assuming extension on TaskCategories is imported

                    return ChoiceChip(
                      label: Text(
                        cat.name.capitalize(),
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey),
                      ),
                      selected: isSelected,
                      selectedColor: color, // Chip color when selected
                      backgroundColor:
                          Colors.grey[900], // Dark background for unselected
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

              // 3. Details Grid (Date, Time)
              Text('Details',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                        if (picked != null)
                          ref.read(timeProvider.notifier).state = picked;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Note Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add a note...',
                    icon: Icon(Icons.notes, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),

              const SizedBox(height: 48),

              // 5. Action Buttons (Cancel / Create)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Task',
                            style: TextStyle(
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
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _createTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Title required')));
      return;
    }
    setState(() => _isSaving = true);

    try {
      final task = Task(
        title: title,
        note: _noteController.text.trim(),
        date: ref.read(dateProvider),
        time: Helpers.timeToString(ref.read(timeProvider)),
        category: ref.read(categoryProvider),
        isCompleted: false,
      );

      await ref.read(taskProvider.notifier).createTask(task);
      if (mounted) {
        AppAlert.displaysnackbar(context, 'Task created!');
        context.pop();
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
