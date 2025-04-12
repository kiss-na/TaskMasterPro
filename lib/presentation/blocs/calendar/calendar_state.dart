import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/task.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarLoadingState extends CalendarState {}

class CalendarLoadedState extends CalendarState {
  final String calendarType;
  final List<Task> tasks;
  final bool isSyncEnabled;

  const CalendarLoadedState({
    required this.calendarType,
    required this.tasks,
    required this.isSyncEnabled,
  });

  @override
  List<Object?> get props => [calendarType, tasks, isSyncEnabled];
}

class TasksForDateLoadedState extends CalendarLoadedState {
  final DateTime selectedDate;
  final List<Task> tasksForSelectedDate;

  const TasksForDateLoadedState({
    required super.calendarType,
    required super.tasks,
    required super.isSyncEnabled,
    required this.selectedDate,
    required this.tasksForSelectedDate,
  });

  @override
  List<Object?> get props => [
    calendarType,
    tasks,
    isSyncEnabled,
    selectedDate,
    tasksForSelectedDate,
  ];
}

class CalendarSyncingState extends CalendarLoadedState {
  const CalendarSyncingState({
    required super.calendarType,
    required super.tasks,
    required super.isSyncEnabled,
  });
}

class CalendarSyncedState extends CalendarLoadedState {
  const CalendarSyncedState({
    required super.calendarType,
    required super.tasks,
    required super.isSyncEnabled,
  });
}

class CalendarSyncFailedState extends CalendarLoadedState {
  final String message;

  const CalendarSyncFailedState({
    required this.message,
    required super.calendarType,
    required super.tasks,
    required super.isSyncEnabled,
  });

  @override
  List<Object?> get props => [message, calendarType, tasks, isSyncEnabled];
}

class CalendarAuthenticatingState extends CalendarLoadedState {
  const CalendarAuthenticatingState({
    required super.calendarType,
    required super.tasks,
    required super.isSyncEnabled,
  });
}

class CalendarAuthFailedState extends CalendarLoadedState {
  final String message;

  const CalendarAuthFailedState({
    required this.message,
    required super.calendarType,
    required super.tasks,
    required super.isSyncEnabled,
  });

  @override
  List<Object?> get props => [message, calendarType, tasks, isSyncEnabled];
}

class CalendarErrorState extends CalendarState {
  final String message;

  const CalendarErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
