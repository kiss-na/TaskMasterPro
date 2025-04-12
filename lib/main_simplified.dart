import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _screens = [
    const TasksScreen(),
    const CalendarScreen(),
    const NotesScreen(),
    const RemindersScreen(),
    const SettingsScreen(),
  ];
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item based on selected tab
          if (_selectedIndex == 0) {
            // Add new task
            _showSnackBar('Add new task feature coming soon');
          } else if (_selectedIndex == 2) {
            // Add new note
            _showSnackBar('Add new note feature coming soon');
          } else if (_selectedIndex == 3) {
            // Add new reminder
            _showSnackBar('Add new reminder feature coming soon');
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

// Placeholder screens for the bottom navigation
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.blue),
          SizedBox(height: 16),
          Text('Tasks Screen', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text('Manage your tasks with priorities and reminders'),
        ],
      ),
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text('Calendar Screen', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text('View your tasks in different calendar formats'),
        ],
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note, size: 80, color: Colors.amber),
          SizedBox(height: 16),
          Text('Notes Screen', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text('Create and manage your notes'),
        ],
      ),
    );
  }
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text('Reminders Screen', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text('Set up different types of reminders'),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Settings Screen', style: TextStyle(fontSize: 24)),
          SizedBox(height: 16),
          Text('Configure app settings and preferences'),
        ],
      ),
    );
  }
}