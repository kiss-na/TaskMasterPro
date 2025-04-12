import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/presentation/blocs/task/task_event.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_event.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_state.dart';
import 'package:task_manager/presentation/widgets/calendar/calendar_widget.dart';
import 'package:task_manager/presentation/widgets/task/task_list_item.dart';
import 'package:task_manager/presentation/widgets/common/empty_state.dart';
import 'package:task_manager/presentation/widgets/common/error_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/config/routes.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCalendarData();
    _loadTasksForSelectedDate();
    _loadUpcomingTasks();
  }

  void _loadCalendarData() {
    context.read<CalendarBloc>().add(const LoadCalendarEvent());
  }

  void _loadTasksForSelectedDate() {
    context.read<CalendarBloc>().add(LoadTasksForDateEvent(_selectedDate));
  }

  void _loadUpcomingTasks() {
    context.read<TaskBloc>().add(const LoadUpcomingTasksEvent(limit: 5));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    context.read<CalendarBloc>().add(LoadTasksForDateEvent(date));
  }

  void _onCalendarTypeChanged(String type) {
    context.read<CalendarBloc>().add(ChangeCalendarTypeEvent(type));
  }

  void _toggleGoogleSync(bool enabled) {
    context.read<CalendarBloc>().add(ToggleGoogleSyncEvent(enabled));
    if (enabled) {
      context.read<CalendarBloc>().add(const AuthenticateGoogleCalendarEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showCalendarSettings();
            },
          ),
        ],
      ),
      body: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, calendarState) {
          if (calendarState is CalendarLoadingState) {
            return const LoadingIndicator();
          } else if (calendarState is CalendarErrorState) {
            return ErrorState(
              message: calendarState.message,
              onRetry: _loadCalendarData,
            );
          } else if (calendarState is CalendarLoadedState ||
                     calendarState is TasksForDateLoadedState) {
            final String calendarType = calendarState is CalendarLoadedState 
                ? calendarState.calendarType 
                : (calendarState as TasksForDateLoadedState).calendarType;
            
            final List<Task> tasksForSelectedDate = calendarState is TasksForDateLoadedState 
                ? calendarState.tasksForSelectedDate 
                : [];
            
            return Column(
              children: [
                // Calendar widget
                CalendarWidget(
                  calendarType: calendarType,
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateSelected,
                ),
                
                // Tasks for selected date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Tasks for ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (tasksForSelectedDate.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No tasks for this date',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: tasksForSelectedDate.length,
                            itemBuilder: (context, index) {
                              final task = tasksForSelectedDate[index];
                              return TaskListItem(
                                task: task,
                                onToggleCompleted: () {
                                  context.read<TaskBloc>().add(ToggleTaskCompletionEvent(task.id));
                                  // Refresh calendar data after toggling
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    _loadTasksForSelectedDate();
                                  });
                                },
                                onTap: () {
                                  Navigator.pushNamed(
                                    context, 
                                    AppRoutes.editTask,
                                    arguments: {'taskId': task.id},
                                  ).then((_) {
                                    // Refresh calendar data after editing
                                    _loadTasksForSelectedDate();
                                  });
                                },
                                onDelete: () {
                                  _confirmDelete(task);
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Upcoming tasks section
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, taskState) {
                    if (taskState is UpcomingTasksLoadedState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Upcoming Tasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (taskState.tasks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No upcoming tasks',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: taskState.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskState.tasks[index];
                                  return SizedBox(
                                    width: 200,
                                    child: Card(
                                      color: task.color.withOpacity(0.1),
                                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context, 
                                            AppRoutes.editTask,
                                            arguments: {'taskId': task.id},
                                          ).then((_) {
                                            _loadUpcomingTasks();
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    size: 12,
                                                    color: task.getPriorityColor(),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      task.priority.toString().split('.').last,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                task.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                task.description ?? 'No description',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Spacer(),
                                              if (task.dueDate != null)
                                                Text(
                                                  'Due: ${task.dueDate!.month}/${task.dueDate!.day}/${task.dueDate!.year}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: task.isOverdue() ? Colors.red : Colors.grey[700],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          } else {
            return const EmptyState(
              icon: Icons.calendar_today,
              message: 'Calendar not available',
              description: 'There was an error loading the calendar',
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTask),
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  void _showCalendarSettings() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state is CalendarLoadedState || state is TasksForDateLoadedState) {
              final calendarType = state is CalendarLoadedState 
                  ? state.calendarType 
                  : (state as TasksForDateLoadedState).calendarType;
              
              final isSyncEnabled = state is CalendarLoadedState 
                  ? state.isSyncEnabled 
                  : (state as TasksForDateLoadedState).isSyncEnabled;
              
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      title: Text(
                        'Calendar Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calendar_view_month),
                      title: const Text('Calendar Type'),
                      trailing: DropdownButton<String>(
                        value: calendarType,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _onCalendarTypeChanged(newValue);
                            Navigator.pop(context);
                          }
                        },
                        items: <String>['gregorian', 'nepali']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value.capitalize()),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.sync),
                      title: const Text('Sync with Google Calendar'),
                      trailing: Switch(
                        value: isSyncEnabled,
                        onChanged: (bool value) {
                          _toggleGoogleSync(value);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    if (isSyncEnabled)
                      ListTile(
                        leading: const Icon(Icons.sync_alt),
                        title: const Text('Sync Now'),
                        onTap: () {
                          context.read<CalendarBloc>().add(
                                const SyncWithGoogleCalendarEvent(),
                              );
                          Navigator.pop(context);
                        },
                      ),
                    if (isSyncEnabled)
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout from Google'),
                        onTap: () {
                          context.read<CalendarBloc>().add(
                                const LogoutGoogleCalendarEvent(),
                              );
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Loading settings...'),
              );
            }
          },
        );
      },
    );
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                // Refresh calendar data after deleting
                Future.delayed(const Duration(milliseconds: 300), () {
                  _loadTasksForSelectedDate();
                  _loadUpcomingTasks();
                });
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
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
