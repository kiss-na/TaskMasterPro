import 'package:equatable/equatable.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarEvent extends CalendarEvent {
  const LoadCalendarEvent();
}

class LoadTasksForDateEvent extends CalendarEvent {
  final DateTime date;

  const LoadTasksForDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeCalendarTypeEvent extends CalendarEvent {
  final String calendarType;

  const ChangeCalendarTypeEvent(this.calendarType);

  @override
  List<Object?> get props => [calendarType];
}

class ToggleGoogleSyncEvent extends CalendarEvent {
  final bool enabled;

  const ToggleGoogleSyncEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class SyncWithGoogleCalendarEvent extends CalendarEvent {
  const SyncWithGoogleCalendarEvent();
}

class AuthenticateGoogleCalendarEvent extends CalendarEvent {
  const AuthenticateGoogleCalendarEvent();
}

class LogoutGoogleCalendarEvent extends CalendarEvent {
  const LogoutGoogleCalendarEvent();
}
