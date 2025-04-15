import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/models/note.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ReminderAdapter());


  // Open Hive Boxes
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Note>('archived_notes');
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox('settings');

  runApp(const TaskManagerApp());
}