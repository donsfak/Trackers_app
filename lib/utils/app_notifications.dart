import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter/foundation.dart';

class AppNotifications {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialisation
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) {
          print('Notification clicked: ${details.payload}');
        }
      },
    );

    // Request permissions explicitly
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      if (scheduledDate.isBefore(now)) {
        if (kDebugMode) {
          print('Skipping notification for past time: $scheduledDate');
        }
        return;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            channelDescription: 'Reminders for your tasks',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      if (kDebugMode) {
        print('Scheduled notification $id for $scheduledDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
      }
    }
  }

  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
