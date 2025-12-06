import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_model.dart';

class DueDateBanner extends StatelessWidget {
  final Todo todo;

  const DueDateBanner({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    if (todo.dueDate == null || todo.isCompleted) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final dueDate = todo.dueDate!;
    final difference = dueDate.difference(now);

    // Show banner if due date is within 24 hours or overdue
    if (difference.inHours > 24) {
      return const SizedBox.shrink();
    }

    final isOverdue = dueDate.isBefore(now);
    final isToday = dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
    final isSoon = difference.inHours <= 24 && difference.inHours > 0;

    String message;
    Color backgroundColor;
    IconData icon;

    if (isOverdue) {
      message = 'Todo này đã quá hạn!';
      backgroundColor = Colors.red;
      icon = Icons.warning;
    } else if (isToday) {
      message = 'Todo này đến hạn hôm nay!';
      backgroundColor = Colors.orange;
      icon = Icons.today;
    } else if (isSoon) {
      message = 'Todo này sắp đến hạn (${difference.inHours} giờ nữa)!';
      backgroundColor = Colors.orange.shade300;
      icon = Icons.access_time;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        border: Border.all(color: backgroundColor, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: backgroundColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: backgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            DateFormat('dd/MM/yyyy HH:mm').format(dueDate),
            style: TextStyle(
              color: backgroundColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

