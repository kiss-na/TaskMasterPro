import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/data/repositories/task_repository.dart';
import 'package:task_manager/presentation/blocs/task/task_event.dart';
import 'package:task_manager/presentation/blocs/task/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;

  TaskBloc({required this.taskRepository}) : super(TasksLoadingState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<LoadTaskEvent>(_onLoadTask);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<SearchTasksEvent>(_onSearchTasks);
    on<LoadTasksByPriorityEvent>(_onLoadTasksByPriority);
    on<LoadTasksForDateEvent>(_onLoadTasksForDate);
    on<LoadUpcomingTasksEvent>(_onLoadUpcomingTasks);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      final tasks = await taskRepository.getAllTasks();
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTask(LoadTaskEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      final task = await taskRepository.getTaskById(event.taskId);
      if (task != null) {
        emit(TaskLoadedState(task));
      } else {
        emit(TasksErrorState('Task not found'));
      }
    } catch (e) {
      emit(TasksErrorState('Failed to load task: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      await taskRepository.addTask(event.task);
      final tasks = await taskRepository.getAllTasks();
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to add task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      await taskRepository.updateTask(event.task);
      final tasks = await taskRepository.getAllTasks();
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      await taskRepository.deleteTask(event.taskId);
      final tasks = await taskRepository.getAllTasks();
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletionEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      await taskRepository.toggleTaskCompletion(event.taskId);
      final tasks = await taskRepository.getAllTasks();
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to toggle task completion: ${e.toString()}'));
    }
  }

  Future<void> _onSearchTasks(SearchTasksEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      final tasks = await taskRepository.searchTasks(event.query);
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to search tasks: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTasksByPriority(LoadTasksByPriorityEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      final tasks = await taskRepository.getTasksByPriority(event.priority);
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to load tasks by priority: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTasksForDate(LoadTasksForDateEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      final tasks = await taskRepository.getTasksForDate(event.date);
      emit(TasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to load tasks for date: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUpcomingTasks(LoadUpcomingTasksEvent event, Emitter<TaskState> emit) async {
    emit(TasksLoadingState());
    try {
      final tasks = await taskRepository.getUpcomingTasks(limit: event.limit);
      emit(UpcomingTasksLoadedState(tasks));
    } catch (e) {
      emit(TasksErrorState('Failed to load upcoming tasks: ${e.toString()}'));
    }
  }
}
