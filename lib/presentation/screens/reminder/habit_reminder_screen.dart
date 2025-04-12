import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_event.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/core/utils/validators.dart';
import 'package:intl/intl.dart';

class HabitReminderScreen extends StatefulWidget {
  const HabitReminderScreen({Key? key}) : super(key: key);

  @override
  State<HabitReminderScreen> createState() => _HabitReminderScreenState();
}

class _HabitReminderScreenState extends State<HabitReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  ReminderType _reminderType = ReminderType.water;
  ReminderFrequency _frequency = ReminderFrequency.daily;
  List<TimeOfDay> _times = [const TimeOfDay(hour: 9, minute: 0)];
  bool _isEnabled = true;
  List<int> _weekdays = [1, 2, 3, 4, 5]; // Monday to Friday
  int _interval = 60; // For water reminder: minutes between reminders
  int _duration = 25; // For pomodoro: duration in minutes
  int _breakDuration = 5; // For pomodoro: break duration in minutes
  
  bool _isEditing = false;
  String? _reminderId;

  @override
  void initState() {
    super.initState();
    
    // Check if we're editing an existing reminder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('reminderId')) {
        _isEditing = true;
        _reminderId = args['reminderId'];
        // Load the existing habit reminder
        _loadHabitReminder(_reminderId!);
      } else {
        _setDefaultValues();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadHabitReminder(String id) {
    // This would call the repository to get the reminder by ID
    // For now, we'll just set some default values
    _setDefaultValues();
  }

  void _setDefaultValues() {
    // Set defaults based on the reminder type
    switch (_reminderType) {
      case ReminderType.water:
        _titleController.text = 'Drink Water';
        _descriptionController.text = 'Remember to stay hydrated!';
        _frequency = ReminderFrequency.daily;
        _times = [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 11, minute: 0),
          const TimeOfDay(hour: 13, minute: 0),
          const TimeOfDay(hour: 15, minute: 0),
          const TimeOfDay(hour: 17, minute: 0),
        ];
        _interval = 120; // Every 2 hours
        break;
      case ReminderType.pomodoro:
        _titleController.text = 'Pomodoro Focus';
        _descriptionController.text = 'Time to focus!';
        _frequency = ReminderFrequency.weekly;
        _times = [
          const TimeOfDay(hour: 10, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
        ];
        _weekdays = [1, 2, 3, 4, 5]; // Monday to Friday
        _duration = 25;
        _breakDuration = 5;
        break;
      case ReminderType.socialization:
        _titleController.text = 'Socialize';
        _descriptionController.text = 'Time to connect with others!';
        _frequency = ReminderFrequency.weekly;
        _times = [const TimeOfDay(hour: 18, minute: 0)];
        _weekdays = [2, 4, 6]; // Tuesday, Thursday, Saturday
        _duration = 30;
        break;
      default:
        _titleController.text = '';
        _descriptionController.text = '';
        _frequency = ReminderFrequency.daily;
        _times = [const TimeOfDay(hour: 9, minute: 0)];
        break;
    }
  }

  void _populateForm(HabitReminder reminder) {
    _titleController.text = reminder.title;
    _descriptionController.text = reminder.description;
    _reminderType = reminder.type;
    _frequency = reminder.frequency;
    _times = reminder.times;
    _isEnabled = reminder.isEnabled;
    _weekdays = reminder.weekdays ?? [1, 2, 3, 4, 5];
    _interval = reminder.interval ?? 60;
    _duration = reminder.duration ?? 25;
    _breakDuration = reminder.breakDuration ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit Reminder' : 'Add Habit Reminder'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: BlocConsumer<ReminderBloc, ReminderState>(
        listener: (context, state) {
          if (state is HabitReminderLoadedState && _isEditing) {
            _populateForm(state.reminder);
          } else if (state is RemindersErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is RemindersLoadingState && _isEditing) {
            return const LoadingIndicator();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReminderTypeSelector(),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) => Validators.validateRequired(value, fieldName: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) => Validators.validateRequired(value, fieldName: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFrequencySelector(),
                  const SizedBox(height: 16),
                  
                  if (_frequency == ReminderFrequency.weekly)
                    _buildWeekdaysSelector(),
                  
                  _buildTimesSelector(),
                  const SizedBox(height: 16),
                  
                  if (_reminderType == ReminderType.water)
                    _buildWaterReminderSettings(),
                  
                  if (_reminderType == ReminderType.pomodoro)
                    _buildPomodoroSettings(),
                  
                  if (_reminderType == ReminderType.socialization)
                    _buildSocializationSettings(),
                  
                  SwitchListTile(
                    title: const Text('Enable Reminder'),
                    subtitle: const Text('Receive notifications for this habit'),
                    value: _isEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isEnabled = value;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _isEditing ? 'Update Habit Reminder' : 'Add Habit Reminder',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ReminderType>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          value: _reminderType,
          items: [
            DropdownMenuItem(
              value: ReminderType.water,
              child: Row(
                children: const [
                  Icon(Icons.water_drop, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Water'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReminderType.pomodoro,
              child: Row(
                children: const [
                  Icon(Icons.timer, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Pomodoro'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReminderType.socialization,
              child: Row(
                children: const [
                  Icon(Icons.people, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Socialization'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: ReminderType.custom,
              child: Row(
                children: const [
                  Icon(Icons.notifications, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('Custom'),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _reminderType = value;
                _setDefaultValues();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ReminderFrequency>(
          segments: const [
            ButtonSegment(
              value: ReminderFrequency.daily,
              label: Text('Daily'),
              icon: Icon(Icons.calendar_today),
            ),
            ButtonSegment(
              value: ReminderFrequency.weekly,
              label: Text('Weekly'),
              icon: Icon(Icons.view_week),
            ),
          ],
          selected: {_frequency},
          onSelectionChanged: (Set<ReminderFrequency> selection) {
            setState(() {
              _frequency = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeekdaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Repeat on days',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: List.generate(7, (index) {
            final weekday = index + 1;
            final day = DateFormat('E').format(
              DateTime(2021, 1, 3 + index), // Jan 4, 2021 was a Monday
            );
            return FilterChip(
              label: Text(day),
              selected: _weekdays.contains(weekday),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _weekdays.add(weekday);
                  } else {
                    _weekdays.remove(weekday);
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTimesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reminder Times',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Time'),
              onPressed: _addTime,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: List.generate(_times.length, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(_times[index].format(context)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    if (_times.length > 1) {
                      setState(() {
                        _times.removeAt(index);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('At least one time is required')),
                      );
                    }
                  },
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _times[index],
                  );
                  if (time != null) {
                    setState(() {
                      _times[index] = time;
                    });
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWaterReminderSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Water Reminder Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Remind every:'),
        Slider(
          value: _interval.toDouble(),
          min: 30,
          max: 240,
          divisions: 7,
          label: '${_interval.toString()} minutes',
          onChanged: (value) {
            setState(() {
              _interval = value.round();
            });
          },
        ),
        Center(
          child: Text(
            '$_interval minutes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPomodoroSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Pomodoro Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Focus duration:'),
        Slider(
          value: _duration.toDouble(),
          min: 15,
          max: 60,
          divisions: 9,
          label: '${_duration.toString()} minutes',
          onChanged: (value) {
            setState(() {
              _duration = value.round();
            });
          },
        ),
        Center(
          child: Text(
            '$_duration minutes focus time',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Break duration:'),
        Slider(
          value: _breakDuration.toDouble(),
          min: 5,
          max: 30,
          divisions: 5,
          label: '${_breakDuration.toString()} minutes',
          onChanged: (value) {
            setState(() {
              _breakDuration = value.round();
            });
          },
        ),
        Center(
          child: Text(
            '$_breakDuration minutes break time',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSocializationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Socialization Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Duration:'),
        Slider(
          value: _duration.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          label: '${_duration.toString()} minutes',
          onChanged: (value) {
            setState(() {
              _duration = value.round();
            });
          },
        ),
        Center(
          child: Text(
            '$_duration minutes of social time',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _times.add(time);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      HabitReminder reminder;
      
      switch (_reminderType) {
        case ReminderType.water:
          reminder = HabitReminder.createWaterReminder(
            times: _times,
            interval: _interval,
          );
          break;
        case ReminderType.pomodoro:
          reminder = HabitReminder.createPomodoroReminder(
            times: _times,
            weekdays: _frequency == ReminderFrequency.weekly ? _weekdays : null,
            duration: _duration,
            breakDuration: _breakDuration,
          );
          break;
        case ReminderType.socialization:
          reminder = HabitReminder.createSocializationReminder(
            times: _times,
            weekdays: _frequency == ReminderFrequency.weekly ? _weekdays : null,
            duration: _duration,
          );
          break;
        default:
          reminder = HabitReminder(
            title: _titleController.text,
            description: _descriptionController.text,
            type: _reminderType,
            frequency: _frequency,
            times: _times,
            isEnabled: _isEnabled,
            weekdays: _frequency == ReminderFrequency.weekly ? _weekdays : null,
          );
      }
      
      // Override the title and description if user changed them
      reminder = reminder.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        isEnabled: _isEnabled,
      );
      
      if (_isEditing && _reminderId != null) {
        // Update the reminder
        context.read<ReminderBloc>().add(AddHabitReminderEvent(reminder));
      } else {
        // Add a new reminder
        context.read<ReminderBloc>().add(AddHabitReminderEvent(reminder));
      }
      
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit Reminder'),
          content: const Text('Are you sure you want to delete this habit reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Delete the reminder
                Navigator.pop(context);
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
