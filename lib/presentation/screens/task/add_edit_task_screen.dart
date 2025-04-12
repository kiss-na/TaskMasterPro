import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/presentation/blocs/task/task_event.dart';
import 'package:task_manager/presentation/blocs/task/task_state.dart';
import 'package:task_manager/presentation/widgets/task/priority_selector.dart';
import 'package:task_manager/presentation/widgets/task/color_picker.dart';
import 'package:task_manager/presentation/widgets/task/location_picker.dart';
import 'package:task_manager/presentation/widgets/task/contact_picker.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/core/utils/validators.dart';

class AddEditTaskScreen extends StatefulWidget {
  final bool isEditing;
  final String? taskId;

  const AddEditTaskScreen({
    Key? key,
    required this.isEditing,
    this.taskId,
  }) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  TaskPriority _priority = TaskPriority.medium;
  Color _color = Colors.blue;
  double? _latitude;
  double? _longitude;
  bool _isCompleted = false;
  DateTime? _reminderDateTime;
  TaskRepeatType _repeatType = TaskRepeatType.none;
  List<int>? _repeatDays;

  bool _isLoading = false;
  bool _showDueTime = false;
  bool _showReminder = false;
  bool _showRepeat = false;
  bool _showLocation = false;
  bool _showContact = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.taskId != null) {
      _loadTask();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationNameController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _loadTask() {
    context.read<TaskBloc>().add(LoadTaskEvent(widget.taskId!));
  }

  void _populateForm(Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _dueDate = task.dueDate;
    _showDueTime = task.dueDate != null;
    if (task.dueDate != null) {
      _dueTime = TimeOfDay(hour: task.dueDate!.hour, minute: task.dueDate!.minute);
    }
    _priority = task.priority;
    _color = task.color;
    _isCompleted = task.isCompleted;
    
    _showLocation = task.hasLocation();
    _locationNameController.text = task.locationName ?? '';
    _latitude = task.latitude;
    _longitude = task.longitude;
    
    _showContact = task.hasContact();
    _contactNameController.text = task.contactName ?? '';
    _contactPhoneController.text = task.contactPhone ?? '';
    
    _showReminder = task.hasReminder();
    _reminderDateTime = task.reminderDateTime;
    
    _showRepeat = task.repeatType != null && task.repeatType != TaskRepeatType.none;
    _repeatType = task.repeatType ?? TaskRepeatType.none;
    _repeatDays = task.repeatDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoadedState && widget.isEditing) {
            _populateForm(state.task);
          } else if (state is TasksErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoadingState && widget.isEditing) {
            return const LoadingIndicator();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.isEditing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value ?? false;
                              });
                            },
                          ),
                          const Text('Mark as completed'),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => Validators.validateRequired(value, fieldName: 'Title'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.event),
                            title: const Text('Due Date'),
                            trailing: Switch(
                              value: _showDueTime,
                              onChanged: (value) {
                                setState(() {
                                  _showDueTime = value;
                                  if (!value) {
                                    _dueDate = null;
                                    _dueTime = null;
                                  }
                                });
                              },
                            ),
                          ),
                          if (_showDueTime) ...[
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.calendar_today),
                                      label: Text(
                                        _dueDate == null
                                            ? 'Select Date'
                                            : DateFormat('MMM dd, yyyy').format(_dueDate!),
                                      ),
                                      onPressed: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _dueDate ?? DateTime.now(),
                                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            _dueDate = date;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.access_time),
                                      label: Text(
                                        _dueTime == null
                                            ? 'Select Time'
                                            : _dueTime!.format(context),
                                      ),
                                      onPressed: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _dueTime ?? TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            _dueTime = time;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: const Text('Reminder'),
                            trailing: Switch(
                              value: _showReminder,
                              onChanged: (value) {
                                setState(() {
                                  _showReminder = value;
                                  if (!value) {
                                    _reminderDateTime = null;
                                  }
                                });
                              },
                            ),
                          ),
                          if (_showReminder) ...[
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.calendar_today),
                                      label: Text(
                                        _reminderDateTime == null
                                            ? 'Select Date'
                                            : DateFormat('MMM dd, yyyy').format(_reminderDateTime!),
                                      ),
                                      onPressed: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: _reminderDateTime ?? DateTime.now(),
                                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                        );
                                        if (date != null) {
                                          setState(() {
                                            if (_reminderDateTime != null) {
                                              _reminderDateTime = DateTime(
                                                date.year,
                                                date.month,
                                                date.day,
                                                _reminderDateTime!.hour,
                                                _reminderDateTime!.minute,
                                              );
                                            } else {
                                              _reminderDateTime = date;
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.access_time),
                                      label: Text(
                                        _reminderDateTime == null
                                            ? 'Select Time'
                                            : DateFormat('HH:mm').format(_reminderDateTime!),
                                      ),
                                      onPressed: () async {
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: _reminderDateTime != null
                                              ? TimeOfDay(
                                                  hour: _reminderDateTime!.hour,
                                                  minute: _reminderDateTime!.minute,
                                                )
                                              : TimeOfDay.now(),
                                        );
                                        if (time != null) {
                                          setState(() {
                                            if (_reminderDateTime != null) {
                                              _reminderDateTime = DateTime(
                                                _reminderDateTime!.year,
                                                _reminderDateTime!.month,
                                                _reminderDateTime!.day,
                                                time.hour,
                                                time.minute,
                                              );
                                            } else {
                                              final now = DateTime.now();
                                              _reminderDateTime = DateTime(
                                                now.year,
                                                now.month,
                                                now.day,
                                                time.hour,
                                                time.minute,
                                              );
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.repeat),
                              title: const Text('Repeat'),
                              trailing: Switch(
                                value: _showRepeat,
                                onChanged: (value) {
                                  setState(() {
                                    _showRepeat = value;
                                    if (!value) {
                                      _repeatType = TaskRepeatType.none;
                                      _repeatDays = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            if (_showRepeat) ...[
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: DropdownButtonFormField<TaskRepeatType>(
                                  decoration: const InputDecoration(
                                    labelText: 'Repeat Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _repeatType,
                                  items: TaskRepeatType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type.toString().split('.').last),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _repeatType = value!;
                                      if (value == TaskRepeatType.weekly) {
                                        _repeatDays ??= [DateTime.now().weekday];
                                      } else {
                                        _repeatDays = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                              if (_repeatType == TaskRepeatType.weekly) ...[
                                const SizedBox(height: 16),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text('Repeat on days:'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Wrap(
                                    spacing: 8.0,
                                    children: List.generate(7, (index) {
                                      final weekday = index + 1;
                                      final day = DateFormat('E').format(
                                        DateTime(2021, 1, 3 + index), // Jan 4, 2021 was a Monday
                                      );
                                      return FilterChip(
                                        label: Text(day),
                                        selected: _repeatDays?.contains(weekday) ?? false,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (_repeatDays == null) {
                                              _repeatDays = [];
                                            }
                                            if (selected) {
                                              _repeatDays!.add(weekday);
                                            } else {
                                              _repeatDays!.remove(weekday);
                                            }
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Priority:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  PrioritySelector(
                    selectedPriority: _priority,
                    onPriorityChanged: (value) {
                      setState(() {
                        _priority = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Task Color:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TaskColorPicker(
                    selectedColor: _color,
                    onColorChanged: (color) {
                      setState(() {
                        _color = color;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.location_on),
                            title: const Text('Location'),
                            trailing: Switch(
                              value: _showLocation,
                              onChanged: (value) {
                                setState(() {
                                  _showLocation = value;
                                  if (!value) {
                                    _locationNameController.clear();
                                    _latitude = null;
                                    _longitude = null;
                                  }
                                });
                              },
                            ),
                          ),
                          if (_showLocation) ...[
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _locationNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Location Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            LocationPicker(
                              latitude: _latitude,
                              longitude: _longitude,
                              onLocationPicked: (lat, lng, name) {
                                setState(() {
                                  _latitude = lat;
                                  _longitude = lng;
                                  if (name != null && _locationNameController.text.isEmpty) {
                                    _locationNameController.text = name;
                                  }
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.contacts),
                            title: const Text('Contact'),
                            trailing: Switch(
                              value: _showContact,
                              onChanged: (value) {
                                setState(() {
                                  _showContact = value;
                                  if (!value) {
                                    _contactNameController.clear();
                                    _contactPhoneController.clear();
                                  }
                                });
                              },
                            ),
                          ),
                          if (_showContact) ...[
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _contactNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Contact Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextFormField(
                                controller: _contactPhoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: Validators.validatePhone,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ContactPicker(
                              onContactPicked: (name, phone) {
                                setState(() {
                                  _contactNameController.text = name;
                                  _contactPhoneController.text = phone;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
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
                        widget.isEditing ? 'Update Task' : 'Add Task',
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

  DateTime? _combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    
    if (time == null) {
      return date;
    }
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final DateTime? dueDateWithTime = _combineDateAndTime(_dueDate, _dueTime);
      
      if (widget.isEditing && widget.taskId != null) {
        final task = Task(
          id: widget.taskId,
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          isCompleted: _isCompleted,
          dueDate: dueDateWithTime,
          priority: _priority,
          color: _color,
          locationName: _showLocation ? _locationNameController.text : null,
          latitude: _showLocation ? _latitude : null,
          longitude: _showLocation ? _longitude : null,
          contactName: _showContact ? _contactNameController.text : null,
          contactPhone: _showContact ? _contactPhoneController.text : null,
          reminderDateTime: _showReminder ? _reminderDateTime : null,
          repeatType: _showReminder && _showRepeat ? _repeatType : TaskRepeatType.none,
          repeatDays: _showReminder && _showRepeat && _repeatType == TaskRepeatType.weekly ? _repeatDays : null,
        );
        
        context.read<TaskBloc>().add(UpdateTaskEvent(task));
      } else {
        final task = Task(
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          isCompleted: _isCompleted,
          dueDate: dueDateWithTime,
          priority: _priority,
          color: _color,
          locationName: _showLocation ? _locationNameController.text : null,
          latitude: _showLocation ? _latitude : null,
          longitude: _showLocation ? _longitude : null,
          contactName: _showContact ? _contactNameController.text : null,
          contactPhone: _showContact ? _contactPhoneController.text : null,
          reminderDateTime: _showReminder ? _reminderDateTime : null,
          repeatType: _showReminder && _showRepeat ? _repeatType : TaskRepeatType.none,
          repeatDays: _showReminder && _showRepeat && _repeatType == TaskRepeatType.weekly ? _repeatDays : null,
        );
        
        context.read<TaskBloc>().add(AddTaskEvent(task));
      }
      
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TaskBloc>().add(DeleteTaskEvent(widget.taskId!));
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
