// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/components/my_heatmap.dart';
import 'package:trackers_app/config/routes/route_location.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/screens/search_screen.dart';
import 'package:trackers_app/screens/screens.dart';
import 'package:trackers_app/utils/utils.dart';
import 'package:trackers_app/providers/heatmap_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add import

class HomeScreen extends ConsumerStatefulWidget {
  static HomeScreen builder(BuildContext context, GoRouterState state) =>
      const HomeScreen();
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  TaskCategories? _selectedCategoryFilter; // Null = All
  int _selectedIndex =
      0; // 0: Home, 1: Calendar (todo), 2: Heatmap/Stats, 3: Profile

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;
    final cardColor = colorScheme.surfaceContainer;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(context), // Index 0
            const CalendarScreen(), // Index 1: Calendar
            _buildHeatmapView(context), // Index 2
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteLocation.createTask),
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ... bottomNavigationBar remains same ...
      bottomNavigationBar: BottomAppBar(
        color: cardColor,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(FontAwesomeIcons.house, 0),
            _buildNavItem(FontAwesomeIcons.solidCalendar, 1),
            const SizedBox(width: 56), // Gap for FAB
            _buildNavItem(FontAwesomeIcons.chartSimple, 2),
            const SizedBox(width: 48), // Balance right side
          ],
        ),
      ),
    );
  }

  // ... _buildNavItem remains same ...
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon:
          FaIcon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 20),
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    // final cardColor = colorScheme.surfaceContainer; // Unused

    final taskState = ref.watch(taskProvider);
    final selectDate = ref.watch(dateProvider);

    // Filter tasks
    final dayTasks = taskState.tasks
        .where((task) => Helpers.isTaskFromSelectedDate(task, selectDate))
        .toList();

    // Apply Category Filter
    final filteredTasks = _selectedCategoryFilter == null
        ? dayTasks
        : dayTasks.where((t) => t.category == _selectedCategoryFilter).toList();

    final incompleteTasks = filteredTasks.where((t) => !t.isCompleted).toList();

    // Timeline Data: 3 upcoming tasks
    final upcomingTasks = incompleteTasks.take(3).toList();

    return Column(
      children: [
        // --- HEADER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            children: [
              // AI Wizard Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.wandMagicSparkles,
                      color: Colors.purpleAccent, size: 18),
                  onPressed: () => context.push(RouteLocation.aiChat),
                  tooltip: 'AI Assistant',
                ),
              ),
              const Spacer(),
              // Search Bar (Functional Material 3)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Hero(
                    tag: 'searchBar',
                    child: Material(
                      color: Colors.transparent,
                      child: SearchBar(
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          );
                        },
                        onChanged: (_) {
                          // Optional: Pass query to search screen
                        },
                        leading: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                              size: 16),
                        ),
                        hintText: 'Search...',
                        hintStyle: WidgetStatePropertyAll(TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                        backgroundColor: WidgetStatePropertyAll(
                            colorScheme.surfaceContainer),
                        elevation: const WidgetStatePropertyAll(0),
                        textStyle: WidgetStatePropertyAll(TextStyle(
                            color: Theme.of(context).colorScheme.onSurface)),
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Theme Toggle Button
              _buildThemeToggle(),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- DATE HEADER ---
                const SizedBox(height: 20),
                Text(
                  'Today',
                  style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  DateFormat('MMM, d • EEEE').format(selectDate),
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 16),
                ),
                const SizedBox(height: 30),

                // --- TIMELINE / UPCOMING FOCUS ---
                if (upcomingTasks.isNotEmpty) ...[
                  Row(
                    children: [
                      Text('Upcoming focus',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12)),
                        child: Text('${upcomingTasks.length} tasks',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.8),
                                fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTimelineCard(upcomingTasks, context),
                ],

                const SizedBox(height: 30),

                // --- TASK LIST HEADER & FILTERS ---
                Row(
                  children: [
                    Text('To-dos',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('${incompleteTasks.length} tasks',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                              fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 15),

                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      ...TaskCategories.values.map((cat) =>
                          _buildFilterChip(cat.name.capitalize(), cat)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- TASK ITEMS ---
                if (incompleteTasks.isEmpty)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text("No tasks for this selection",
                              style: TextStyle(color: Colors.grey))))
                else
                  ...incompleteTasks
                      .map((task) => _buildTaskItem(task, context)),

                const SizedBox(height: 80), // Fab space
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmapView(BuildContext context) {
    final heatmapDataAsync = ref.watch(heatmapDataProvider);
    // Use fixed start date like in HeatmapScreen or dynamic
    final DateTime startDate = DateTime(DateTime.now().year, 1, 1);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Text("Activity Overview",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: heatmapDataAsync.when(
            data: (datasets) {
              if (datasets.isEmpty) {
                return const Center(
                    child: Text('No completed tasks yet.',
                        style: TextStyle(color: Colors.grey)));
              }
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  child: MyHeatmap(
                    startDate: startDate,
                    datasets: datasets,
                    onClick: (date, count) {
                      // Optional: Show list of tasks for that day
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
                child: Text("Error: $err",
                    style: const TextStyle(color: Colors.red))),
          ),
        ),
      ],
    );
  }

  // ... (Keep existing helpers like _buildFilterChip, _buildTimelineCard, but Update _buildTaskItem)

  Widget _buildFilterChip(String label, TaskCategories? category) {
    final isSelected = _selectedCategoryFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategoryFilter = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final themeMode = ref.watch(themeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark || themeMode == ThemeMode.system;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.withValues(alpha: 0.15)
            : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: FaIcon(
          isDark ? FontAwesomeIcons.solidSun : FontAwesomeIcons.solidMoon,
          color: isDark ? Colors.amber : Colors.blueGrey,
          size: 18,
        ),
        onPressed: () {
          ref.read(themeNotifierProvider.notifier).setThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
        },
        tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }

  Widget _buildTimelineCard(List<Task> tasks, BuildContext context) {
    // Build dynamic time slots from actual tasks
    final timeSlots = tasks.take(3).map((task) {
      return {
        'time': task.time,
        'title': task.title,
        'category': task.category
      };
    }).toList();

    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.indigoAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main upcoming task
          Row(
            children: [
              Container(
                  width: 4, height: 40, color: tasks.first.category.color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tasks.first.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                        tasks.first.time.isNotEmpty
                            ? tasks.first.time
                            : 'No time set',
                        style:
                            TextStyle(color: Colors.purple[100], fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('NEXT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          // Dynamic time slots row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: timeSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              final colors = [
                Colors.cyanAccent,
                Colors.purpleAccent,
                Colors.pinkAccent
              ];
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (slot['time'] as String).isNotEmpty
                        ? slot['time'] as String
                        : '--:--',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task, BuildContext context) {
    final catColor = task.category.color;
    return GestureDetector(
      // FIXED: Use RouteLocation.modifyTask instead of createTask
      onTap: () => context.push(RouteLocation.modifyTask, extra: task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: catColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                ref
                    .read(taskProvider.notifier)
                    .updateTask(task.copyWith(isCompleted: !task.isCompleted));
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: task.isCompleted ? Colors.white : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: task.isCompleted
                    ? FaIcon(FontAwesomeIcons.check, size: 14, color: catColor)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  if (task.note.isNotEmpty)
                    Text(task.note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12)),
                ],
              ),
            ),
            if (task.time.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.clock,
                        size: 15, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(task.time,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
