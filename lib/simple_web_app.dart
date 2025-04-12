import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleTaskManager());
}

class SimpleTaskManager extends StatelessWidget {
  const SimpleTaskManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
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
      body: Center(
        child: _getContentForCurrentTab(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add new item for ${_getTabName(_selectedIndex)}')),
          );
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
  
  Widget _getContentForCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildTabContent(
          'Tasks',
          Icons.task_alt,
          Colors.blue,
          'Manage your tasks with priorities and reminders',
        );
      case 1:
        return _buildTabContent(
          'Calendar',
          Icons.calendar_month,
          Colors.green,
          'View your tasks in different calendar formats',
        );
      case 2:
        return _buildTabContent(
          'Notes',
          Icons.note,
          Colors.amber,
          'Create and manage your notes',
        );
      case 3:
        return _buildTabContent(
          'Reminders',
          Icons.alarm,
          Colors.red,
          'Set up different types of reminders',
        );
      case 4:
        return _buildTabContent(
          'Settings',
          Icons.settings,
          Colors.grey,
          'Configure app settings and preferences',
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildTabContent(String title, IconData icon, Color color, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: color),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(description),
      ],
    );
  }
  
  String _getTabName(int index) {
    switch (index) {
      case 0: return 'Tasks';
      case 1: return 'Calendar';
      case 2: return 'Notes';
      case 3: return 'Reminders';
      case 4: return 'Settings';
      default: return '';
    }
  }
}