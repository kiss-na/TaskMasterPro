import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/models/note.dart';
import 'package:task_manager/data/models/reminder.dart';

// Task Priority Adapter
class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 0;

  @override
  TaskPriority read(BinaryReader reader) {
    final index = reader.readInt();
    return TaskPriority.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    writer.writeInt(obj.index);
  }
}

// TaskRepeatType Adapter
class TaskRepeatTypeAdapter extends TypeAdapter<TaskRepeatType> {
  @override
  final int typeId = 1;

  @override
  TaskRepeatType read(BinaryReader reader) {
    final index = reader.readInt();
    return TaskRepeatType.values[index];
  }

  @override
  void write(BinaryWriter writer, TaskRepeatType obj) {
    writer.writeInt(obj.index);
  }
}

// Task Adapter
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      isCompleted: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      dueDate: fields[5] as DateTime?,
      priority: fields[6] as TaskPriority,
      color: Color(fields[7] as int),
      contactName: fields[8] as String?,
      contactPhone: fields[9] as String?,
      locationName: fields[10] as String?,
      latitude: fields[11] as double?,
      longitude: fields[12] as double?,
      reminderDateTime: fields[13] as DateTime?,
      repeatType: fields[14] as TaskRepeatType?,
      repeatDays: (fields[15] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeByte(16);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.isCompleted);
    writer.writeByte(4);
    writer.write(obj.createdAt);
    writer.writeByte(5);
    writer.write(obj.dueDate);
    writer.writeByte(6);
    writer.write(obj.priority);
    writer.writeByte(7);
    writer.write(obj.color.value);
    writer.writeByte(8);
    writer.write(obj.contactName);
    writer.writeByte(9);
    writer.write(obj.contactPhone);
    writer.writeByte(10);
    writer.write(obj.locationName);
    writer.writeByte(11);
    writer.write(obj.latitude);
    writer.writeByte(12);
    writer.write(obj.longitude);
    writer.writeByte(13);
    writer.write(obj.reminderDateTime);
    writer.writeByte(14);
    writer.write(obj.repeatType);
    writer.writeByte(15);
    writer.write(obj.repeatDays);
  }
}

// Note Adapter
class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 3;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return Note(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      tags: (fields[5] as List).cast<String>(),
      color: Color(fields[6] as int),
      imagePaths: (fields[7] as List).cast<String>(),
      isArchived: fields[8] as bool,
      archivedAt: fields[9] as DateTime?,
      scheduledDeletionDate: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.content);
    writer.writeByte(3);
    writer.write(obj.createdAt);
    writer.writeByte(4);
    writer.write(obj.updatedAt);
    writer.writeByte(5);
    writer.write(obj.tags);
    writer.writeByte(6);
    writer.write(obj.color.value);
    writer.writeByte(7);
    writer.write(obj.imagePaths);
    writer.writeByte(8);
    writer.write(obj.isArchived);
    writer.writeByte(9);
    writer.write(obj.archivedAt);
    writer.writeByte(10);
    writer.write(obj.scheduledDeletionDate);
  }
}

// ReminderFrequency Adapter
class ReminderFrequencyAdapter extends TypeAdapter<ReminderFrequency> {
  @override
  final int typeId = 4;

  @override
  ReminderFrequency read(BinaryReader reader) {
    final index = reader.readInt();
    return ReminderFrequency.values[index];
  }

  @override
  void write(BinaryWriter writer, ReminderFrequency obj) {
    writer.writeInt(obj.index);
  }
}

// ReminderType Adapter
class ReminderTypeAdapter extends TypeAdapter<ReminderType> {
  @override
  final int typeId = 5;

  @override
  ReminderType read(BinaryReader reader) {
    final index = reader.readInt();
    return ReminderType.values[index];
  }

  @override
  void write(BinaryWriter writer, ReminderType obj) {
    writer.writeInt(obj.index);
  }
}

// TimeOfDay Adapter for Hive
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 9;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}

// Simplified adapters for Reminder, BirthdayReminder and HabitReminder
// These are basic implementations to get the app running
class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 6;

  @override
  Reminder read(BinaryReader reader) {
    return Reminder(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      type: ReminderType.values[reader.readInt()],
      frequency: ReminderFrequency.values[reader.readInt()],
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      times: [const TimeOfDay(hour: 9, minute: 0)],
      isEnabled: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.frequency.index);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isEnabled);
  }
}

class BirthdayReminderAdapter extends TypeAdapter<BirthdayReminder> {
  @override
  final int typeId = 7;

  @override
  BirthdayReminder read(BinaryReader reader) {
    return BirthdayReminder(
      id: reader.readString(),
      name: reader.readString(),
      date: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isEnabled: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, BirthdayReminder obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.isEnabled);
  }
}

class HabitReminderAdapter extends TypeAdapter<HabitReminder> {
  @override
  final int typeId = 8;

  @override
  HabitReminder read(BinaryReader reader) {
    return HabitReminder(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      type: ReminderType.values[reader.readInt()],
      frequency: ReminderFrequency.values[reader.readInt()],
      times: [const TimeOfDay(hour: 9, minute: 0)],
      isEnabled: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitReminder obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeInt(obj.type.index);
    writer.writeInt(obj.frequency.index);
    writer.writeBool(obj.isEnabled);
  }
}