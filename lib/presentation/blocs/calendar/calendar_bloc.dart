import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/repositories/calendar_repository.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_event.dart';
import 'package:task_manager/presentation/blocs/calendar/calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository calendarRepository;
  final TaskRepository taskRepository;

  CalendarBloc({
    required this.calendarRepository,
    required this.taskRepository,
  }) : super(CalendarLoadingState()) {
    on<LoadCalendarEvent>(_onLoadCalendar);
    on<LoadTasksForDateEvent>(_onLoadTasksForDate);
    on<ChangeCalendarTypeEvent>(_onChangeCalendarType);
    on<ToggleGoogleSyncEvent>(_onToggleGoogleSync);
    on<SyncWithGoogleCalendarEvent>(_onSyncWithGoogleCalendar);
    on<AuthenticateGoogleCalendarEvent>(_onAuthenticateGoogleCalendar);
    on<LogoutGoogleCalendarEvent>(_onLogoutGoogleCalendar);
  }

  Future<void> _onLoadCalendar(LoadCalendarEvent event, Emitter<CalendarState> emit) async {
    emit(CalendarLoadingState());
    try {
      final calendarType = await calendarRepository.getCalendarType();
      final isSyncEnabled = await calendarRepository.isSyncEnabled();
      final tasks = await taskRepository.getAllTasks();
      
      emit(CalendarLoadedState(
        calendarType: calendarType,
        tasks: tasks,
        isSyncEnabled: isSyncEnabled,
      ));
    } catch (e) {
      emit(CalendarErrorState('Failed to load calendar: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTasksForDate(LoadTasksForDateEvent event, Emitter<CalendarState> emit) async {
    try {
      // Keep current state data
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        final tasksForDate = await taskRepository.getTasksForDate(event.date);
        
        emit(TasksForDateLoadedState(
          calendarType: currentState.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: currentState.isSyncEnabled,
          selectedDate: event.date,
          tasksForSelectedDate: tasksForDate,
        ));
      }
    } catch (e) {
      emit(CalendarErrorState('Failed to load tasks for date: ${e.toString()}'));
    }
  }

  Future<void> _onChangeCalendarType(ChangeCalendarTypeEvent event, Emitter<CalendarState> emit) async {
    try {
      await calendarRepository.setCalendarType(event.calendarType);
      
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarLoadedState(
          calendarType: event.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: currentState.isSyncEnabled,
        ));
      } else {
        add(const LoadCalendarEvent());
      }
    } catch (e) {
      emit(CalendarErrorState('Failed to change calendar type: ${e.toString()}'));
    }
  }

  Future<void> _onToggleGoogleSync(ToggleGoogleSyncEvent event, Emitter<CalendarState> emit) async {
    try {
      await calendarRepository.setSyncEnabled(event.enabled);
      
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarLoadedState(
          calendarType: currentState.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: event.enabled,
        ));
      } else {
        add(const LoadCalendarEvent());
      }
    } catch (e) {
      emit(CalendarErrorState('Failed to toggle Google sync: ${e.toString()}'));
    }
  }

  Future<void> _onSyncWithGoogleCalendar(SyncWithGoogleCalendarEvent event, Emitter<CalendarState> emit) async {
    try {
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarSyncingState(
          calendarType: currentState.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: currentState.isSyncEnabled,
        ));
        
        final success = await calendarRepository.syncWithGoogleCalendar(currentState.tasks);
        
        if (success) {
          emit(CalendarSyncedState(
            calendarType: currentState.calendarType,
            tasks: currentState.tasks,
            isSyncEnabled: currentState.isSyncEnabled,
          ));
        } else {
          emit(CalendarSyncFailedState(
            message: 'Failed to sync with Google Calendar',
            calendarType: currentState.calendarType,
            tasks: currentState.tasks,
            isSyncEnabled: currentState.isSyncEnabled,
          ));
        }
      }
    } catch (e) {
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarSyncFailedState(
          message: 'Failed to sync with Google Calendar: ${e.toString()}',
          calendarType: currentState.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: currentState.isSyncEnabled,
        ));
      } else {
        emit(CalendarErrorState('Failed to sync with Google Calendar: ${e.toString()}'));
      }
    }
  }

  Future<void> _onAuthenticateGoogleCalendar(AuthenticateGoogleCalendarEvent event, Emitter<CalendarState> emit) async {
    try {
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarAuthenticatingState(
          calendarType: currentState.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: currentState.isSyncEnabled,
        ));
        
        final success = await calendarRepository.authenticateWithGoogleCalendar();
        
        if (success) {
          add(const LoadCalendarEvent());
        } else {
          emit(CalendarAuthFailedState(
            message: 'Failed to authenticate with Google Calendar',
            calendarType: currentState.calendarType,
            tasks: currentState.tasks,
            isSyncEnabled: currentState.isSyncEnabled,
          ));
        }
      }
    } catch (e) {
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarAuthFailedState(
          message: 'Failed to authenticate with Google Calendar: ${e.toString()}',
          calendarType: currentState.calendarType,
          tasks: currentState.tasks,
          isSyncEnabled: currentState.isSyncEnabled,
        ));
      } else {
        emit(CalendarErrorState('Failed to authenticate with Google Calendar: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLogoutGoogleCalendar(LogoutGoogleCalendarEvent event, Emitter<CalendarState> emit) async {
    try {
      if (state is CalendarLoadedState) {
        final currentState = state as CalendarLoadedState;
        
        emit(CalendarLoadingState());
        
        final success = await calendarRepository.clearGoogleCalendarAuth();
        
        if (success) {
          add(const LoadCalendarEvent());
        } else {
          emit(CalendarErrorState('Failed to logout from Google Calendar'));
        }
      }
    } catch (e) {
      emit(CalendarErrorState('Failed to logout from Google Calendar: ${e.toString()}'));
    }
  }
}
