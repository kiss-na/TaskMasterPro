import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_event.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_state.dart';
import 'package:task_manager/presentation/blocs/note/note_bloc.dart';
import 'package:task_manager/presentation/blocs/note/note_event.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _calendarType = 'gregorian';
  bool _isSyncEnabled = false;
  int _retentionDays = 30;
  String _appVersion = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppInfo();
  }

  Future<void> _loadSettings() async {
    final settingsBox = await Hive.openBox('settings');
    
    setState(() {
      _isDarkMode = settingsBox.get('dark_mode', defaultValue: false);
      _retentionDays = settingsBox.get('note_retention_days', defaultValue: 30);
      _isLoading = false;
    });
    
    // Load calendar state from the bloc
    context.read<CalendarBloc>().add(const LoadCalendarEvent());
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      _appVersion = '1.0.0'; // Fallback version
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('dark_mode', value);
    
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _updateRetentionDays(int days) async {
    context.read<NoteBloc>().add(UpdateNoteRetentionDaysEvent(days));
    
    setState(() {
      _retentionDays = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading 
          ? const LoadingIndicator() 
          : ListView(
              children: [
                _buildAppearanceSection(),
                const Divider(),
                _buildCalendarSection(),
                const Divider(),
                _buildNotesSection(),
                const Divider(),
                _buildAboutSection(),
              ],
            ),
    );
  }

  Widget _buildAppearanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Appearance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Use dark theme'),
          value: _isDarkMode,
          onChanged: _toggleDarkMode,
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Calendar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        BlocConsumer<CalendarBloc, CalendarState>(
          listener: (context, state) {
            if (state is CalendarLoadedState) {
              setState(() {
                _calendarType = state.calendarType;
                _isSyncEnabled = state.isSyncEnabled;
              });
            }
          },
          builder: (context, state) {
            if (state is CalendarLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Column(
              children: [
                ListTile(
                  title: const Text('Calendar Type'),
                  subtitle: Text('Currently using ${_calendarType.capitalize()} calendar'),
                  trailing: DropdownButton<String>(
                    value: _calendarType,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<CalendarBloc>().add(ChangeCalendarTypeEvent(newValue));
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
                SwitchListTile(
                  title: const Text('Google Calendar Sync'),
                  subtitle: const Text('Sync tasks with Google Calendar'),
                  value: _isSyncEnabled,
                  onChanged: (bool value) {
                    context.read<CalendarBloc>().add(ToggleGoogleSyncEvent(value));
                    if (value) {
                      context.read<CalendarBloc>().add(const AuthenticateGoogleCalendarEvent());
                    }
                  },
                ),
                if (_isSyncEnabled)
                  ListTile(
                    title: const Text('Sync Now'),
                    subtitle: const Text('Manually sync with Google Calendar'),
                    trailing: const Icon(Icons.sync),
                    onTap: () {
                      context.read<CalendarBloc>().add(const SyncWithGoogleCalendarEvent());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing with Google Calendar...')),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Notes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Archive Retention Period'),
          subtitle: Text('Delete archived notes after $_retentionDays days'),
          onTap: () => _showRetentionDaysDialog(),
        ),
        ListTile(
          title: const Text('Clean Up Archived Notes'),
          subtitle: const Text('Permanently delete expired notes'),
          trailing: const Icon(Icons.cleaning_services),
          onTap: () {
            context.read<NoteBloc>().add(const CleanupExpiredNotesEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expired notes cleaned up')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: const Text('Version'),
          subtitle: Text(_appVersion),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchURL('https://example.com/privacy-policy'),
        ),
        ListTile(
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchURL('https://example.com/terms-of-service'),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            '© 2023 Task Manager',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showRetentionDaysDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int selectedDays = _retentionDays;
        
        return AlertDialog(
          title: const Text('Archive Retention Period'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Auto-delete archived notes after:'),
                  Slider(
                    value: selectedDays.toDouble(),
                    min: 7,
                    max: 365,
                    divisions: 358,
                    label: selectedDays.toString(),
                    onChanged: (double value) {
                      setState(() {
                        selectedDays = value.round();
                      });
                    },
                  ),
                  Text(
                    '$selectedDays days',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateRetentionDays(selectedDays);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
