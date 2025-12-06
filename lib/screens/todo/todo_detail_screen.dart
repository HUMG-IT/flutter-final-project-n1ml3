import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/todo_model.dart';
import '../../providers/todo_provider.dart';
import 'todo_form_screen.dart';

class TodoDetailScreen extends StatelessWidget {
  final String todoId;

  const TodoDetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Todo'),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, _) {
              final todo = todoProvider.allTodos.firstWhere(
                (t) => t.id == todoId,
                orElse: () => throw Exception('Todo not found'),
              );

              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TodoFormScreen(todo: todo),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, _) {
          if (todoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final todo = todoProvider.allTodos.firstWhere(
              (t) => t.id == todoId,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: todo.isCompleted,
                        onChanged: (_) {
                          todoProvider.toggleTodoComplete(todo.id);
                        },
                      ),
                      Expanded(
                        child: Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: todo.isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (todo.description != null &&
                      todo.description!.isNotEmpty) ...[
                    const Text(
                      'Mô tả:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todo.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildDetailRow(
                    'Trạng thái',
                    todo.isCompleted ? 'Hoàn thành' : 'Chưa hoàn thành',
                    todo.isCompleted ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Ưu tiên',
                    _getPriorityText(todo.priority),
                    _getPriorityColor(todo.priority),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Ngày tạo',
                    DateFormat('dd/MM/yyyy HH:mm').format(todo.createdAt),
                    Colors.grey,
                  ),
                  if (todo.dueDate != null) ...[
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Hạn chót',
                      DateFormat('dd/MM/yyyy HH:mm').format(todo.dueDate!),
                      todo.dueDate!.isBefore(DateTime.now()) &&
                              !todo.isCompleted
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xóa todo'),
                            content: Text('Bạn có chắc muốn xóa "${todo.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          final success =
                              await todoProvider.deleteTodo(todo.id);
                          if (context.mounted) {
                            if (success) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Xóa thành công!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Xóa thất bại: ${todoProvider.error}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Xóa Todo'),
                    ),
                  ),
                ],
              ),
            );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: $e'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  String _getPriorityText(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return 'Cao';
      case TodoPriority.medium:
        return 'Trung bình';
      case TodoPriority.low:
        return 'Thấp';
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.low:
        return Colors.green;
    }
  }
}

