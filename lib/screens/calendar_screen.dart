import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trackers_app/config/routes/route_location.dart';
import 'package:trackers_app/data/data.dart';
import 'package:trackers_app/providers/providers.dart';
import 'package:trackers_app/utils/utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final selectedDate = ref.watch(dateProvider);
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    final kLastDay = DateTime(kToday.year + 1, kToday.month + 3, kToday.day);

    // Group tasks by day for markers
    List<Task> getTasksForDay(DateTime day) {
      return taskState.tasks.where((task) {
        return isSameDay(task.date, day);
      }).toList();
    }

    final dayTasks = getTasksForDay(selectedDate);

    return Column(
      children: [
        const SizedBox(height: 10),
        TableCalendar<Task>(
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: selectedDate,
          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
          calendarFormat: _calendarFormat,
          eventLoader: getTasksForDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            defaultTextStyle: const TextStyle(color: Colors.white),
            weekendTextStyle: const TextStyle(color: Colors.grey),
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.purpleAccent,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(selectedDate, selectedDay)) {
              // Update provider
              ref.read(dateProvider.notifier).state = selectedDay;
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("Tasks for ${Helpers.dateToString(selectedDate)}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: dayTasks.isEmpty
                      ? const Center(
                          child: Text("No tasks for this day",
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: dayTasks.length,
                          itemBuilder: (context, index) {
                            final task = dayTasks[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border(
                                      left: BorderSide(
                                          color: task.category.color,
                                          width: 4))),
                              child: ListTile(
                                title: Text(task.title,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                subtitle: Text(task.time,
                                    style: const TextStyle(color: Colors.grey)),
                                trailing: Icon(
                                    task.isCompleted
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Colors.grey),
                                onTap: () => context.push(
                                    RouteLocation.modifyTask,
                                    extra: task),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
