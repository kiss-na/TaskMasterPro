import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  high,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  low
}

@HiveType(typeId: 1)
enum TaskRepeatType {
  @HiveField(0)
  none,
  
  @HiveField(1)
  daily,
  
  @HiveField(2)
  weekly,
  
  @HiveField(3)
  monthly,
  
  @HiveField(4)
  yearly
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime? dueDate;
  
  @HiveField(6)
  TaskPriority priority;
  
  @HiveField(7)
  Color color;
  
  @HiveField(8)
  String? contactName;
  
  @HiveField(9)
  String? contactPhone;
  
  @HiveField(10)
  String? locationName;
  
  @HiveField(11)
  double? latitude;
  
  @HiveField(12)
  double? longitude;
  
  @HiveField(13)
  DateTime? reminderDateTime;
  
  @HiveField(14)
  TaskRepeatType? repeatType;
  
  @HiveField(15)
  List<int>? repeatDays; // For weekly repeat, store days of week (1-7)
  
  Task({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    Color? color,
    this.contactName,
    this.contactPhone,
    this.locationName,
    this.latitude,
    this.longitude,
    this.reminderDateTime,
    this.repeatType,
    this.repeatDays,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        color = color ?? Colors.blue;

  // Create a copy of the task with modified fields
  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    TaskPriority? priority,
    Color? color,
    String? contactName,
    String? contactPhone,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? reminderDateTime,
    TaskRepeatType? repeatType,
    List<int>? repeatDays,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  // Get priority color
  Color getPriorityColor() {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // Check if task has location
  bool hasLocation() {
    return locationName != null || (latitude != null && longitude != null);
  }

  // Check if task has contact
  bool hasContact() {
    return contactName != null || contactPhone != null;
  }

  // Check if task has reminder
  bool hasReminder() {
    return reminderDateTime != null;
  }

  // Check if task is overdue
  bool isOverdue() {
    if (dueDate == null) return false;
    return !isCompleted && dueDate!.isBefore(DateTime.now());
  }

  // Check if task is due today
  bool isDueToday() {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }
}
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  high,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  low
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  DateTime? dueDate;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  TaskPriority priority;
  
  @HiveField(6)
  Color color;

  Task({
    String? id,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.low,
    this.color = Colors.blue,
  }) : id = id ?? const Uuid().v4();
}
