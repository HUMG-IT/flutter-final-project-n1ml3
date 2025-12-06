import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/todo_model.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/todo_item.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/filter_chip.dart';
import '../../widgets/due_date_banner.dart';
import 'todo_detail_screen.dart';
import 'todo_form_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).listenToTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, _) {
          if (todoProvider.isLoading && todoProvider.allTodos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (todoProvider.error != null && todoProvider.allTodos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${todoProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => todoProvider.loadTodos(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Tổng',
                      todoProvider.totalCount.toString(),
                      Colors.blue,
                    ),
                    _buildStatItem(
                      'Hoàn thành',
                      todoProvider.completedCount.toString(),
                      Colors.green,
                    ),
                    _buildStatItem(
                      'Chưa xong',
                      todoProvider.pendingCount.toString(),
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              // Search bar
              SearchBarWidget(
                hintText: 'Tìm kiếm todos...',
                controller: _searchController,
                onChanged: (value) => todoProvider.setSearchQuery(value),
              ),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChipWidget(
                      label: 'Tất cả',
                      selected: todoProvider.currentFilter == TodoFilter.all,
                      onSelected: () =>
                          todoProvider.setFilter(TodoFilter.all),
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Chưa xong',
                      selected: todoProvider.currentFilter == TodoFilter.pending,
                      onSelected: () =>
                          todoProvider.setFilter(TodoFilter.pending),
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Hoàn thành',
                      selected:
                          todoProvider.currentFilter == TodoFilter.completed,
                      onSelected: () =>
                          todoProvider.setFilter(TodoFilter.completed),
                    ),
                    const SizedBox(width: 8),
                    FilterChipWidget(
                      label: 'Ưu tiên cao',
                      selected:
                          todoProvider.currentFilter == TodoFilter.highPriority,
                      onSelected: () =>
                          todoProvider.setFilter(TodoFilter.highPriority),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Sort options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<TodoSortOption>(
                  value: todoProvider.currentSort,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: TodoSortOption.dateCreated,
                      child: Text('Sắp xếp theo ngày tạo'),
                    ),
                    DropdownMenuItem(
                      value: TodoSortOption.dueDate,
                      child: Text('Sắp xếp theo hạn'),
                    ),
                    DropdownMenuItem(
                      value: TodoSortOption.priority,
                      child: Text('Sắp xếp theo ưu tiên'),
                    ),
                    DropdownMenuItem(
                      value: TodoSortOption.alphabetical,
                      child: Text('Sắp xếp theo bảng chữ cái'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      todoProvider.setSortOption(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Todo list
              Expanded(
                child: todoProvider.todos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              todoProvider.searchQuery.isNotEmpty
                                  ? 'Không tìm thấy kết quả'
                                  : 'Chưa có todo nào',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => todoProvider.loadTodos(),
                        child: ListView.builder(
                          itemCount: todoProvider.todos.length,
                          itemBuilder: (context, index) {
                            final todo = todoProvider.todos[index];
                            return Column(
                              children: [
                                // Show banner if todo is due soon or overdue
                                DueDateBanner(todo: todo),
                                TodoItem(
                                  todo: todo,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TodoDetailScreen(
                                          todoId: todo.id,
                                        ),
                                      ),
                                    );
                                  },
                                  onToggle: () => todoProvider.toggleTodoComplete(
                                    todo.id,
                                  ),
                                  onDelete: () => _showDeleteDialog(
                                    context,
                                    todo,
                                    todoProvider,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TodoFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Todo todo,
    TodoProvider todoProvider,
  ) async {
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await todoProvider.deleteTodo(todo.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Xóa thành công!'
                  : 'Xóa thất bại: ${todoProvider.error}',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

