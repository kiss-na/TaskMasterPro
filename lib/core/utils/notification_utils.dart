import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationUtils {
  // Private constructor to prevent instantiation
  NotificationUtils._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  static Future<void> init() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap based on payload
        final String? payload = response.payload;
        if (payload != null) {
          // Handle navigation based on payload
          // This would typically be handled in the app's main class
        }
      },
    );
  }

  // Request permission
  static Future<bool> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.requestPermission() ?? false;
    }
    
    return false;
  }

  // Schedule task notification
  static Future<void> scheduleTaskNotification(Task task) async {
    if (task.reminderDateTime == null) return;

    // Cancel existing notification if there is one
    await cancelNotification(task.id.hashCode);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: task.color,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Task Reminder: ${task.title}',
      task.description ?? 'You have a task to complete',
      tz.TZDateTime.from(task.reminderDateTime!, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task_${task.id}',
      matchDateTimeComponents: _getDateTimeComponents(task.repeatType),
    );
  }

  // Schedule birthday reminder notification
  static Future<void> scheduleBirthdayReminder(BirthdayReminder reminder) async {
    final DateTime now = DateTime.now();
    DateTime nextBirthday = DateTime(
      now.year,
      reminder.date.month,
      reminder.date.day,
    );
    
    // If the birthday has already occurred this year, schedule for next year
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(
        now.year + 1,
        reminder.date.month,
        reminder.date.day,
      );
    }
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'birthday_channel',
      'Birthday Reminders',
      channelDescription: 'Notifications for birthday reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      'Birthday Reminder',
      '${reminder.name}\'s birthday today!',
      tz.TZDateTime.from(nextBirthday, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'birthday_${reminder.id}',
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  // Schedule habit reminder notification
  static Future<void> scheduleHabitReminder(HabitReminder reminder) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'habit_channel',
      'Habit Reminders',
      channelDescription: 'Notifications for habit reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    if (reminder.frequency == ReminderFrequency.daily) {
      for (final time in reminder.times) {
        final now = DateTime.now();
        final scheduled = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        
        final tz.TZDateTime scheduledDate = _nextInstanceOfTime(scheduled);
        
        await _notificationsPlugin.zonedSchedule(
          '${reminder.id}_${time.hour}_${time.minute}'.hashCode,
          reminder.title,
          reminder.description,
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'habit_${reminder.id}',
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } else if (reminder.frequency == ReminderFrequency.weekly && 
               reminder.weekdays != null && 
               reminder.weekdays!.isNotEmpty) {
      for (final weekday in reminder.weekdays!) {
        for (final time in reminder.times) {
          final tz.TZDateTime scheduledDate = _nextInstanceOfDayAndTime(weekday, time);
          
          await _notificationsPlugin.zonedSchedule(
            '${reminder.id}_${weekday}_${time.hour}_${time.minute}'.hashCode,
            reminder.title,
            reminder.description,
            scheduledDate,
            notificationDetails,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'habit_${reminder.id}',
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
    }
  }

  // Cancel a notification by ID
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Get the DateTimeComponents based on the repeat type
  static DateTimeComponents? _getDateTimeComponents(TaskRepeatType? repeatType) {
    switch (repeatType) {
      case TaskRepeatType.daily:
        return DateTimeComponents.time;
      case TaskRepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case TaskRepeatType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case TaskRepeatType.yearly:
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  // Get the next instance of a specific time
  static tz.TZDateTime _nextInstanceOfTime(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Get the next instance of a specific day and time
  static tz.TZDateTime _nextInstanceOfDayAndTime(int weekday, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }
}
