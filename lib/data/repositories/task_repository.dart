import 'package:hive/hive.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:task_manager/core/utils/notification_utils.dart';

class TaskRepository {
  // Hive box name
  static const String boxName = 'tasks';

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final box = await Hive.openBox<Task>(boxName);
    return box.values.toList();
  }

  // Get task by ID
  Future<Task?> getTaskById(String id) async {
    final box = await Hive.openBox<Task>(boxName);
    
    for (final task in box.values) {
      if (task.id == id) {
        return task;
      }
    }
    
    return null;
  }

  // Add task
  Future<void> addTask(Task task) async {
    final box = await Hive.openBox<Task>(boxName);
    await box.add(task);
    
    // Schedule notification if the task has a reminder
    if (task.reminderDateTime != null) {
      await NotificationUtils.scheduleTaskNotification(task);
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    final box = await Hive.openBox<Task>(boxName);
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == task.id) {
        await box.put(entry.key, task);
        
        // Update notification
        if (task.reminderDateTime != null) {
          await NotificationUtils.scheduleTaskNotification(task);
        } else {
          await NotificationUtils.cancelNotification(task.id.hashCode);
        }
        
        break;
      }
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    final box = await Hive.openBox<Task>(boxName);
    
    for (final entry in box.toMap().entries) {
      if (box.get(entry.key)?.id == id) {
        await box.delete(entry.key);
        
        // Cancel notification
        await NotificationUtils.cancelNotification(id.hashCode);
        
        break;
      }
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String id) async {
    final task = await getTaskById(id);
    
    if (task != null) {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
      );
      
      await updateTask(updatedTask);
    }
  }

  // Get tasks by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }

  // Get tasks due on a specific date
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final tasks = await getAllTasks();
    
    return tasks.where((task) {
      if (task.dueDate == null) return false;
      
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      
      final targetDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
      
      return taskDate == targetDate;
    }).toList();
  }

  // Get upcoming tasks
  Future<List<Task>> getUpcomingTasks({int limit = 10}) async {
    final tasks = await getAllTasks();
    final now = DateTime.now();
    
    // Filter tasks that are not completed and have due date in the future
    final upcomingTasks = tasks.where((task) {
      return !task.isCompleted && 
             task.dueDate != null && 
             task.dueDate!.isAfter(now);
    }).toList();
    
    // Sort by due date (nearest first)
    upcomingTasks.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    
    // Return limited number of tasks
    return upcomingTasks.take(limit).toList();
  }

  // Get tasks that are overdue
  Future<List<Task>> getOverdueTasks() async {
    final tasks = await getAllTasks();
    final now = DateTime.now();
    
    return tasks.where((task) {
      return !task.isCompleted && 
             task.dueDate != null && 
             task.dueDate!.isBefore(now);
    }).toList();
  }
  
  // Search tasks
  Future<List<Task>> searchTasks(String query) async {
    final tasks = await getAllTasks();
    
    if (query.isEmpty) {
      return tasks;
    }
    
    final lowerCaseQuery = query.toLowerCase();
    
    return tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(lowerCaseQuery);
      final descriptionMatch = task.description?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final locationMatch = task.locationName?.toLowerCase().contains(lowerCaseQuery) ?? false;
      final contactMatch = task.contactName?.toLowerCase().contains(lowerCaseQuery) ?? false;
      
      return titleMatch || descriptionMatch || locationMatch || contactMatch;
    }).toList();
  }
}
