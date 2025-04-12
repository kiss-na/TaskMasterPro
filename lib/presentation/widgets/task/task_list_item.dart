import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task.dart';
import 'package:intl/intl.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompleted;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onToggleCompleted,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: Text('Are you sure you want to delete "${task.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: task.color.withOpacity(0.1),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              onToggleCompleted();
            },
            activeColor: task.color,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              fontSize: 16,
              fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    task.description!,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: task.getPriorityColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(task.priority),
                      style: TextStyle(
                        fontSize: 12,
                        color: task.getPriorityColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Due date
                  if (task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 14,
                            color: task.isOverdue() ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd').format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: task.isOverdue() ? Colors.red : Colors.grey,
                              fontWeight: task.isOverdue() ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Reminder indicator
                  if (task.reminderDateTime != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.notifications,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  
                  // Location indicator
                  if (task.hasLocation())
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  
                  // Contact indicator
                  if (task.hasContact())
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showTaskOptions(context);
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
      default:
        return 'Unknown';
    }
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onTap();
                },
              ),
              ListTile(
                leading: Icon(task.isCompleted ? Icons.refresh : Icons.check_circle),
                title: Text(task.isCompleted ? 'Mark as incomplete' : 'Mark as complete'),
                onTap: () {
                  Navigator.pop(context);
                  onToggleCompleted();
                },
              ),
              if (task.hasLocation())
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Open in Maps'),
                  onTap: () {
                    Navigator.pop(context);
                    _openInMaps(context);
                  },
                ),
              if (task.hasContact())
                ListTile(
                  leading: const Icon(Icons.call),
                  title: const Text('Call contact'),
                  onTap: () {
                    Navigator.pop(context);
                    _callContact(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openInMaps(BuildContext context) {
    // This would open the map with the task's location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening location in Maps...')),
    );
  }

  void _callContact(BuildContext context) {
    // This would call the task's contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling contact...')),
    );
  }
}
