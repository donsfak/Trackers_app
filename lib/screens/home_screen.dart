// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/components/my_heatmap.dart';
import 'package:trackers_app/config/routes/route_location.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
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
    // Premium Dark Theme Colors
    final bgColor = Colors.black;
    final cardColor = Colors.grey[900];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(context), // Index 0
            const CalendarScreen(), // Index 1: Calendar
            _buildHeatmapView(context), // Index 2
            const Center(
                child: Text("Profile (Coming Soon)",
                    style: TextStyle(color: Colors.white))), // Index 3
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(FontAwesomeIcons.house, 0),
            _buildNavItem(FontAwesomeIcons.solidCalendar, 1),
            const SizedBox(width: 40), // Gap for FAB
            _buildNavItem(FontAwesomeIcons.chartSimple, 2), // Heatmap
            _buildNavItem(FontAwesomeIcons.user, 3),
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
    final cardColor = Colors.grey[900];
    final userProfile = 'https://i.pravatar.cc/150?img=12'; // Placeholder

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
              // Settings / Menu
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.gear,
                    color: Colors.grey, size: 20),
                onPressed: () => context.push(RouteLocation.aiChat),
              ),
              const Spacer(),
              // Search Bar (Functional Material 3)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SearchAnchor(
                    builder:
                        (BuildContext context, SearchController controller) {
                      return SearchBar(
                        controller: controller,
                        padding: const WidgetStatePropertyAll<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: 16.0)),
                        onTap: () {
                          controller.openView();
                        },
                        onChanged: (_) {
                          controller.openView();
                        },
                        leading: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FaIcon(FontAwesomeIcons.magnifyingGlass,
                              color: Colors.grey, size: 16),
                        ),
                        hintText: 'Search...',
                        hintStyle: const WidgetStatePropertyAll(
                            TextStyle(color: Colors.grey)),
                        backgroundColor: WidgetStatePropertyAll(cardColor),
                        elevation: const WidgetStatePropertyAll(0),
                        // Dark Theme for Search View
                        textStyle: const WidgetStatePropertyAll(
                            TextStyle(color: Colors.white)),
                      );
                    },
                    viewBackgroundColor:
                        Colors.grey[900], // Dark Background for View
                    viewHintText: 'Search your tasks...',
                    headerTextStyle: const TextStyle(color: Colors.white),
                    viewLeading: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.arrowLeft,
                          color: Colors.white, size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    suggestionsBuilder:
                        (BuildContext context, SearchController controller) {
                      final keyword = controller.text.toLowerCase();
                      final allTasks = taskState.tasks; // Search global tasks
                      final results = keyword.isEmpty
                          ? <Task>[]
                          : allTasks
                              .where((t) =>
                                  t.title.toLowerCase().contains(keyword))
                              .toList();

                      return List<ListTile>.generate(results.length,
                          (int index) {
                        final task = results[index];
                        return ListTile(
                          title: Text(task.title,
                              style: const TextStyle(color: Colors.white)),
                          subtitle: Text(Helpers.dateToString(task.date),
                              style: const TextStyle(color: Colors.grey)),
                          onTap: () {
                            setState(() {
                              controller.closeView(task.title);
                              // Navigate to modify or show task
                              context.push(RouteLocation.modifyTask,
                                  extra: task);
                            });
                          },
                        );
                      });
                    },
                  ),
                ),
              ),
              const Spacer(),
              // Profile
              CircleAvatar(
                backgroundImage: NetworkImage(userProfile),
                radius: 18,
              ),
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
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  DateFormat('MMM, d • EEEE').format(selectDate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
                const SizedBox(height: 30),

                // --- TIMELINE / UPCOMING FOCUS ---
                if (upcomingTasks.isNotEmpty) ...[
                  Row(
                    children: [
                      Text('Upcoming focus',
                          style: TextStyle(
                              color: Colors.white,
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
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
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
                            color: Colors.white,
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
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
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
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Activity Overview",
              style: TextStyle(
                  color: Colors.white,
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
                color: isSelected ? Colors.black : Colors.grey[400],
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(List<Task> tasks, BuildContext context) {
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
          Row(
            children: [
              Container(width: 4, height: 40, color: Colors.cyanAccent),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tasks.first.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${tasks.first.time} - Review',
                      style:
                          TextStyle(color: Colors.purple[100], fontSize: 12)),
                ],
              ),
              const Spacer(),
              const Text('NOW',
                  style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('||||', style: TextStyle(color: Colors.cyanAccent)),
              Text('1 PM',
                  style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('||', style: TextStyle(color: Colors.purpleAccent)),
              Text('3 PM',
                  style: TextStyle(color: Colors.white30, fontSize: 10)),
              Text('|||', style: TextStyle(color: Colors.pinkAccent)),
            ],
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
