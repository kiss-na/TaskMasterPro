import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_bloc.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_event.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/core/utils/validators.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class BirthdayReminderScreen extends StatefulWidget {
  const BirthdayReminderScreen({Key? key}) : super(key: key);

  @override
  State<BirthdayReminderScreen> createState() => _BirthdayReminderScreenState();
}

class _BirthdayReminderScreenState extends State<BirthdayReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  DateTime _birthDate = DateTime(DateTime.now().year - 30);
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isEnabled = true;
  
  bool _isEditing = false;
  String? _reminderId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Check if we're editing an existing reminder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('reminderId')) {
        _isEditing = true;
        _reminderId = args['reminderId'];
        _loadBirthdayReminder(_reminderId!);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadBirthdayReminder(String id) {
    context.read<ReminderBloc>().add(LoadBirthdayReminderEvent(id));
  }

  void _populateForm(BirthdayReminder reminder) {
    _nameController.text = reminder.name;
    _phoneController.text = reminder.phoneNumber ?? '';
    _emailController.text = reminder.email ?? '';
    _notesController.text = reminder.notes ?? '';
    _birthDate = reminder.date;
    _reminderTime = reminder.reminderTime;
    _isEnabled = reminder.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Birthday Reminder' : 'Add Birthday Reminder'),
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
          if (state is BirthdayReminderLoadedState && _isEditing) {
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
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => Validators.validateRequired(value, fieldName: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDateSelector(),
                  const SizedBox(height: 16),
                  
                  _buildTimeSelector(),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.phone),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contacts),
                        onPressed: _pickContact,
                        tooltip: 'Pick from contacts',
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isNotEmpty ? Validators.validateEmail(value) : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Enable Reminder'),
                    subtitle: const Text('Receive notifications for this birthday'),
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
                        _isEditing ? 'Update Birthday Reminder' : 'Add Birthday Reminder',
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

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birthday Date',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              DateFormat('MMMM dd, yyyy').format(_birthDate),
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _birthDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _birthDate = date;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Time',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
              _reminderTime.format(context),
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (time != null) {
                setState(() {
                  _reminderTime = time;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickContact() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final Contact? contact = await ContactsService.openDeviceContactPicker();
        if (contact != null) {
          setState(() {
            _nameController.text = contact.displayName ?? '';
            if (contact.phones != null && contact.phones!.isNotEmpty) {
              _phoneController.text = contact.phones!.first.value ?? '';
            }
            if (contact.emails != null && contact.emails!.isNotEmpty) {
              _emailController.text = contact.emails!.first.value ?? '';
            }
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking contact: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission to access contacts was denied')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing && _reminderId != null) {
        final reminder = BirthdayReminder(
          id: _reminderId,
          name: _nameController.text,
          date: _birthDate,
          phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          isEnabled: _isEnabled,
          reminderTime: _reminderTime,
        );
        
        context.read<ReminderBloc>().add(UpdateBirthdayReminderEvent(reminder));
      } else {
        final reminder = BirthdayReminder(
          name: _nameController.text,
          date: _birthDate,
          phoneNumber: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          isEnabled: _isEnabled,
          reminderTime: _reminderTime,
        );
        
        context.read<ReminderBloc>().add(AddBirthdayReminderEvent(reminder));
      }
      
      Navigator.pop(context);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Birthday Reminder'),
          content: const Text('Are you sure you want to delete this birthday reminder?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ReminderBloc>().add(DeleteBirthdayReminderEvent(_reminderId!));
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
