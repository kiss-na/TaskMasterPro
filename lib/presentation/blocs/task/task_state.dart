import 'package:equatable/equatable.dart';
import 'package:task_manager/data/models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TasksLoadingState extends TaskState {}

class TasksLoadedState extends TaskState {
  final List<Task> tasks;

  const TasksLoadedState(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskLoadedState extends TaskState {
  final Task task;

  const TaskLoadedState(this.task);

  @override
  List<Object?> get props => [task];
}

class UpcomingTasksLoadedState extends TaskState {
  final List<Task> tasks;

  const UpcomingTasksLoadedState(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TasksErrorState extends TaskState {
  final String message;

  const TasksErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
