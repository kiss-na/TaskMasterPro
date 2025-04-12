import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/core/utils/notification_utils.dart';

class ReminderRepository {
  // Hive box name
  static const String boxName = 'reminders';

  // Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    final box = await Hive.openBox<Reminder>(boxName);
    return box.values.toList();
  }

  // Get reminder by ID
  Future<Reminder?> getReminderById(String id) async {
    final box = await Hive.openBox<Reminder>(boxName);
    
    for (final reminder in box.values) {
      if (reminder.id == id) {
        return reminder;
      }
    }
    
    return null;
  }

  // Add reminder
  Future<void> addReminder(Reminder reminder) async {
    final box = await Hive.openBox<Reminder>(boxName);
    await box.add(reminder);
    
    // Schedule notifications for habit reminders
    if (reminder is HabitReminder && reminder.isEnabled) {
      await NotificationUtils.scheduleHabitReminder(reminder);
    }
  }

  // Update reminder
  Future<void> updateReminder(Reminder reminder) async {
    final box = await Hive.openBox<Reminder>(boxName);
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == reminder.id) {
        await box.put(entry.key, reminder);
        
        // Update notifications for habit reminders
        if (reminder is HabitReminder) {
          if (reminder.isEnabled) {
            await NotificationUtils.scheduleHabitReminder(reminder);
          } else {
            await NotificationUtils.cancelNotification(reminder.id.hashCode);
          }
        }
        
        break;
      }
    }
  }

  // Delete reminder
  Future<void> deleteReminder(String id) async {
    final box = await Hive.openBox<Reminder>(boxName);
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == id) {
        await box.delete(entry.key);
        
        // Cancel notifications
        await NotificationUtils.cancelNotification(id.hashCode);
        
        break;
      }
    }
  }

  // Get reminders by type
  Future<List<Reminder>> getRemindersByType(ReminderType type) async {
    final reminders = await getAllReminders();
    return reminders.where((reminder) => reminder.type == type).toList();
  }

  // Toggle reminder enabled status
  Future<void> toggleReminderEnabled(String id) async {
    final reminder = await getReminderById(id);
    
    if (reminder != null) {
      final updatedReminder = reminder.copyWith(
        isEnabled: !reminder.isEnabled,
      );
      
      await updateReminder(updatedReminder);
    }
  }

  // Get all birthday reminders
  Future<List<BirthdayReminder>> getAllBirthdayReminders() async {
    final box = await Hive.openBox<BirthdayReminder>('birthday_reminders');
    return box.values.toList();
  }

  // Get birthday reminder by ID
  Future<BirthdayReminder?> getBirthdayReminderById(String id) async {
    final box = await Hive.openBox<BirthdayReminder>('birthday_reminders');
    
    for (final reminder in box.values) {
      if (reminder.id == id) {
        return reminder;
      }
    }
    
    return null;
  }

  // Add birthday reminder
  Future<void> addBirthdayReminder(BirthdayReminder reminder) async {
    final box = await Hive.openBox<BirthdayReminder>('birthday_reminders');
    await box.add(reminder);
    
    // Schedule notification
    if (reminder.isEnabled) {
      await NotificationUtils.scheduleBirthdayReminder(reminder);
    }
  }

  // Update birthday reminder
  Future<void> updateBirthdayReminder(BirthdayReminder reminder) async {
    final box = await Hive.openBox<BirthdayReminder>('birthday_reminders');
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == reminder.id) {
        await box.put(entry.key, reminder);
        
        // Update notification
        if (reminder.isEnabled) {
          await NotificationUtils.scheduleBirthdayReminder(reminder);
        } else {
          await NotificationUtils.cancelNotification(reminder.id.hashCode);
        }
        
        break;
      }
    }
  }

  // Delete birthday reminder
  Future<void> deleteBirthdayReminder(String id) async {
    final box = await Hive.openBox<BirthdayReminder>('birthday_reminders');
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == id) {
        await box.delete(entry.key);
        
        // Cancel notification
        await NotificationUtils.cancelNotification(id.hashCode);
        
        break;
      }
    }
  }

  // Get upcoming birthdays
  Future<List<BirthdayReminder>> getUpcomingBirthdays({int limit = 5}) async {
    final reminders = await getAllBirthdayReminders();
    final now = DateTime.now();
    
    // Prepare a list with days until next birthday
    final upcomingList = reminders.map((reminder) {
      final daysUntil = reminder.daysUntilNextBirthday();
      return {'reminder': reminder, 'daysUntil': daysUntil};
    }).toList();
    
    // Sort by days until birthday
    upcomingList.sort((a, b) => (a['daysUntil'] as int).compareTo(b['daysUntil'] as int));
    
    // Return limited number of reminders
    return upcomingList
        .take(limit)
        .map((item) => item['reminder'] as BirthdayReminder)
        .toList();
  }

  // Get birthdays for today
  Future<List<BirthdayReminder>> getTodayBirthdays() async {
    final reminders = await getAllBirthdayReminders();
    final now = DateTime.now();
    
    return reminders.where((reminder) {
      return reminder.date.month == now.month && reminder.date.day == now.day;
    }).toList();
  }

  // Get all habit reminders
  Future<List<HabitReminder>> getAllHabitReminders() async {
    final box = await Hive.openBox<HabitReminder>('habit_reminders');
    return box.values.toList();
  }

  // Get habit reminders by type
  Future<List<HabitReminder>> getHabitRemindersByType(ReminderType type) async {
    final reminders = await getAllHabitReminders();
    return reminders.where((reminder) => reminder.type == type).toList();
  }

  // Add habit reminder
  Future<void> addHabitReminder(HabitReminder reminder) async {
    final box = await Hive.openBox<HabitReminder>('habit_reminders');
    await box.add(reminder);
    
    // Schedule notification
    if (reminder.isEnabled) {
      await NotificationUtils.scheduleHabitReminder(reminder);
    }
  }

  // Create default habit reminders if none exist
  Future<void> createDefaultHabitRemindersIfNeeded() async {
    final waterReminders = await getHabitRemindersByType(ReminderType.water);
    final pomodoroReminders = await getHabitRemindersByType(ReminderType.pomodoro);
    final socializationReminders = await getHabitRemindersByType(ReminderType.socialization);
    
    // Create default water reminder if none exists
    if (waterReminders.isEmpty) {
      final waterReminder = HabitReminder.createWaterReminder(
        times: [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 13, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
          const TimeOfDay(hour: 17, minute: 0),
        ],
        interval: 120, // Every 2 hours
      );
      
      await addHabitReminder(waterReminder);
    }
    
    // Create default pomodoro reminder if none exists
    if (pomodoroReminders.isEmpty) {
      final pomodoroReminder = HabitReminder.createPomodoroReminder(
        times: [
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
        ],
        weekdays: [1, 2, 3, 4, 5], // Monday to Friday
        duration: 25,
        breakDuration: 5,
      );
      
      await addHabitReminder(pomodoroReminder);
    }
    
    // Create default socialization reminder if none exists
    if (socializationReminders.isEmpty) {
      final socializationReminder = HabitReminder.createSocializationReminder(
        times: [
          const TimeOfDay(hour: 18, minute: 0),
        ],
        weekdays: [2, 4, 6], // Tuesday, Thursday, Saturday
        duration: 30,
      );
      
      await addHabitReminder(socializationReminder);
    }
  }
}
