import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/reminder.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadRemindersEvent extends ReminderEvent {
  const LoadRemindersEvent();
}

class LoadReminderEvent extends ReminderEvent {
  final String reminderId;

  const LoadReminderEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class AddReminderEvent extends ReminderEvent {
  final Reminder reminder;

  const AddReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class UpdateReminderEvent extends ReminderEvent {
  final Reminder reminder;

  const UpdateReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class DeleteReminderEvent extends ReminderEvent {
  final String reminderId;

  const DeleteReminderEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class ToggleReminderEnabledEvent extends ReminderEvent {
  final String reminderId;

  const ToggleReminderEnabledEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class LoadBirthdayRemindersEvent extends ReminderEvent {
  const LoadBirthdayRemindersEvent();
}

class LoadBirthdayReminderEvent extends ReminderEvent {
  final String reminderId;

  const LoadBirthdayReminderEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class AddBirthdayReminderEvent extends ReminderEvent {
  final BirthdayReminder reminder;

  const AddBirthdayReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class UpdateBirthdayReminderEvent extends ReminderEvent {
  final BirthdayReminder reminder;

  const UpdateBirthdayReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class DeleteBirthdayReminderEvent extends ReminderEvent {
  final String reminderId;

  const DeleteBirthdayReminderEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class LoadHabitRemindersEvent extends ReminderEvent {
  const LoadHabitRemindersEvent();
}

class LoadHabitRemindersByTypeEvent extends ReminderEvent {
  final ReminderType type;

  const LoadHabitRemindersByTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class AddHabitReminderEvent extends ReminderEvent {
  final HabitReminder reminder;

  const AddHabitReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class CreateDefaultHabitRemindersEvent extends ReminderEvent {
  const CreateDefaultHabitRemindersEvent();
}
