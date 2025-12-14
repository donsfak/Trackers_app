import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Theme-aware colors
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background color based on theme (white or dark grey)
    final bgColor = isDark ? Colors.black : colorScheme.surface;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'New Task',
          style: GoogleFonts.poppins(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
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
            tooltip: 'Auto-fill with AI',
            onPressed: _isAnalyzing ? null : _analyzeTaskWithAI,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Main Task Card
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header: Checkbox + Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Visual Checkbox (Decorative)
                          Container(
                            margin: const EdgeInsets.only(top: 12, right: 16),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[600]!
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                          ),
                          // Title Input
                          Expanded(
                            child: TextField(
                              controller: _titleController,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                              decoration: InputDecoration(
                                hintText: 'What needs to be done?',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Divider(
                          color: isDark ? Colors.grey[800] : Colors.grey[100]),
                    ),

                    // Note Input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(60, 0, 20, 20),
                      child: TextField(
                        controller: _noteController,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          icon: Icon(Icons.notes,
                              color:
                                  isDark ? Colors.grey[600] : Colors.grey[400],
                              size: 20),
                        ),
                        maxLines: null,
                        minLines: 2,
                      ),
                    ),

                    // Action Bar (Bottom of Card)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[900]!.withValues(alpha: 0.5)
                            : Colors.grey[50]!,
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(24)),
                        border: Border(
                          top: BorderSide(
                            color:
                                isDark ? Colors.grey[800]! : Colors.grey[100]!,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Date Picker
                          _buildMiniActionButton(
                            context,
                            icon: Icons.calendar_today_rounded,
                            label: Helpers.dateToString(ref.watch(dateProvider),
                                showYear: false),
                            isActive: true, // Always show date
                            onTap: () => Helpers.selectDate(context, ref),
                          ),
                          const SizedBox(width: 8),

                          // Time Picker
                          _buildMiniActionButton(
                            context,
                            icon: Icons.access_time_rounded,
                            label:
                                Helpers.timeToString(ref.watch(timeProvider)),
                            isActive: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                  context: context,
                                  initialTime: ref.read(timeProvider));
                              if (picked != null) {
                                ref.read(timeProvider.notifier).state = picked;
                              }
                            },
                          ),
                          const SizedBox(width: 8),

                          // Category Picker (Tag)
                          Consumer(builder: (context, ref, _) {
                            final cat = ref.watch(categoryProvider);
                            return _buildMiniActionButton(
                              context,
                              icon: Icons.local_offer_rounded,
                              label: cat.name.capitalize(),
                              color: cat.color,
                              isActive: true,
                              onTap: () => _showCategoryPicker(context),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Create Button (Floating style below card)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _createTask,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text(_isSaving ? 'Creating...' : 'Create Task',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mini Action Button for the card footer
  Widget _buildMiniActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = color ??
        (isActive ? (isDark ? Colors.blueAccent : Colors.blue) : Colors.grey);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: contentColor),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Category',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: TaskCategories.values.length,
                  itemBuilder: (context, index) {
                    final cat = TaskCategories.values[index];
                    return InkWell(
                      onTap: () {
                        ref.read(categoryProvider.notifier).state = cat;
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cat.color),
                        ),
                        alignment: Alignment.center,
                        child: Text(cat.name.capitalize(),
                            style: TextStyle(
                                color: cat.color, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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
      final date = ref.read(dateProvider);
      final time = ref.read(timeProvider);
      final timeString = Helpers.timeToString(time);

      final task = Task(
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        date: date,
        time: timeString,
        category: ref.read(categoryProvider),
        isCompleted: false,
      );

      await ref.read(taskProvider.notifier).createTask(task);

      try {
        final DateTime scheduleTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        await AppNotifications.scheduleNotification(
          id: task.title.hashCode,
          title: "Reminder: ${task.title}",
          body: task.note.isNotEmpty ? task.note : "It's time for your task!",
          scheduledTime: scheduleTime,
        );
      } catch (e) {
        debugPrint("Notification scheduling failed: $e");
      }

      if (!mounted) return;
      AppAlert.displaysnackbar(context, 'Task created!');
      context.pop();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
