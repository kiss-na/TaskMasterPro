import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/presentation/blocs/task/task_event.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_event.dart';
import 'package:task_manager/presentation/blocs/note/note_bloc.dart';
import 'package:task_manager/presentation/blocs/note/note_event.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_event.dart';
import 'package:task_manager/presentation/screens/task/task_screen.dart';
import 'package:task_manager/presentation/screens/calendar/calendar_screen.dart';
import 'package:task_manager/presentation/screens/note/note_screen.dart';
import 'package:task_manager/presentation/screens/reminder/reminder_screen.dart';
import 'package:task_manager/presentation/screens/settings/settings_screen.dart';
import 'package:task_manager/config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // List of screens to navigate between
  final List<Widget> _screens = const [
    TaskScreen(),
    CalendarScreen(),
    NoteScreen(),
    ReminderScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadData() {
    // Load tasks
    context.read<TaskBloc>().add(const LoadTasksEvent());
    
    // Load calendar data
    context.read<CalendarBloc>().add(const LoadCalendarEvent());
    
    // Load notes
    context.read<NoteBloc>().add(const LoadNotesEvent());
    
    // Load reminders and create defaults if needed
    context.read<ReminderBloc>().add(const LoadRemindersEvent());
    context.read<ReminderBloc>().add(const CreateDefaultHabitRemindersEvent());

    // Clean up expired notes
    context.read<NoteBloc>().add(const CleanupExpiredNotesEvent());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildFloatingActionButton() {
    switch (_selectedIndex) {
      case 0: // Tasks
        return FloatingActionButton(
          heroTag: 'addTask',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addTask),
          child: const Icon(Icons.add),
          tooltip: 'Add Task',
        );
      case 1: // Calendar
        return FloatingActionButton(
          heroTag: 'syncCalendar',
          onPressed: () {
            context.read<CalendarBloc>().add(const SyncWithGoogleCalendarEvent());
          },
          child: const Icon(Icons.sync),
          tooltip: 'Sync Calendar',
        );
      case 2: // Notes
        return FloatingActionButton(
          heroTag: 'addNote',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addNote),
          child: const Icon(Icons.add),
          tooltip: 'Add Note',
        );
      case 3: // Reminders
        return FloatingActionButton(
          heroTag: 'addReminder',
          onPressed: () {
            // Show a menu to select which type of reminder to add
            _showReminderTypeMenu(context);
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Reminder',
        );
      default:
        return Container();
    }
  }

  void _showReminderTypeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.cake),
                title: const Text('Birthday Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.birthdayReminders);
                },
              ),
              ListTile(
                leading: const Icon(Icons.water_drop),
                title: const Text('Water Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.habitReminders);
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Pomodoro Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.habitReminders);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Socialization Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.habitReminders);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Task Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Organize your life efficiently',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.archive),
            title: const Text('Archived Notes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.archivedNotes);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Task Filters',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.priority_high, color: Colors.red),
            title: const Text('High Priority'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
                _pageController.jumpToPage(0);
              });
              context.read<TaskBloc>().add(
                    const LoadTasksByPriorityEvent(TaskPriority.high),
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.priority_high, color: Colors.orange),
            title: const Text('Medium Priority'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
                _pageController.jumpToPage(0);
              });
              context.read<TaskBloc>().add(
                    const LoadTasksByPriorityEvent(TaskPriority.medium),
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.low_priority, color: Colors.green),
            title: const Text('Low Priority'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
                _pageController.jumpToPage(0);
              });
              context.read<TaskBloc>().add(
                    const LoadTasksByPriorityEvent(TaskPriority.low),
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Today\'s Tasks'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
                _pageController.jumpToPage(0);
              });
              context.read<TaskBloc>().add(
                    LoadTasksForDateEvent(DateTime.now()),
                  );
            },
          ),
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('All Tasks'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
                _pageController.jumpToPage(0);
              });
              context.read<TaskBloc>().add(const LoadTasksEvent());
            },
          ),
        ],
      ),
    );
  }
}
