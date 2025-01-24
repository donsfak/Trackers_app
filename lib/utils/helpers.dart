import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/providers/date_provider.dart';

import '../data/models/task.dart';

class Helpers {
  Helpers._();

  static String timeToString(TimeOfDay time) {
    try {
      final DateTime now = DateTime.now();
      final date = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      return DateFormat.jm().format(date);
    } catch (e) {
      return '12:00 PM';
    }
  }
  //

  static bool isTaskFromSelectedDate(Task task, DateTime selectedDate) {
    final DateTime taskDate = _stringToDateTime(task.date);
    if (taskDate.year == selectedDate.year &&
        taskDate.month == selectedDate.month &&
        taskDate.day == selectedDate.day) {
      return true;
    }
    return false;
  }

  static DateTime _stringToDateTime(String dateString) {
    try {
      return DateFormat.yMMMd().parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  static selectDate(BuildContext context, WidgetRef ref) async {
    final initialDate = ref.read(dateProvider);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2090),
    );

    if (pickedDate != null) {
      //
      ref.read(dateProvider.notifier).state = pickedDate;
    }
  }

  static TimeOfDay stringToTime(String time) {
    final format = DateFormat.jm(); //"6:00 AM"

    return TimeOfDay.fromDateTime(format.parse(time));
  }

  static TimeOfDay stringToTimeOfDay(String time) {
    final format = DateFormat.jm();
    return TimeOfDay.fromDateTime(format.parse(time));
  }
}
