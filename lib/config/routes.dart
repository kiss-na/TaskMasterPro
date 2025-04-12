import 'package:flutter/material.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';
import 'package:task_manager/presentation/screens/task/task_screen.dart';
import 'package:task_manager/presentation/screens/task/add_edit_task_screen.dart';
import 'package:task_manager/presentation/screens/calendar/calendar_screen.dart';
import 'package:task_manager/presentation/screens/note/note_screen.dart';
import 'package:task_manager/presentation/screens/note/add_edit_note_screen.dart';
import 'package:task_manager/presentation/screens/note/archived_notes_screen.dart';
import 'package:task_manager/presentation/screens/reminder/reminder_screen.dart';
import 'package:task_manager/presentation/screens/reminder/birthday_reminder_screen.dart';
import 'package:task_manager/presentation/screens/reminder/habit_reminder_screen.dart';
import 'package:task_manager/presentation/screens/settings/settings_screen.dart';

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String addTask = '/tasks/add';
  static const String editTask = '/tasks/edit';
  static const String calendar = '/calendar';
  static const String notes = '/notes';
  static const String addNote = '/notes/add';
  static const String editNote = '/notes/edit';
  static const String archivedNotes = '/notes/archived';
  static const String reminders = '/reminders';
  static const String birthdayReminders = '/reminders/birthday';
  static const String habitReminders = '/reminders/habit';
  static const String settings = '/settings';

  // Route map
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    tasks: (context) => const TaskScreen(),
    addTask: (context) => const AddEditTaskScreen(isEditing: false),
    calendar: (context) => const CalendarScreen(),
    notes: (context) => const NoteScreen(),
    addNote: (context) => const AddEditNoteScreen(isEditing: false),
    archivedNotes: (context) => const ArchivedNotesScreen(),
    reminders: (context) => const ReminderScreen(),
    birthdayReminders: (context) => const BirthdayReminderScreen(),
    habitReminders: (context) => const HabitReminderScreen(),
    settings: (context) => const SettingsScreen(),
  };

  // For routes that need parameters
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case editTask:
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => AddEditTaskScreen(
            isEditing: true,
            taskId: args['taskId'],
          ),
        );
        
      case editNote:
        final Map<String, dynamic> args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => AddEditNoteScreen(
            isEditing: true,
            noteId: args['noteId'],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
}
