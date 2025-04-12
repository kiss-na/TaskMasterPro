import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  const LoadTasksEvent();
}

class LoadTaskEvent extends TaskEvent {
  final String taskId;

  const LoadTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class AddTaskEvent extends TaskEvent {
  final Task task;

  const AddTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final String taskId;

  const ToggleTaskCompletionEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class SearchTasksEvent extends TaskEvent {
  final String query;

  const SearchTasksEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadTasksByPriorityEvent extends TaskEvent {
  final TaskPriority priority;

  const LoadTasksByPriorityEvent(this.priority);

  @override
  List<Object?> get props => [priority];
}

class LoadTasksForDateEvent extends TaskEvent {
  final DateTime date;

  const LoadTasksForDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class LoadUpcomingTasksEvent extends TaskEvent {
  final int limit;

  const LoadUpcomingTasksEvent({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}
