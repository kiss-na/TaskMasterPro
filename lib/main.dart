import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/app.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/models/note.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/data/models/hive_adapters.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/data/repositories/note_repository.dart';
import 'package:task_manager/data/repositories/reminder_repository.dart';
import 'package:task_manager/data/repositories/calendar_repository.dart';
import 'package:task_manager/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/presentation/blocs/note/note_bloc.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskRepeatTypeAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(ReminderFrequencyAdapter());
  Hive.registerAdapter(ReminderTypeAdapter());
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(BirthdayReminderAdapter());
  Hive.registerAdapter(HabitReminderAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  
  // Open Hive boxes
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Note>('archived_notes');
  await Hive.openBox<Reminder>('reminders');
  await Hive.openBox('settings');
  
  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
    },
  );
  
  // Create repositories
  final taskRepository = TaskRepository();
  final noteRepository = NoteRepository();
  final reminderRepository = ReminderRepository();
  final calendarRepository = CalendarRepository();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(taskRepository: taskRepository),
        ),
        BlocProvider<NoteBloc>(
          create: (context) => NoteBloc(noteRepository: noteRepository),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc(
            calendarRepository: calendarRepository,
            taskRepository: taskRepository,
          ),
        ),
        BlocProvider<ReminderBloc>(
          create: (context) => ReminderBloc(
            reminderRepository: reminderRepository,
          ),
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}
