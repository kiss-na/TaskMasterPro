import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 4)
enum ReminderFrequency {
  @HiveField(0)
  once,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
  
  @HiveField(4)
  yearly
}

@HiveType(typeId: 5)
enum ReminderType {
  @HiveField(0)
  birthday,
  
  @HiveField(1)
  water,
  
  @HiveField(2)
  pomodoro,
  
  @HiveField(3)
  socialization,
  
  @HiveField(4)
  custom
}

@HiveType(typeId: 6)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  ReminderType type;
  
  @HiveField(4)
  ReminderFrequency frequency;
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  List<TimeOfDay> times;
  
  @HiveField(7)
  bool isEnabled;
  
  @HiveField(8)
  List<int>? weekdays; // 1=Monday, 7=Sunday
  
  Reminder({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    DateTime? createdAt,
    required this.times,
    this.isEnabled = true,
    this.weekdays,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Create a copy of the reminder with modified fields
  Reminder copyWith({
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    List<TimeOfDay>? times,
    bool? isEnabled,
    List<int>? weekdays,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt,
      times: times ?? this.times,
      isEnabled: isEnabled ?? this.isEnabled,
      weekdays: weekdays ?? this.weekdays,
    );
  }
}

@HiveType(typeId: 7)
class BirthdayReminder extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  DateTime date;
  
  @HiveField(3)
  String? phoneNumber;
  
  @HiveField(4)
  String? email;
  
  @HiveField(5)
  String? notes;
  
  @HiveField(6)
  bool isEnabled;
  
  @HiveField(7)
  TimeOfDay reminderTime;
  
  BirthdayReminder({
    String? id,
    required this.name,
    required this.date,
    this.phoneNumber,
    this.email,
    this.notes,
    this.isEnabled = true,
    TimeOfDay? reminderTime,
  })  : id = id ?? const Uuid().v4(),
        reminderTime = reminderTime ?? const TimeOfDay(hour: 9, minute: 0);

  // Create a copy of the birthday reminder with modified fields
  BirthdayReminder copyWith({
    String? name,
    DateTime? date,
    String? phoneNumber,
    String? email,
    String? notes,
    bool? isEnabled,
    TimeOfDay? reminderTime,
  }) {
    return BirthdayReminder(
      id: id,
      name: name ?? this.name,
      date: date ?? this.date,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      isEnabled: isEnabled ?? this.isEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  // Calculate age based on birth date
  int calculateAge() {
    final now = DateTime.now();
    int age = now.year - date.year;
    
    if (now.month < date.month || 
        (now.month == date.month && now.day < date.day)) {
      age--;
    }
    
    return age;
  }

  // Check if birthday is today
  bool isBirthdayToday() {
    final now = DateTime.now();
    return date.month == now.month && date.day == now.day;
  }

  // Calculate days until next birthday
  int daysUntilNextBirthday() {
    final now = DateTime.now();
    DateTime nextBirthday = DateTime(
      now.year,
      date.month,
      date.day,
    );
    
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, date.month, date.day);
    }
    
    return nextBirthday.difference(now).inDays;
  }
}

@HiveType(typeId: 8)
class HabitReminder extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String description;
  
  @HiveField(3)
  ReminderType type;
  
  @HiveField(4)
  ReminderFrequency frequency;
  
  @HiveField(5)
  List<TimeOfDay> times;
  
  @HiveField(6)
  bool isEnabled;
  
  @HiveField(7)
  List<int>? weekdays; // 1=Monday, 7=Sunday
  
  @HiveField(8)
  int? interval; // For water reminder: minutes between reminders
  
  @HiveField(9)
  int? duration; // For pomodoro: duration in minutes
  
  @HiveField(10)
  int? breakDuration; // For pomodoro: break duration in minutes
  
  HabitReminder({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.times,
    this.isEnabled = true,
    this.weekdays,
    this.interval,
    this.duration,
    this.breakDuration,
  }) : id = id ?? const Uuid().v4();

  // Create a copy of the habit reminder with modified fields
  HabitReminder copyWith({
    String? title,
    String? description,
    ReminderType? type,
    ReminderFrequency? frequency,
    List<TimeOfDay>? times,
    bool? isEnabled,
    List<int>? weekdays,
    int? interval,
    int? duration,
    int? breakDuration,
  }) {
    return HabitReminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      isEnabled: isEnabled ?? this.isEnabled,
      weekdays: weekdays ?? this.weekdays,
      interval: interval ?? this.interval,
      duration: duration ?? this.duration,
      breakDuration: breakDuration ?? this.breakDuration,
    );
  }

  // Create a water reminder
  static HabitReminder createWaterReminder({
    required List<TimeOfDay> times,
    int interval = 60, // Default: remind every hour
  }) {
    return HabitReminder(
      title: 'Drink Water',
      description: 'Remember to stay hydrated!',
      type: ReminderType.water,
      frequency: ReminderFrequency.daily,
      times: times,
      interval: interval,
    );
  }

  // Create a pomodoro reminder
  static HabitReminder createPomodoroReminder({
    required List<TimeOfDay> times,
    List<int>? weekdays,
    int duration = 25, // Default: 25 minutes focus time
    int breakDuration = 5, // Default: 5 minutes break
  }) {
    return HabitReminder(
      title: 'Pomodoro Focus',
      description: 'Time to focus!',
      type: ReminderType.pomodoro,
      frequency: weekdays != null && weekdays.isNotEmpty 
          ? ReminderFrequency.weekly 
          : ReminderFrequency.daily,
      times: times,
      weekdays: weekdays,
      duration: duration,
      breakDuration: breakDuration,
    );
  }

  // Create a socialization reminder
  static HabitReminder createSocializationReminder({
    required List<TimeOfDay> times,
    List<int>? weekdays,
    int duration = 30, // Default: 30 minutes of social time
  }) {
    return HabitReminder(
      title: 'Socialize',
      description: 'Time to connect with others!',
      type: ReminderType.socialization,
      frequency: weekdays != null && weekdays.isNotEmpty 
          ? ReminderFrequency.weekly 
          : ReminderFrequency.daily,
      times: times,
      weekdays: weekdays,
      duration: duration,
    );
  }
}
