import 'package:flutter/material.dart';
import 'package:task_manager/data/models/task.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final Function(TaskPriority) onPriorityChanged;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPriorityOption(
            context, 
            TaskPriority.high, 
            'High', 
            Colors.red,
          ),
          _buildPriorityOption(
            context, 
            TaskPriority.medium, 
            'Medium', 
            Colors.orange,
          ),
          _buildPriorityOption(
            context, 
            TaskPriority.low, 
            'Low', 
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(
    BuildContext context, 
    TaskPriority priority, 
    String label, 
    Color color,
  ) {
    final isSelected = selectedPriority == priority;
    
    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.flag,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
