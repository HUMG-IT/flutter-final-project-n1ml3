import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';

enum TodoFilter { all, pending, completed, highPriority }

enum TodoSortOption {
  dateCreated,
  dueDate,
  priority,
  alphabetical,
}

class TodoProvider with ChangeNotifier {
  final TodoService _todoService = TodoService();

  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  bool _isLoading = false;
  String? _error;

  // Filter and search
  TodoFilter _currentFilter = TodoFilter.all;
  TodoSortOption _currentSort = TodoSortOption.dateCreated;
  String _searchQuery = '';

  List<Todo> get todos => _filteredTodos;
  List<Todo> get allTodos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TodoFilter get currentFilter => _currentFilter;
  TodoSortOption get currentSort => _currentSort;
  String get searchQuery => _searchQuery;

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get pendingCount => _todos.where((t) => !t.isCompleted).length;

  TodoProvider() {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _todos = await _todoService.getTodos();
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _todos = [];
      _filteredTodos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void listenToTodos() {
    _todoService.getTodosStream().listen((todos) {
      _todos = todos;
      _applyFilters();
      notifyListeners();
    });
  }

  Future<bool> createTodo(Todo todo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final createdTodo = await _todoService.createTodo(todo);
      await loadTodos();
      
      // Schedule notifications if due date is set
      if (createdTodo.dueDate != null && !createdTodo.isCompleted) {
        // Notifications are scheduled in TodoService.createTodo
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTodo(Todo todo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.updateTodo(todo);
      await loadTodos();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTodo(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.deleteTodo(id);
      await loadTodos();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleTodoComplete(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _todoService.toggleTodoComplete(id);
      await loadTodos();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(TodoSortOption sortOption) {
    _currentSort = sortOption;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<Todo> filtered = List.from(_todos);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(lowerQuery) ||
            (todo.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Apply status filter
    switch (_currentFilter) {
      case TodoFilter.all:
        break;
      case TodoFilter.pending:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.highPriority:
        filtered =
            filtered.where((todo) => todo.priority == TodoPriority.high).toList();
        break;
    }

    // Apply sorting
    switch (_currentSort) {
      case TodoSortOption.dateCreated:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TodoSortOption.dueDate:
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TodoSortOption.priority:
        final priorityOrder = {
          TodoPriority.high: 3,
          TodoPriority.medium: 2,
          TodoPriority.low: 1,
        };
        filtered.sort((a, b) =>
            priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!));
        break;
      case TodoSortOption.alphabetical:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    _filteredTodos = filtered;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

