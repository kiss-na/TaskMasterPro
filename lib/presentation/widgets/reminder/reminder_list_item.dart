import 'package:flutter/material.dart';
import 'package:task_manager/data/models/reminder.dart';
import 'package:intl/intl.dart';

class ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onToggleEnabled;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReminderListItem({
    Key? key,
    required this.reminder,
    required this.onToggleEnabled,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(reminder.id),
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
              title: const Text('Delete Reminder'),
              content: Text('Are you sure you want to delete "${reminder.title}"?'),
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
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: _getReminderTypeColor(reminder.type),
            child: Icon(
              _getReminderTypeIcon(reminder.type),
              color: Colors.white,
            ),
          ),
          title: Text(
            reminder.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: reminder.isEnabled ? null : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.description,
                style: TextStyle(
                  color: reminder.isEnabled ? null : Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildFrequencyChip(reminder.frequency),
                  if (reminder.times.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        _getTimeString(reminder.times),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: Switch(
            value: reminder.isEnabled,
            onChanged: (value) {
              onToggleEnabled();
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.pomodoro:
        return Icons.timer;
      case ReminderType.socialization:
        return Icons.people;
      case ReminderType.custom:
        return Icons.notifications;
      default:
        return Icons.alarm;
    }
  }

  Color _getReminderTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.birthday:
        return Colors.pink;
      case ReminderType.water:
        return Colors.blue;
      case ReminderType.pomodoro:
        return Colors.red;
      case ReminderType.socialization:
        return Colors.green;
      case ReminderType.custom:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFrequencyChip(ReminderFrequency frequency) {
    Color chipColor;
    String label;
    
    switch (frequency) {
      case ReminderFrequency.once:
        chipColor = Colors.amber;
        label = 'Once';
        break;
      case ReminderFrequency.daily:
        chipColor = Colors.green;
        label = 'Daily';
        break;
      case ReminderFrequency.weekly:
        chipColor = Colors.blue;
        label = 'Weekly';
        break;
      case ReminderFrequency.monthly:
        chipColor = Colors.purple;
        label = 'Monthly';
        break;
      case ReminderFrequency.yearly:
        chipColor = Colors.red;
        label = 'Yearly';
        break;
      default:
        chipColor = Colors.grey;
        label = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getTimeString(List<TimeOfDay> times) {
    if (times.isEmpty) return '';
    
    if (times.length == 1) {
      return '${times[0].hour}:${times[0].minute.toString().padLeft(2, '0')}';
    }
    
    return '${times.length} times per day';
  }
}
