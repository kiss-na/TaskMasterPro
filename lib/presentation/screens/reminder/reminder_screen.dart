import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_event.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_state.dart';
import 'package:task_manager/presentation/widgets/reminder/reminder_list_item.dart';
import 'package:task_manager/presentation/widgets/common/empty_state.dart';
import 'package:task_manager/presentation/widgets/common/error_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/config/routes.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReminders() {
    context.read<ReminderBloc>().add(const LoadRemindersEvent());
    context.read<ReminderBloc>().add(const LoadBirthdayRemindersEvent());
    context.read<ReminderBloc>().add(const LoadHabitRemindersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Birthdays'),
            Tab(text: 'Habits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllRemindersTab(),
          _buildBirthdayRemindersTab(),
          _buildHabitRemindersTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showReminderTypeMenu();
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Reminder',
      ),
    );
  }

  Widget _buildAllRemindersTab() {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is RemindersLoadingState) {
          return const LoadingIndicator();
        } else if (state is RemindersLoadedState) {
          if (state.reminders.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications,
              message: 'No reminders yet',
              description: 'Tap the + button to create a new reminder',
            );
          }
          
          return ListView.builder(
            itemCount: state.reminders.length,
            itemBuilder: (context, index) {
              final reminder = state.reminders[index];
              return ReminderListItem(
                reminder: reminder,
                onToggleEnabled: () {
                  context.read<ReminderBloc>().add(ToggleReminderEnabledEvent(reminder.id));
                },
                onTap: () {
                  _navigateToReminderEdit(reminder);
                },
                onDelete: () {
                  _confirmDelete(reminder);
                },
              );
            },
          );
        } else if (state is RemindersErrorState) {
          return ErrorState(
            message: state.message,
            onRetry: _loadReminders,
          );
        } else {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'Unknown state',
            description: 'Something went wrong',
          );
        }
      },
    );
  }

  Widget _buildBirthdayRemindersTab() {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is RemindersLoadingState) {
          return const LoadingIndicator();
        } else if (state is BirthdayRemindersLoadedState) {
          if (state.reminders.isEmpty) {
            return const EmptyState(
              icon: Icons.cake,
              message: 'No birthday reminders yet',
              description: 'Tap the + button to add a birthday reminder',
            );
          }
          
          // Sort by days until next birthday
          final sortedReminders = List<BirthdayReminder>.from(state.reminders);
          sortedReminders.sort((a, b) => a.daysUntilNextBirthday().compareTo(b.daysUntilNextBirthday()));
          
          return ListView.builder(
            itemCount: sortedReminders.length,
            itemBuilder: (context, index) {
              final reminder = sortedReminders[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.cake),
                ),
                title: Text(reminder.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Birthday: ${reminder.date.month}/${reminder.date.day}/${reminder.date.year}'),
                    Text(
                      reminder.isBirthdayToday() 
                          ? 'Today!' 
                          : '${reminder.daysUntilNextBirthday()} days remaining',
                      style: TextStyle(
                        color: reminder.isBirthdayToday() ? Colors.red : null,
                        fontWeight: reminder.isBirthdayToday() ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: reminder.isEnabled,
                  onChanged: (value) {
                    final updatedReminder = reminder.copyWith(isEnabled: value);
                    context.read<ReminderBloc>().add(UpdateBirthdayReminderEvent(updatedReminder));
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.birthdayReminders,
                    arguments: {'reminderId': reminder.id},
                  );
                },
              );
            },
          );
        } else if (state is RemindersErrorState) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<ReminderBloc>().add(const LoadBirthdayRemindersEvent()),
          );
        } else {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'Unknown state',
            description: 'Something went wrong',
          );
        }
      },
    );
  }

  Widget _buildHabitRemindersTab() {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is RemindersLoadingState) {
          return const LoadingIndicator();
        } else if (state is HabitRemindersLoadedState) {
          if (state.reminders.isEmpty) {
            return const EmptyState(
              icon: Icons.repeat,
              message: 'No habit reminders yet',
              description: 'Tap the + button to create a habit reminder',
            );
          }
          
          // Group by reminder type
          final Map<ReminderType, List<HabitReminder>> groupedReminders = {};
          for (final reminder in state.reminders) {
            if (!groupedReminders.containsKey(reminder.type)) {
              groupedReminders[reminder.type] = [];
            }
            groupedReminders[reminder.type]!.add(reminder);
          }
          
          return ListView(
            children: [
              if (groupedReminders.containsKey(ReminderType.water))
                _buildHabitReminderSection('Water Reminders', Icons.water_drop, groupedReminders[ReminderType.water]!),
              if (groupedReminders.containsKey(ReminderType.pomodoro))
                _buildHabitReminderSection('Pomodoro Reminders', Icons.timer, groupedReminders[ReminderType.pomodoro]!),
              if (groupedReminders.containsKey(ReminderType.socialization))
                _buildHabitReminderSection('Socialization Reminders', Icons.people, groupedReminders[ReminderType.socialization]!),
              if (groupedReminders.containsKey(ReminderType.custom))
                _buildHabitReminderSection('Custom Reminders', Icons.notifications, groupedReminders[ReminderType.custom]!),
            ],
          );
        } else if (state is RemindersErrorState) {
          return ErrorState(
            message: state.message,
            onRetry: () => context.read<ReminderBloc>().add(const LoadHabitRemindersEvent()),
          );
        } else {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'Unknown state',
            description: 'Something went wrong',
          );
        }
      },
    );
  }

  Widget _buildHabitReminderSection(String title, IconData icon, List<HabitReminder> reminders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return ListTile(
              title: Text(reminder.title),
              subtitle: Text(_getHabitReminderDetails(reminder)),
              trailing: Switch(
                value: reminder.isEnabled,
                onChanged: (value) {
                  final updatedReminder = reminder.copyWith(isEnabled: value);
                  context.read<ReminderBloc>().add(AddHabitReminderEvent(updatedReminder));
                },
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.habitReminders,
                  arguments: {'reminderId': reminder.id},
                );
              },
            );
          },
        ),
        const Divider(),
      ],
    );
  }

  String _getHabitReminderDetails(HabitReminder reminder) {
    final buffer = StringBuffer();
    
    // Frequency
    if (reminder.frequency == ReminderFrequency.daily) {
      buffer.write('Daily');
    } else if (reminder.frequency == ReminderFrequency.weekly && reminder.weekdays != null) {
      buffer.write('Weekly: ');
      final days = <String>[];
      for (final day in reminder.weekdays!) {
        switch (day) {
          case 1: days.add('Mon'); break;
          case 2: days.add('Tue'); break;
          case 3: days.add('Wed'); break;
          case 4: days.add('Thu'); break;
          case 5: days.add('Fri'); break;
          case 6: days.add('Sat'); break;
          case 7: days.add('Sun'); break;
        }
      }
      buffer.write(days.join(', '));
    }
    
    // Times
    if (reminder.times.isNotEmpty) {
      buffer.write(' at ');
      final times = reminder.times.map((time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}').toList();
      buffer.write(times.join(', '));
    }
    
    return buffer.toString();
  }

  void _navigateToReminderEdit(Reminder reminder) {
    // Navigate based on the reminder type
    if (reminder.type == ReminderType.birthday) {
      Navigator.pushNamed(
        context,
        AppRoutes.birthdayReminders,
        arguments: {'reminderId': reminder.id},
      );
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.habitReminders,
        arguments: {'reminderId': reminder.id},
      );
    }
  }

  void _confirmDelete(Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: Text('Are you sure you want to delete "${reminder.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ReminderBloc>().add(DeleteReminderEvent(reminder.id));
              },
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReminderTypeMenu() {
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
                  _createWaterReminder();
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Pomodoro Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  _createPomodoroReminder();
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Socialization Reminder'),
                onTap: () {
                  Navigator.pop(context);
                  _createSocializationReminder();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _createWaterReminder() {
    final reminder = HabitReminder.createWaterReminder(
      times: [
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 11, minute: 0),
        const TimeOfDay(hour: 13, minute: 0),
        const TimeOfDay(hour: 15, minute: 0),
        const TimeOfDay(hour: 17, minute: 0),
      ],
    );
    
    context.read<ReminderBloc>().add(AddHabitReminderEvent(reminder));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Water reminder created')),
    );
  }

  void _createPomodoroReminder() {
    final reminder = HabitReminder.createPomodoroReminder(
      times: [
        const TimeOfDay(hour: 9, minute: 0),
        const TimeOfDay(hour: 14, minute: 0),
      ],
      weekdays: [1, 2, 3, 4, 5], // Monday to Friday
    );
    
    context.read<ReminderBloc>().add(AddHabitReminderEvent(reminder));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pomodoro reminder created')),
    );
  }

  void _createSocializationReminder() {
    final reminder = HabitReminder.createSocializationReminder(
      times: [
        const TimeOfDay(hour: 18, minute: 0),
      ],
      weekdays: [2, 4, 6], // Tuesday, Thursday, Saturday
    );
    
    context.read<ReminderBloc>().add(AddHabitReminderEvent(reminder));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Socialization reminder created')),
    );
  }
}
