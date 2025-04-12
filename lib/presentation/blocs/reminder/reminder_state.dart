import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/reminder.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class RemindersLoadingState extends ReminderState {}

class RemindersLoadedState extends ReminderState {
  final List<Reminder> reminders;

  const RemindersLoadedState(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class ReminderLoadedState extends ReminderState {
  final Reminder reminder;

  const ReminderLoadedState(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class BirthdayRemindersLoadedState extends ReminderState {
  final List<BirthdayReminder> reminders;

  const BirthdayRemindersLoadedState(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class BirthdayReminderLoadedState extends ReminderState {
  final BirthdayReminder reminder;

  const BirthdayReminderLoadedState(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class HabitRemindersLoadedState extends ReminderState {
  final List<HabitReminder> reminders;

  const HabitRemindersLoadedState(this.reminders);

  @override
  List<Object?> get props => [reminders];
}

class HabitReminderLoadedState extends ReminderState {
  final HabitReminder reminder;

  const HabitReminderLoadedState(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class RemindersErrorState extends ReminderState {
  final String message;

  const RemindersErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
