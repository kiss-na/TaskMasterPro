import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:task_manager/data/repositories/reminder_repository.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_event.dart';
import 'package:task_manager/presentation/blocs/reminder/reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderRepository reminderRepository;

  ReminderBloc({required this.reminderRepository}) : super(RemindersLoadingState()) {
    on<LoadRemindersEvent>(_onLoadReminders);
    on<LoadReminderEvent>(_onLoadReminder);
    on<AddReminderEvent>(_onAddReminder);
    on<UpdateReminderEvent>(_onUpdateReminder);
    on<DeleteReminderEvent>(_onDeleteReminder);
    on<ToggleReminderEnabledEvent>(_onToggleReminderEnabled);
    on<LoadBirthdayRemindersEvent>(_onLoadBirthdayReminders);
    on<LoadBirthdayReminderEvent>(_onLoadBirthdayReminder);
    on<AddBirthdayReminderEvent>(_onAddBirthdayReminder);
    on<UpdateBirthdayReminderEvent>(_onUpdateBirthdayReminder);
    on<DeleteBirthdayReminderEvent>(_onDeleteBirthdayReminder);
    on<LoadHabitRemindersEvent>(_onLoadHabitReminders);
    on<LoadHabitRemindersByTypeEvent>(_onLoadHabitRemindersByType);
    on<AddHabitReminderEvent>(_onAddHabitReminder);
    on<CreateDefaultHabitRemindersEvent>(_onCreateDefaultHabitReminders);
  }

  Future<void> _onLoadReminders(LoadRemindersEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      final reminders = await reminderRepository.getAllReminders();
      emit(RemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to load reminders: ${e.toString()}'));
    }
  }

  Future<void> _onLoadReminder(LoadReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      final reminder = await reminderRepository.getReminderById(event.reminderId);
      if (reminder != null) {
        emit(ReminderLoadedState(reminder));
      } else {
        emit(RemindersErrorState('Reminder not found'));
      }
    } catch (e) {
      emit(RemindersErrorState('Failed to load reminder: ${e.toString()}'));
    }
  }

  Future<void> _onAddReminder(AddReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.addReminder(event.reminder);
      final reminders = await reminderRepository.getAllReminders();
      emit(RemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to add reminder: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReminder(UpdateReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.updateReminder(event.reminder);
      final reminders = await reminderRepository.getAllReminders();
      emit(RemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to update reminder: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteReminder(DeleteReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.deleteReminder(event.reminderId);
      final reminders = await reminderRepository.getAllReminders();
      emit(RemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to delete reminder: ${e.toString()}'));
    }
  }

  Future<void> _onToggleReminderEnabled(ToggleReminderEnabledEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.toggleReminderEnabled(event.reminderId);
      final reminders = await reminderRepository.getAllReminders();
      emit(RemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to toggle reminder: ${e.toString()}'));
    }
  }

  Future<void> _onLoadBirthdayReminders(LoadBirthdayRemindersEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      final reminders = await reminderRepository.getAllBirthdayReminders();
      emit(BirthdayRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to load birthday reminders: ${e.toString()}'));
    }
  }

  Future<void> _onLoadBirthdayReminder(LoadBirthdayReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      final reminder = await reminderRepository.getBirthdayReminderById(event.reminderId);
      if (reminder != null) {
        emit(BirthdayReminderLoadedState(reminder));
      } else {
        emit(RemindersErrorState('Birthday reminder not found'));
      }
    } catch (e) {
      emit(RemindersErrorState('Failed to load birthday reminder: ${e.toString()}'));
    }
  }

  Future<void> _onAddBirthdayReminder(AddBirthdayReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.addBirthdayReminder(event.reminder);
      final reminders = await reminderRepository.getAllBirthdayReminders();
      emit(BirthdayRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to add birthday reminder: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBirthdayReminder(UpdateBirthdayReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.updateBirthdayReminder(event.reminder);
      final reminders = await reminderRepository.getAllBirthdayReminders();
      emit(BirthdayRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to update birthday reminder: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteBirthdayReminder(DeleteBirthdayReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.deleteBirthdayReminder(event.reminderId);
      final reminders = await reminderRepository.getAllBirthdayReminders();
      emit(BirthdayRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to delete birthday reminder: ${e.toString()}'));
    }
  }

  Future<void> _onLoadHabitReminders(LoadHabitRemindersEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      final reminders = await reminderRepository.getAllHabitReminders();
      emit(HabitRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to load habit reminders: ${e.toString()}'));
    }
  }

  Future<void> _onLoadHabitRemindersByType(LoadHabitRemindersByTypeEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      final reminders = await reminderRepository.getHabitRemindersByType(event.type);
      emit(HabitRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to load habit reminders by type: ${e.toString()}'));
    }
  }

  Future<void> _onAddHabitReminder(AddHabitReminderEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.addHabitReminder(event.reminder);
      final reminders = await reminderRepository.getAllHabitReminders();
      emit(HabitRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to add habit reminder: ${e.toString()}'));
    }
  }

  Future<void> _onCreateDefaultHabitReminders(CreateDefaultHabitRemindersEvent event, Emitter<ReminderState> emit) async {
    emit(RemindersLoadingState());
    try {
      await reminderRepository.createDefaultHabitRemindersIfNeeded();
      final reminders = await reminderRepository.getAllHabitReminders();
      emit(HabitRemindersLoadedState(reminders));
    } catch (e) {
      emit(RemindersErrorState('Failed to create default habit reminders: ${e.toString()}'));
    }
  }
}
