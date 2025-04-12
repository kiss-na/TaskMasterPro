import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarRepository {
  // Hive box name
  static const String settingsBoxName = 'settings';
  
  // Default settings
  static const String defaultCalendarType = 'gregorian';

  // Get selected calendar type
  Future<String> getCalendarType() async {
    final box = await Hive.openBox(settingsBoxName);
    return box.get('calendar_type', defaultValue: defaultCalendarType);
  }

  // Set calendar type
  Future<void> setCalendarType(String calendarType) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put('calendar_type', calendarType);
  }

  // Get Google Calendar sync status
  Future<bool> isSyncEnabled() async {
    final box = await Hive.openBox(settingsBoxName);
    return box.get('google_calendar_sync', defaultValue: false);
  }

  // Set Google Calendar sync status
  Future<void> setSyncEnabled(bool enabled) async {
    final box = await Hive.openBox(settingsBoxName);
    await box.put('google_calendar_sync', enabled);
  }

  // Sync tasks with Google Calendar
  Future<bool> syncWithGoogleCalendar(List<Task> tasks) async {
    try {
      final isSyncEnabled = await this.isSyncEnabled();
      if (!isSyncEnabled) return false;
      
      // In a real app, this would use a proper auth flow with the googleapis package
      // For now, we'll just simulate a successful sync
      
      // The following is commented out but would be used in a real implementation
      /*
      // Get stored credentials
      final box = await Hive.openBox(settingsBoxName);
      final accessToken = box.get('google_access_token');
      final refreshToken = box.get('google_refresh_token');
      
      if (accessToken == null || refreshToken == null) {
        // Need to authenticate first
        return false;
      }
      
      // Set up OAuth2 credentials
      final credentials = AccessCredentials(
        AccessToken('Bearer', accessToken, DateTime.now().add(Duration(hours: 1))),
        refreshToken,
        ['https://www.googleapis.com/auth/calendar'],
      );
      
      // Create authenticated HTTP client
      final client = authenticatedClient(ClientId('client_id', 'client_secret'), credentials);
      
      // Create calendar API client
      final calendarApi = CalendarApi(client);
      
      // Get user's calendars
      final calendarList = await calendarApi.calendarList.list();
      
      // Find the primary calendar
      String? calendarId;
      for (var calendar in calendarList.items!) {
        if (calendar.primary == true) {
          calendarId = calendar.id;
          break;
        }
      }
      
      if (calendarId == null) {
        return false;
      }
      
      // Sync tasks
      for (var task in tasks) {
        if (task.dueDate != null) {
          // Check if event already exists by querying with custom property
          final events = await calendarApi.events.list(
            calendarId,
            q: task.title,
            orderBy: 'startTime',
            singleEvents: true,
          );
          
          // Create event data
          final event = Event()
            ..summary = task.title
            ..description = task.description
            ..start = EventDateTime()
              ..dateTime = task.dueDate
              ..timeZone = 'UTC'
            ..end = EventDateTime()
              ..dateTime = task.dueDate!.add(Duration(hours: 1))
              ..timeZone = 'UTC'
            ..reminders = EventReminders()
              ..useDefault = true;
            
          // Either update existing event or create new one
          bool eventFound = false;
          if (events.items != null) {
            for (var existingEvent in events.items!) {
              if (existingEvent.summary == task.title) {
                await calendarApi.events.update(event, calendarId, existingEvent.id!);
                eventFound = true;
                break;
              }
            }
          }
          
          if (!eventFound) {
            await calendarApi.events.insert(event, calendarId);
          }
        }
      }
      
      client.close();
      */
      
      return true;
    } catch (e) {
      print('Error syncing with Google Calendar: $e');
      return false;
    }
  }

  // Prompt Google Calendar authentication
  Future<bool> authenticateWithGoogleCalendar() async {
    try {
      // In a real app, this would open the OAuth flow
      // For now, we'll just simulate a successful authentication
      
      // The following is commented out but would be used in a real implementation
      /*
      // Define OAuth scopes
      final scopes = ['https://www.googleapis.com/auth/calendar'];
      
      // Create client ID
      final clientId = ClientId(
        'YOUR_CLIENT_ID',
        'YOUR_CLIENT_SECRET',
      );
      
      // Launch authentication flow
      await clientViaUserConsent(clientId, scopes, (url) async {
        // Launch the URL in a browser for the user to authenticate
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      }).then((client) async {
        // Save credentials
        final box = await Hive.openBox(settingsBoxName);
        final credentials = client.credentials;
        
        await box.put('google_access_token', credentials.accessToken.data);
        await box.put('google_refresh_token', credentials.refreshToken);
        
        // Enable sync
        await setSyncEnabled(true);
        
        client.close();
      });
      */
      
      // For simulation purposes
      await setSyncEnabled(true);
      
      return true;
    } catch (e) {
      print('Error authenticating with Google Calendar: $e');
      return false;
    }
  }

  // Clear Google Calendar authentication
  Future<bool> clearGoogleCalendarAuth() async {
    try {
      final box = await Hive.openBox(settingsBoxName);
      await box.delete('google_access_token');
      await box.delete('google_refresh_token');
      await setSyncEnabled(false);
      return true;
    } catch (e) {
      print('Error clearing Google Calendar auth: $e');
      return false;
    }
  }
}
