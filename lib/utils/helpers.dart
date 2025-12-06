// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trackers_app/providers/date_provider.dart';
import '../data/models/task.dart';

class Helpers {
  Helpers._();

  // Convertit TimeOfDay en String (ex: "6:00 AM")
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
      return '12:00 PM'; // Valeur par défaut en cas d'erreur
    }
  }

  static String dateToString(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  // Vérifie si une tâche correspond à la date sélectionnée
  static bool isTaskFromSelectedDate(Task task, DateTime selectedDate) {
    final DateTime taskDate =
        _stringToDateTime(DateFormat('MMM dd, yyyy').format(task.date));
    final DateTime normalizedSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    print('Date de la tâche: ${task.date}');
    print('Date convertie: $taskDate');
    print('Date sélectionnée normalisée: $normalizedSelectedDate');
    return taskDate.year == normalizedSelectedDate.year &&
        taskDate.month == normalizedSelectedDate.month &&
        taskDate.day == normalizedSelectedDate.day;
  }

  // Convertit une String en DateTime
  static DateTime _stringToDateTime(String dateString) {
    try {
      return DateFormat('MMM dd, yyyy')
          .parse(dateString); // Format correspondant à "Feb 24, 2025"
    } catch (e) {
      print('Erreur de parsing de la date: $e');
      return DateTime.now(); // Retourne la date actuelle en cas d'erreur
    }
  }

  // Permet à l'utilisateur de sélectionner une date
  static Future<void> selectDate(BuildContext context, WidgetRef ref) async {
    final initialDate = ref.read(dateProvider);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2090),
    );

    if (pickedDate != null) {
      ref.read(dateProvider.notifier).state = pickedDate;
    }
  }

  // Convertit une String en TimeOfDay
  static TimeOfDay stringToTimeOfDay(String time) {
    final format = DateFormat.jm(); // Format "6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(time));
  }
}
