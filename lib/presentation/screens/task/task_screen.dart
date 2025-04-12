import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/presentation/blocs/task/task_bloc.dart';
import 'package:task_manager/presentation/blocs/task/task_event.dart';
import 'package:task_manager/presentation/blocs/task/task_state.dart';
import 'package:task_manager/presentation/widgets/task/task_list_item.dart';
import 'package:task_manager/presentation/widgets/common/empty_state.dart';
import 'package:task_manager/presentation/widgets/common/error_state.dart';
import 'package:task_manager/presentation/widgets/common/loading_indicator.dart';
import 'package:task_manager/config/routes.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchBar();
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TasksLoadingState) {
            return const LoadingIndicator();
          } else if (state is TasksLoadedState) {
            if (state.tasks.isEmpty) {
              return const EmptyState(
                icon: Icons.task_alt,
                message: 'No tasks found',
                description: 'Tap the + button to create a new task',
              );
            }
            
            // Group tasks by completion status
            final completedTasks = state.tasks.where((task) => task.isCompleted).toList();
            final incompleteTasks = state.tasks.where((task) => !task.isCompleted).toList();
            
            // Sort incomplete tasks by priority (high to low)
            incompleteTasks.sort((a, b) {
              // First by priority
              final priorityComparison = a.priority.index.compareTo(b.priority.index);
              if (priorityComparison != 0) return priorityComparison;
              
              // Then by due date if both have due dates
              if (a.dueDate != null && b.dueDate != null) {
                return a.dueDate!.compareTo(b.dueDate!);
              } else if (a.dueDate != null) {
                return -1; // a has a due date, b doesn't
              } else if (b.dueDate != null) {
                return 1; // b has a due date, a doesn't
              }
              
              // Finally by creation date
              return a.createdAt.compareTo(b.createdAt);
            });
            
            return CustomScrollView(
              slivers: [
                // High priority tasks section
                if (incompleteTasks.any((task) => task.priority == TaskPriority.high))
                  _buildPrioritySection(
                    'High Priority', 
                    incompleteTasks.where((task) => task.priority == TaskPriority.high).toList()
                  ),
                
                // Medium priority tasks section
                if (incompleteTasks.any((task) => task.priority == TaskPriority.medium))
                  _buildPrioritySection(
                    'Medium Priority', 
                    incompleteTasks.where((task) => task.priority == TaskPriority.medium).toList()
                  ),
                
                // Low priority tasks section
                if (incompleteTasks.any((task) => task.priority == TaskPriority.low))
                  _buildPrioritySection(
                    'Low Priority', 
                    incompleteTasks.where((task) => task.priority == TaskPriority.low).toList()
                  ),
                
                // Completed tasks section (if any)
                if (completedTasks.isNotEmpty)
                  _buildCompletedTasksSection(completedTasks),
              ],
            );
          } else if (state is TasksErrorState) {
            return ErrorState(
              message: state.message,
              onRetry: _loadTasks,
            );
          } else {
            return const EmptyState(
              icon: Icons.error_outline,
              message: 'Unknown state',
              description: 'Something went wrong',
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addTask);
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }

  SliverList _buildPrioritySection(String title, List<Task> tasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: title == 'High Priority' 
                      ? Colors.red 
                      : title == 'Medium Priority' 
                          ? Colors.orange 
                          : Colors.green,
                ),
              ),
            );
          }
          
          final task = tasks[index - 1];
          return TaskListItem(
            task: task,
            onToggleCompleted: () {
              context.read<TaskBloc>().add(ToggleTaskCompletionEvent(task.id));
            },
            onTap: () {
              Navigator.pushNamed(
                context, 
                AppRoutes.editTask,
                arguments: {'taskId': task.id},
              );
            },
            onDelete: () {
              _confirmDelete(task);
            },
          );
        },
        childCount: tasks.length + 1, // +1 for section title
      ),
    );
  }

  SliverList _buildCompletedTasksSection(List<Task> completedTasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
              child: Row(
                children: [
                  const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${completedTasks.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final task = completedTasks[index - 1];
          return TaskListItem(
            task: task,
            onToggleCompleted: () {
              context.read<TaskBloc>().add(ToggleTaskCompletionEvent(task.id));
            },
            onTap: () {
              Navigator.pushNamed(
                context, 
                AppRoutes.editTask,
                arguments: {'taskId': task.id},
              );
            },
            onDelete: () {
              _confirmDelete(task);
            },
          );
        },
        childCount: completedTasks.length + 1, // +1 for section title
      ),
    );
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
              },
              child: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSearchBar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<TaskBloc>().add(SearchTasksEvent(value));
                    } else {
                      context.read<TaskBloc>().add(const LoadTasksEvent());
                    }
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        context.read<TaskBloc>().add(SearchTasksEvent(_searchController.text));
                        Navigator.pop(context);
                      } else {
                        context.read<TaskBloc>().add(const LoadTasksEvent());
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
